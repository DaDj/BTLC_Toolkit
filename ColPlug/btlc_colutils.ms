function isCol obj=
(
    isit = false
    if ((isProperty obj #isShadow ) == true) or ((custattributes.get obj TheColMesh) == true) then isit =true

    isit
)
