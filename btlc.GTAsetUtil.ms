struct btlc_gtaDatUtils 
(
	IDE = #(),
	IMG =#(),
	IPL = #(),
	ZON = #(),

	fn LoadGtaDat GamePath =
	(
		IDE = #()
		IMG =#()
		IPL = #()
		ZON = #()

		ThePath = GamePath + "\data\gta.dat";
		fs = openFile ThePath
		while not eof fs do
		(
			line = readline fs
			if line[1] != "#" do
			(
				print line
				LineData = filterString line " "
				
				if LineData[1] == "IMG" do append IMG (substring line 5 200)
				if LineData[1] == "IDE" do append IDE (substring line 5 200)
				if LineData[1] == "IPL" do append IPL (substring line 5 200)
				--if LineData[1] == "ZON" do append ZON (substring line 5 200)
				
			)
		)
		close fs
	),

	fn SaveDat GamePath =
	(
		ThePath = GamePath + "\data\gta.dat";
		f = createFile ThePath mode:"wt"
		for aline in IMG do 
		(
			print theline
			format "IMG % \n" aline to:f 
		)
		format "\n"  to:f 

		for aline in IDE do 
		(
			print theline
			format "IDE % \n" aline to:f 
		)
		format "\n"  to:f 

		for aline in IPL do 
		(
			print theline
			format "IPL % \n" aline to:f 
		)
		format "\n"  to:f 
		close  f
	),

	fn AddEntry Name isIMG isIDE isIPL =
	(
		if isIMG do append IMG Name
		if isIDE do append IDE Name
		if isIPL do append IPL Name
	)
)
btlcgtaDatUtils = btlc_gtaDatUtils();


function btlc_GUIGtaDatUtil =
(
	rollout DirSettings "Directories" width:210 height:400
	(
		label lblGameDir "Game Dir:" align:#left across:2
		button btn_GameDir btlcConfig.GameDir width:400 height:25 align:#right tooltip:" game Dir "
		on  btn_GameDir pressed do 
		(
			FilePath   = getSavePath caption:"Test path..." initialDir: ""
			if(FilePath != undefined ) do 
			( 
				btn_GameDir.text  = btlcConfig.GameDir =  FilePath
				btlcConfig.Save()
			)
		)
		on  btn_GameDir rightclick do try (shellLaunch btlcConfig.GameDir "") catch()a	
    )

	rollout Lists "Data" width:210 height:200
	(
		button btn_load "Load Gta.dat" width:250 height:25 align:#center tooltip:"Load gta.dat " across:2
		
		button btn_Save "Save Gta.dat" width:250 height:25 align:#center tooltip:"Save gta.dat "
	
		on btn_Save pressed do 
		(
			btlcgtaDatUtils.SaveDat btlcConfig.GameDir
		)
		listbox lBox_IMG "IMG:" items:#() height:20 across:3
		listbox lBox_IDE "IDE:" items:#() height:20 
		listbox lBox_IPL "IPL:" items:#() height:20 
		on btn_load pressed do 
		(
			btlcgtaDatUtils.LoadGtaDat btlcConfig.GameDir
			lBox_IMG.items = btlcgtaDatUtils.IMG
			lBox_IDE.items = btlcgtaDatUtils.IDE
			lBox_IPL.items = btlcgtaDatUtils.IPL
		)
		group "Delete "
		(
			button btn_DltSelIMG "Delete selected" width:150 height:25  across:3 align:#center tooltip:" "
			button btn_DltSelIDE "Delete selected" width:150 height:25  align:#center tooltip:" "
			button btn_DltSelIPL"Delete selected" width:150 height:25   align:#center tooltip:" "
		)
		group "Add "
		(
			edittext prefix_txt "Name of new Part" fieldWidth:150  across:2 Labelontop:false align:#center
			button btn_AddtoAll"Add to All" width:150 height:25   align:#center tooltip:""
			checkbox  btn_AddImg "Add as IMG" width:150 height:25  across:3 align:#center tooltip:" "
			checkbox  btn_AddIDE "Add as IDE" width:150 height:25  align:#center tooltip:" "
			checkbox  btn_AddIPL"Add as IPL" width:150 height:25   align:#center tooltip:"" 
		)
		
	
	)

    try (closeRolloutFloater btlcGtaDatUtilFloater) catch ()
	Pos = getMaxWindowSize() 	
	PosX = Pos[1]/2 - 300
	btlcGtaDatUtilFloater  = newRolloutFloater  "BTLC Model Convert" 700 500 PosX 250
	addRollout  DirSettings btlcGtaDatUtilFloater
	addRollout  Lists btlcGtaDatUtilFloater
)
btlc_GUIGtaDatUtil()