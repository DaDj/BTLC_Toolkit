struct  Btlc_ModelConvert
(
	GenericTxdPath,
	ImportPath,
	ExportPath,

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

	fn CopyTxds ObjDef  TxdPath =
	(

	),

	fn ConvertIde Path = 
	(

	),

	fn oft_ConvertCol obj = 
	(
		for Child in obj.children do append TheChilds Child

		for Child in TheChilds do 
		(
			-- Check type first: Mesh,box,quad etc.
			-- If mesh add to main mesh
			--IF box:
			--Check if rotation is quat 0 0 0 1 (not roatetd)
			-- if rotated: converttomesh and attach
			-- else convert to Sa colbox
		)
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
			if theobj == TheMainNode then continue 
			else if theobj == TheMainColNode then continue
			if  classof theobj == Editable_mesh then theobj.parent = TheMainNode 
			else if  classof theobj == freeSpot or classof theobj == Omnilight  then theobj.parent = TheMainNode 
			else if  classof theobj == ofio_iv_col_box then theobj.parent = TheMainColNode  
			else if  classof theobj == Editable_Poly and (getUserProp theobj "type") == "BoundGeometry" then theobj.parent = TheMainColNode 
			-- ofio_iv_col_box , Editable_mesh
			-- Try to attach the meshes to the main mesh
			-- Try to attach the collision to the main collision. (keep boxes or just duck it to a single mesh?)
			-- put the lights below the main mesh
		)

		-- Build damage mesh
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
		TheMeshNodes = get_all_nodes TheMainNode
		for obj in TheMeshNodes do 
		(
			if (isValidNode obj) != true or  obj == TheMainNode then continue 
			if  classof obj == Editable_mesh then 
			(
				-- if obj.name[obj.name.count ]  ==  "d" do continue -- do not attach damaged parts. maybe we implement damaged models at SOME point....
				converttomesh obj
				meshop.attach TheMainNode obj  attachMat:#IDToMat condenseMat:true
			)
		)

		-- delete dummies.  
		for theobj in deleteNode do if isValidNode theobj do  delete theobj
		

	),

	fn ImportOft Path = 
	(
		local input_oft_file_name = getOpenFileName caption:"Select GTA IV *.oft file" types:"gta iv open formats fragments (*.oft)|*oft"
		if (input_oft_file_name != undefined) and (getFileSize input_oft_file_name) > 0 then
		(
			with undo off
			(
				with redraw off
				(
					local oft = ofio_iv_oft()
					--ofioLog.start()
					try ( 
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						oft.read(input_oft_file_name)
						ofioLog.print "building"
						oft.build()
						ofioLog.print ("oft import succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						gc()
					) catch
					(
						ofutils.showException()
						oft.cleanup()
						ofioLog.print "IMPORT ERROR !"
					)
					--ofioLog.finish()
					oft = undefined

					--Clean up
					TheStructName = getFilenameFile input_oft_file_name
					TheStructName = "ft_" + TheStructName
					TheStructNode = (getNodeByName TheStructName)
					oft_CleanUp TheStructNode 

				)
			)			
		)		
	),

	fn ImportOdr Path =
	(

	),

	fn ImportModels Folder = 
	(

	),

	function btlc_GUIModelConvert =
	(
		try (closeRolloutFloater btlcIdeModelsFloater) catch ()
		Pos = getMaxWindowSize() 	
		PosX = Pos[1]/2 - 300
		btlcIdeModelsFloater  = newRolloutFloater  "BTLC Main" 620 400 PosX 250
	)

)
btlcModelConvert = Btlc_ModelConvert();
--btlcModelConvert.ImportOft ""