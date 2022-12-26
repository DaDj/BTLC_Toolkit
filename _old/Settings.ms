global MyBtlcSettingsFloater

struct BTLCConfig 
(
	ConfigDir = GetDir #plugcfg+ @"\BTLCToolkit",
	ConfigFile = ConfigDir + @"\Btlc_Cfg.ini",
    IntialDirs = "F:\Modding\BTLC\02_GameData",
	GTAConverterPath = "E:\GTA Modding\Modding\Projects\IVSA\Code\I7KivynE6xKyO3\GTAConverter\GTAConverter\bin\Debug\GTAConverter.exe", 
	-- Generic Settings
	GenericTexDir = "", -- Generic texture IV
	GenericSATexDir = "", -- Generic textures already cutted names

	-- Current Settings
	CurrentCityPart = "", -- Path to the wdr,wtd,wpl etc files (original IV)
	CurrentSACityPart = "", -- Path to the "Output" Folder

	function Save  = 
	(
		try 
		(
			makedir ConfigDir
		)
		catch 
		(
			messageBox title:"Permission Error while creating the Settings File"
		)

		setINISetting ConfigFile "Directories" "GenericTexDir" GenericTexDir
		setINISetting ConfigFile "Directories" "GenericSATexDir" GenericSATexDir
		setINISetting ConfigFile "Directories" "CurrentCityPart" CurrentCityPart
		setINISetting ConfigFile "Directories" "CurrentSACityPart" CurrentSACityPart
	),

	function Load = 
	(
		GenericTexDir 	= if (tmp = getINISetting ConfigFile "Directories" "GenericTexDir") != undefined then tmp else "" 
		GenericSATexDir = if (tmp = getINISetting ConfigFile "Directories" "GenericSATexDir") != undefined then tmp else "" 
		CurrentCityPart =  if (tmp = getINISetting ConfigFile "Directories" "CurrentCityPart") != undefined then tmp else ""
		CurrentSACityPart = if (tmp = getINISetting ConfigFile "Directories" "CurrentSACityPart") != undefined then tmp else ""
	)
)
MyConfig = BTLCConfig()
MyConfig.Load()

function OpenSettings = 
	(
		rollout GenericSettings "Generic" width:210 height:400
		(
			label lbl_PathGenericTxd "GenericTexDir:" align:#left across:2
			button btn_PathGenericTxd MyConfig.GenericTexDir width:400 height:25 align:#right tooltip:""
			on btn_PathGenericTxd pressed do 
			(
				FilePath   = getSavePath caption:"Test path..." initialDir: MyConfig.IntialDirs
				if(FilePath != undefined ) do 
                ( 
					btn_PathGenericTxd.text = MyConfig.GenericTexDir = FilePath
					MyConfig.Save() 
				)
			)
			on btn_PathGenericTxd rightclick do try (shellLaunch MyConfig.GenericTexDir "") catch()

			label lbl_PathSAGenericTxd "GenericSATexDir:" align:#left across:2
			button btn_PathsaGenericTxd MyConfig.GenericSATexDir width:400 height:25 align:#right tooltip:""
			on btn_PathsaGenericTxd pressed do 
			(
				FilePath   = getSavePath caption:"Test path..." initialDir: MyConfig.IntialDirs
				if(FilePath != undefined ) do 
                ( 
					btn_PathsaGenericTxd.text = MyConfig.GenericSATexDir = FilePath
					MyConfig.Save() 
				)
			)
			on btn_PathsaGenericTxd rightclick do try (shellLaunch MyConfig.GenericSATexDir "") catch()
		)

		rollout Current_Settings "Current City Part" width:210 height:400
		(
			label lbl_CityPartDir "IV Current CityPart:" align:#left across:2
			button btn_CityPartDir MyConfig.CurrentCityPart width:400 height:25 align:#right tooltip:""
            on btn_CityPartDir pressed do 
			(
				FilePath   = getSavePath caption:"Test path..." initialDir: MyConfig.IntialDirs
				if(FilePath != undefined ) do 
                ( 
					btn_CityPartDir.text = MyConfig.CurrentCityPart = FilePath
                	MyConfig.Save()
				)
			)
			on btn_CityPartDir rightclick do try (shellLaunch MyConfig.CurrentCityPart "") catch()a

            label lbl_SACityPartDir "SA Current Output dir:" align:#left across:2
			button btn_SACityPartDir MyConfig.CurrentSACityPart width:400 height:25 align:#right tooltip:"Folder in which the subfoldr for the sa data will be exported."
			on btn_SACityPartDir pressed do 
			(
				FilePath   = getSavePath caption:"Test path..." initialDir: MyConfig.IntialDirs
				if(FilePath != undefined ) do 
                ( 
					btn_SACityPartDir.text = MyConfig.CurrentSACityPart = FilePath
					MyConfig.Save()

				)
			)
			on btn_SACityPartDir rightclick do try (shellLaunch MyConfig.CurrentSACityPart "") catch()
		)

		rollout CityConvert "CityConvert" width:210 height:400
		(
			button btn_ConvertCity "Import City Part" width:200 height:35 align:#center tooltip:"Imports the selected city part" across:3
			--button btn_ConvertIDE "Convert an IDE" width:150 height:25 align:#center tooltip:"Converts an Ide File" across:2 enabled: false

			spinner  strtid "Start ID:" range:[200,19999,1194] type:#integer width:70 enabled: true offset:[0,8]
			on btn_ConvertCity pressed do 
			(
				CityImportandPrepare strtid.value
			)
			button btn_ExportCity "Export City Part" width:200 height:35 align:#center tooltip:"Exports the selected city part" across:3
			on btn_ExportCity pressed do 
			(
				CityExport()
			)
		)

		rollout BTLC_Utils "Utils" width:210 height:400
		(
			button btn_ShowColsOnly "Show Collision only" width:150 height:35 align:#center tooltip:"Imports the selected city part" across:3
			on btn_ShowColsOnly pressed do 
			(
				for obj in objects do 
				(
					hide obj
			   		if  (classof  obj == Collision_Sphere)then 	unhide obj
			   		if  (classof  obj == Collision_Box)then 	unhide obj
					if  (isCol obj == true)  then	unhide obj
		   		)
			)

			button btn_ShowObjOnly "Show Models only" width:150 height:35 align:#center tooltip:"Imports the selected city part" 
			on btn_ShowObjOnly pressed do 
			(
				for obj in objects do 
				(
					unhide obj
					if  (classof  obj == Collision_Sphere)then 	hide obj
					if  (classof  obj == Collision_Box)then  	hide obj
					if  (isCol obj == true)  then hide obj
		   		)
			)

			button btn_ShowALL "Show All" width:150 height:35 align:#center tooltip:"Imports the selected city part" 
			on btn_ShowALL pressed do 
			(
				for obj in objects do 
				(
					unhide obj
		   		)
			)
			
		)

		rollout Map_Utils "Map Utils" width:210 height:400
		(
			button btn_ExportCollision "ExportCollision" width:120 height:35 align:#center tooltip:"Imports the selected city part" across:4
			on btn_ExportCollision pressed do 
			(
				OutputPath = MyConfig.CurrentSACityPart + "\\img"
				makeDir OutputPath

				local MyObjs = #()
				for i in objects as array do if (isCol i) == false do append MyObjs i
				MyObjs =  makeUniqueArray MyObjs

			    /* Export Collision to .col file */
				MapPartName =  filenameFromPath MyConfig.CurrentSACityPart 
				Filepath = OutputPath + "\\" + MapPartName + ".col"
				ExportCollision Filepath MyObjs
			)

			button btn_ExportModels "Export Models" width:120 height:35 align:#center tooltip:"Imports the selected city part" 
			on btn_ExportModels pressed do 
			(
				OutputPath = MyConfig.CurrentSACityPart + "\\img"
				makeDir OutputPath
			
				/* Generate .dffs*/
				local MyObjs = #()
				for i in objects as array do if (isCol i) == false do append MyObjs i
				MyObjs =  makeUniqueArray MyObjs
				ExportModels OutputPath MyObjs
			)

			button btn_GenerateTxds "GenerateTXDs" width:120 height:35 align:#center tooltip:"Imports the selected city part" 
			on btn_GenerateTxds pressed do 
			(
				 /* Generate .txds */
				 OutputPath = MyConfig.CurrentSACityPart + "\\img"
				 TxdPath = MyConfig.CurrentSACityPart + "\\txd"
				 GenerateTxds TxdPath OutputPath
			)

			button btn_GenerateIMG "Generate IMG" width:120 height:35 align:#center tooltip:"Imports the selected city part" 
			on btn_GenerateIMG pressed do 
			(
				 /* Build final .img*/
				 MapPartName =  filenameFromPath MyConfig.CurrentSACityPart 
				 mypath = MyConfig.CurrentSACityPart + "\\" + MapPartName + ".ini"
				 BuildImg_WirteIni mypath
				 BuildImg mypath (pathConfig.removePathLeaf MyConfig.CurrentSACityPart) 
			)
			
		)




		--try (cui.UnRegisterDialogBar MyBtlcSettingsFloater) catch () 	
		try (closeRolloutFloater MyBtlcSettingsFloater) catch ()

		Pos = getMaxWindowSize() 	
		PosX = Pos[1]/2 - 300
		MyBtlcSettingsFloater  = newRolloutFloater  "BTLC CITY" 600 450 PosX 250 
		addRollout GenericSettings MyBtlcSettingsFloater
		addRollout Current_Settings MyBtlcSettingsFloater
		addRollout CityConvert MyBtlcSettingsFloater
		addRollout Map_Utils MyBtlcSettingsFloater
		addRollout BTLC_Utils MyBtlcSettingsFloater

		--cui.RegisterDialogBar MyBtlcSettingsFloater style:#(#cui_floatable,#cui_dock_right ,#cui_dock_left)  
	)


--MyConfig.OpenSettings()
