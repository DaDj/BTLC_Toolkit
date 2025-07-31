global btlcCityFloater -- All Controls needed to convert a city part
global btlcUtilsFloater  -- Utils, mostly what to display/ alphasorting etc.
global btlcModelToolsFloater
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

	rollout MYconvert "CityConvert" width:210 height:400
	(	
		spinner  strtid "Start ID:" range:[200,50000,(btlcConfig.CurrentID as float)] type:#integer width:70 enabled: true offset:[0,8] align:#left

		on strtid changed val  do 
		(
			btlcConfig.CurrentID = strtid.value  = val
			btlcConfig.Save() 
		)

		button btn_ConvertCity "Import City Part" width:110 height:35 align:#left tooltip:"Imports the selected city part" across:5
		on btn_ConvertCity pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.StartId = strtid.value;
			BTLCCityConvert.Import();
			strtid.value = btlcConfig.CurrentID;
		)

		button btn_ExportCity "Gen/Export Files" width:110 height:35 align:#left tooltip:"Exports .dff Models & Collision" 
		on btn_ExportCity pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.Export();
		)

		button btn_GenTxd "Build .Txds" width:110 height:35 align:#left tooltip:"Generates Txds" 
		on btn_GenTxd pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.BuildTxd();
		)

		button btn_OpenCol "Open .Col" width:110 height:35 align:#left tooltip:"Opens the .COl File to generate facegroups" 
		on btn_OpenCol pressed do 
		(
			OutputPath = btlcConfig.CurrentExpoSaPAth  + "\\img";
			MapPartName =  filenameFromPath btlcConfig.CurrentExpoSaPAth 
			Command = OutputPath + "\\" + MapPartName + ".col";
			scriptPath = (GetDir #userScripts )
       		
			Program =  scriptPath + "\\BTLC\\Tools\\CollEditor2.exe"
        	ShellLaunch Program Command
		)

		button btn_GenerateIMG "Build IMG" width:110 height:35 align:#left tooltip:"Builds the final Img File" 
		on btn_GenerateIMG pressed do 
		(
			MapPartName =  filenameFromPath btlcConfig.CurrentExpoSaPAth 
			/* Build final .img*/
			IniPath = btlcConfig.CurrentExpoSaPAth + "\\" + MapPartName + ".ini"
			OutPath = (pathConfig.removePathLeaf btlcConfig.CurrentExpoSaPAth) 

			btlcImgBuild.BuildImg IniPath OutPath
		)

		group "Utils"
		(
			button btn_ExportCollision "ExportCollision" width:110 height:25 align:#center tooltip:"Export the Collision models" across:5
	
			button btn_ExportModels "Export Models" width:110 height:25 align:#center tooltip:"Export the models" 

			button btn_PaintWorld "Paint World" width:110 height:25 align:#center tooltip:"Paint Light on World"
		
			button btn_CrtCol "Create Collision" width:110 height:25 align:#center tooltip:"Create Collision for all models in Scene"  
			
			button btn_CrtSelCol "Selected to Col" width:110 height:25 align:#center tooltip:"Create Collision for selected"  

			button btn_GenerateData "Gen Data" width:110 height:25 align:#center tooltip:"Create external Data again" across:5 
			button btn_GenPlacement "Gen Opl only" width:110 height:25 align:#center tooltip:"Create external placement data only. Doens't impact Models/IDE" 

			button btn_Paintselected "Paint Selected" width:110 height:25 align:#center tooltip:"Create external Data again" 
			button btn_Paintselected2 "" width:110 height:25 align:#center tooltip:"Create external Data again" 
			button btn_Paintselected3 "" width:110 height:25 align:#center tooltip:"Create external Data again" 
		)

		group "Misc."
		(
			button btn_ReinitTxdDb "ReInit Texture DB" width:110 height:25 align:#left tooltip:"Export the models" across:5
			button btn_Cleanup "Cleanup Files" width:110 height:25 align:#left tooltip:"Cleanup external Files" 
			button btn_FixTextures "Fix TexturePaths" width:110 height:25 align:#center tooltip:"Export the models" 
			
		)

	
		on btn_FixTextures pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =  btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.InitTexDb()
			BtlcTextDB.FixTexturesforAllObjs()
			--BtlcTextDB.ReApplyTextures()
			gc();	
		)

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

		on btn_ReinitTxdDb pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.InitTexDb()
			gc();	
		)

		on btn_PaintWorld pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.PaintLights()
		)

		on btn_Paintselected pressd do 
		(
			Obj =selection[1]
			setuserprop Obj "BTLC_PrelightApplied" 0
			btlcVertexPaint.PrelightModel Obj
			btlcVertexPaint.PaintWorldLights Obj 
		)

		on btn_CrtCol pressed do 
		(
			BTLCCityConvert.GenerateCollsion()
		)

		on btn_CrtSelCol pressed do 
		(
			for obj in selection do 
			(
				btlcCol.GenerateColMeshes obj tresh:0.3 delforbid:false
			)
			
		)


		on btn_Cleanup pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth 
			BTLCCityConvert.CleanupFiles()
		)

		on btn_GenerateData pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.StartId = 	btlcConfig.CurrentID ;
			BTLCCityConvert.GenMyData();
			strtid.value = btlcConfig.CurrentID;
		)


		on btn_GenPlacement pressed do 
		(
			BTLCCityConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			BTLCCityConvert.ImportCityPath =  btlcConfig.CurrentCityPart
			BTLCCityConvert.ExportCityPath =    btlcConfig.CurrentExpoSaPAth
			BTLCCityConvert.RedoPlacement();
		)
	)


	try (closeRolloutFloater btlcCityFloater) catch ()
	Pos = getMaxWindowSize() 	
	PosX = Pos[1]/2 - 300
	btlcCityFloater  = newRolloutFloater  "BTLC Main" 620 400 PosX 250
	addRollout DirSettings btlcCityFloater
	addRollout MYconvert btlcCityFloater
	--addRollout Map_Utils btlcCityFloater
)


fn btlcUIModelTools = 
(
	rollout CollisionTools "Collision" width:350 height:400
	(
		button btn_SetasCol "Set As Col" width:110 height:25 align:#center tooltip:"Set selected as Col" across:2
		on btn_SetasCol pressed do 
		(
			btlcCol.ConvertMeshtoCol selection[1]
		)
		button btn_SetasShdw "Set As Shadow" width:110 height:25 align:#center tooltip:"Set selected as Shadow" 
		on btn_SetasShdw pressed do 
		(
			btlcCol.ConvertMeshtoCol selection[1]
			selection[1].isShadow = true
		)
		button btn_PivotasParent "Pivot to Parent" width:110 height:25 align:#center tooltip:"Set selected pivot to same as the parent" across:2
		on btn_PivotasParent pressed do 
		(
			if selection[1].parent != undefined do 
			(
				selection[1].pivot = selection[1].parent.pivot
				ResetXForm selection[1]
				converttomesh selection[1]
			)
		)

		button btn_AddDynObj "Set as Dynamic Obj" width:110 height:25 align:#center tooltip:"Adds dynamic attributes to Object" 
		on btn_AddDynObj pressed do 
		(
			custAttributes.add selection[1] gtaDynObject
		)
	)

	try (closeRolloutFloater btlcModelToolsFloater) catch ()
	Pos = getMaxWindowSize() 	
	PosX = Pos[1]/2 - 300
	btlcModelToolsFloater  = newRolloutFloater  "ModelTools" 400 400 PosX 250
	addRollout CollisionTools btlcModelToolsFloater
)


rollout btlcUtility  "BTLC Toolkit"
(
	
	button btn_ConvertCity "Convert Map Menu" width:150 align:#center
	on btn_ConvertCity pressed do  btlc_GUICityConvert()

	button btn_ModelConvert "Convert Models menu" width:150 align:#center enabled:true
	on btn_ModelConvert pressed do  btlc_GUIModelConvert()
	
	button btn_PathTool "Path Tools" width:150 align:#center enabled:false

	button btn_ModelTools "Model Tools" width:150 align:#center 


	label lbl_dummy1 "///// Display Utils /////"
	button btn_ShowAll "All" width:45 align:#center across:3
	button btn_ShowCollision "Col" width:45 align:#center across:3
	button btn_ShowModels "Models" width:45 align:#center across:3

	button btn_Showallmods "--" width:45 align:#center across:3
	button btn_ShowLOD "LOD" width:45 align:#center across:3
	button btn_ShowHD "HD" width:45 align:#center across:3

	label lbl_dummy2 "///// Vertex Display Utils /////"
	button btn_VertexDay "Day" width:50 align:#center across:2
	button btn_VertexNight "Night" width:50 align:#center across:2
	button btn_VertexAlphA "Alpha1" width:50 align:#center across:2
	button btn_VertexNone "None" width:50 align:#center across:2

	checkbutton btn_map "Map" width:100 align:#center across:1




	hyperLink link_doc "Help" address:"https://btlcdoc.ratpool.de/"

	on btn_ModelTools pressed do 
	(
		btlcUIModelTools();
	)


	on btn_ShowHD pressed do 
	(
		for obj in objects do 
		(
			unhide obj
			if  (classof  obj == Collision_Sphere)then 	hide obj
			if  (classof  obj == Collision_Box)then  	hide obj
			if  (isCol obj == true)  then hide obj
			bIsLOd = getUserProp  obj  "type" 
			if  (bIsLOd == "LOD")  then hide obj
		)
	)

	on btn_ShowLOD pressed do 
	(
		for obj in objects do 
		(
			unhide obj
			if  (classof  obj == Collision_Sphere)then 	hide obj
			if  (classof  obj == Collision_Box)then  	hide obj
			if  (isCol obj == true)  then hide obj
			bIsLOd = getUserProp  obj  "type" 
			if  (bIsLOd != "LOD")  then hide obj
		)
	)


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
	(
		for o in objects do
		if superclassof o == GeometryClass then 
		(
			o.showVertexColors = true
			o.vertexColorType = #illum
		)
		
		completeRedraw()
	)
	
	on btn_VertexDay pressed do
	(
		for o in objects do
		if superclassof o == GeometryClass then 
		(
			o.showVertexColors = true
			o.vertexColorType = #color
		)
		completeRedraw()
	)

	on btn_VertexNone pressed do
	(
		for o in objects do
		if superclassof o == GeometryClass then 
		(
			o.showVertexColors = false
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


