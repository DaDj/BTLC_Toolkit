struct btlc_WorldLightPaint
(
    TheLightObjs = #(),

    fn LoadLightObjs = --Loads light objs as omni to provide lights
    (

    ),

    fn UnloadLightObjs = -- Unloads the lightobjects again 
    (
        -- just delete all dummies + children with the names of the lightobjects. simple as that.
    ),

    fn PaintWorld = 
    (
        for obj in objects do 
        (
            if iskindof obj Editable_mesh do  btlcVertexPaint.PaintWorldLights obj
        )
    )
)
btlcWorldLightPaint = btlc_WorldLightPaint();