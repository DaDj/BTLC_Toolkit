struct Childdef
(
    Obj,
    Childs = #()
)


if versions==undefned then
(
	global versions=#(0x1803FFFF, 0xC02FFFF, 0x800FFFF)
)

struct Btlc_Modelexport 
(
    fn getMyDffData TheObjs = (

       
        objects = for obj in TheObjs where (canExport obj) collect obj
        if objects.count>0 then (
            atomics=#()
            bones=#()
            hAnimTable=#()
            for i = 1 to objects.count do (
           
                if (superclassof (objects[i]) == GeometryClass) then append atomics (#(i, undefined))
                if useAnimation (objects[i]) then(
                    bones[i]=#(objects[i].id)
                    if (hAnimTable.count==0) then bones[i][2]=hAnimTable
                    append hAnimTable (getAnimEntry (objects[i]))
                )
            )
            if (hAnimTable.count==0) then bones=undefined
            
            return #(objects, atomics, bones)
        )
        return undefined
    ),

    function ExportObj Obj Path = 
    (
        --here we check if it is a multiclump model, becuase we have to export it differently
        windfx = false
        isMulticlump = false
        ClumpMdl = undefined
        ClumpMdlDmg = undefined
        domulti = false

      --  Obj = copy TheObj
        btlcVertexPaint.OptimzeMapChannels Obj
 

            expData=getMyDffData Obj
         
            if (getUserProp Obj "windfx") == "yes" do windfx = true
            if expData!=undefined then (
                doExtraColor = true;
                doUVAnim = true;
                doNormals = true;
    
            
                f =  fopen Path "wb"
                if f != undefined then 
                (
                    if (1)and( doUVAnim ) then writeUVAnimationDictionary f expData[1] expData[2]
                    writeClump f expData[1] expData[2] doExtraColor doNormals versions[1] bones:(expData[3])  iswindfx:windfx
                    fclose f
                )
            )
        
        btlcUtil.WeldVertices Obj 0.0001
       -- delete Obj
    ),


    function ExportModels dir lstItems =
    (
        for obj in lstItems as array  do
        (
            TheChilds= #()
            Childdefs = #()
            for Child in obj.children do append TheChilds Child

            for Child in TheChilds do 
            (
                if (btlcCol.isCol Child) == true do  Child.parent = undefined  -- unparent Collsions for export
                if (getUserProp Child "breakmdl") == "breakable"  do  Child.parent = undefined  -- unparent breakable for export

                if Child.children.count > 0 do 
                (
                    theThing = Childdef()
                    append Childdefs theThing
                    Childdefs[Childdefs.count].Obj = Child

                    for ChildChild in Child.children do 
                    (
                        append Childdefs[Childdefs.count].Childs ChildChild
                        ChildChild.parent = undefined
                    )
                )
               
            ) 
                --select obj
                Fielpath =  dir  + "/" + obj.name + ".dff" 
                ExportObj obj Fielpath

        for Child in TheChilds do  Child.parent = obj -- parent Collsions after export

        for ADef in Childdefs do 
        (
            for AChild in ADef.Childs do 
            (
                AChild.parent = ADef.obj
            )
        )

        )		
    ),

    function ExportAllModels OutputPath = 
    (
        local MyObjs = #()
        for i in objects as array  do 
        (
            if (btlcCol.isCol i) == false and (i.parent == undefined) do append MyObjs i
        ) 
        MyObjs =  makeUniqueArray MyObjs
        ExportModels OutputPath MyObjs
    )

)
btlcModelExport = Btlc_Modelexport()