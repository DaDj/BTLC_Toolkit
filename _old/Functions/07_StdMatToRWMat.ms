function StdMattoRWMat m = 
(
    if (classof m) == Multimaterial do 
    (
        for i = 1 to m.materialList.count do
        (
            if m.materialList[i] != undefined do
            (
                m.materialList[i] = StdMattoRWMat m.materialList[i]
                        
            )
                
        )
        return m
    )

    if (ClassOf m) == Standard then 
    (
        rw = RW_Mtl()
        rw.sp_ambient  = 1.0
        rw.sp_specular = 1.0 
        rw.sp_diffuse  = 1.0
        rw.color = color 255 255 255 255
        rw.texmap_texture = m.diffuseMap 
        rw.delegate.shaderType = 1;
        if rw.delegate.diffuseMap != undefined do
                rw.delegate.diffuseMap.color1 = rw.color*rw.sp_diffuse
    
        rw.delegate.diffuse = rw.color*rw.sp_diffuse
    
        if m.reflectionMap != undefined do
        (
            rw.enEnv = true
            rw.shininess = 0.25
            rw.matfxeffect = 3
            rw.texmap_envmap = m.reflectionMap
            rw.envmap_amount = 0.5
        ) 
        rw.showInViewport = true
       return rw --return material
    )
    return m 
)


function Objs_StdtoRW Objs = 
(
    for o in Objs do (
        o.material = StdMattoRWMat o.material
    )
)