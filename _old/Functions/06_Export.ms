function GenerateObjList Outputpath= 
(
    things = #()
    for i in objects do
    (
        thingy = i.name
        appendIfUnique things thingy
    )
    count = things.count 
    fs = openfile Outputpath mode: "wt"
    for x = 1 to count do 
    (
        format(things[x]+ "\n") to: fs
    )
    close fs
)

fn writeCols f cols version = 
(
	for c in cols do writeCol f c version
)


function ExportCollision Filepath items = 
(
    myobjects = for obj in items where (classof obj == Editable_mesh) collect obj
    
    -- Make exported objects unique, dont export duplicates
    MyObjs = #()
    allNames = #() 
    for i in myobjects do
    (
      if findItem allNames i.name == 0  do 
      (
        append MyObjs i
        append allNames i.name 
      )
    )
    myobjects = MyObjs
    free allNames

    if myobjects.count>0 then 
    (
        f = fopen Filepath "wb"
        if f != undefined then 
        (
            writeCols f myobjects 3
            print "closestream"
            fclose f
        )
    )
)

function ExportModels dir lstItems =
(
    dffExp.prelight = 1
    dffExp.NodeNames = 1
    dffExp.normals = 1
    dffExp.skinning = 0
    dffExp.worldSpace = 0
    dffExp.FILEVERSION = 0x36003
    dffExp.extraColors = 1
    dffExp.Lighting  = 1
    dffExp.createHAnim = 0
  
  --  dir = MyConfig.CurrentSACityPart + "\\img"
 --   local lstItems = selection as array 
    
	for obj in lstItems as array  do
    (
       TheChilds= #()
        for Child in obj.children do append TheChilds Child

        for Child in TheChilds do 
        (
            if isCol Child == false do 
            (
                Child.parent = undefined  -- unparent Collsions for export
            ) 
         
        ) 
      
            select obj
           -- print dir
            dff =   dir  + "/" + obj.name + ".dff" 
          --  print dff
            exportfile dff #noprompt using:"DFF File Im-/Exporter" 

	   

       for Child in TheChilds do  Child.parent = obj -- parent Collsions after export
	)		
)
