function isCol obj=
(
    isit = false
    if (classof obj != GTA_Light) do 
	if ( (isProperty obj #isShadow ) == true) or ((custattributes.get obj TheColMesh != undefined)  and (custattributes.get obj TheColMesh) == true) then isit =true

    isit
)