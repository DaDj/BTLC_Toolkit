struct btlc_VertexPaint
(
    fn SetEmmissePrelightMaterial Obj MtlID = 
    ( 
		ch_Day = 0 -- (0 - vertex color)
        ch_Night = -1 --  (-1 - vert illum)
        
        for f=1 to Obj.numfaces where (getFaceMatID Obj f) == MtlID do 
        (
            meshop.setFaceColor Obj ch_Night f  (color 255 255 255 255)
            meshop.setFaceColor Obj ch_Day f (color 255 255 255 255)
        )
    ),

    fn SetEmmissivePrelight Obj =
    ( 
           /* Uses the shader  from IV to set every emissive Faces to White
            This helps making for example night lights and glowing stuff at night.*/
       
            if (classof obj.Material) == Multimaterial do 
            (
                for MtlID= 1 to Obj.Material.MaterialList.Count do
                (
                    if Obj.Material.MaterialList[MtlID] != undefined then
                    (   
                        Shader = custAttributes.get Obj.Material.MaterialList[MtlID] BTLC_MatShader 
                        if ((findstring Shader.MyShaderName "emissive")  != undefined) do  SetEmmissePrelightMaterial Obj MtlID				
                    )
                )
            )
            if (classof obj.Material) == RW_Mtl do 
            (
                Shader = custAttributes.get Obj.Material BTLC_MatShader 
                if ((findstring Shader.MyShaderName "emissive")  != undefined) do  SetEmmissePrelightMaterial Obj 1
            ) 
    
        
     
    ),
    -- Prelights Model with respect for Emissives = white
    fn PrelightModel Obj= 
    (
        converttomesh  Obj	  
        update Obj
        ch_Day = 0 -- (0 - vertex color)
        ch_Night = -1 --  (-1 - vert illum)
        

        bPrelight = getUserProp  Obj  "BTLC_PrelightApplied" 
        
        meshop.setMapSupport Obj ch_Night true
        vcnum = meshop.getNumMapVerts Obj ch_Day 
        meshop.setNumMapVerts Obj ch_Night vcnum
        
        vcfaces = meshop.getNumMapFaces Obj ch_Day 
        meshop.setnummapfaces Obj ch_Night vcfaces
        
        /* Makes the Prelight in grayscale(sometimes imported VC is pink) 
        Makes the Color little bit dark in general and creates the Night VC*/
        if (bPrelight == undefined) then
        (
            for i = 1 to vcnum do 
            (
                my_color = meshop.getMapVert Obj ch_Day  i 
                my_color2 = (my_color*0.6*255) as color 
                my_color2.saturation = 0
                my_color_Night = (my_color2*0.1)
                meshop.setMapVert Obj ch_Day  i (my_color2/255)
                meshop.setMapVert Obj ch_Night i (my_color_Night/255)
            )
            for i = 1 to vcfaces do 
            (
                meshop.setMapFace Obj ch_Night i (meshop.getMapFace Obj ch_Day  i) 
            )
            /* Read the shader of the texture and paints the night vertex bright if emissive */
            SetEmmissivePrelight Obj

            setuserprop Obj  "BTLC_PrelightApplied" 1
        )

    
    ),

    --Moves the Alpha of the objects to Channel 9 for Dff exporter
    fn MoveAlphaChannel Obj = 
    (
        converttomesh  obj	  
        update obj
        
        CHVertex_Alpha = 9
        ChVertexAlpha3dsmax = -2;
        meshop.setNumMaps obj 10 keep:true
        meshop.setMapSupport obj CHVertex_Alpha true
        
        vcnum = meshop.getNumMapVerts obj ChVertexAlpha3dsmax 
        meshop.setNumMapVerts obj CHVertex_Alpha vcnum
        
        vcfaces = meshop.getNumMapFaces obj ChVertexAlpha3dsmax 
        meshop.setnummapfaces obj CHVertex_Alpha vcfaces

        for i = 1 to vcnum do meshop.setMapVert obj CHVertex_Alpha i ( meshop.getMapVert obj ChVertexAlpha3dsmax  i )
        for i = 1 to vcfaces do meshop.setMapFace obj CHVertex_Alpha i (meshop.getMapFace obj ChVertexAlpha3dsmax  i) 
        update obj
    )
)
btlcVertexPaint = btlc_VertexPaint();