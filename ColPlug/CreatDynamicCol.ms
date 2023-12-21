fileIn ("io.ms") quiet:true
fileIn ("utils.ms") quiet:true
fileIn ("colOut.ms") quiet:true
fileIn ("collision.ms") quiet:true

fn computeConvexHull theNode maxVerts:64 pushAmt:-10.0 cleanup:true = 
(
    with redraw off (
        local rb = MassFX_RBody()
        select theNode
        local cmdMode = getCommandPanelTaskMode()		-- store previous mode
        setCommandPanelTaskMode #modify
        addModifier theNode rb
        rb.meshVerticesLimit  = maxVerts
        rb.meshType = 4  		-- 3 = capsule, 4 = convex
        rb.meshInflation = pushAmt
        rb.RBMeshRegenerate 1
        hull = rb.RBMeshConvertToCustomMesh 1
        if isValidNode hull then (
            hull.name += "_Hull"
        -- RBMeshCustomNodeExtract 
        )
        if cleanup then (
            deleteModifier theNode 1
            setCommandPanelTaskMode cmdMode		-- restore previous mode
        )
    )
    hull
)

fn CreatDynamicCol ObjectMesh maxVert:16 push:-5.0= 
(
   TheHull =  computeConvexHull ObjectMesh maxVerts:maxVert pushAmt:push
   TheHull.parent = ObjectMesh
   custattributes.add TheHull ColMesh
   convertToMesh  TheHull
   i_verts = meshop.getNumVerts TheHull
   for idx_vert = 1 to i_verts do 
   (
    Thepos = meshop.getVert TheHull idx_vert
    s= Collision_Sphere  pos:Thepos
    s.delegate.radius = 0.05
    s.name = TheHull.name+"_sp" 
    s.wirecolor =  color 50 210 250
    s.parent = ObjectMesh
   )
   delete TheHull
)


for obj in selection do CreatDynamicCol obj 