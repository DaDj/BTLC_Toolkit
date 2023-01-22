for Obj in selection do 
(
    meshop.setMapSupport Obj 3 true
    vcnum = meshop.getNumMapVerts Obj 0 
    meshop.setNumMapVerts Obj 3 vcnum
)