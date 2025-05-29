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
      
        try(deletefile Newpath)catch(print "error delating file")
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
        format "finished ide converter \n"
        /*Placement Converter*/
        btlcDataConverter.ConvertPlacementData ImportCityPath ExportCityPath;
        format "finished opl converter \n"
        /*Copy Textures*/
        btlcDataConverter.CopyTextures ("\"" + ImportCityPath + "\\wtd" + "\"") ("\"" +ExportCityPath + "\\txd" + "\"");
        format "finished Copy textures \n"
        btlcConfig.UpdateCurrentID (ExportCityPath + ".ide")
    ),
	
	fn GenerateCollsion = 
    (
        /*Generate Col Meshes */
        MyObjs = #()
        allNames = #() 
        for i in objects do
        (
            bIsLOd = getUserProp  i  "type" 
        if i.parent == undefined  do  append MyObjs i
        )
        btlcCol.GenerateColMeshes MyObjs delforbid:true
        gc()
    ),

    fn PaintLights = 
    (
        MapPartName =  filenameFromPath ExportCityPath 
        --autosave.tempDisable = true
        Numofobj = 0;
        FailCnt = 0;
        suspendEditing()
        do -- run this in a loop, cause with many objects in one go, assignvertexcolors gets slow. maybe this helps a  bit.
        (
           
            with undo off
            (
                with redraw off
                (
                   Numofobj =  btlcWorldLightPaint.PaintWorld() -- paint lights of lightsources on main models
                )
            )
            freeSceneBitmaps() 	
            gc()
            if Numofobj == -1 do  --try to reload scene if painting gets sooooo slow
            (
                print "PaintWorld got slow, relaoding scene..."
                FailCnt = FailCnt  + 1 
                saveMaxFile MapPartName
                sleep 5
                --resetMaxFile() #noPrompt
                gc()
                freeSceneBitmaps() -- trying to free up memory
                gc()
                loadMaxFile MapPartName quiet:true
                Numofobj == 1
            )
            if Numofobj == 0 do Numofobj = -2
            print Numofobj
            if FailCnt > 2 do quitmax #noprompt 
        ) while Numofobj > -2

        resumeEditing()
        redrawviews()
        saveMaxFile MapPartName	
        --    autosave.tempDisable = false
    ),

    fn CityLightSettings =  
    (
        for TheLight in Lights do 
        (
            if classof TheLight == GTA_Light do 
            ( -- We hide shadows of map gta Lights. is painted anyway
                TheLight.shadowSize =  0.0
                TheLight.shadowColorMultiplier = 0
                
                -- Increase Drawdistance of LOD Coronas.
                if TheLight.parent != undefined and (getUserProp  TheLight.parent  "type" ) == "LOD" do  TheLight.coronaFarClip = 700
            )
        )
    ),
    
    fn ApplyUVAnim =
    (
        MapPartName =  filenameFromPath ExportCityPath
        AnimPath = ImportCityPath + "\\wad\\" + MapPartName + ".oad"
        BtlcUVAnim = BTLC_UVAnim()
        IsAnim =  BtlcUVAnim.ImportAnim AnimPath
        if IsAnim > 0 do  BtlcUVAnim.ApplytoAllObjs()
    ),
    
    fn BuildMap = 
    (
        TheMap.BuildAll();
        local IdeFile = (ExportCityPath  + ".ide")
        format "Load map\n"
        TheMap.PlaceLodModels (ExportCityPath  + "_LOD.ipl")
        ObjDeleteIfUnused IdeFile
        format "lod map\n"

       
        ApplyUVAnim()

        CityLightSettings()
        start = timeStamp()
        PaintLights();
        end = timeStamp()
		format "WorldLightsPaint: Processing took % seconds\n" ((end - start) / 1000.0)  
       
     
        start = timeStamp()
        GenerateCollsion();
        end = timeStamp()
        format "Collision: Processing took % seconds\n" ((end - start) / 1000.0)  
    ),

    fn GenMyData = 
    (
        LoadMap();      -- load map data etc.
        GenerateData(); -- generate data ipl,ide , copy txd etc
        CleanupFiles();
    ),

    fn Import = 
    (
        GenMyData();
        InitTexDb();    -- Run Texture Database to get correct textures
        BuildMap();      -- Build Map --
        btlcIDEUtils.IVParticlestoModels (ImportCityPath + ".IDE")  -- Import Particles
        btlcIDEUtils.SetAlphaFlags (ExportCityPath  + ".ide") -- Find Decal Flags etc
        freeSceneBitmaps();
        gc();
    ),
    
    fn BuildTxd = 
    (
     -- Build Txd with Magictxd
        start = timeStamp();
        TxdPath = ExportCityPath + "\\txd"
        Outpath = ExportCityPath + "\\img"
        btlcMagicTxd.RunMagicTxd TxdPath OutPath
        end = timeStamp();
        format "Build Txds: Processing took % seconds\n" ((end - start) / 1000.0)  
        gc();
    ),

    fn BuildImg = 
    (
        start = timeStamp();
        MapPartName =  filenameFromPath ExportCityPath
        IniPath = ExportCityPath + "\\" + MapPartName + ".ini"
        OutPath = (pathConfig.removePathLeaf ExportCityPath) 
        btlcImgBuild.BuildImg IniPath OutPath       
        end = timeStamp();
        format "Build Img: Processing took % seconds\n" ((end - start) / 1000.0)  
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
