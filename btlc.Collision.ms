struct Btlc_Collision 
(
	-- Get Col Material Ids based on Materialname
	fn set_COLMAT texture_name =
	(
		COL_MATERIALS = #("grass","pavement","road","metal","dirt","glass","path","water","window","wood","rustedmtl","railing","chrome","meshfencing","mesh","fence","soil","dc_pavement_plainvent01")
		COL_MATERIALS_ID = #(11,4,1,167,26,45,5,39,45,43,167,167,167,55,164,55,26)
		
		GRASS_ID = 80 --11
		PAVEMENT_ID = 4
		ROAD_ID = 1
		ROAD_FUCKED_ID = 2
		METAL_ID = 167
		DIRT_ID = 26
		PATH_ID = 5
		WATER_ID = 39
		GLASS_ID = 45
		WOOD_ID = 43
		
		MyID = 0
		for i in COL_MATERIALS do
		(
			test_mat = findstring texture_name i
			
			if test_mat != undefined and test_mat > 0 do
			(
				if i == COL_MATERIALS[1] do  MyID =  GRASS_ID --grass
				if i == COL_MATERIALS[2] do  MyID =  PAVEMENT_ID --pavement
				if i == COL_MATERIALS[3] do  MyID =  ROAD_ID--road
				if i == COL_MATERIALS[4] do  MyID =  METAL_ID --metal
				if i == COL_MATERIALS[5] do  MyID =  DIRT_ID--dirt
				if i == COL_MATERIALS[6] do  MyID =  GLASS_ID--glass
				if i == COL_MATERIALS[7] do  MyID =  PATH_ID--path
				if i == COL_MATERIALS[8] do MyID =  WATER_ID --water
				if i == COL_MATERIALS[9] do MyID = GLASS_ID --window
				if i == COL_MATERIALS[10] do MyID = WOOD_ID --wood
				if i == COL_MATERIALS[11] do MyID = METAL_ID--metal	
				if i == COL_MATERIALS[12] do MyID = METAL_ID --metal		
				if i == COL_MATERIALS[13] do MyID = METAL_ID --metal		
				if i == COL_MATERIALS[14] do MyID = METAL_ID --MEtalmeshfence		
				if i == COL_MATERIALS[15] do MyID = METAL_ID --MEtal (flor mesh) 	
				if i == COL_MATERIALS[16] do MyID = METAL_ID --Fence					
				if i == COL_MATERIALS[17] do MyID = DIRT_ID --Dirt/Soil		
				if i == COL_MATERIALS[18] do MyID = METAL_ID --Pavement vent metal	
			)
		)
		MyID
	),

	-- Delete Meshface of given ID
	fn deleteMeshFacesByMatID_Mesh node matID = 
	(
		if iskindof node Editable_Mesh do
		(
			if canconvertto node Editable_Mesh do converttomesh node
			faces = for f=1 to node.numfaces where (getFaceMatID node f) == matID collect f
			meshop.deletefaces node (faces as bitarray)
			update node
		)
	),
	--Find and delte materials of glue and stuff.
	fn DeleteForbiddenCollison node MtlID Material= 
	(
		Materialname = Material.name
		isgone = false
		MatsForbidden = #("MO_DC_Road_Markings_01MO_D","DC_Road_Markings_01DC_Road","MC_Glue_01MC_Glue_01_A","DC_Glue_01dc_glue_01_A","swnjdirt1")
		for i in MatsForbidden do
		(   
			test_mat = findstring  Materialname i
			if test_mat != undefined and test_mat > 0 do
			(
				deleteMeshFacesByMatID_Mesh node MtlID
				isgone = true
			)
		)
		isgone
	),

	fn ConvertMaterialtoCol Mat = 
	(
		if  Mat.name != undefined do
		(
			--texture_path = (filterString i.Material.MaterialList[MtlID].diffuseMap.filename	"\\")
			-- texture_name = substring 	texture_path[texture_path.count] 1 26
			COL_Material =  GTA_COLSurface name:Mat.name
			COL_Material.showInViewport = true;
			COL_Material.part =  -1
			COL_Material.surface =  set_COLMAT Mat.name
			
			COL_Material
			--i.Material.MaterialList[MtlID].diffu = 11
		)  
		COL_Material
	),

	-- Convert  Materials to CollisionMaterial
	fn StdMattoColMat TheObj = 
	(
		if 	(IsKindOf TheObj Editable_Mesh) and (((custattributes.get TheObj ColMesh)!=undefined) or (isProperty TheObj #isShadow) != undefined)  then 
		(
			TheObj.showVertexColors = false
			--i.Material = copy i.Material
			if (classof TheObj.Material) == Multimaterial do 
			(
				TheObj.Material= copy TheObj.Material
				for MtlID = 1 to TheObj.Material.MaterialList.Count do 
				(
					isgone =  DeleteForbiddenCollison TheObj MtlID TheObj.Material.MaterialList[MtlID] 
					
					if isgone == false do TheObj.Material.MaterialList[MtlID]  = ConvertMaterialtoCol TheObj.Material.MaterialList[MtlID] 
				)
			)
			if (classof TheObj.Material) == RW_Mtl do 
			(
				isgone = DeleteForbiddenCollison TheObj 1 TheObj.Material  
				TheObj.Material  = copy TheObj.Material  
				if isgone == false  do TheObj.Material  = ConvertMaterialtoCol TheObj.Material 
			)
			
		)
	),

	fn OptimizeColMesh obj = 
	(
		optimizer = optimize()
		addModifier obj optimizer
		optimizer.facethreshold1 = 4.0
		optimizer.edgethreshold1 = 1.0
		maxOps.CollapseNode obj 1
	),
	-- for Clean Col Mesh
	fn fn_getNarrowFace obj face degree = 
	(
		verts_ = meshop.getVertsUsingFace obj face 
		verts = verts_ as array
		distA = distance (meshop.getVert obj verts[1]) (meshop.getVert obj verts[2])
		distB = distance (meshop.getVert obj verts[2]) (meshop.getVert obj verts[3])
		distC = distance (meshop.getVert obj verts[3]) (meshop.getVert obj verts[1])			
		cosAngleAB = (((distA*distA) + (distB*distB) - (distC*distC)) as double) / ((2*distB*distA) as double)
		--format "A = % A2 = %\nB =  % B2 = %\nC = % C2 = %\n = %\n cos = = %\n angle = %\n" distA (distA*distA) distB (distB*distB) distC (distC*distC) (2*distA*distB) cosAngleAB ((acos cosAngleAB) as float)
		AngleAB = (acos(cosAngleAB) as float)
		--format "angle = %\n"  AngleAB
		cosAngleBC = (((distB*distB) + (distC*distC) - (distA*distA)) as double) / ((2*distC*distB) as double)
		AngleBC = (acos(cosAngleBC) as float)
		--format "angle = %\n"  AngleBC
		cosAngleCA = (((distC*distC) + (distA*distA) - (distB*distB)) as double) / ((2*distA*distC) as double)
		AngleCA = (acos(cosAngleCA) as float)
		--format "angle = %\n"  AngleCA		
		if AngleAB > degree then return true
		if AngleBC > degree then return true
		if AngleCA > degree then return true else return false
	),

	-- Clean and Simplify Mesh for Collsion
	function CleanColMesh obj =
	(
		if 	(IsKindOf obj  Editable_Mesh) and  (obj.parent != undefined) and ((custattributes.get obj ColMesh)!=undefined) then 
		(
			try 
			(
				thresh = 0.02 -- weld threshold
				allVerts = #{1..(obj.numVerts)} -- get all verts list
				meshop.weldVertsByThreshold obj allVerts thresh -- Weld
				meshop.deleteIsoVerts obj
				f = #{}
				f2 = #{}
				fnarrow = #{}
				for i = 1 to obj.numfaces do (
					if abs (meshop.getFaceArea obj i) < 0.001 then append f i
					if (fn_getNarrowFace obj i 178) == true then  append f2 i
				)
				if not f.isEmpty then (
					meshop.deleteFaces obj f
					-- format "%: % No Area faces deleted\n" obj.name f.numberset
					-- format "%: % Narrow faces deleted\n" obj.name f2.numberset
				)
				-- else format "% have no zero-area faces\n" obj.name

				allVerts = #{1..(obj.numVerts)} -- get all verts list
				meshop.weldVertsByThreshold obj allVerts thresh -- Weld
			)
			catch ()
			
		)
		/*
		if IsKindOf Obj Editable_Poly then 
		(
			obj.weldThreshold = 0.015 -- set weld threshold value
			allVerts = #{1..(polyop.getNumVerts obj)} -- get all verts list
			polyop.weldVertsByThreshold obj allVerts -- Weld
				Obj.EditablePoly.deleteIsoVerts ()
		) */

	),

	function ConvertMeshtoCol Obj = 
	(
		if (custattributes.get Obj ColMesh)==undefined then 
		(
			custattributes.add Obj ColMesh
			Obj.wirecolor =  color 50 210 250
		)
	),

	-- Generates Collisionmeshes from the main Mesh
	function GenerateColMeshes MyObjs = 
	(
		with redraw off
		(
			for obj in MyObjs do 
			(
				if classof obj == Editable_mesh and obj.parent == undefined  then -- checks that the meshes don't have aprent, making sure to get the mainmodel
				(
					thecopy = copy obj
					thecopy.name = obj.name + "_COL" 
					thecopy.parent = obj
					
					ConvertMeshtoCol thecopy 
				/*	if (custattributes.get thecopy ColMesh)==undefined then 
					(
						custattributes.add thecopy ColMesh
						thecopy.wirecolor =  color 50 210 250
					) */
					StdMattoColMat thecopy
					OptimizeColMesh thecopy 
					CleanColMesh thecopy 
				)
			)
			gc()
		)
		redrawviews()
	),

	fn writeCols f cols version = 
	(
		for c in cols do writeCol f c version
	),

	function isCol obj=
	(
		isit = false
		if ((isProperty obj #isShadow ) == true) or ((custattributes.get obj TheColMesh) == true) then isit =true
		if classof obj == Collision_Box then isit = true
		if classof obj ==Collision_Sphere then isit = true 
		isit
	),

	fn ExportCollisions Filepath items =
	(
		myobjects = for obj in items where (classof obj == Editable_mesh) collect obj
		
		-- Make exported objects unique, dont export duplicates
		MyObjs = #()
		allNames = #() 
		for i in myobjects do
		(
			if findItem allNames i.name == 0  do 
			(
				append MyObjs i
				append allNames i.name 
			)
		)
		myobjects = MyObjs
		free allNames

		if myobjects.count > 0 then 
		(
			f = fopen Filepath "wb"
			if f != undefined then 
			(
				writeCols f myobjects 3
				print "closestream"
				fclose f
			)
		)
	),

	fn ExportAllCollisions Filepath =
	( 
		local Theobjs = #()
		for i in objects as array do if (isCol i) == false do append Theobjs i
		Theobjs =  makeUniqueArray Theobjs

		
		ExportCollisions Filepath Theobjs
	)

)
btlcCol = Btlc_Collision();


struct btlc_IvBoundtoCol
(
	-- Converts all Materials of current IV Collision
	fn ConvertIVMatToColMaterial TheMat = 
	(
		Mtlgrp = TheMat.iv_col_getmtlselection (TheMat.mtlid)  mtl:false
		Mtl = TheMat.iv_col_getmtlselection (TheMat.mtlid)  mtl:true
		TheMat.name = iv_col_material_mtlgrp[3][Mtlgrp][Mtl]
		TheMat = btlcCol.ConvertMaterialtoCol TheMat
		--print	iv_col_material_mtlgrp[3][Mtlgrp][Mtl]
		TheMat
	),

	-- for example: capsuels/cylinder and rotated boxes will be mesh
	-- spheres / no rotates boxes wil be GTA SA sphere/boxes
	fn ConvertColType theobj = 
	(
		if classof theobj == Editable_Poly and (getUserProp theobj "type") == "BoundGeometry" then 
		(
			converttomesh theobj
			btlcCol.ConvertMeshtoCol theobj 
		)
		else if classof theobj == ofio_iv_col_box then 
		(
			if theobj.rotation == (quat 0 0 0 1) then 
			(
				NewObj = Collision_Box();
				NewObj.len = theobj.depth;
				NewObj.width = theobj.width;
				NewObj.height = theobj.height;
				NewObj.parent = theobj.parent
				NewObj.name = theobj.name
				NewObj.position = theobj.position
				NewObj.matID = theobj.Material.surface
				delete theobj
				theobj = NewObj
			) 
			else 
			(
				converttomesh theobj
				btlcCol.ConvertMeshtoCol theobj 
			)
		)
		else if classof theobj == ofio_iv_col_sphere then 
		(
			NewObj = Collision_Sphere();
			NewObj.delegate.radius = theobj.radius;
			NewObj.parent = theobj.parent
			NewObj.name = theobj.name
			NewObj.position = theobj.position
			NewObj.matID = theobj.Material.surface
			delete theobj
			theobj = NewObj
		)
		else 
		(
			converttomesh theobj
			btlcCol.ConvertMeshtoCol theobj 
		)
		--ofio_iv_col_box    ofio_iv_col_sphere   ofio_iv_col_capsule
		theobj
	),

	-- Gets all geometry parts and converts them into Gta SA formats
	-- calls material conversion
	fn ConvertColGeometry Obj= 
	(
		if (classof Obj.Material) != Multimaterial do
		(
			Obj.Material = ConvertIVMatToColMaterial Obj.Material
		)

		if (classof Obj.Material) == Multimaterial do
		(
			for MtlID= 1 to Obj.Material.MaterialList.Count do
			(
			  if Obj.Material.MaterialList[MtlID] != undefined then
			  (   
				Obj.Material.MaterialList[MtlID] = ConvertIVMatToColMaterial Obj.Material.MaterialList[MtlID] 
			  )
			)
		)

		Obj = ConvertColType Obj
	),

	-- Starts general conversion
	fn ConvertObd TheObj = 
	(
		MakeAsMesh = undefined--first part to which all meshes shall connect to

		BoundType = getUserProp theobj "type"
		BoundType = ofutils.lowercase(BoundType)

		if BoundType == undefined do return()

		if BoundType == "boundcomposite" then 
		(
			for Child in TheObj.children do 
			(
				ConvertObd Child
			)

			-- combine mesh
			for Child in TheObj.children do 
			(
				if classof Child == Editable_mesh do 
				(
					if MakeAsMesh == undefined then MakeAsMesh = Child
					else meshop.attach MakeAsMesh Child attachMat:#IDToMat condenseMat:true
				)
			)	
			
			if MakeAsMesh != undefined do 
			(
				MakeAsMesh.pivot = theobj.pos
				resetxform MakeAsMesh
			)
		)

		if 	BoundType == "boundbvh" or \
			BoundType == "boundgeometry" or  \
		  	BoundType == "boundcurvedgeometry" or \
			BoundType == "boundbox" or  \
		  	BoundType == "boundsphere" or \
			BoundType == "boundcapsule" then 
		( 
			TheObj = ConvertColGeometry TheObj 
		)
		TheObj
	)
)
btlcIVColConvert = btlc_IvBoundtoCol();

/* Testscript
	Objs = selection[1].children

	for TheObj in Objs do 
	( 
		print TheObj.name
		btlcIVColConvert.ConvertObd TheObj;
		print "________"
	) 
*/