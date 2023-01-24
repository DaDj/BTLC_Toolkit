struct Btlc_ConvertCity 
(
    GenericTxdPath,
    ImportCityPath,
    ExportCityPath,
    UsedObjs,
    TheMap,
    StartId,

    fn InitTexDb = 
    ( 
       BtlcTextDB = Btlc_TextureDB()
       BtlcTextDB.Folders = #() --Main folder to search for textures.
       BtlcTextDB.TexturesList = #() -- Full Filepaths to all Textures
       BtlcTextDB.TexNameList = #()-- Names to all Textures in same Order

       append BtlcTextDB.Folders  GenericTxdPath
       append BtlcTextDB.Folders  (ExportCityPath + "\\txd")
       BtlcTextDB.FindAllTextures()
    ),

    fn ExportUsedObjs Outputpath = 
    (
        count = UsedObjs.count 
        fs = openfile Outputpath mode: "wt"
        for x = 1 to count do 
        (
            format(UsedObjs[x]+ "\n") to: fs
        )
        close fs
    ),

    fn ObjDeleteIfUnused IDEFile =
    (
        --read generatedIDE and take list of object names
        local   theFile = openfile IDEFile
        local  UsedObjs = #()
        if theFile != undefined then
        (
            while not eof theFile do
            (
                mystring = readline theFile
                mystring = filterString  mystring ", "
                if mystring[2] != undefined do mystring = toLower (mystring[2])
                append UsedObjs mystring
            )
            close theFile
            gc()
            free theFile
            -- dele te object not listed
            for obj in objects as array do 
            (
                theobjname = toLower (obj.name)
                IsUsed = finditem UsedObjs  theobjname
                if  IsUsed == 0  and obj.parent == undefined do 
                (
                  --  print obj.name
                    delete obj
                )        
            )
        )
    ),

    function CleanupFiles  =
    (
        Pathup = (pathConfig.removePathLeaf ExportCityPath) 
        MapPartName =  filenameFromPath ExportCityPath 
        ImgPath = ExportCityPath + "\\img"
        makeDir ImgPath

        /* Remove uncleaned ide file */
        deleteFile  (ExportCityPath + "\\" + MapPartName + ".ide")

        /* Move ipls into img folder */
        files = getFiles (Pathup + "\\" + MapPartName + "_stream*.ipl")  --maybe try to only find mapartname_stream*
        for f in files do 
        (
            Filename = filenameFromPath f
            Newpath = ImgPath + "\\" + Filename
            renameFile f Newpath
        )
        for f in files do 
        (
            deleteFile f
        )
    ),

    fn LoadMap = 
    (
        TheMap = ofio_BTLC_MassOPL()
        TheMap.MainPath =  ImportCityPath
        TheMap.LoadAll()
        UsedObjs = TheMap.UsedObjects
    ),

    fn GenerateData = 
    (    
        -- Gta Converter: create IDE, copy txds, gen ipls and copy txds
        ExportUsedObjs (ImportCityPath +  @"/Object.objs")

        /*Convert IDE*/
        local IDEFILE = (getfiles (ImportCityPath + ".IDE"))
        local IDStart =  StartId as string
        btlcDataConverter.ConvertIDE ("\"" + IDEFILE[1] + "\"") ("\"" + ExportCityPath + "/" + "\"") IDStart;
   
        /*Placement Converter*/
        btlcDataConverter.ConvertPlacementData ImportCityPath ExportCityPath;

        /*Copy Textures*/
        btlcDataConverter.CopyTextures ("\"" + ImportCityPath + "\\wtd" + "\"") ("\"" +ExportCityPath + "\\txd" + "\"");

        btlcConfig.UpdateCurrentID (ExportCityPath + ".ide")
    ),
	
	fn GenerateCollsion = 
    (
        /*Generate Col Meshes */
        MyObjs = #()
        allNames = #() 
        for i in objects do
        (
        if i.parent == undefined do  append MyObjs i
        )
        btlcCol.GenerateColMeshes MyObjs
        gc()
    ),
    
    fn BuildMap = 
    (
        TheMap.BuildAll();
        local IdeFile = (ExportCityPath  + ".ide")
        ObjDeleteIfUnused IdeFile
        start = timeStamp()
        GenerateCollsion();
        end = timeStamp()
        format "Collision: Processing took % seconds\n" ((end - start) / 1000.0)  
    ),

    fn Import = 
    (
        LoadMap();      -- load map data etc.
        GenerateData(); -- generate data ipl,ide , copy txd etc
        InitTexDb();    -- Run Texture Database to get correct textures
        BuildMap();      -- Build Map --
        CleanupFiles();

        freeSceneBitmaps();
        gc();
    ),

    fn Export = 
    (
        
        -- Export Models
        start = timeStamp();
        OutputPath = ExportCityPath + "\\img";
        btlcModelExport.ExportAllModels(OutputPath);

        end = timeStamp();
        format "Model Export: Processing took % seconds\n" ((end - start) / 1000.0)  
        gc();

        -- Collision Export
        start = timeStamp();
        MapPartName =  filenameFromPath ExportCityPath 
        Filepath = OutputPath + "\\" + MapPartName + ".col";
        btlcCol.ExportAllCollisions(Filepath);
        end = timeStamp();
        format "Collision Export: Processing took % seconds\n" ((end - start) / 1000.0)  
      
        freeSceneBitmaps() ; -- trying to free up memory
        gc();

        -- Build Txd
        start = timeStamp();
		TxdPath = ExportCityPath + "\\txd"
		Outpath = ExportCityPath + "\\img"
		btlcMagicTxd.GenerateTxds TxdPath OutPath
        end = timeStamp();
        format "Build Txds: Processing took % seconds\n" ((end - start) / 1000.0)  

       /* -- Build Final Img
        start = timeStamp();
        MapPartName =  filenameFromPath ExportCityPath
        IniPath = ExportCityPath + "\\" + MapPartName + ".ini"
        OutPath = (pathConfig.removePathLeaf ExportCityPath) 
        btlcImgBuild.BuildImg IniPath OutPath       
        end = timeStamp();
        format "Build Img: Processing took % seconds\n" ((end - start) / 1000.0)  
        */
        gc();
    )
)

BTLCCityConvert = Btlc_ConvertCity();


fn BTLC_TESTCONVERT =
(
    BTLCCityConvert = Btlc_ConvertCity()
    BTLCCityConvert.GenericTxdPath = @"F:\Modding\BTLC\02_GameData\SA_A\data\cdimages\gtxd"
    BTLCCityConvert.ImportCityPath = @"F:\Modding\BTLC\02_GameData\IV\data\maps\jersey\nj_liberty"
    BTLCCityConvert.ExportCityPath = @"F:\Modding\BTLC\02_GameData\SA_A\data\maps\jersey\nj_liberty"

    --BTLCCityConvert.ImportCityPath = @"F:\Modding\BTLC\02_GameData\IV\data\maps\manhat\manhat01"
    --BTLCCityConvert.ExportCityPath = @"F:\Modding\BTLC\02_GameData\SA_A\data\maps\manhat\manhat01"
    BTLCCityConvert.StartId = 1000;
    BTLCCityConvert.Import();
    BTLCCityConvert.Export();
)
