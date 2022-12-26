struct ofio_OPL_Placement
(
    modelname,
    pos = [0,0,0],
    rot  = quat 0 0 0 0
)

struct ofio_BTLC_OPL
(
    Path = "",
    placements = #(),
    ModelPath = "",
    LoadDuplicates = false,
    usedobjs = #(),

    fn Load ObjectsInFolder =
    (
        fs = openFile Path
        while not eof fs do
        (
            line = readline fs
            if line == "inst" do 
            (
                local i_instance = 1
                while line != "end" do 
                (
                    line = readline fs
                    if line == "end" then exit
                    LineData = filterString line ","
                    Modelname = (substituteString LineData[8] " " "")
                    Modelname = toLower(Modelname)
                    isUsed = findItem ObjectsInFolder Modelname
                    if   (isUsed != 0) then 
                    (
                        appendIfUnique usedobjs Modelname
                        placements[i_instance] = ofio_OPL_Placement()
                        placements[i_instance].pos.x  = LineData[1] as float
                        placements[i_instance].pos.y  = LineData[2] as float
                        placements[i_instance].pos.z  = LineData[3] as float
    
                        placements[i_instance].rot.x  = -1*(LineData[4] as float)
                        placements[i_instance].rot.y  = -1*(LineData[5] as float)
                        placements[i_instance].rot.z  = -1*(LineData[6] as float)
                        placements[i_instance].rot.w  = LineData[7] as float
                        placements[i_instance].modelname = substituteString LineData[8] " " ""

                        i_instance  += 1
                    )    
                ) 
            )
           
        )
        close fs
    ),
    fn Build = 
    (
        objNames = #()
        for Singleone in placements do 
        (
            if findItem objNames Singleone.modelname == 0  do 
            (
                append objNames Singleone.modelname 
                Modelfile = (getfiles (ModelPath + "\\" + Singleone.modelname + ".odr"))
                if ( Modelfile[1] != undefined) then 
                (
                    local dr = ofio_iv_odr()
                    dr.read(Modelfile[1])
                    dr.TexDir  = @"F:\Modding\BTLC\02_GameData\IV\data\maps\manhat\manhat01\wtd\"
                    ThisObj =  dr.build()
                   -- objID = amax (for o in objects collect o.inode.handle) 
                   -- Object =  maxOps.getNodeByHandle objID
                   -- if ThisObj.name.count >  19 do print ThisObj.name
                   -- if ThisObj.name.count >  19 do ThisObj.name = substring ThisObj.name 1 19 --move into importer
                    ThisObj.pos = Singleone.pos
                    rotate ThisObj  Singleone.rot
                    gc()
                )
            )         
        )
        gc()
    )
)

struct ofio_BTLC_MassOPL
(
    MainPath = "",
    Filepaths = #(),
    ObjectsInFolder = #(),
    UsedObjects = #(),
    LodObjectsinFolder = #(),
    OPls = #(),
    fn FindFilepaths  = -- Get all the files
    (
        fl = MainPath + "/wpl"
        Filepaths = (getfiles (fl + "\\*.opl"))
		MainFile = (getfiles (MainPath + ".opl"))
		Filepaths = Filepaths + MainFile
        gc()
    ),

    fn FindModels = 
    (
        ObjectsInFolder = getFiles (MainPath +"\\wdr\\"+ "*.odr")
        local myidx = 1
        for obj in ObjectsInFolder do 
        (
            ObjectsInFolder[myidx] = toLower (getFilenameFile obj)
			myidx+= 1
        )
    ),

    fn FindLodModels = 
    (
        LodObjectsinFolder = getFiles (MainPath +"\\wdd\\"+ "*.odd")
        local myidx = 1
        for obj in LodObjectsinFolder do 
        (
            LodObjectsinFolder[myidx] = toLower (obj)
			myidx+= 1
        )
    ),

    fn BuildLodModels = 
    (
        for obj in LodObjectsinFolder do 
        (
            local dr = ofio_iv_odd()
            dr.read(obj)
             dr.build()
        )
      
    ),

    fn LoadAll =
    (
        start = timeStamp()
        --suspendEditing()
        with undo off
        (
            with redraw off
            (
                FindModels()
                FindFilepaths()

                -- Load Data
               local i_opls = 1
                for file in Filepaths do
                (	
                    MYOPl = ofio_BTLC_OPL()
                    MYOPl.ModelPath = MainPath + "\\wdr"
                    MYOPl.Path = file
                    MYOPl.Load ObjectsInFolder
                    --print OPls[i].usedobjs
                    for theobj in MYOPl.usedobjs do appendIfUnique UsedObjects theobj
                    append OPls MYOPl
                    i_opls += 1
                )
            )
            FindLodModels()
        )
        --resumeEditing()
        redrawviews()
        --freeSceneBitmaps() 	
        --gc()
        end = timeStamp()
        format "Load Opls: Processing took % seconds\n" ((end - start) / 1000.0)  
    ),

    fn BuildAll =   -- Build Models etc
    (
        start = timeStamp()
        suspendEditing()
        with undo off
        (
            with redraw off
            (
                for OPL in OPls do 
                (
                  OPL.Build() -- Loading Main Models
                )

                BuildLodModels() -- Load the corresponding LOds
            )
        )
        resumeEditing()
        redrawviews()
        freeSceneBitmaps() 	
        gc()
        end = timeStamp()
        format "Building Models: Processing took % seconds\n" ((end - start) / 1000.0)  
    )
)

