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

    fn ImportOft Path = 
    (
        local input_oft_file_name = getOpenFileName caption:"Select GTA IV *.oft file" types:"gta iv open formats fragments (*.oft)|*oft"
		if (input_oft_file_name != undefined) and (getFileSize input_oft_file_name) > 0 then
		(
			with undo off
			(
				with redraw off
				(
                    TheObj = undefined
					local oft = ofio_iv_oft()
				--ofioLog.start()
					try ( 
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						oft.read(input_oft_file_name)
						ofioLog.print "building"
						print "read oft success"
						TheObj = oft.build()
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
                   TheObjName = getFilenameFile input_oft_file_name
                   AllNodes = get_all_nodes (getNodeByName TheObjName)
					deleteNode = #()
					KeepNodes = #()
					for aNode in AllNodes do 
					(
					
						Theclass = (classOf aNode)
					if Theclass == Dummy then  append deleteNode aNode
					else   append KeepNodes aNode
					
					)
					
					for theobj in deleteNode do if isValidNode theobj do  delete theobj
					for theobj in KeepNodes do 
					(
						print (classOf theobj) as string
						
						-- Try to attach the meshes to the main mesh
						-- Try to attach the collision to the main collision. (keep boxes or just duck it to a single mesh?)
						-- put the lights below the main mesh
					)

				)
			)			
		)		
    ),

    fn ImportOdr Path =
    (

    ),

    fn ImportModels Folder = 
    (

    )
)
btlcModelConvert = Btlc_ModelConvert();