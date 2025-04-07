struct btlc_VertexPaint
(	
	fn averageColor colors = 
	(		
		local sum = Point3 0 0 0
		for c in colors do
			sum += c
		sum / colors.count
	),

	fn unifyVC TheMesh mapChannel = 
	(		
		 
		local vertexColors = for v = 1 to TheMesh.numVerts collect
			#()
		for f = 1 to TheMesh.numFaces do
		(			
			local vertIndices = getFace TheMesh f
			local vertColorIndices = meshop.getMapFace TheMesh mapChannel f
			for v = 1 to 3 do
				append vertexColors[vertIndices[v]]( meshop.getMapVert TheMesh mapChannel vertColorIndices[v] )
		)
		meshop.setNumMapVerts TheMesh mapChannel TheMesh.numVerts
		meshop.defaultMapFaces TheMesh mapChannel
		for v = 1 to vertexColors.count do
			meshop.setMapVert TheMesh mapChannel v( averageColor vertexColors[v] )

	),

	-- Checks if verts are below 65k Vertices limit and fits them if needed
	fn OptimzeMapChannels Obj = 
	(	
		--btlcUtil.WeldVertices Obj 0.01	

		if ( meshop.getNumMapVerts Obj -1 ) > 45000 do 
		(
			ReduceMapVerts Obj -1 0.009  --high threshold to weld more colors together
			if ( meshop.getNumMapVerts Obj -1 ) > 45000 do unifyVC Obj -1
		)

		if ( meshop.getNumMapVerts Obj 0 ) > 45000 do 
		(
			ReduceMapVerts Obj 0 0.009 --high threshold to weld more colors together
			if ( meshop.getNumMapVerts Obj 0 ) > 45000 do unifyVC Obj 0
		)
		--unifyVC Obj -2 -- always reduce the alphamap. duh
	),
	
	fn ReduceMapVerts TheMesh mapChannel ColorTresh = 
	(		
		for vertId = 1 to meshop.getNumVerts TheMesh do
		(			
			TheFaces = meshop.getFacesUsingVert TheMesh #{ vertId }
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
						ThevertCol = meshop.getMapVert TheMesh mapChannel vertColorIndices[idxFaceVert]
						idxMatch = 0
						MatchedColor = false
						for VertFaceColor in VertColorFaceArray
						while
							MatchedColor == false do
						(							
							idxMatch = idxMatch + 1
							ColorDist = distance VertFaceColor ThevertCol
							if ColorDist < ColorTresh do
								MatchedColor = true
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
	),

	fn ReduceMapVertsObjects Objs = 
	(
					/*    start = timeStamp();
			btlcUtil.ReduceVertsforAllModels()
			end = timeStamp();
			format "Processing took % seconds\n" ((end - start) / 1000.0) */
		for Obj in Objs do
		(
			btlcUtil.WeldVertices Obj 0.01
			ReduceMapVerts Obj -1 0.002
			ReduceMapVerts Obj 0 0.002
		)
	),

	fn SetEmmissePrelightMaterial Obj MtlID = 
	(		
		ch_Day = 0 -- (0 - vertex color)
		ch_Night = -1 --  (-1 - vert illum)
		for f = 1 to Obj.numfaces
		where( getFaceMatID Obj f )== MtlID do
		(			
			meshop.setFaceColor Obj ch_Night f( color 255 255 255 255 )
			--   meshop.setFaceColor Obj ch_Day f (color 255 255 255 255) --should we do the day prelight? looks a little bit weird to be honest
		)
	),
	fn SetEmmissivePrelight Obj = 
	(		
		/* Uses the shader  from IV to set every emissive Faces to White
		          This helps making for example night lights and glowing stuff at night.*/
		if( classof obj.Material )== Multimaterial do
		(			
			for MtlID = 1 to Obj.Material.MaterialList.Count do
			(				
				if Obj.Material.MaterialList[MtlID] != undefined then
				(					
					Shader = custAttributes.get Obj.Material.MaterialList[MtlID] BTLC_MatShader
					if( Shader != undefined and( findstring Shader.MyShaderName "emissive" )!= undefined ) do
						SetEmmissePrelightMaterial Obj MtlID
				)
			)
		)
		if( classof obj.Material )== RW_Mtl do
		(			
			Shader = custAttributes.get Obj.Material BTLC_MatShader
			if( Shader != undefined and( findstring Shader.MyShaderName "emissive" )!= undefined ) do
				SetEmmissePrelightMaterial Obj 1
		)
	),
	fn PaintWorldLights Obj = 
	(
		-- Renders the lights onto the night prelight
		converttomesh Obj
		v = PaintLayerMod()
		addModifier Obj v
		-- Obj.showVertexColors = on
		v.layerMode = "Lighten"
		v.useMaps = true
		v.mapChannel = -1
		v.colorBy = 1
		try( AssignVertexColors.ApplyNodes Obj vertexPaint: v ) catch()
		converttomesh Obj
		update Obj
		ReduceMapVerts Obj -1 0.002
	),
	
	-- Prelights Model with respect for Emissives = white
	fn PrelightModel Obj = 
	(		
		converttomesh Obj
		update Obj
		ch_Day = 0 -- (0 - vertex color)
		ch_Night = -1 --  (-1 - vert illum)
		bPrelight = getUserProp Obj "BTLC_PrelightApplied"
		meshop.setMapSupport Obj ch_Night true
		vcnum = meshop.getNumMapVerts Obj ch_Day
		meshop.setNumMapVerts Obj ch_Night vcnum
		vcfaces = meshop.getNumMapFaces Obj ch_Day
		meshop.setnummapfaces Obj ch_Night vcfaces
		/* Makes the Prelight in grayscale(sometimes imported VC is pink) 
		      Makes the Color little bit dark in general and creates the Night VC*/
		if( bPrelight == undefined ) then
		(			
			for i = 1 to vcnum do
			(				
				my_color = meshop.getMapVert Obj ch_Day i
				my_color2 = ( my_color * 0.6 * 255 ) as color
				my_color2.saturation = 0
				my_color_Night = ( my_color2 * 0.15 )
				meshop.setMapVert Obj ch_Day i( my_color2 / 255 )
				meshop.setMapVert Obj ch_Night i( my_color_Night / 255 )
			)
			for i = 1 to vcfaces do
			(				
				meshop.setMapFace Obj ch_Night i( meshop.getMapFace Obj ch_Day i )
			)
			/* Read the shader of the texture and paints the night vertex bright if emissive */
			SetEmmissivePrelight Obj
			setuserprop Obj "BTLC_PrelightApplied" 1
		)
	),
	--Moves the Alpha of the objects to Channel 9 for Dff exporter
	fn MoveAlphaChannel Obj = 
	(		
		converttomesh obj
		update obj
		CHVertex_Alpha = 9
		ChVertexAlpha3dsmax = -2
		meshop.setNumMaps obj 10 keep: true
		meshop.setMapSupport obj CHVertex_Alpha true
		vcnum = meshop.getNumMapVerts obj ChVertexAlpha3dsmax
		meshop.setNumMapVerts obj CHVertex_Alpha vcnum
		vcfaces = meshop.getNumMapFaces obj ChVertexAlpha3dsmax
		meshop.setnummapfaces obj CHVertex_Alpha vcfaces
		for i = 1 to vcnum do
			meshop.setMapVert obj CHVertex_Alpha i( meshop.getMapVert obj ChVertexAlpha3dsmax i )
		for i = 1 to vcfaces do
			meshop.setMapFace obj CHVertex_Alpha i( meshop.getMapFace obj ChVertexAlpha3dsmax i )
		update obj
	),

	fn PaintWindMatiID Obj MtlID = 
	(		
		for f = 1 to Obj.numfaces
		where( getFaceMatID Obj f )== MtlID do
		(			
			meshop.setFaceColor Obj -2 f( color 230 230 230 255 )
			meshop.setFaceColor Obj 9 f( color 230 230 230 255 )
		)
	)
)
btlcVertexPaint = btlc_VertexPaint()