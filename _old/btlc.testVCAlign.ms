--https://help.autodesk.com/view/MAXDEV/2024/ENU/?guid=GUID-CBBA20AD-F7D5-46BC-9F5E-5EDA109F9CF4


fn ReduceMapVerts  TheMesh mapChannel ColorTresh = 
(
	for vertId = 1 to meshop.getNumVerts TheMesh do 
	(
		TheFaces = meshop.getFacesUsingVert TheMesh #{vertId}
		VertColorFaceArray = #()
		VertIdxFaceArray = #()
		for TheFace in TheFaces do 
		(
			local vertIndices = getFace TheMesh TheFace
			local vertColorIndices = meshop.getMapFace TheMesh mapChannel TheFace
				
			for idxFaceVert = 1 to 3 do 
			(
				if vertIndices[idxFaceVert] == vertID do 
				(
					ThevertCol =  meshop.getMapVert TheMesh mapChannel vertColorIndices[idxFaceVert]
					idxMatch = 0
					MatchedColor = false
					for VertFaceColor in VertColorFaceArray while MatchedColor == false do 
					(
						idxMatch = idxMatch + 1
						ColorDist = distance  VertFaceColor ThevertCol
						if ColorDist < ColorTresh do  MatchedColor = true
					)
							
					if MatchedColor == true then 
					(
						vertColorIndices[idxFaceVert] = VertIdxFaceArray[idxMatch]
						meshop.setMapFace TheMesh mapChannel TheFace vertColorIndices
					)
					else 
					(
						append VertColorFaceArray ThevertCol
						append VertIdxFaceArray vertColorIndices[idxFaceVert]
					)
				)
			)
		)
	)
	meshop.deleteIsoMapVertsAll TheMesh
)




TheMesh = copy selection[1]
mapChannel = -1;
ColorTresh = 0.002;

ReduceMapVerts  TheMesh mapChannel ColorTresh

