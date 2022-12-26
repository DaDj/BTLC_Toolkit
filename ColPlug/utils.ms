
function isCol obj=
(
    isit = false
    if ((isProperty obj #isShadow ) == true) or ((custattributes.get obj TheColMesh) == true) then isit =true

    isit
)

fn enableEdges msh id = (
	for i = 1 to 3 do setEdgeVis msh id i true
)

fn disableBox theNode =(
	theNode.showlinks=true
	theNode.showLinksOnly=true
)

fn deleteIsolated msh= (
	meshop.deleteIsoVerts msh
	meshop.deleteIsoMapVertsAll msh
)

fn appendToSet arr v= (
	idx=findItem arr v
	if idx==0 then (
		append arr v
		return arr.count
	)
	return idx
)

fn getHierarchi obj arr=(
	append arr obj
	for c in obj.children do getHierarchi c arr
)

fn getTexture texName ext:"bmp"= (
	(bitmaptexture name:texName filename:(texName+"."+ext))
)

fn bitFlag mask idx = (
	((bit.and mask (bit.shift 1 idx))!=0)
)

fn bitMask flags= (
	mask=0
	for i = 1 to flags.count do (
		if (flags[i]) then mask+=(bit.shift 1 (i-1))
	)
	mask
)