struct btlc_StaticLightObj 
(
    Name = "Default",
    Position = [0,0,0],
    Direction = [0,0,0], -- if spot
    Color = (color 255 218 153 255),
    Type = "Spot",
    Distance  = 15.0,
    Range = 12.0,
    HotSpot = 25.0,
    Falloff = 60.0

)

struct btlc_WorldLightPaint
(
    TheLightObjs = #(),

    fn LoadLightObjs = --Loads light objs as omni to provide lights
    (
        TheLight  = btlc_StaticLightObj();
        TheLight.Name = "bm_wall_light_01"
        TheLight.Color = (color 255 218 153 0)
        TheLight.Position = [1.79, 0.0, 0.29]
        TheLight.Direction = [-0.087, 0.00,-0.99]
        TheLight.Type = "Spot"
        TheLight.Distance = 15.0
        TheLight.Range = 12.0
        TheLight.HotSpot = 25.0
        TheLight.Falloff = 60.0
        TheLightObjs[1] = TheLight;

        TheLight  = btlc_StaticLightObj();
        TheLight.Name = "bm_wall_light_02"
        TheLight.Color = (color 255 144 46 0)
        TheLight.Position = [0.0012, 0.24, 0.00]
        TheLight.Direction = [0.0, -1.00,-0.000]
        TheLight.Type = "Omni"
        TheLight.Distance = 8.0
        TheLight.Range = 8.0
        TheLight.HotSpot = 0.0
        TheLight.Falloff = 0.0
        TheLightObjs[2] = TheLight;

        TheLight  = btlc_StaticLightObj();
        TheLight.Name = "bm_wall_light_02_n"
        TheLight.Color = (color 255 144 46 0)
        TheLight.Position = [0.0012, 0.24, 0.00]
        TheLight.Direction = [0.0, -1.00,-0.000]
        TheLight.Type = "Omni"
        TheLight.Distance = 8.0
        TheLight.Range = 8.0
        TheLight.HotSpot = 0.0
        TheLight.Falloff = 0.0
        TheLightObjs[3] = TheLight;

        TheLight  = btlc_StaticLightObj();
        TheLight.Name = "bm_wall_light_03"
        TheLight.Color = (color 255 233 196 0)
        TheLight.Position = [0.01, -0.115, -0.08]
        TheLight.Direction = [0.0, -0.00,-1.000]
        TheLight.Type = "Omni"
        TheLight.Distance = 8.15
        TheLight.Range = 8.0
        TheLight.HotSpot = 0.0
        TheLight.Falloff = 0.0
        TheLightObjs[4] = TheLight;

        TheLight  = btlc_StaticLightObj();
        TheLight.Name = "bm_wall_light_04"
        TheLight.Color = (color 255 221 163 0)
        TheLight.Position = [-0.0022, -0.2993, 0.07]
        TheLight.Direction = [0.0, -0.76,-0.642]
        TheLight.Type = "Spot"
        TheLight.Distance = 11.0
        TheLight.Range = 12.0
        TheLight.HotSpot = 40.0
        TheLight.Falloff = 60.0
        TheLightObjs[5] = TheLight;

        TheLight  = btlc_StaticLightObj();
        TheLight.Name = "cj_et_dock_light"
        TheLight.Color = (color 255 221 163 0)
        TheLight.Position = [-0.001, 0.003, 20.953]
        TheLight.Direction = [0.0, 0.0,0.0]
        TheLight.Type = "Spot"
        TheLight.Distance = 45.0
        TheLight.Range = 45.0
        TheLight.HotSpot = 40.0
        TheLight.Falloff = 60.0
        TheLightObjs[6] = TheLight;
    ),

    fn UnloadLightObjs = -- Unloads the lightobjects again 
    (
        -- just delete all dummies + children with the names of the lightobjects. simple as that.
    ),

    fn PaintWorld = 
    (
        ObjCounter = 0; 
        Fail = false;
        for obj in objects do 
        (
            if ObjCounter < 250  do 
            (
                bPrelight = getUserProp  obj  "BTLC_Worldpaint" 
                NumOfInst = getNodeByName obj.name all:true 
                if NumOfInst.count < 2 and  bPrelight == undefined  and (isCol obj == false) do  -- only apply lights to uniqe models. Otherwise we have weird lightning if the model is placed multiple times.
                (
                    if iskindof obj Editable_mesh  do 
                    (   
                        bIsLOd = getUserProp  obj  "type" 
                     
                     for TheLight in lights do 
                        (   
                            TheLight.enabled = true;
                            LightParent = TheLight.parent;
                            IsLightLod = getUserProp  LightParent  "type" 
                            /* 
                            myDims = (obj.max - obj.min)
                            myDims = amax myDims[1] myDims[2] myDims[3]
                            Dist = distance TheLight.pos  obj.pos 
                            if Dist > (myDims + 30.0) do TheLight.enabled = false;   
                            */
                        
                            if  (bIsLOd != "LOD") and  (IsLightLod == "LOD") do TheLight.enabled = false;    
                           -- if  (bIsLOd == "LOD") and  (IsLightLod != "LOD") do TheLight.enabled = false;
                            
                        ) 
                        start = timeStamp()
                        btlcVertexPaint.PaintWorldLights obj
                        end = timeStamp()
                        
                        setuserprop obj  "BTLC_Worldpaint" 1
                        ObjCounter = ObjCounter + 1;

                        if  ((end - start) / 1000.0)  > 20 do
                        (
                            ObjCounter = 301
                            Fail = true
                            
                        )
                    ) 
                    freeSceneBitmaps() -- trying to free up memory
                    gc()
                    gc()
                    gc()
                )
               -- if NumOfInst.count > 1 do print obj.name
            )
        )
        if Fail == true do 
        (
            ObjCounter = -1
        )
        --saveMaxFile "temp"
        freeSceneBitmaps() -- trying to free up memory
        gc()
        ObjCounter
    )
)
btlcWorldLightPaint = btlc_WorldLightPaint();