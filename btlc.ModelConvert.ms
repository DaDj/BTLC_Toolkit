global btlcIdeModelsFloater -- Controls for converting a img/Ide (props and stuff.)


struct ObjectDat 
(
	Name,
	Mass = 100.0,
	TurnMass = 150.0,
	AirResistance = 0.99,
	Elasticity = 0.03,
	PercSubmerged = 50.0,
	Uproot = 20.0,
	CDMult = 2.0,
	CDEff = 0, -- 0: none, 1:changemdl , 20:smash , 21: changthensmash , 200:breakable, 202:breakable ansd remove forever
	SpCDR = 0, -- 0: none, 1: lampost, 2:smallbox, 3: bigbox, 4:fencepart,5:grenade,6:swingdoor,7:Lockdoor, 8:Hanging, 9:ob_col_poolball
	CamAv = 1,
	Expl = 0,
	FX_TYPE = 0, -- 0 - no FxSystem, 1 - play when hit, 2 - play when destroyed, 3 - play when hit or destroyed
	FX_OFFSET = [0.0,0.0,0.0],
	FX_NAME = "none",
	B_SM = 100.0, --if set to 2.0 then it will take twice the force to smash as opposed to break an object (1.0 - smash only - never break, set very large if it only breaks and never smashes)
	B_VX = 0.0,
	B_VY = 0.0,
	B_VZ = 0.1,
	B_VR = 0.07,
	B_GUN = 0, 
	B_SPK = 1
)


struct btlc_MdlIde 
(
	Id = 0,
	MdlName = undefined,
	Renamed = false,
	OrgName = undefined,
	Txd = "none",
	DrawDist = 100,
	Flag = 0,
	ObjectData = ObjectDat()
)

struct  Btlc_ModelConvert
(
	GenericTxdPath,
	ImportPath,
	ExportPath,
	Ide= #(),
	IdStart = 0,

	fn InitTexDb = 
	( 
		BtlcTextDB = Btlc_TextureDB()
		BtlcTextDB.Folders = #() --Main folder to search for textures.
		BtlcTextDB.TexturesList = #() -- Full Filepaths to all Textures
		BtlcTextDB.TexNameList = #()-- Names to all Textures in same Order
		
		append BtlcTextDB.Folders  GenericTxdPath
		append BtlcTextDB.Folders  (ExportPath + "\\txd")
		BtlcTextDB.FindAllTextures()
	),

	fn CopyTxds =
	(
		TheTxdDir = ExportPath + "\\txd"
		ImageName =  filenameFromPath ExportPath

		-- Copy normal txd folders first
		-- delte old txd folder. (gtaconverter hangs up for some reason if already existing.
		sioDir = dotNetClass "System.IO.Directory"
		if (SIODir.Exists TheTxdDir) do SIODir.Delete (TheTxdDir) true -- kinda unsafe just deletes stuff.
		btlcDataConverter.CopyTextures ("\"" + ImportPath + "\\wtd" + "\"") ("\"" + ExportPath + "\\txd" + "\"");

		-- Copy textures of wdr objects to right folders
		for Itemdef in Ide do 
		(
			--if the wdr has no texture archive, give it one (IMg name + txd)
			if Itemdef.Txd == "null" then  Itemdef.Txd = (substring ImageName  1 10 ) + "txd"

			TheTextures = (getfiles (ImportPath + "\\wdr\\" +  Itemdef.OrgName + "\\" +  "*.dds"))
			--print TheTextures

			for Texture in TheTextures do  
			(
				MyFilename = getFilenameFile Texture 
				FilenameNew = substring MyFilename 1 26
				NewPath = TheTxdDir + "\\" +  Itemdef.Txd + "\\" + FilenameNew + ".dds"

				makeDir  (getFilenamePath NewPath)
				copyFile Texture NewPath
			)
		)
	),

	-- Load IdeData
	fn ConvertIde Path  = 
	(
		Ide = #()
		IdObj= 1
		IDCurr = IdStart
		fs = openFile Path
		while not eof fs do
		(
			l = readline fs
			if l == "objs" do 
			(
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					Ide[IdObj] = btlc_MdlIde();
					Ide[IdObj].Id = IDCurr
					Ide[IdObj].MdlName = toLower  (trimLeft(trimRight fl[1]))
					Ide[IdObj].OrgName = Ide[IdObj].MdlName
					if Ide[IdObj].MdlName.count > 19 do 
					(
						Ide[IdObj].MdlName = btlcUtil.CutNameAdv Ide[IdObj].MdlName
						Ide[IdObj].Renamed = true
					)  	
					Ide[IdObj].Txd =  toLower  (trimLeft(trimRight fl[2])) 
					ImageName =  filenameFromPath ExportPath
					if Ide[IdObj].Txd == "null" then  Ide[IdObj].Txd = (substring ImageName  1 10 ) + "txd"
					Ide[IdObj].DrawDist =  toLower  (trimLeft(trimRight fl[3])) as integer
					IDCurr = IDCurr + 1 
					IdObj = IdObj + 1
				)
			)

			if l == "anim" do 
			(
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					Ide[IdObj] = btlc_MdlIde();
					Ide[IdObj].Id = IDCurr
					Ide[IdObj].MdlName = toLower  (trimLeft(trimRight fl[1]))
					Ide[IdObj].OrgName = Ide[IdObj].MdlName
					if Ide[IdObj].MdlName.count > 19 do 
					(
						Ide[IdObj].MdlName = btlcUtil.CutNameAdv Ide[IdObj].MdlName
						Ide[IdObj].Renamed = true
					)  	
					Ide[IdObj].Txd =  toLower  (trimLeft(trimRight fl[2])) 
					if Ide[IdObj].Txd == "null" then  Ide[IdObj].Txd = (substring ImageName  1 10 ) + "txd"
					Ide[IdObj].DrawDist =  toLower  (trimLeft(trimRight fl[4])) as integer
					IDCurr = IDCurr + 1 
					IdObj = IdObj + 1
				)
			)

		)
		close fs
		IdStart = IDCurr 
	),

	fn ExportIde Path = 
	(
		fs = openFile Path mode:"wb"
		format "objs\n" to:fs
		for Item in Ide do 
		(
			format "%, %, %, %, % \n" (Item.Id as string) Item.MdlName Item.Txd (Item.DrawDist as string) (Item.Flag as string)  to:fs
		)
		format "end\n" to:fs
		close fs

	),

	fn oft_ConvertCol myobj = 
	(
		TheChilds = #()
		MakeAsMesh = undefined;
		newnodes = #()
		if (isValidNode myobj) == true do
		(
			for Child in myobj.children do append TheChilds Child

			for i=1 to TheChilds.count do 
			(
				newnodes[i] = btlcIVColConvert.ConvertColGeometry TheChilds[i]
				newnodes[i].parent = undefined;
			)

			mynewobj = btlcIVColConvert.ConvertColGeometry myobj
			if classof mynewobj == Editable_mesh and MakeAsMesh == undefined do  MakeAsMesh = mynewobj
			mynewobj.name = "COL" + mynewobj.name  
			for child in newnodes do 
			(
				child.parent = mynewobj
				child.name = "COL" + child.name
				if classof child == Editable_mesh do 
				(
					if MakeAsMesh == undefined then MakeAsMesh = child
					else meshop.attach MakeAsMesh child attachMat:#IDToMat condenseMat:true
				)
			)
		)
		mynewobj
	),

	fn oft_IsDamagable TheMainObj = 
	(
		IsDamage = false;

		TheMeshNodes = get_all_nodes TheMainObj
		for obj in TheMeshNodes do 
		(
			--	if (isValidNode obj) != true or  obj == TheMainNode then continue 
			if  classof obj == Editable_mesh then 
			(
				--if obj.name[obj.name.count ]  ==  "d" do continue -- do not attach damaged parts. maybe we implement damaged models at SOME point....
				if (getUserProp obj "damaged") == true do IsDamage = true; 

			)
		)
		IsDamage
	),

	-- Build a damaged Model (if it is ofc) --> oft_IsDamagable  )
	fn oft_BuildDamageMdl TheMainObj = 
	(
		-- goes trough all subparts and tries to find if a dmaged version exists
		-- yes: attach the damaged if not attach the normal
		TheDmgMain = undefined

		TheMeshNodes = get_all_nodes TheMainObj

		-- check if main node also has a damaged model
		for obj in TheMeshNodes do
		(
			if (isValidNode obj) != true or  obj == TheMainObj then continue 	
			
			if classof obj == Editable_mesh and (getUserProp obj "damaged") == true do 
			(
				Name = substring obj.name 1 (obj.name.count-3)
				if Name == TheMainObj.name do 
				(
					TheDmgMain = obj
					TheDmgMain.parent = undefined;
					TheDmgMain.name =  TheMainObj.name + "_dam"
				)
			)
			
		)

		if TheDmgMain == undefined do
		(
			TheDmgMain = copy TheMainObj
			TheDmgMain.name = TheMainObj.name + "_dam"
		)
		
		TheMeshNodes = get_all_nodes TheMainObj --get again because maindmg may be gone now :)
		names = for node in TheMeshNodes collect node.name
		for obj in TheMeshNodes do 
		(
			if (isValidNode obj) != true or  obj == TheMainObj then continue 
			if  classof obj == Editable_mesh then 
			(
				if (getUserProp obj "damaged") == true then obj.parent = TheDmgMain 
				else if (finditem names (obj.name + "d")) == false do
				(
					myob = copy obj
					myob.parent = TheDmgMain
				)
			)
		)

		-- Combien Mesh
		TheMeshNodes = get_all_nodes TheDmgMain 
		for obj in TheMeshNodes do 
		(
			if (isValidNode obj) != true or  obj == TheDmgMain then continue 
			converttomesh obj
			meshop.attach TheDmgMain obj  attachMat:#IDToMat condenseMat:true
		)

		TheDmgMain
	),

	fn oft_combineMesh TheMainNode = 
	(
		--BreakNode = copy TheMainNode
		--BreakNode.name = BreakNode.name + "_b"
		--BreakNode.parent = TheMainNode
		--setUserProp BreakNode "breakmdl" "breakable"

		--	for iface = 1 to (getNumFaces BreakNode) do  setFaceSmoothGroup BreakNode iface 1
		for iface = 1 to (getNumFaces TheMainNode) do  setFaceSmoothGroup TheMainNode iface 1

	

		TheMeshNodes = get_all_nodes TheMainNode
		objcounter = 2
		for obj in TheMeshNodes do 
		(
			sg_bitarray = #{} as bitarray
			sg_bitarray[32] = 0
			if (isValidNode obj) != true or  obj == TheMainNode   then continue 
			if  classof obj == Editable_mesh then 
			(

				sg_bitarray[objcounter] = 1
				converttomesh obj
				for iface = 1 to (getNumFaces obj) do
				(
					local sgroup_val=0
					for i in sg_bitarray do sgroup_val += 2^(i-1)
					setFaceSmoothGroup obj iface sgroup_val
				) 
				update obj

				--objb = copy obj name:(obj.name + "_b")
				--objb.Material = copy objb.Material
				--meshop.attach BreakNode objb attachMat:#IDtoMat condenseMat:false

				meshop.attach TheMainNode obj attachMat:#matToID condenseMat:true
				
				objcounter = objcounter + 1 
			)
		)
		TheMainNode
	),
	
	fn oft_CleanUp TheStructNode = 
	(
		AllNodes = get_all_nodes TheStructNode
		deleteNode = #()
		KeepNodes = #()
		for aNode in AllNodes do 
		(
			Theclass = (classOf aNode)
			if Theclass == Dummy then  append deleteNode aNode
			else   append KeepNodes aNode	
		)

		-- Get the complete Mass
		MassArray = #()
		WholeMass = 0.0
		for theobj in deleteNode do 
		(
			SSname = substring theobj.name  1 4 		
			if SSname == "ftc_" do 
			(
				MassArray[MassArray.count +1 ] = getUserProp theobj "pristineMass"
				WholeMass = WholeMass + ( getUserProp theobj "pristineMass")
			)		
			
		)

		-- The main Mesh name
		TheObjName = substring TheStructNode.name 4 (TheStructNode.name.count)   + "_1"
		TheObjName = toLower TheObjName 
		-- Get the Main Node and Main Col Node
		TheMainNode = undefined;
		TheMainColNode = undefined;
		for theobj in KeepNodes do 
		(
			if ( toLower theobj.name) == TheObjName and (classof theobj) == Editable_mesh then 
			(
				theobj.parent = undefined
				TheMainNode = theobj

				if TheStructNode != undefined do 
				(
					minMoveForce = getUserProp TheStructNode  "minMoveForce"
					CenterOfMass = getUserProp TheStructNode  "CenterOfMass"
				)
				setUserProp TheMainNode "minMoveForce" minMoveForce
				setUserProp TheMainNode "CenterOfMass" CenterOfMass
				setUserProp TheMainNode "MassArray" MassArray
				setUserProp TheMainNode "Mass" WholeMass	
			)

			if (toLower theobj.name) == TheObjName and (classof theobj) != Editable_mesh then 
			(
				TheMainColNode = theobj
				theobj.parent = undefined
			)
		)
	
		-- delete "-1"
		TheMainNode.name = substring TheMainNode.name 1 (TheMainNode.name.count-2)


		-- sort the objects
		for theobj in KeepNodes do 
		(
			if isValidNode theobj == false then continue
			if theobj == TheMainNode then continue 
			else if theobj == TheMainColNode then continue
			if  classof theobj == Editable_mesh then theobj.parent = TheMainNode 
			else if  classof theobj == freeSpot or classof theobj == Omnilight  then theobj.parent = TheMainNode 
			else if  classof theobj == GTA_Light   then theobj.parent = TheMainNode 
			else if  classof theobj == ofio_iv_col_box then theobj.parent = TheMainColNode  
			else if  classof theobj == Editable_Poly and (getUserProp theobj "type") == "BoundGeometry" then theobj.parent = TheMainColNode 
			else if  classof theobj == ofio_iv_col_sphere then theobj.parent = TheMainColNode  
			else delete theobj
			-- ofio_iv_col_box , Editable_mesh
			-- Try to attach the meshes to the main mesh
			-- Try to attach the collision to the main collision. (keep boxes or just duck it to a single mesh?)
			-- put the lights below the main mesh
		)
		
		-- Build damage mesh
		dummyObj = undefined
		if (oft_IsDamagable TheMainNode) == true then 
		(
			TheDmgMain = oft_BuildDamageMdl TheMainNode

			dummyObj = Dummy() 
			dummyObj.Name = TheMainNode.name
			dummyObj.pos = TheMainNode.pos
			dummyObj.boxsize = [1, 1, 1]
			TheMainNode.parent = dummyObj
			TheDmgMain.parent = dummyObj
		)

		-- combine into one mesh
		oft_combineMesh TheMainNode 

		-- delete dummies.  
		for theobj in deleteNode do if isValidNode theobj do  delete theobj
		

		-- Set new colobjects under mainmodel and set pivot of colmesh to mainmodel pos
		mynewobj = oft_ConvertCol TheMainColNode
		TheColNodes = get_all_nodes mynewobj
		for Node in TheColNodes do
		(
			Node.parent = TheMainNode
			if  classof Node == Editable_mesh then 
			(
				Node.pivot = TheMainNode.pos
				resetxform Node
			)
		)

		if dummyobj != undefined then 
		(
			TopNode =  dummyobj
		)
		else
		(
			TopNode =  TheMainNode
		)

		Allnodes = get_all_nodes TopNode
		for Node in Allnodes do 
		(
			Node.name =	btlcUtil.CutNameAdv Node.name
		)
		TopNode
	),

	fn ImportOft = 
	(
		TheModels = (getfiles (ImportPath + "\\wft\\" + "*.oft"))

		posX = 0;
		posY = 0;

		for AModel in TheModels do 
		(
			try 
			(
				ThisObj = undefined
				local oft = ofio_iv_oft()

				oft.read(AModel)
				ThisObj = oft.build()

				
				if ThisObj != undefined do ThisObj = oft_CleanUp ThisObj 

				ThisObj.pos = [-(posX*10)-10, (posY * 10), 0]

				posX = posX + 1;
				if posX == 11 do 
				(
					posX = 0;
					posY = posY + 1
				)
			)
			catch 
			(
				print "Error while importing .oft files."
				print AModel
				oft.cleanup()
			)
		)
		--
	),

	fn ImportOdr =
	(	
		TheModels = (getfiles (ImportPath + "\\wdr\\" + "*.odr"))

		posX = 0;
		posY = 0;
	
			for AModel in TheModels do 
			(	try 
				(
					local dr = ofio_iv_odr()
					dr.read(AModel)
					ThisObj =  dr.build AdvCutName:true

					ThisObj.pos = [(posX*10), (posY * 10), 0]
					posX = posX + 1;
					if posX == 11 do 
					(
						posX = 0;
						posY = posY + 1
					)	
				)
				catch 
				(
					print "Error while importing .odr files."
					print AModel
				)
			)
	
	),

	fn ImportObd = 
	(
		descriptor = undefined;
		dummyObj = undefined;
		Filepath = ImportPath +  "\\" --+(filenameFromPath ImportPath)
		try 
		( 		
			ObdFiles = (getfiles (Filepath  + "*.obd"))
			if ObdFiles != undefined do 
			(
				dummyObj = Dummy() 
				dummyObj.Name = "bd_" + (filenameFromPath ImportPath)
				dummyObj.boxsize = [1, 1, 1]
				
				for ObdFile in ObdFiles do 
				(
					local bd = ofio_iv_obd()
					bd.read(ObdFile)
					descriptor = bd.build()
					for Child in descriptor.children do Child.parent = dummyObj
					delete descriptor
				)
			) 
		)
		catch 
		(
			print "Error while converting .obd file. Maybe missing?"
		)

		dummyObj
	),

	fn MatchOdrtoCol ColContainer = 
	(
		Collisions = ColContainer.children

		for Col in Collisions do 
		(
			TheModel = getNodeByName Col.name  exact:true ignoreCase:true all:true

			for mdl in TheModel do 
			(
				if mdl != Col do 
				(
					Col.parent = mdl
					Col.pos = mdl.pos
					for ColChild in Col.children do 
					(
						ColChild.parent = mdl
					)
					CenterOfMass = getUserProp Col  "CenterOfMass"
					setUserProp mdl "CenterOfMass" CenterOfMass
					if  classof Col == Dummy do delete Col
				) 
			)
		)
		delete ColContainer
		
	),

	fn BuildTxd = 
    (
     -- Build Txd with Magictxd
        start = timeStamp();
        TxdPath = ExportPath  + "\\txd"
        Outpath = ExportPath + "\\img"
        btlcMagicTxd.RunMagicTxd TxdPath OutPath
        end = timeStamp();
        format "Build Txds: Processing took % seconds\n" ((end - start) / 1000.0)  
        gc();
    ),

	fn StartImport = 
	(
		with redraw off
		(
			IDEFILE = (getfiles (ImportPath  + ".ide"))
			print IDEFILE
			ConvertIde IDEFILE[1] 
			CopyTxds();
			InitTexDb();
			ImportOft();
			ImportOdr();
			ColContainer = ImportObd();

			if ColContainer != undefined do 
			(
				Objs = ColContainer.children
				for TheObj in Objs do btlcIVColConvert.ConvertObd TheObj;

				MatchOdrtoCol ColContainer
			) 
			btlcIDEUtils.IVParticlestoModels IDEFILE[1]  -- Import Particles
			btlcIDEUtils.IVSpawntoModel IDEFILE[1]
			
		)
		gc();
		resumeEditing()
		redrawviews()
		freeSceneBitmaps() 	
	),

	fn StartExport = 
	(
	--	Path =  ExportPath + ".ide"
		--btlcModelConvert.ExportIde Path

		OutputPath = ExportPath + "\\img";
		makeDir OutputPath
		btlcModelExport.ExportAllModels(OutputPath);
		
		MapPartName =  filenameFromPath ExportPath
		Filepath = OutputPath + "\\" + MapPartName + ".col";
		btlcCol.ExportAllCollisions(Filepath);
	)



)
btlcModelConvert = Btlc_ModelConvert();
--btlcModelConvert.ImportOft ""

function btlc_GUIModelConvert =
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
		
		label lbl_CityPartDir "IV Current ModelPath:" align:#left across:2
		button btn_CityPartDir btlcConfig.CurrentModelConvPath width:400 height:25 align:#right tooltip:""
		
		label lbl_SACityPartDir "SA Current Output dir:" align:#left across:2
		button btn_SACityPartDir btlcConfig.CurrentModelConvPathSA width:400 height:25 align:#right tooltip:"Folder in which the subfoldr for the sa data will be exported."
		
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
			FilePath   = getSavePath caption:"Test path..." initialDir: btlcConfig.CurrentModelConvPath
			if(FilePath != undefined ) do 
			( 
				btn_CityPartDir.text = btlcConfig.CurrentModelConvPath = FilePath
				Temp =  substituteString btlcConfig.CurrentModelConvPath  "\IV" "\SA"
				btn_SACityPartDir.text = btlcConfig.CurrentModelConvPathSA = Temp
				btlcConfig.Save()
			)
		)
		on btn_CityPartDir rightclick do try (shellLaunch btlcConfig.CurrentModelConvPath "") catch()a
		
		
		on btn_SACityPartDir pressed do 
		(
			FilePath   = getSavePath caption:"Test path..." initialDir: btlcConfig.CurrentModelConvPathSA
			if(FilePath != undefined ) do 
			( 
				btn_SACityPartDir.text = btlcConfig.CurrentModelConvPathSA = FilePath
				btlcConfig.Save()
				
			)
		)
		on btn_SACityPartDir rightclick do try (shellLaunch btlcConfig.CurrentModelConvPathSA "") catch()
		
		
	)

	rollout ModelConvert "ModelConvert" width:210 height:450
	(	
		spinner  strtid "Start ID:" range:[200,50000,(btlcConfig.CurrentID as float)] type:#integer width:70 enabled: true offset:[0,8] align:#left
		
		on strtid changed val  do 
		(
			btlcConfig.CurrentID = strtid.value  = val
			btlcConfig.Save() 
		)
		
		button btn_ConvertCity "Import" width:110 height:35 align:#center tooltip:"Imports the selected Models iMage an converts IDE" across:5
		on btn_ConvertCity pressed do 
		(
			btlcModelConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			btlcModelConvert.ImportPath =  btlcConfig.CurrentModelConvPath
			btlcModelConvert.ExportPath =    btlcConfig.CurrentModelConvPathSA
			btlcModelConvert.IdStart = strtid.value;
			btlcModelConvert.StartImport();

			strtid.value = btlcConfig.CurrentID = btlcModelConvert.IdStart ;
		)
		
		button btn_ExportCity "Gen/Export Files" width:110 height:35 align:#center tooltip:"Exports .dff Models & Collision" 
		on btn_ExportCity pressed do 
		(
			btlcModelConvert.ExportPath  =  btlcConfig.CurrentModelConvPathSA
			btlcModelConvert.StartExport()
		)
		
		button btn_GenTxd "Build .Txds" width:110 height:35 align:#center tooltip:"Generates Txds" 
		on btn_GenTxd pressed do 
		(
			btlcModelConvert.ImportPath =  btlcConfig.CurrentModelConvPath
			btlcModelConvert.ExportPath =    btlcConfig.CurrentModelConvPathSA
			btlcModelConvert.BuildTxd()
		)
		
		button btn_OpenCol "Open .Col" width:110 height:35 align:#center tooltip:"Opens the .COl File to generate facegroups" 
		on btn_OpenCol pressed do 
		(
			OutputPath = btlcConfig.CurrentModelConvPathSA  + "\\img";
			MapPartName =  filenameFromPath btlcConfig.CurrentModelConvPathSA 
			Command = OutputPath + "\\" + MapPartName + ".col";
			scriptPath = (GetDir #userScripts )
			
			Program =  scriptPath + "\\BTLC\\Tools\\CollEditor2.exe"
			ShellLaunch Program Command
		)
		
		button btn_GenerateIMG "Build IMG" width:110 height:35 align:#center tooltip:"Builds the final Img File" 
		on btn_GenerateIMG pressed do 
		(
			MapPartName =  filenameFromPath btlcConfig.CurrentModelConvPathSA 
			/* Build final .img*/
			IniPath = btlcConfig.CurrentModelConvPathSA + "\\" + MapPartName + ".ini"
			OutPath = (pathConfig.removePathLeaf btlcConfig.CurrentModelConvPathSA) 
			
			btlcImgBuild.BuildImg IniPath OutPath
		)
	)

	rollout Model_Utils "Map Utils" width:210 height:400
	(
		button btn_ExportCollision "ExportCollision" width:110 height:35 align:#center tooltip:"Export the Collision models" across:5
		on btn_ExportCollision pressed do 
		(
			-- Collision Export
			start = timeStamp();
			OutputPath = btlcConfig.CurrentModelConvPathSA  + "\\img";
			MapPartName =  filenameFromPath btlcConfig.CurrentModelConvPathSA 
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
			OutputPath = btlcConfig.CurrentModelConvPathSA + "\\img";
			makeDir OutputPath
			btlcModelExport.ExportAllModels(OutputPath);
			
			end = timeStamp();
			format "Model Export: Processing took % seconds\n" ((end - start) / 1000.0)  
			gc();	
		)

		
		button btn_ReinitTxdDb "ReInit Texture DB" width:110 height:35 align:#center tooltip:"Export the models" 
		on btn_ReinitTxdDb pressed do 
		(
			btlcModelConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			btlcModelConvert.ImportPath =  btlcConfig.CurrentModelConvPath
			btlcModelConvert.ExportPath =  btlcConfig.CurrentModelConvPathSA
			btlcModelConvert.InitTexDb()
			gc();	
		)

		button btn_FixTextures "Fix TexturePaths" width:110 height:35 align:#center tooltip:"Export the models" 
		on btn_FixTextures pressed do 
		(
			btlcModelConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			btlcModelConvert.ImportPath =  btlcConfig.CurrentModelConvPath
			btlcModelConvert.ExportPath =  btlcConfig.CurrentModelConvPathSA
			btlcModelConvert.InitTexDb()
			BtlcTextDB.FixTexturesforAllObjs();
			--BtlcTextDB.ReApplyTextures()
			gc();	
		)

		button btn_ideredo "Convert IDE" width:110 height:35 align:#center tooltip:"Gen IDE" 
		on btn_ideredo pressed do 
		(
			
			btlcModelConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			btlcModelConvert.ImportPath =  btlcConfig.CurrentModelConvPath
			btlcModelConvert.ExportPath =  btlcConfig.CurrentModelConvPathSA
			btlcModelConvert.IdStart = btlcConfig.CurrentID as integer
			IDEFILE = (getfiles (btlcModelConvert.ImportPath   + ".ide"))
			print IDEFILE
			btlcModelConvert.ConvertIde IDEFILE[1] 

			Path =  btlcModelConvert.ExportPath + ".ide"
			btlcModelConvert.ExportIde Path
		btlcConfig.CurrentID = btlcModelConvert.IdStart ;
		)

		button btn_iplexpo "Export Ipl" width:110 height:35 align:#center tooltip:"Export model placement as ipl lines" 
		on btn_iplexpo pressed do 
		(
				
			btlcModelConvert.GenericTxdPath =  btlcConfig.GenericTexDir
			btlcModelConvert.ImportPath =  btlcConfig.CurrentModelConvPath
			btlcModelConvert.ExportPath =  btlcConfig.CurrentModelConvPathSA
			btlcModelConvert.IdStart = btlcConfig.CurrentID as integer
			IDEFILE = (getfiles (btlcModelConvert.ExportPath   + ".ide"))
			Iplexpo = btlc_SA_IPL()
			Iplexpo.ExportToList IDEFILE[1]
		)



		group "WindFx and effects"
		(
			button btn_setWindfyx "Set as WindFx" width:110 height:35 align:#center tooltip:"Sets the model to have wind swaying"  across:4
			on btn_setWindfyx pressed do 
			(
				for obj in selection do setUserProp obj "windfx" "yes"
				
			)

			
			button btn_unsetWindfyx "unSet  WindFx" width:110 height:35 align:#center tooltip:"unSets the model to have wind swaying" 
			on btn_unsetWindfyx pressed do 
			(
				for obj in selection do setUserProp obj "windfx" "no"
			)

			button btn_PaintLights "PaintLights" width:110 height:35 align:#center tooltip:"Paints the Lights to vertex night" 
			on btn_PaintLights pressed do 
			(
				btlcWorldLightPaint.PaintWorld() 
			)

			button btn_empty "--" width:110 height:35 align:#center tooltip:"Paints the Lights to vertex night" 
			on btn_empty pressed do 
			(
				
			)

				
		)

		group "Dynamic Col Creation"
		(
			button btn_AddDynObj "Set as Dynamic Obj" width:110 height:35 align:#center tooltip:"Adds dynamic attributes to Object"  across:4
			on btn_AddDynObj pressed do 
			(
				custAttributes.add selection[1] gtaDynObject 
			)
	
			button btn_CreateBrk "Set as Breakable" width:110 height:35 align:#center tooltip:"Export the models" 
			on btn_CreateBrk pressed do 
			(
				btlcIDEUtils.SetObjAsBreakable selection[1] 
			)
	
			button btn_DynData "Export Dynamic Data" width:110 height:35 align:#center tooltip:"Export the objects dynamic data" 
			on btn_DynData pressed do 
			(
				btlcIDEUtils.WriteDynObjData idePath: (btlcConfig.CurrentModelConvPathSA + ".ide")
			)
	 
			label lbldum ""



			spinner spinMaxverts "maxvert" range:[0,32,16]  type:#integer  across:4
			spinner spinSphSize "SphereRadius" range:[0.0,1.0,0.05]  type:#float
			spinner spinpushin "Push in" range:[-30.0,0.0,-5.0]  type:#float
	
			
			button btn_DynCol "Create Dyn. Spheres" width:110 height:35 align:#center tooltip:"Tool for Dynmaic Collision creation.(spheres)"  
			on btn_DynCol pressed do 
			(
				if selection.count > 0 do CreatDynamicCol selection[1]  maxVert:spinMaxverts.value push:spinpushin.value tradius:spinSphSize.value
				
			)
			
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

	try (closeRolloutFloater btlcIdeModelsFloater) catch ()
	Pos = getMaxWindowSize() 	
	PosX = Pos[1]/2 - 300
	btlcIdeModelsFloater  = newRolloutFloater  "BTLC Model Convert" 620 650 PosX 250
	addRollout  DirSettings btlcIdeModelsFloater
	addRollout  ModelConvert btlcIdeModelsFloater
	addRollout  Model_Utils btlcIdeModelsFloater
)