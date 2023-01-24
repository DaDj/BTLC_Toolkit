struct Btlc_Modelexport 
(
    function SetExporterSettings =
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
    ),

    function ExportModels dir lstItems =
    (
        SetExporterSettings();
        
        for obj in lstItems as array  do
        (
            TheChilds= #()
            for Child in obj.children do append TheChilds Child

            for Child in TheChilds do 
            (
                if (btlcCol.isCol Child) == false do  Child.parent = undefined  -- unparent Collsions for export
            ) 
                select obj
            -- print dir
                dff =   dir  + "/" + obj.name + ".dff" 
            --  print dff
                exportfile dff #noprompt using:"DFF File Im-/Exporter" 

        for Child in TheChilds do  Child.parent = obj -- parent Collsions after export

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