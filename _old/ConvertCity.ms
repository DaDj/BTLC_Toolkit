function ConvertCity_CutObjNames = 
(
    /*Cut Objectsnames to SA*/
     
    for obj in objects do 
    (
        obj.name =  substituteString  obj.name "_high_0" ""  --Delete :high_0 of animated objects

        if obj.name.count >  19 do
        (	
            newname =  substring obj.name 1 19
           -- print( i.name +  " --> " + newname)
           obj.name =newname
        )    
    ) 
)

function ObjDeleteIfUnused IDEFile =
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
    -- delte object not listed
       for obj in objects as array do 
        (
            theobjname = toLower (obj.name)
             IsUsed = finditem UsedObjs  theobjname
            if  IsUsed == 0 do 
            (
                print obj.name
                delete obj
            )        
        )
    )
)

function CleanupFiles Citypartpath =
(
    Pathup = (pathConfig.removePathLeaf Citypartpath) 
    MapPartName =  filenameFromPath MyConfig.CurrentSACityPart 
    ImgPath = Citypartpath + "\\img"
    makeDir ImgPath

    /* Remove uncleaned ide file */
    deleteFile  (Citypartpath + "\\" + MapPartName + ".ide")

    /* Move ipls into img folder */
    files = getFiles (Pathup + "\\*stream*.ipl") 
    for f in files do 
    (
        Filename = filenameFromPath f
        Newpath = ImgPath + "\\" + Filename
        renameFile f Newpath
    )
)

function CityExport =
(
    gc()
    OutputPath = MyConfig.CurrentSACityPart + "\\img"
    makeDir OutputPath

    /* Generate .dffs*/
    local MyObjs = #()
    for i in objects as array do if (isCol i) == false do append MyObjs i
    MyObjs =  makeUniqueArray MyObjs
    ExportModels OutputPath MyObjs

    /* Export Collision to .col file */
    MapPartName =  filenameFromPath MyConfig.CurrentSACityPart 
    Filepath = OutputPath + "\\" + MapPartName + ".col"
    ExportCollision Filepath MyObjs

    /* Generate .txds */
    OutputPath = MyConfig.CurrentSACityPart + "\\img"
    TxdPath = MyConfig.CurrentSACityPart + "\\txd"
    GenerateTxds TxdPath OutputPath


    messageBox "Pause for txd to finish"
    /* Build final .img*/
    mypath = MyConfig.CurrentSACityPart + "\\" + MapPartName + ".ini"
    BuildImg_WirteIni mypath
    BuildImg mypath (pathConfig.removePathLeaf MyConfig.CurrentSACityPart) 

)

function CityImportandPrepare StartID =
(
    MapPartName =  filenameFromPath MyConfig.CurrentSACityPart 
    /*Import Current CityPart */
    path =  MyConfig.CurrentCityPart
    ImportProgress path  MassImport:true

    /*Cut Objectsnames to SA*/
    ConvertCity_CutObjNames()
    gc()

    /*Convert IDE*/
    local IDEFILE = (getfiles (path + ".IDE"))
    local IDEFileName = filenameFromPath IDEFILE[1]
    local IDStart = StartID as string
    ConvertIDE ("\"" + IDEFILE[1] + "\"") ("\"" + MyConfig.CurrentSACityPart  + "/" + "\"") IDStart

    /*Convert the WPLs to SA Placement*/
    Outputpath =  MyConfig.CurrentCityPart +  @"/Object.objs"
    GenerateObjList Outputpath
    Convert_MapConvert()  -- convert the wpls 
    gc()

    /*Copy Textures from wtd and cut them */
    CopyTextures  ("\"" + MyConfig.CurrentCityPart + "\\wtd" + "\"") ("\"" + MyConfig.CurrentSACityPart + "\\txd" + "\"")

    --Import LODS and filter  out unused 
    local ModelFolder = MyConfig.CurrentCityPart + "\\wdd"
    local mymode = bit.set wplmode 2 true 
    local textdir = getpathsDefinedPath mymode
    textdir = textdir[2]
    ImportLodModels  ModelFolder textdir[1]
    free ModelFolder
    free mymode
    free textdir
    free IDEFILE
    free IDEFileName
    free path

    ConvertCity_CutObjNames() --again for LoDs, needs to be 2 fucntion. eralier is used for objlist
    gc()
    gc()
    --Remove unused Models 
    local IdeFile = (MyConfig.CurrentSACityPart  + ".ide")
    ObjDeleteIfUnused IdeFile

    /*Update Texturepaths*/
    MassUpdateTextures() -- after map convert because mapconverter also converts images inside models
    gc()

    /*Generate Col Meshes */
    MyObjs = #()
    allNames = #() 
    for i in objects do
    (
      if i.parent == undefined do  append MyObjs i
    )
    GenerateColMeshes MyObjs
    gc()
    
    /*Convert Models to RW Material to support reflections*/
    MyObjs = #()
    for i in objects do
    (
      if (isCol i) == false do append MyObjs i
    )
    Objs_StdtoRW MyObjs

    /*Clean up tempfiles and move ipls in IMG*/
    CleanupFiles  MyConfig.CurrentSACityPart
    freeSceneBitmaps()  -- trying to free up memory
    for obj in objects do 
		(
		    unhide obj
		    if  (classof  obj == Collision_Sphere)then 	hide obj
			if  (classof  obj == Collision_Box)then  	hide obj
			if  (isCol obj == true)  then hide obj
		)
    gc()
    gc()
)





