global btlcCityFloater -- All Controls needed to convert a city part
global btlcUtilsFloater  -- Utils, mostly what to display/ alphasorting etc.
global btlcIdeModelsFloater -- Controls for converting a img/Ide (props and stuff.)
global btlcPathTools -- Tools for path creation
global gims_maphlpr --mapdisplay
function btlc_GUICityConvert = 
(

	rollout DirSettings "Directories" width:210 height:400
	(
		label lbl_PathGenericTxd "GenericTexDir:" align:#left across:2
		button btn_PathGenericTxd btlcConfig.GenericTexDir width:400 height:25 align:#right tooltip:""
		on btn_PathGenericTxd pressed do 
		(
			FilePath   = getSavePath caption:"Test path..." initialDir: btlcConfig.IntialDirs
			if(FilePath != undefined ) do 
			( 
				btn_PathGenericTxd.text = btlcConfig.GenericTexDir = FilePath
				btlcConfig.Save() 
			)
		)
		on btn_PathGenericTxd rightclick do try (shellLaunch btlcConfig.GenericTexDir "") catch()
		
		label lbl_MainGamedataDir "Game Data Dir:" align:#left across:2
		button btn_MainGamedataDir btlcConfig.MainGameDataDir width:400 height:25 align:#right tooltip:"Main game Data Dir (Sa and IV gamedata)"

		label lbl_CityPartDir "IV Current CityPart:" align:#left across:2
		button btn_CityPartDir btlcConfig.CurrentCityPart width:400 height:25 align:#right tooltip:""

		label lbl_SACityPartDir "SA Current Output dir:" align:#left across:2
		button btn_SACityPartDir btlcConfig.CurrentExpoSaPAth width:400 height:25 align:#right tooltip:"Folder in which the subfoldr for the sa data will be exported."
		
		on  btn_MainGamedataDir pressed do 
		(
			FilePath   = getSavePath caption:"Test path..." initialDir: btlcConfig.MainGameDataDir
			if(FilePath != undefined ) do 
			( 
				btn_MainGamedataDir.text = btlcConfig.MainGameDataDir = FilePath
				btlcConfig.Save()
			)
		)
		on  btn_MainGamedataDir rightclick do try (shellLaunch btlcConfig.MainGameDataDir "") catch()a


		on btn_CityPartDir pressed do 
		(
			FilePath   = getSavePath caption:"Test path..." initialDir: btlcConfig.IntialDirs
			if(FilePath != undefined ) do 
			( 
				btn_CityPartDir.text = btlcConfig.CurrentCityPart = FilePath
				Temp =  substituteString btlcConfig.CurrentCityPart  "\IV" "\SA"
				btn_SACityPartDir.text = btlcConfig.CurrentExpoSaPAth = Temp
				btlcConfig.Save()
			)
		)
		on btn_CityPartDir rightclick do try (shellLaunch btlcConfig.CurrentCityPart "") catch()a


		on btn_SACityPartDir pressed do 
		(
			FilePath   = getSavePath caption:"Test path..." initialDir: btlcConfig.IntialDirs
			if(FilePath != undefined ) do 
			( 
				btn_SACityPartDir.text = btlcConfig.CurrentExpoSaPAth = FilePath
				btlcConfig.Save()

			)
		)
		on btn_SACityPartDir rightclick do try (shellLaunch btlcConfig.CurrentExpoSaPAth "") catch()

		
	)

	rollout CityConvert "CityConvert" width:210 height:400
	(	
		spinner  strtid "Start ID:" range:[200,19999,(btlcConfig.CurrentID as float)] type:#integer width:70 enabled: true offset:[0,8] align:#left

		on strtid changed val  do 
		(
			btlcConfig.CurrentID = strtid.value  = val
			btlcConfig.Save() 
		)

		button btn_ConvertCity "Import City Part" width:110 height:35 align:#center tooltip:"Imports the selected city part" across:5
		on btn_ConvertCity pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.StartId = strtid.value;
			BTLCCityConvert.Import();
			strtid.value = btlcConfig.CurrentID;
		)

		button btn_ExportCity "Gen/Export Files" width:110 height:35 align:#center tooltip:"Exports .dff Models & Collision" 
		on btn_ExportCity pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.Export();
		)

		button btn_GenTxd "Build .Txds" width:110 height:35 align:#center tooltip:"Generates Txds" 
		on btn_GenTxd pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.BuildTxd();
		)

		button btn_OpenCol "Open .Col" width:110 height:35 align:#center tooltip:"Opens the .COl File to generate facegroups" 
		on btn_OpenCol pressed do 
		(
			OutputPath = btlcConfig.CurrentExpoSaPAth  + "\\img";
			MapPartName =  filenameFromPath btlcConfig.CurrentExpoSaPAth 
			Command = OutputPath + "\\" + MapPartName + ".col";
			scriptPath = (GetDir #userScripts )
       		
			Program =  scriptPath + "\\BTLC\\Tools\\CollEditor2.exe"
        	ShellLaunch Program Command
		)

		button btn_GenerateIMG "Build IMG" width:110 height:35 align:#center tooltip:"Builds the final Img File" 
		on btn_GenerateIMG pressed do 
		(
			MapPartName =  filenameFromPath btlcConfig.CurrentExpoSaPAth 
			/* Build final .img*/
			IniPath = btlcConfig.CurrentExpoSaPAth + "\\" + MapPartName + ".ini"
			OutPath = (pathConfig.removePathLeaf btlcConfig.CurrentExpoSaPAth) 

			btlcImgBuild.BuildImg IniPath OutPath
		)
	)

	rollout Map_Utils "Map Utils" width:210 height:400
	(
		button btn_ExportCollision "ExportCollision" width:110 height:35 align:#center tooltip:"Export the Collision models" across:4
		on btn_ExportCollision pressed do 
		(
			-- Collision Export
			start = timeStamp();
			OutputPath = btlcConfig.CurrentExpoSaPAth  + "\\img";
			MapPartName =  filenameFromPath btlcConfig.CurrentExpoSaPAth 
			Filepath = OutputPath + "\\" + MapPartName + ".col";
			btlcCol.ExportAllCollisions(Filepath);
			
			end = timeStamp();
			format "Collision Export: Processing took % seconds\n" ((end - start) / 1000.0)  
			freeSceneBitmaps() ; -- trying to free up memory
			gc();
		)

		button btn_ExportModels "Export Models" width:110 height:35 align:#center tooltip:"Export the models" 
		on btn_ExportModels pressed do 
		(
			-- Export Models
			start = timeStamp();
			OutputPath = btlcConfig.CurrentExpoSaPAth + "\\img";
			makeDir OutputPath
			btlcModelExport.ExportAllModels(OutputPath);
			
			end = timeStamp();
			format "Model Export: Processing took % seconds\n" ((end - start) / 1000.0)  
			gc();	
		)

		
		button btn_ReinitTxdDb "ReInit Texture DB" width:110 height:35 align:#center tooltip:"Export the models" 
		on btn_ReinitTxdDb pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.InitTexDb()
			gc();	
		)
		/*
		button btn_GenerateTxds "GenerateTXDs" width:120 height:35 align:#center tooltip:"Generate the .txds" 
		on btn_GenerateTxds pressed do 
		(
			
			TxdPath = btlcConfig.CurrentExpoSaPAth + "\\txd"
			Outpath = btlcConfig.CurrentExpoSaPAth + "\\img"
			btlcMagicTxd.GenerateTxds TxdPath OutPath
		)

		button btn_GenerateIMG "Generate IMG" width:120 height:35 align:#center tooltip:"Generate the Img file" 
		on btn_GenerateIMG pressed do 
		(
			MapPartName =  filenameFromPath btlcConfig.CurrentExpoSaPAth 
		
			IniPath = btlcConfig.CurrentExpoSaPAth + "\\" + MapPartName + ".ini"
			OutPath = (pathConfig.removePathLeaf btlcConfig.CurrentExpoSaPAth) 

			btlcImgBuild.BuildImg IniPath OutPath
		)
		*/
	)

	try (closeRolloutFloater btlcCityFloater) catch ()
	Pos = getMaxWindowSize() 	
	PosX = Pos[1]/2 - 300
	btlcCityFloater  = newRolloutFloater  "BTLC Main" 620 400 PosX 250
	addRollout DirSettings btlcCityFloater
	addRollout CityConvert btlcCityFloater
	addRollout Map_Utils btlcCityFloater
)



rollout btlcUtility  "BTLC Toolkit"
(
	
	button btn_ConvertCity "Convert Map Menu" width:150 align:#center
	on btn_ConvertCity pressed do  btlc_GUICityConvert()

	button btn_ModelConvert "Convert Models menu" width:150 align:#center enabled:false

	button btn_PathTool "Path Tools" width:150 align:#center enabled:false


	label lbl_dummy1 "///// Display Utils /////"
	button btn_ShowAll "All" width:45 align:#center across:3
	button btn_ShowCollision "Col" width:45 align:#center across:3
	button btn_ShowModels "Models" width:45 align:#center across:3

	label lbl_dummy2 "///// Vertex Display Utils /////"
	button btn_VertexDay "Day" width:50 align:#center across:2
	button btn_VertexNight "Night" width:50 align:#center across:2
	button btn_VertexAlphA "Alpha1" width:50 align:#center across:2
	button btn_VertexAlphaday "Alpha2" width:50 align:#center across:2

	checkbutton btn_map "Map" width:100 align:#center across:1

	on btn_ShowCollision pressed do 
	(
		for obj in objects do 
		(
			hide obj
			if  (classof  obj == Collision_Sphere)then 	unhide obj
			if  (classof  obj == Collision_Box)then 	unhide obj
			if  (isCol obj == true)  then	unhide obj
		)
	)
	on btn_ShowModels pressed do 
	(
		for obj in objects do 
		(
			unhide obj
			if  (classof  obj == Collision_Sphere)then 	hide obj
			if  (classof  obj == Collision_Box)then  	hide obj
			if  (isCol obj == true)  then hide obj
		)
	)

	on btn_ShowAll pressed do 
	(
		for obj in objects do   unhide obj
	)


	on btn_VertexNight pressed do
	if $ != undefined then 
	(
		for o in $ do
		if superclassof o == GeometryClass then 
		(
			o.showVertexColors = true
			o.vertexColorType = #illum
		)
		
		completeRedraw()
	)
	
	on btn_VertexDay pressed do
	if $ != undefined then 
	(
		for o in $ do
		if superclassof o == GeometryClass then 
		(
			o.showVertexColors = true
			o.vertexColorType = #color
		)
		completeRedraw()
	)

	on btn_map changed state do (
		try
		(
			delete gims_maphlpr
			gims_maphlpr = undefined
		) catch ()
		if btn_map.state == on then
		(
			scriptPath = (GetDir #userScripts )
			mapimgpath  =  scriptPath + "\\BTLC\\data\\"
			maps = #(
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_7.jpg")) showinviewport:true,
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_8.jpg")) showinviewport:true,
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_9.jpg")) showinviewport:true,
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_4.jpg")) showinviewport:true,
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_5.jpg")) showinviewport:true,
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_6.jpg")) showinviewport:true,
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_1.jpg")) showinviewport:true,
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_2.jpg")) showinviewport:true,
					standard diffuseMap:(bitmaptexture filename:(mapimgpath + "map_3.jpg")) showinviewport:true
				)
				gims_maphlpr = (converttopoly (plane width:6000 length:6000 lengthsegs:3 widthsegs:3 name:"maphelper" material:(multimaterial material:maps) displayByLayer:false realWorldMapSize:false showFrozenInGray:false))
				for i = 1 to 9 do
					polyop.setfacematid gims_maphlpr i i
				polyop.applyUVWMap gims_maphlpr #face utile:1.0 vtile:1.0 wtile:1.0 uflip:false vflip:false wflip:false cap:true tm:(matrix3 1) channel:1
				modxform = (UVW_Xform Rotation_Angle:-90)
				addmodifier gims_maphlpr modxform
				collapsestack gims_maphlpr
				freeze gims_maphlpr
				free maps
		
	
		)
		redrawviews()
	)


)
addrollout btlcUtility