-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- dev-c.com, openiv.com

-- Description: odr/odd/oft
-- Last changed: Jan 2015

fileIn "ofio.iv.drawable.mtl.ms"
fileIn "ofio.iv.skeleton.ms"
--fileIn "btlc.Material.ms"

struct ofio_iv_vertex_skinned (
	_uniq,
	_meshvertid,	
	
	pos,
	normal,
	blendweight,
	blendindicies,
	color,
	tangent,
	texcoord_0,
	texcoord_1	
)

struct ofio_iv_vertex (
	_uniq,
	_meshvertid,
	
	pos,
	normal,
	color,
	tangent,
	texcoord_0,
	texcoord_1,
	texcoord_2,
	texcoord_3,
	texcoord_4,
	texcoord_5
)

struct ofio_iv_mesh_mtl (
	Id,
	Idx = #(),
	Verts = #()
)

struct ofio_iv_mesh (
	objs = #(),
	
	Skinned,
	Bounds = #(),
	Mtls = #(),
	
	bone_ids = #(),
	bone_weights = #(),
	
	m_Boundbox,
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		l = undefined	
		return s
	),	
	
	fn linearAttach obj objArr = (
		if objArr.count > 0 then
		(
			convertToPoly obj
			with undo off
			(
				with redraw off
				(
					local i
					for i in 1 to objArr.count do polyOp.attach obj objArr[i]
				)
			)
		)
	),	
	
	fn makeclone obj = (
		local result = #() 
		maxOps.cloneNodes obj offset:[0,0,0] expandHierarchy:true actualNodeList:#() newNodes:&result 
		local res = result[1]
		return res
	),	
	
	fn detachsg obj = (
		if classof obj != Editable_Poly then
			convertToPoly obj
		local fid, i, faces
		local sg = (for i = 1 to 33 collect #())
		for fid = 1 to obj.numfaces do
		(
			local cur_sg = obj.GetFaceSmoothingGroups fid
			if cur_sg == 0 then
			(
				append sg[1] fid
			) else
			(
				for i = 1 to 32 do
				(
					if (bit.get cur_sg i) then
					(
						append sg[i + 1] fid
						exit
					)
				)
			)
		)
		for faces in sg do
			polyOp.detachFaces obj faces
		convertToMesh obj
	),
	
	fn calculate_tangents verts_processed = (
		local tangents = #()
		local normals = #()
		local tan1 = #()
		local tan2 = #()
		
		local i, j
		
		for i = 1 to verts_processed.count do
		(
			local cf = verts_processed[i]
			if cf == undefined or cf.count != 3 then throw "tangents exception\n"
			
			local v1 = cf[1].pos
			local v2 = cf[2].pos	
			local v3 = cf[3].pos
			
			local w1 = copy cf[1].texcoord_0
			local w2 = copy cf[2].texcoord_0
			local w3 = copy cf[3].texcoord_0

			w1.y *= -1		
			w2.y *= -1
			w3.y *= -1
			
			local x1 = v2.x - v1.x
			local x2 = v3.x - v1.x
			local y1 = v2.y - v1.y
			local y2 = v3.y - v1.y
			local z1 = v2.z - v1.z
			local z2 = v3.z - v1.z
			
			local s1 = w2.x - w1.x
			local s2 = w3.x - w1.x
			local t1 = w2.y - w1.y
			local t2 = w3.y - w1.y
			
			local r = 1.0 / (s1 * t2 - s2 * t1)
			local sdir = [(t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r]
			local tdir = [(s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r]					
			
	        local i1 = cf[1]._meshvertid
	        local i2 = cf[2]._meshvertid
	        local i3 = cf[3]._meshvertid
	
			normals[i1]	= cf[1].normal
			normals[i2]	= cf[2].normal
			normals[i3]	= cf[3].normal
			
			if tan1[i1] == undefined then tan1[i1] = Point3 0 0 0
			if tan1[i2] == undefined then tan1[i2] = Point3 0 0 0
			if tan1[i3] == undefined then tan1[i3] = Point3 0 0 0
			tan1[i1] += sdir					
			tan1[i2] += sdir					
			tan1[i3] += sdir
	
			if tan2[i1] == undefined then tan2[i1] = Point3 0 0 0
			if tan2[i2] == undefined then tan2[i2] = Point3 0 0 0
			if tan2[i3] == undefined then tan2[i3] = Point3 0 0 0
			tan2[i1] += tdir					
			tan2[i2] += tdir					
			tan2[i3] += tdir					
		)
		
		for i = 1 to tan1.count do
		(
			local n = normals[i]
			local t = tan1[i]
			local p
			try (
				p = normalize (t - n * (dot n t))
			) catch	(
				tangents[i] = Point4 1 0 0 1
				format "bad tan % %\n" i tan1.count
				continue
			)
			
			if (bit.isnan p.x) or (bit.isnan p.y) or (bit.isnan p.z) \
			or (not (bit.isfinite p.x)) or (not (bit.isfinite p.y)) or (not (bit.isfinite p.z)) then
	 		(
			   	tangents[i] = Point4 1 0 0 1					
			) else
			(
				local w = if (dot (cross n t) tan2[i]) < 0.0 then -1.0 else 1.0
				tangents[i] = Point4 p.x p.y p.z w
			)
		)
		
		for i = 1 to verts_processed.count do
			for j = 1 to verts_processed[i].count do
				verts_processed[i][j].tangent = tangents[verts_processed[i][j]._meshvertid]
		
		tangents = undefined
		normals = undefined
		tan1 = undefined
		tan2 = undefined	
	),
	
	fn calculate_uniques verts_processed use_skinned_verts = (
		local i, j
		for i = 1 to verts_processed.count do
		(		
			for j = 1 to verts_processed[i].count do
			(
				local vert = verts_processed[i][j]
				local ss = stringstream ""
				if use_skinned_verts then
				(
					format "% % % / % % % / % % % % / % % % % / % % % % / % % % % / % % / % %" \
							vert.pos.x vert.pos.y vert.pos.z \
							vert.normal.x vert.normal.y vert.normal.z \
							vert.blendweight[1] vert.blendweight[2] vert.blendweight[3] vert.blendweight[4] \
							vert.blendindicies[1] vert.blendindicies[2] vert.blendindicies[3] vert.blendindicies[4] \
							vert.color[1] vert.color[2] vert.color[3] vert.color[4] \
							vert.tangent.x vert.tangent.y vert.tangent.z vert.tangent.w \
							vert.texcoord_0.x vert.texcoord_0.y \
							vert.texcoord_1.x vert.texcoord_1.y to:ss
				) else
				(
					format "% % % / % % % / % % % % / % % % % / % % / % % / % % / % % / % % / % %" \
							vert.pos.x vert.pos.y vert.pos.z \
							vert.normal.x vert.normal.y vert.normal.z \
							vert.color[1] vert.color[2] vert.color[3] vert.color[4] \
							vert.tangent.x vert.tangent.y vert.tangent.z vert.tangent.w \
							vert.texcoord_0.x vert.texcoord_0.y \
							vert.texcoord_1.x vert.texcoord_1.y \
							vert.texcoord_2.x vert.texcoord_2.y \
							vert.texcoord_3.x vert.texcoord_3.y \
							vert.texcoord_4.x vert.texcoord_4.y \
							vert.texcoord_5.x vert.texcoord_5.y to:ss
				)
				vert._uniq = getHashValue (ss as String) 0
				ss = undefined
			)
		)		
	),	
	
	fn calculate_boundbox vert_coords = (
		local AABBMin = Point3 0xFFFF 0xFFFF 0xFFFF
		local AABBMax = Point3 -0xFFFF -0xFFFF -0xFFFF
		local vert, i
		for vert in vert_coords do
		(
			for i = 1 to 3 do
			(
				if vert[i] < AABBMin[i] then AABBMin[i] = vert[i]
				if vert[i] > AABBMax[i] then AABBMax[i] = vert[i]
			)
		)
		return #(AABBMin, AABBMax)		
	),
	
	fn calculate_bounds vert_coords = (
		local boundbox = calculate_boundbox vert_coords
		local AABBMin = boundbox[1]
		local AABBMax = boundbox[2]
		local Centroid = (AABBMin + AABBMax) / 2
		local Radius = length (AABBmax - Centroid)
		return #(Centroid.x, Centroid.y, Centroid.z, Radius)
	),
	
	fn dumpBoneId obj arr = (
		if ofutils.lowercase(getUserProp obj "type") == "bone" then
		(
			local index = getUserProp obj "_ignore_this_autogenerated_index"
			local name = ofutils.lowercase(obj.name)
			append arr #(name, index)
			local child
			for child in obj.Children do
				arr = dumpBoneId child arr
		)
		return arr
	),
	
	fn dump obj material_hashes skel:undefined normal_as_skinned:false = (
		if ofutils.lowercase(getUserProp obj "type") != "mesh" then
			throw "dumping obj type is not mesh"
			
		local cpy_obj = makeclone(obj)
		obj = cpy_obj		
		objs = #(obj)
		
		-- Skinned 
		local skel_bone_names = #(), skel_bone_inds = #()
		local modskin = obj.modifiers[#Skin]
		if modskin == undefined then Skinned = 0 else Skinned = 1
		
		-- check if this is not fragmented common mesh
		if not normal_as_skinned then
		if Skinned == 0 then 
		(
			format "% %\n" obj obj.numverts
			detachsg obj
			format "% %\n" obj obj.numverts
		) else
		(
			if skel == undefined then 
				throw "undefined skel in skinned mesh"
			
			-- make array for bone names and the corresponding one for their ids
			local bone_names_ids = dumpBoneId skel #()
			local bone
			for bone in bone_names_ids do
			(
				append skel_bone_names bone[1]
				append skel_bone_inds bone[2]
			)
				
			select obj
			max modify mode
			modPanel.setCurrentObject modskin
		)	
			
		-- convert to mesh
		if classof obj != Editable_Mesh then
			convertToMesh obj
			
		-- collect faces by groups
		local facegroups = #()
		local mtl = obj.Material
		if mtl == undefined then
			throw "undefined material"			
		if not (meshop.getMapSupport obj 1) then
		(
			meshop.defaultMapFaces obj 1
			buildTVFaces obj
		)	

		if classof mtl == Multimaterial then
		(		
			local mat_list = obj.material.materialList
			local matid_list = obj.material.materialIDList
			local i, j
			for i = 1 to obj.numfaces do
			(
				local matid = getFaceMatID obj i
				if matid > 0 then
					if obj.material[matid] == undefined then
					(
						local verts = getFace obj i
						local vert = ((getVert obj verts[1]) + (getVert obj verts[2]) + (getVert obj verts[3])) / 3
						throw ("MATERIAL ERROR\n\nMesh " + obj.name + " has polys with bad material id " + matid as String + " at " + vert as String)
					)
			)
			for i = 1 to mat_list.count do
			(
				local faces = #()
				for j = 1 to obj.numfaces do
				(
					if (getFaceMatID obj j) == matid_list[i] then
						append faces j
				)
				if faces.count > 0 then
				(
					local mtl = mat_list[i]
					local hash = getHashValue (mtl.getInfo()) 0
					j = findItem material_hashes hash 
					if j == 0 then throw "MATERIAL ERROR\n can't find material hash\n"
					append facegroups #(j - 1, faces, ofio_iv_shaders[mtl.mtlid])
				) else
				(
					ofioLog.print("warning: " + obj.name + " has unused material")
					--throw ""
				)
			)		
		) else
		(
			local faces = #()
			for j = 1 to obj.numfaces do
				append faces j
			local hash = getHashValue (mtl.getInfo()) 0
			j = findItem material_hashes hash
			if j == 0 then throw "MATERIAL ERROR\n can't find material hash\n"				
			append facegroups #(j - 1, faces)
		)
		if facegroups.count == 0 then
			throw "facegroups.count = 0"
		-- each group max vertex count is 65536, such groups must be divided
		local newfacegroups = #()
		local facegroup
		for facegroup in facegroups do
		(
			local FACES_ALLOWED = (65532 / 3) as Integer
			if facegroup[2].count > FACES_ALLOWED then
			(
				--throw ("MESH ERROR\n\n " + obj.name + " has to many faces (~20K) covered by one material")
				
				local count = facegroup[2].count
				local cur_face_start = 0
				while (count > 0) do
				(
					local faces = #()
					local readcount = FACES_ALLOWED
					if readcount > count then readcount = count
					for i = 1 to readcount do
						append faces facegroup[2][cur_face_start + i]
					count -= readcount
					cur_face_start += readcount
					append newfacegroups #(facegroup[1], faces)
				)
			) else
			(
				append newfacegroups facegroup
			)
		)
		facegroups = newfacegroups
		
		-- collect geometries
		local verts_processed = #()
		-- fill verts
		local has_color = meshop.getMapSupport obj 0
		local has_alpha = meshop.getMapSupport obj -2
		local chcount = (if Skinned == 1 then 2 else 6)
		local chenabled = #()
		local i, j
		for i = 1 to chcount do
			append chenabled (meshop.getMapSupport obj i)
		--local flip = (dot (cross obj.transform.row1 obj.transform.row2) obj.transform.row3) <= 0	
		for facegroup in facegroups do
		(
			local faceId
			for faceId in facegroup[2] do
			(
				-- map faces
				local face = getFace obj faceId
				local vcFace = (if has_color then (getVCFace obj faceId) else undefined)
				local vcaFace = (if has_alpha then meshOp.getMapFace obj -2 faceId else undefined)
				local vmaps = #()
				for i = 1 to chcount do
					append vmaps (if chenabled[i] then meshop.getMapFace obj i faceId else undefined)
				local vert_ids = #()
				for i = 1 to 3 do
				(
						local vert

						vert = (if Skinned == 1 or normal_as_skinned then ofio_iv_vertex_skinned() else ofio_iv_vertex())
						vert._meshvertid = face[i]
						vert.pos = (in coordsys obj (getVert obj face[i]))
						vert.normal = getNormal obj face[i]
						vert.color = (if has_color then getVertColor obj vcFace[i] else color 255 255 255 255)
						vert.color.a = (if has_alpha then (255 * (meshOp.getMapVert obj -2 vcaFace[i]).x) as Integer else 255)
						vert.color = #(vert.color.b as Integer, vert.color.g as Integer, vert.color.r as Integer, vert.color.a as Integer)
						vmap = #()
						-- get UVs
						for j = 1 to chcount do 
						(
							if chenabled[j] == true then 
							(
								vmap[j] = meshop.getMapVert obj j vmaps[j][i]
								if bit.isnan vmap[j].x then
								(
									vmap[j].x = 0.0
								) else 
								(
									if not (bit.isfinite vmap[j].x) then
										vmap[j].x = 1.0
								)
								if bit.isnan vmap[j].y then
								(
									vmap[j].y = 0.0
								) else
								(
									if not (bit.isfinite vmap[j].y) then
										vmap[j].y = 1.0
								)
								-- flip V for the first 4 coord pairs
								if j <= 4 then
									vmap[j].y *= -1
							) else
							(
								vmap[j] = [0.0, 0.0]
							)							
						)	
						for j = 1 to vmap.count do
							vmap[j] = [vmap[j][1], vmap[j][2]]
						vert.texcoord_0 = vmap[1]
						vert.texcoord_1 = vmap[2]
						if normal_as_skinned then
						(
							vert.blendweight = #(0.0, 0.0, 1.0, 0.0)
							vert.blendindicies = #(0, 0, (meshop.getVertWeight obj face[i]) as Integer, 0)
						) else
						if Skinned == 1 then
						(
							vert.blendweight = #(0.0, 0.0, 0.0, 0.0)
							vert.blendindicies = #(0, 0, 0, 0)					
							local vbonecount = skinOps.GetVertexWeightCount modskin face[i]
							if vbonecount > 0 then
							(
								-- weights and indicies
								for j = 1 to vbonecount do
								(
									local vw = skinOps.GetVertexWeight modskin face[i] j
									if vw > 0.0 then
									(
										local vboneid = skinOps.GetVertexWeightBoneID modskin face[i] j
										local vbonename = ofutils.lowercase(skinOps.GetBoneName modskin vboneid 0)
										
										local ind = findItem skel_bone_names vbonename
										if ind == 0 then
											throw ("can't find bone in skel " + vbonename)
										local bone_index = skel_bone_inds[ind]
										
										if bone_index == undefined then
											throw ("can't find bone " + vbonename)
										vert.blendweight[j] = vw
										vert.blendindicies[j] = bone_index
									) else
									(
										vert.blendweight[j] = 0.0
										vert.blendindicies[j] = 0
									)									
								)
								-- sort by weights
								local v
								for j = 1 to vert.blendweight.Count do
									for v = 1 to vert.blendweight.Count - 1 do
										if vert.blendweight[v] < vert.blendweight[v + 1] then
										(
											local temp = vert.blendweight[v + 1]
											vert.blendweight[v + 1] = vert.blendweight[v]
											vert.blendweight[v] = temp
											temp = vert.blendindicies[v + 1]
											vert.blendindicies[v + 1] = vert.blendindicies[v]
											vert.blendindicies[v] = temp
										)
								-- arr length must be 4
								local _blendweight = #(0.0, 0.0, 0.0, 0.0), _blendindicies = #(0, 0, 0, 0)
								for j = 1 to 4 do
								(
									if vert.blendweight.count >= j then
									(
										_blendweight[j] = vert.blendweight[j]
										_blendindicies[j] = vert.blendindicies[j]
									)
								)
								-- replace bone id of zero weight with already used id
								for j = 2 to 4 do
									if _blendweight[j] == 0.0 then
										_blendindicies[j] = _blendindicies[1]
								vert.blendweight = _blendweight
								vert.blendindicies = _blendindicies	
							) 
							if vert.blendweight.count == 0 then
							(
								vert.blendweight = #(1.0, 0.0, 0.0, 0.0)
								vert.blendindicies = #(0, 0, 0, 0)
							)
						) else
						(
							vert.texcoord_2 = vmap[3]
							vert.texcoord_3 = vmap[4]						
							vert.texcoord_4 = vmap[5]
							vert.texcoord_5 = vmap[6]
						)
						
						-- append vertex to vertex arr
						if verts_processed[faceId] == undefined then
							verts_processed[faceId] = #()
						append verts_processed[faceId] vert

				) -- for verts in face
					
			) -- for faceId in facegroup
		)
		
		-- tangents
		calculate_tangents verts_processed
		
		-- vert uniques
		local use_skinned_verts = Skinned == 1 or normal_as_skinned
		calculate_uniques verts_processed use_skinned_verts
		
		-- geometry
		local vert_coords = #()
		local vert, verts
		for verts in verts_processed do
			for vert in verts do
				append vert_coords vert.pos
		Bounds = #(calculate_bounds vert_coords)
		m_Boundbox = calculate_boundbox vert_coords
		
		local late_Mtls = #()
		for facegroup in facegroups do
		(
			local mtl = ofio_iv_mesh_mtl()
			local shader_name = (if facegroup[3] != undefined then facegroup[3] else "")
			mtl.Id = facegroup[1]
			mtl.Verts = #()
			mtl.Idx = #()
			local vert_uniq_idents = #()
			local vert_coords = #()
			local faceId
			for faceId in facegroup[2] do
			(
				local face_verts = verts_processed[faceId]
				for i = 1 to 3 do
				(
					--local vert_id = findItem vert_uniq_idents face_verts[i]._uniq
					--if vert_id == 0 then
					
					local uniq_group = bit.and (face_verts[i]._uniq) 0x00000FFF
					if uniq_group < 0 then uniq_group *= -1 else
						if uniq_group == 0 then uniq_group = 1
					local vert_id = undefined, j
					local vert_ids = vert_uniq_idents[uniq_group]
					if vert_ids != undefined then
						for j = 1 to vert_ids.count do
							if vert_ids[j][1] == face_verts[i]._uniq then
							(
								vert_id = vert_ids[j][2]
								exit
							)
					
					if vert_id == undefined then
					(
						append mtl.Verts face_verts[i]
						append mtl.Idx (mtl.Verts.count - 1)
						
						--append vert_uniq_idents face_verts[i]._uniq						
						if vert_uniq_idents[uniq_group] == undefined then vert_uniq_idents[uniq_group] = #()
						append vert_uniq_idents[uniq_group] #(face_verts[i]._uniq, mtl.Verts.count)
						
						append vert_coords face_verts[i].pos
					) else				
					(
						append mtl.Idx (vert_id - 1)
					)
				)
			)
			vert_uniq_idents = undefined
		
			-- calc bound
			append Bounds (calculate_bounds vert_coords)			
			-- append mtl
			if (findString shader_name "glass") == undefined -- such mtls as glass must be rendered in the end
				then append Mtls mtl
				else append late_Mtls mtl
		)
		join Mtls late_Mtls
		
		-- one mtl mesh has only one bound
		if Mtls.count == 1 then
			Bounds = #(Bounds[1])
			
		-- set mesh Skinned flag for normal as skinned dump	
		if normal_as_skinned then Skinned = 1
	),
	
	fn build_skinned_as_chunked = (
		objs = #()
		local objs_using_bone = #()
		local mtl
		local smoothing_group_bit = 0
		local mesh_part = 0
		for mtl in Mtls do
		(	
			smoothing_group_bit += 1
			if smoothing_group_bit == 32 then smoothing_group_bit = 1
			smoothing_group = bit.set 0 smoothing_group_bit true
			
			-- faces
			local faces = #(), i = 1 
			do
			(
				append faces [mtl.Idx[i] + 1, mtl.Idx[i+1] + 1, mtl.Idx[i+2] + 1]	
				i += 3
			) while i < mtl.Idx.count			
			
			-- chunked verts
			local chunked_verts = #(), bone_ind_using_vertex_ind = #(), vertex_translation = #()
			for i = 1 to mtl.Verts.count do
			(
				-- get bone index from vertex declaration
				local boneind = 0, ind, weightscount = 0
				for ind = 1 to 4 do
				(
					if mtl.Verts[i].blendweight[ind] > 0 then
					(
						weightscount += 1
						boneind = mtl.Verts[i].blendindicies[ind]
					)
				)				
						
				if weightscount != 1 then throw "common mesh is way too skinned, more than 1 attached bone"	
						
				boneind += 1
				bone_ind_using_vertex_ind[i] = boneind
				-- group vertexes using boned indexes
				if chunked_verts[boneind] == undefined then chunked_verts[boneind] = #()
				append chunked_verts[boneind] mtl.Verts[i]
				if vertex_translation[boneind] == undefined then vertex_translation[boneind] = #()
				vertex_translation[boneind][i] = chunked_verts[boneind].count
			)

			-- chunked faces
			local chunked_faces = #()
			for i = 1 to faces.count do
			(
				local ind1 = bone_ind_using_vertex_ind[faces[i][1]],
					  ind2 = bone_ind_using_vertex_ind[faces[i][2]],
					  ind3 = bone_ind_using_vertex_ind[faces[i][3]]
				if (ind1 != ind2) or (ind2 != ind3)
					then throw ""
					
				local face = [ vertex_translation[ind1][faces[i][1]], 
				               vertex_translation[ind1][faces[i][2]], 
							   vertex_translation[ind1][faces[i][3]] ]
					
				if chunked_faces[ind1] == undefined then chunked_faces[ind1] = #()				
				append chunked_faces[ind1] face
			)
			
			for i = 1 to chunked_faces.count do
			(
				if chunked_faces[i] == undefined then continue
				
				local verts = #()				
				local vert
				for vert in chunked_verts[i] do
					append verts vert.pos
				local obj = mesh vertices:verts faces:chunked_faces[i]	
				if objs_using_bone[i] == undefined then objs_using_bone[i] = #()
				append objs_using_bone[i] #(obj, mtl.Id)				
			
				local j
				meshop.defaultMapFaces obj 0
				meshop.defaultMapFaces obj -2
				for j = 1 to 6 do
					meshop.defaultMapFaces obj j
				for j = 1 to verts.count do 
				(
					meshop.setMapVert obj 0 j [(chunked_verts[i][j].color[3]) as Float / 255, (chunked_verts[i][j].color[2]) as Float / 255, (chunked_verts[i][j].color[1]) as Float / 255]
					meshop.setMapVert obj -2 j [(chunked_verts[i][j].color[4]) as Float / 255, (chunked_verts[i][j].color[4]) as Float / 255, (chunked_verts[i][j].color[4]) as Float / 255]	
	
					setNormal obj j chunked_verts[i][j].normal
					
					meshop.setMapVert obj 1 j [chunked_verts[i][j].texcoord_0[1], chunked_verts[i][j].texcoord_0[2] * -1, 0]
					meshop.setMapVert obj 2 j [chunked_verts[i][j].texcoord_1[1], chunked_verts[i][j].texcoord_1[2] * -1, 0]
					meshop.setMapVert obj 3 j [0, 0, 0]
					meshop.setMapVert obj 4 j [0, 0, 0]
					meshop.setMapVert obj 5 j [0, 0, 0]
					meshop.setMapVert obj 6 j [0, 0, 0]
				)
				for j = 1 to chunked_faces[i].count do
					setFaceSmoothGroup obj j smoothing_group
					
				update obj				
			)				
		)		
		objs = objs_using_bone
	),
	
	fn build = (
		objs = #()
		bone_ids = #()
		bone_weights = #()		
		local mtl
		local smoothing_group_bit = 0
		local mesh_part = 0
		for mtl in Mtls do
		(	
			ofioLog.print ("building mesh part " + mesh_part as String + " with mtl " + mtl.Id as String)
			mesh_part += 1
		
			smoothing_group_bit += 1
			if smoothing_group_bit == 32 then smoothing_group_bit = 1
			smoothing_group = bit.set 0 smoothing_group_bit true
				
			local faces = #(), i = 1 
			do
			(
				append faces [mtl.Idx[i] + 1, mtl.Idx[i+1] + 1, mtl.Idx[i+2] + 1]	
				i += 3
			) while i < mtl.Idx.count
			local verts = #()
			local vert
			for vert in mtl.Verts do
				append verts vert.pos
			local obj = mesh vertices:verts faces:faces
			
			meshop.defaultMapFaces obj 0
			meshop.defaultMapFaces obj -2
			for i = 1 to 6 do
				meshop.defaultMapFaces obj i
			for i = 1 to verts.count do 
			(
				meshop.setMapVert obj 0 i [(mtl.Verts[i].color[3]) as Float / 255, (mtl.Verts[i].color[2]) as Float / 255, (mtl.Verts[i].color[1]) as Float / 255]
				meshop.setMapVert obj -2 i [(mtl.Verts[i].color[4]) as Float / 255, (mtl.Verts[i].color[4]) as Float / 255, (mtl.Verts[i].color[4]) as Float / 255]	

				setNormal obj i mtl.Verts[i].normal
				
				meshop.setMapVert obj 1 i [mtl.Verts[i].texcoord_0[1], mtl.Verts[i].texcoord_0[2] * -1, 0]
				meshop.setMapVert obj 2 i [mtl.Verts[i].texcoord_1[1], mtl.Verts[i].texcoord_1[2] * -1, 0]
				if Skinned != 1 then
				(
					meshop.setMapVert obj 3 i [mtl.Verts[i].texcoord_2[1], mtl.Verts[i].texcoord_2[2] * -1, 0]
					meshop.setMapVert obj 4 i [mtl.Verts[i].texcoord_3[1], mtl.Verts[i].texcoord_3[2] * -1, 0]
					meshop.setMapVert obj 5 i [mtl.Verts[i].texcoord_4[1], mtl.Verts[i].texcoord_4[2], 0]
					meshop.setMapVert obj 6 i [mtl.Verts[i].texcoord_5[1], mtl.Verts[i].texcoord_5[2], 0]
				) else
				(
					meshop.setMapVert obj 3 i [0, 0, 0]
					meshop.setMapVert obj 4 i [0, 0, 0]
					meshop.setMapVert obj 5 i [0, 0, 0]
					meshop.setMapVert obj 6 i [0, 0, 0]
				)				
			)
			for i = 1 to faces.count do
				setFaceSmoothGroup obj i smoothing_group
				
			update obj	

			if Skinned == 1 then
			(
				for i = 1 to mtl.Verts.count do
				(
					local _bone_ids = #()
					local _bone_weights = #()
					local j
					for j = 1 to mtl.Verts[i].blendweight.count do
					(
						if (mtl.Verts[i].blendweight[j] > 0) then
						(
							append _bone_ids (mtl.Verts[i].blendindicies[j] + 1)
							append _bone_weights mtl.Verts[i].blendweight[j]
						)	
					)
					append bone_ids _bone_ids
					append bone_weights _bone_weights
				)
			)
			append objs obj
		)
	),
	
	fn skin_attached bones = (
		if Skinned != 1 or bones == undefined or bones.count == 0 
			then return undefined
			
		ofioLog.print "skinning mesh"	
			
		local i
		local obj = objs[1]
		local modskin = Skin()
		max modify mode
		select obj
		addmodifier obj modskin
		
		for i = 1 to bones.count do 
		(
			skinOps.addbone modskin bones[i].boneObject 0
			skinOps.SetInnerRadius modskin i 1 0
			skinOps.SetOuterRadius modskin i 1 0
			skinOps.SetInnerRadius modskin i 2 0
			skinOps.SetOuterRadius modskin i 2 0
		)
		
		if obj.numverts != bone_ids.count then throw ""		
		for i = 1 to obj.numverts do
			skinOps.ReplaceVertexWeights modskin i bone_ids[i] bone_weights[i]
			
		forceCompleteRedraw()
		clearselection()				
	),
	
	fn cleanup = (
		local obj
		for obj in objs do
			if obj != undefined then delete obj
		objs = #()
	),	
	
	fn write fOutputName = (
		local fOutput = createFile fOutputName
		format "Version 11 13\n{\n" to:fOutput
		format "\x09Skinned %\n" Skinned to:fOutput
		if Skinned == 0 then
		(
			format ("\x09" + "Bounds %\n\x09{\n") Bounds.count to:fOutput
			local bound
			for bound in Bounds do
				format "\x09\x09% % % %\n" bound[1] bound[2] bound[3] bound[4] to:fOutput
			format "\x09}\n" to:fOutput
		)
		local mtl
		for mtl in Mtls do
		(
			format "\x09Mtl %\n\x09{\n\x09\x09Prim 0\n\x09\x09{\n" mtl.Id to:fOutput
			format "\x09\x09\x09Idx %\n\x09\x09\x09{\n\x09\x09\x09\x09" mtl.Idx.count to:fOutput
			local i
			for i = 1 to mtl.Idx.count do
			(
				if (mod (i - 1) 15) == 0 and (i > 1) then format "\n\x09\x09\x09\x09" padding to:fOutput
				format "% " mtl.Idx[i] to:fOutput
			)			
			format "\n\x09\x09\x09}\n\x09\x09\x09Verts %\n\x09\x09\x09{\n" mtl.Verts.count to:fOutput
			local vert
			for vert in mtl.Verts do
			(
				if Skinned == 1 then
				(
					format "\x09\x09\x09\x09% % % / % % % / % % % % / % % % % / % % % % / % % % % / % % / % %\n" \
							vert.pos.x vert.pos.y vert.pos.z \
							vert.normal.x vert.normal.y vert.normal.z \
							vert.blendweight[1] vert.blendweight[2] vert.blendweight[3] vert.blendweight[4] \
							vert.blendindicies[1] vert.blendindicies[2] vert.blendindicies[3] vert.blendindicies[4] \
							vert.color[1] vert.color[2] vert.color[3] vert.color[4] \
							vert.tangent.x vert.tangent.y vert.tangent.z vert.tangent.w \
							vert.texcoord_0.x vert.texcoord_0.y \
							vert.texcoord_1.x vert.texcoord_1.y to:fOutput
				) else
				(
					format "\x09\x09\x09\x09% % % / % % % / % % % % / % % % % / % % / % % / % % / % % / % % / % %\n" \
							vert.pos.x vert.pos.y vert.pos.z \
							vert.normal.x vert.normal.y vert.normal.z \
							vert.color[1] vert.color[2] vert.color[3] vert.color[4] \
							vert.tangent.x vert.tangent.y vert.tangent.z vert.tangent.w \
							vert.texcoord_0.x vert.texcoord_0.y \
							vert.texcoord_1.x vert.texcoord_1.y \
							vert.texcoord_2.x vert.texcoord_2.y \
							vert.texcoord_3.x vert.texcoord_3.y \
							vert.texcoord_4.x vert.texcoord_4.y \
							vert.texcoord_5.x vert.texcoord_5.y to:fOutput
				)
			)
			format "\x09\x09\x09}\n" to:fOutput			
			format "\x09\x09}\n\x09}\n" to:fOutput
		)
		format "}\n" to:fOutput
		close fOutput
	),

	fn read fInputName = (
		local fInput = openFile fInputName
		local version = scanline fInput		
		case ofutils.lowercase(version[1]) of
		(
			"version":
			(
				if (version[2] as Integer != 11) or (version[3] as Integer != 13) then
					throw "IMPORT ERROR\n\nNot supported mesh, version 11 13 is supported only"	
			)
			default: throw "IMPORT ERROR\n\nIncorrect mesh"
		)
		local blockstart = scanline fInput
		if blockstart[1] != "{" then throw "block start expected"	
		local elements = scanline fInput
		if ofutils.lowercase(elements[1]) != "skinned" then
			throw "skinned attribute expected"
		Skinned = elements[2] as Integer
		Mtls = #()	
		elements = scanline fInput
		while elements[1] != "}" do
		(	
			case ofutils.lowercase(elements[1]) of
			(
				"locked": throw "IMPORT ERROR\n\nMesh is locked"
				"bounds":
				(
					local blockstart = scanline fInput
					if blockstart[1] != "{" then throw "bounds block start expected"				
					Bounds = #()
					local count = elements[2] as Integer
					local i
					for i = 1 to count do
					(
						elements = scanline fInput
						local bound = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
						append Bounds bound
					)
					local blockend = scanline fInput
					if blockend[1] != "}" then throw "bounds block end expected"					
				)
				"mtl":
				(
					local mtl = ofio_iv_mesh_mtl()
					mtl.Id = elements[2] as Integer
					elements = scanline fInput
					if elements[1] != "{" then throw "mtl block start expected"					
					elements = scanline fInput
					if ofutils.lowercase(elements[1]) != "prim" then throw "prim expected"	
					elements = scanline fInput
					if elements[1] != "{" then throw "prim block start expected"
					elements = scanline fInput
					if ofutils.lowercase(elements[1]) != "idx" then throw "prim expected"	
					local count = elements[2] as Integer	
					elements = scanline fInput
					if elements[1] != "{" then throw "idx block start expected"		
					mtl.Idx = #()
					elements = scanline fInput					
					while elements[1] != "}" do
					(	
						local element
						for element in elements do 
							append mtl.Idx (element as Integer)
						elements = scanline fInput
					)
					if mtl.Idx.count != count then throw "idx count mismatch"
					elements = scanline fInput
					if ofutils.lowercase(elements[1]) != "verts" then throw "verts expected"	
					count = elements[2] as Integer
					elements = scanline fInput
					if elements[1] != "{" then throw "vertex block start expected"	
					local i
					mtl.Verts = #()
					for i = 1 to count do
					(
						elements = scanline fInput
						local vert
						if Skinned == 1 then
						(
							vert = ofio_iv_vertex_skinned()
							vert.pos = Point3 (elements[1] as Float) (elements[2] as Float) (elements[3] as Float)
							vert.normal = Point3 (elements[5] as Float) (elements[6] as Float) (elements[7] as Float)
							vert.blendweight = #(elements[9] as Float, elements[10] as Float, elements[11] as Float, elements[12] as Float)
							vert.blendindicies = #(elements[14] as Integer, elements[15] as Integer, elements[16] as Integer, elements[17] as Integer)
							vert.color = #(elements[19] as Integer, elements[20] as Integer, elements[21] as Integer, elements[22] as Integer)
							vert.tangent = Point4 (elements[24] as Float) (elements[25] as Float) (elements[26] as Float) (elements[27] as Float)
							vert.texcoord_0 = #(elements[29] as Float, elements[30] as Float)
							vert.texcoord_1	= #(elements[32] as Float, elements[33] as Float)						
						) else
						(
							vert = ofio_iv_vertex()
							vert.pos = Point3 (elements[1] as Float) (elements[2] as Float) (elements[3] as Float)
							vert.normal = Point3 (elements[5] as Float) (elements[6] as Float) (elements[7] as Float)
							vert.color = #(elements[9] as Integer, elements[10] as Integer, elements[11] as Integer, elements[12] as Integer)
							vert.tangent = Point4 (elements[14] as Float) (elements[15] as Float) (elements[16] as Float) (elements[17] as Float)
							vert.texcoord_0 = #(elements[19] as Float, elements[20] as Float)						
							vert.texcoord_1 = #(elements[22] as Float, elements[23] as Float)
							vert.texcoord_2 = #(elements[25] as Float, elements[26] as Float)
							vert.texcoord_3 = #(elements[28] as Float, elements[29] as Float)
							vert.texcoord_4 = #(elements[31] as Float, elements[32] as Float)
							vert.texcoord_5 = #(elements[34] as Float, elements[35] as Float)
						)
						append mtl.Verts vert
					)
					elements = scanline fInput
					if elements[1] != "}" then throw "verts end expected"
					elements = scanline fInput
					if elements[1] != "}" then throw "prim end expected"					
					elements = scanline fInput
					if elements[1] != "}" then throw "mtl end expected"	
					
					append Mtls mtl				
				)
				default: throw "unknown mesh element"
			)
			elements = scanline fInput	
		)	
		elements = undefined	
		close fInput
	)	
)

struct ofio_iv_mesh_decl (
	path,
	boneid
)

struct light_attribute (
	obj,
	
	Position,
	Direction,
	Origin,
	Color,
	_f28,
	_f2C,
	_f30,
	Distance,
	Range,
	CoronaSize,
	HotSpot,
	Falloff,
	Flags,
	CoronaHash,
	LuminescenceHash,
	TypeFlags,
	Type,
	_f58,
	_f5C,
	_f60,
	BoneID,
	_f66
)

struct ofio_iv_additional_lodgroup (
	name,
	
	high = #(),	
	med = #(),
	low = #(),
	vlow = #(),	
	center,
	AABBMin,
	AABBMax,
	radius,
	
	high_obj = #(),
	med_obj = #(),
	low_obj = #(),
	vlow_obj = #(),	
	
	high_ids = #(),
	med_ids = #(),
	low_ids = #(),
	vlow_ids = #(),	
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		l = undefined	
		return s
	),		

	fn read fInput cur_path = (
		local blockstart = scanline fInput
		if blockstart[1] != "{" then throw "block start expected"
		elements = scanline fInput
		while elements[1] != "}" do
		(	
			case ofutils.lowercase(elements[1]) of
			(
				"high": 
				(
					if ofutils.lowercase(elements[2]) != "none" then 
					(
						high = #() 
						local count = elements[2] as Integer
						local i = 3 
						while count > 0 do
						(
							append high (ofio_iv_mesh_decl path:elements[i] boneid:(elements[i+1] as Integer))
							i += 2
							count -= 1 
						)
					)
				)
				"med": 
				(
					if ofutils.lowercase(elements[2]) != "none" then 
					(
						med = #() 
						local count = elements[2] as Integer
						local i = 3 
						while count > 0 do
						(
							append med (ofio_iv_mesh_decl path:elements[i] boneid:(elements[i+1] as Integer))
							i += 2
							count -= 1 
						)
					)
				)							
				"low": 
				(
					if ofutils.lowercase(elements[2]) != "none" then 
					(
						low = #() 
						local count = elements[2] as Integer
						local i = 3 
						while count > 0 do
						(
							append low (ofio_iv_mesh_decl path:elements[i] boneid:(elements[i+1] as Integer))
							i += 2
							count -= 1 
						)
					)
				)							
				"vlow": 
				(
					if ofutils.lowercase(elements[2]) != "none" then 
					(
						vlow = #() 
						local count = elements[2] as Integer
						local i = 3 
						while count > 0 do
						(
							append vlow (ofio_iv_mesh_decl path:elements[i] boneid:(elements[i+1] as Integer))
							i += 2
							count -= 1 
						)
					)
				)							
				"radius": radius = (elements[2] as Float)
				"center": center = (elements[2] as Float)
				"aabbmax": AABBMax = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"aabbmin": AABBMin = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				default: throw "unknown lodgroup element"
			)
			elements = scanline fInput	
		)
		local cur_mesh
		high_obj = #()
		if (high != undefined) and (high.count > 0) then
		(
			for cur_mesh in high do
			(
 				local obj = ofio_iv_mesh()
				obj.read (cur_path + cur_mesh.path)
				append high_obj obj
				append high_ids cur_mesh.boneid
			)
		)		
		med_obj = #()
		if (med != undefined) and (med.count > 0) then
		(
			for cur_mesh in med do
			(
 				local obj = ofio_iv_mesh()
				obj.read (cur_path + cur_mesh.path)
				append med_obj obj
				append med_ids cur_mesh.boneid
			)
		)	
		low_obj = #()
		if (low != undefined) and (low.count > 0) then
		(
			for cur_mesh in low do
			(
 				local obj = ofio_iv_mesh()
				obj.read (cur_path + cur_mesh.path)
				append low_obj obj
				append low_ids cur_mesh.boneid
			)
		)
		vlow_obj = #()
		if (vlow != undefined) and (vlow.count > 0) then
		(
			for cur_mesh in vlow do
			(
 				local obj = ofio_iv_mesh()
				obj.read (cur_path + cur_mesh.path)
				append vlow_obj obj
				append vlow_ids cur_mesh.boneid
			)
		)	
	)	
)

struct ofio_iv_odr (
	descriptor,
	descName,
	cur_path,
	TexDir,
	bone_using_id = #(),
	
	shadinggroup_shaders = #(),
	skel_skel,
	lodgroup_high = #(),	
	lodgroup_med = #(),
	lodgroup_low = #(),
	lodgroup_vlow = #(),
	lodgroup_center,
	lodgroup_AABBMin,
	lodgroup_AABBMax,
	lodgroup_radius,
	
	lights = #(),
	
	skel_obj,
	light_root,
	high_obj = #(),
	med_obj = #(),
	low_obj = #(),
	vlow_obj = #(),
	
	_mtls, -- for external access
	_mtl_hashes,
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		l = undefined	
		return s
	),	

	fn get_meshes obj meshes = (
		if ofutils.lowercase(getUserProp obj "type") == "mesh" then
		(
			append meshes obj
		) else
		(
			local child
			for child in obj.Children do
				meshes = get_meshes child meshes
		)
		return meshes
	),	
	
	fn get_common_mesh_chunks obj meshes = (
		if ofutils.lowercase(getUserProp obj "type") == "common_mesh" then
		(
			append meshes obj
		) else
		(
			local child
			for child in obj.Children do
				meshes = get_common_mesh_chunks child meshes
		)
		return meshes
	),	
	
	fn calculate_bounds vert_coords = (
		local AABBMin = Point3 0xFFFF 0xFFFF 0xFFFF
		local AABBMax = Point3 -0xFFFF -0xFFFF -0xFFFF
		local vert, i
		for vert in vert_coords do
		(
			for i = 1 to 3 do
			(
				if vert[i] < AABBMin[i] then AABBMin[i] = vert[i]
				if vert[i] > AABBMax[i] then AABBMax[i] = vert[i]
			)
		)	
		local Centroid = (AABBMin + AABBMax) / 2
		local Radius = length (AABBmax - Centroid)
		return #(AABBMin, AABBMax, Centroid, Radius)
	),	
	
	fn mesh_set_vert_weight obj w = (
		convertToMesh obj
		meshop.supportVertWeights obj
		local i, verts = #()
		for i = 1 to obj.numverts do
			append verts i
		meshop.setVertWeight obj verts w
	),
	
	fn dump obj chunked_as_skinned:false = (
		if ofutils.lowercase(getUserProp obj "type") != (if chunked_as_skinned then "fragments" else "drawable") then
			throw ("MESH ERROR\n\n" + obj.name + " type paramerter is not drawable\n")
		descName = obj.name
		-- collect meshes
		local meshes, meshes_for_mtlsearch
		if not chunked_as_skinned then -- normal drawable
		(
			meshes = get_meshes obj #()
			if meshes.count == 0 then
				throw ("MESH ERROR\n\n" + obj.name + " drawable must have atleast one mesh, check type parameter in scene mesh objects\n")
			meshes_for_mtlsearch = meshes
		) else -- chunked common drawable in fragments
		(
			meshes = get_common_mesh_chunks obj #()
			meshes_for_mtlsearch = get_meshes obj #()
			join meshes_for_mtlsearch meshes
		)
		-- collect materials
		local materials = #()
		local material_hashes = #()
		_mtl_hashes = material_hashes
		local cur_mesh		
		for cur_mesh in meshes_for_mtlsearch do
		(
			local mtl = cur_mesh.Material
			if mtl == undefined then
				throw ("MATERIAL ERROR\n\n" + obj.name + " has undefined material\n")
			if classof mtl == Multimaterial then
			(
				local sub_mtl
				for sub_mtl in mtl.Material do
					if sub_mtl != undefined then
					(
						if classof sub_mtl != iv_drawable_material then
							throw ("MATERIAL ERROR\n\n" + cur_mesh.name + " mesh multimat sub material isn't iv_drawable_material\n")
						local hash = getHashValue (sub_mtl.getInfo()) 0
						if (findItem material_hashes hash) == 0 then
						(
							append material_hashes hash
							append materials sub_mtl
						)
					)
			) else
			(
				if classof mtl != iv_drawable_material then
					throw ("MATERIAL ERROR\n\n" + cur_mesh.name + " mesh material isn't iv_drawable_material\n")
				local hash = getHashValue (mtl.getInfo()) 0
				if (findItem material_hashes hash) == 0 then
				(
					append material_hashes hash
					append materials mtl
				)
			)
		)
		-- dump shaders
		shadinggroup_shaders = #()
		local mtl
		for mtl in materials do
			append shadinggroup_shaders (mtl.getInfo())
			
		print shadinggroup_shaders
		
		-- dump skel
		skel_obj = undefined
		if (getUserProp obj "skeleton_flags") != undefined then
		(
			local child 
			for child in obj.Children do
			(
				if ofutils.lowercase(getUserProp child "type") == "bone" then
				(
					if (getUserProp child "id") != 0 then
						throw ("bad skel root bone " + child.name + " id, must be 0")
					skel_obj = ofio_iv_skeleton()
					skel_obj.dump child
					exit
				)
			)
			if skel_obj == undefined then
				throw ("skel is not found but drawable/fragment root " + obj.name + " has skel flags")
		)
		
		-- lights
		lights = #()
		for light_root in obj.Children do
		(
			if ofutils.lowercase(getUserProp light_root "type") == "lights_root" then
			(
				local light
				for light in light_root.Children do
				(
					if ofutils.lowercase(getUserProp light "type") == "light" then
					(
						local attr = light_attribute()
						attr.Origin = Point3 0.0 1.0 0.0
						attr.Color = light.color
						attr.Distance = light.farattenend * 2
						attr.Range = light.multiplier * 10
						if light.type == #omni then 
						(
							attr.Type = "Omni"
							attr.Falloff = 0.0
							attr.HotSpot = 0.0
						) else 
						(
							attr.Type = "Spot"
							attr.Falloff = light.falloff
							attr.HotSpot = light.hotspot
						)
						
						attr.TypeFlags = execute (getUserProp light "typeflags")
						attr.CoronaSize = getUserProp light "coronasize"
						attr.CoronaHash = execute (getUserProp light "coronahash")
						attr.LuminescenceHash = execute (getUserProp light "luminescencehash")
						attr.Flags = getUserProp light "flags"
						attr.BoneId = getUserProp light "boneid"
						
						attr._f28 = getUserProp light "_f28"
						attr._f2C = getUserProp light "_f2C"
						attr._f30 = getUserProp light "_f30"
						attr._f58 = getUserProp light "_f58"
						attr._f5C = getUserProp light "_f5C"
						attr._f60 = getUserProp light "_f60"
						attr._f66 = getUserProp light "_f66"
						
						if (attr.TypeFlags == undefined) \
						or (attr.CoronaSize == undefined) \
						or (attr.CoronaHash == undefined) \
						or (attr.LuminescenceHash == undefined) \
						or (attr.Flags == undefined) \
						or (attr.BoneId == undefined) then
							throw ("LIGHTS ERROR\n\nTypeFlags/CoronaSize/CoronaHash/LuminescenceHash/Flags/BoneId isn't set in " + light.name + "object\n")
							
						if (attr._f28 == undefined) \
						or (attr._f2C == undefined) \
						or (attr._f30 == undefined) \
						or (attr._f58 == undefined) \
						or (attr._f5C == undefined) \
						or (attr._f60 == undefined) \
						or (attr._f66 == undefined) then
							throw ("LIGHTS ERROR\n\nSome of _fXX params isn't set in " + light.name + "object\n")
							
						local light_bone = undefined
						if skel_obj != undefined then
							light_bone = skel_obj.boneObjUsingGameId skel_obj.rootBone attr.BoneId
						if light_bone == undefined then
							light_bone = light_root
						
						in coordsys light_bone
						(
							attr.Direction = light.dir * -1
							attr.Position = light.pos
						)							
						
						append lights attr
					)
				)
				exit
			)
		)		
		
		-- check if there is no common mesh
		if meshes.count == 0 then
		(
			lodgroup_high = #()
			lodgroup_med = #()
			lodgroup_low = #()
			lodgroup_vlow = #()
			lodgroup_AABBMin = [0, 0, 0]
			lodgroup_AABBMax = [0, 0, 0]
			lodgroup_center = [0, 0, 0]
			lodgroup_radius = 0.0			
			return OK
		)
		
		-- dump lodgroups
		meshgroups = #(#(), #(), #(), #()) -- high, med, low, vlow
		for cur_mesh in meshes do
		(
			case ofutils.lowercase(getUserProp cur_mesh "lod") of
			(
				"med": append meshgroups[2] cur_mesh
				"low": append meshgroups[3] cur_mesh
				"vlow": append meshgroups[4] cur_mesh
				default: append meshgroups[1] cur_mesh
			)			
		)	

		-- common mesh in fragments must be combined from chunked
		if chunked_as_skinned then
		(
			local i, j
			for i = 1 to meshgroups.count do
			(
				-- check if meshgroup is empty
				if meshgroups[i].count == 0 then continue
				_meshgroup = #()
				-- for every mesh in meshgroup
				for j = 1 to meshgroups[i].count do
				(
					local m = meshgroups[i][j]
					-- get parent bone index
					local m_parent_bone_ind = undefined					
					if m.parent != undefined then
						if ofutils.lowercase(getUserProp m.parent "type") == "bone" then
							m_parent_bone_ind = getUserProp m.parent "_ignore_this_autogenerated_index"
					if m_parent_bone_ind == undefined then throw "common mesh chunk must have parent bone with index\n"
					-- make clone							
					local _m = ofio_iv_mesh.makeclone m
					append _meshgroup _m
					-- detach smoothing groups
					ofio_iv_mesh.detachsg _m
					-- set vert weights of the clone to parent bone index				
					mesh_set_vert_weight _m m_parent_bone_ind
				)
				-- attach
				if _meshgroup.count > 1 then
				(
					local arr = #(), cur
					for cur = 2 to _meshgroup.count do
						append arr _meshgroup[cur]
					ofio_iv_mesh.linearAttach _meshgroup[1] arr
					_meshgroup.count = 1					
				)
				-- set props
				if _meshgroup.count == 1 then
				(
					convertToMesh _meshgroup[1]
					_meshgroup[1].parent = undefined
					_meshgroup[1].name = "common_mesh"
					setUserProp _meshgroup[1] "type" "mesh"
				)				
				meshgroups[i] = _meshgroup
			)
		)
		
		local i
		for i = 1 to 4 do
		(
			for cur_mesh in meshgroups[i] do
			(
				local mesh_decl = ofio_iv_mesh_decl()
				mesh_decl.boneid = 0
				if cur_mesh.parent != undefined then
				(
					if ofutils.lowercase(getUserProp cur_mesh.parent "type") == "bone" then
					(
						local bone_id = getUserProp cur_mesh.parent "_ignore_this_autogenerated_index"
						if bone_id != undefined then
							mesh_decl.boneid = bone_id
					)
				)
				mesh_decl.path = cur_mesh.name + "_"
				local ofio_mesh = ofio_iv_mesh()
				local skel = undefined
				if skel_obj != undefined then 
					skel = skel_obj.rootBone.boneObject
				local e = undefined
				try (
					ofio_mesh.dump cur_mesh material_hashes skel:skel normal_as_skinned:chunked_as_skinned
				) catch (
					e = getcurrentexception()
					if chunked_as_skinned then
					(
						local _i, _j
						for _i = 1 to meshgroups.count do
							if meshgroups[_i].count > 0 then
								for _j = 1 to meshgroups[_i].count do
									delete meshgroups[_i][_j]
					)					
				)
				ofio_mesh.cleanup() -- cleans up mesh scene objects if any
				if e != undefined then throw e
				case i of
				(
					1: 
					(
						mesh_decl.path += "high.mesh"
						append high_obj ofio_mesh
						append lodgroup_high mesh_decl
					)
					2: 
					(
						mesh_decl.path += "med.mesh"
						append med_obj ofio_mesh
						append lodgroup_med mesh_decl
					)		
					3: 
					(
						mesh_decl.path += "low.mesh"
						append low_obj ofio_mesh
						append lodgroup_low mesh_decl
					)		
					4: 
					(
						mesh_decl.path += "vlow.mesh"
						append vlow_obj ofio_mesh
						append lodgroup_vlow mesh_decl
					)		
				)
			)
		)
		
		-- cleanup cloned meshgroups
		if chunked_as_skinned then
		(
			local i, j
			for i = 1 to meshgroups.count do
				if meshgroups[i].count > 0 then
					for j = 1 to meshgroups[i].count do
						delete meshgroups[i][j]
		)		
		
		-- bounds
		local coords = #()
		for cur_mesh in high_obj do
		(
			append coords cur_mesh.m_Boundbox[1]
			append coords cur_mesh.m_Boundbox[2]
		)
		local bounds = calculate_bounds coords
		lodgroup_AABBMin = bounds[1]
		lodgroup_AABBMax = bounds[2]
		lodgroup_center = bounds[3]
		lodgroup_radius = bounds[4]
		
	),
	
	fn build_skinned_mesh_as_chunked _obj mtls = (
		_obj.build_skinned_as_chunked()
		local i, j
		if _obj != undefined do 
		(
			for i = 1 to _obj.objs.count do
			(
				if _obj.objs[i] == undefined then continue
				-- set materials
				for j = 1 to _obj.objs[i].count do
					_obj.objs[i][j][1].Material = mtls[_obj.objs[i][j][2] + 1]			
				-- attach same bone related meshes
				if _obj.objs[i].count > 1 then
					for j = 2 to _obj.objs[i].count do
						attach _obj.objs[i][1][1] _obj.objs[i][j][1]
				-- props					
				setUserProp _obj.objs[i][1][1] "type" "common_mesh"
			)	
		)
		
	),
	
	fn build_mesh _obj mtls name = (
		local i 
		if _obj != undefined then
		(
			ofioLog.print ("building mesh " + name)
			_obj.build()		
			for i = 1 to _obj.objs.count do
				_obj.objs[i].Material = mtls[_obj.Mtls[i].Id + 1]
			if _obj.objs.count > 1 then
			(
				for i = 2 to _obj.objs.count do
					attach _obj.objs[1] _obj.objs[i]				
				_obj.objs.count = 1
			)
			if _obj.Skinned == 1 then
				_obj.skin_attached bone_using_id			
			_obj.objs[1].name = name
			setUserProp _obj.objs[1] "type" "mesh"
		)
		_obj		
	),	
	
	fn add_bone_object root bone_arr = (
		bone_arr[root.Index+1] = root
		if root.Children != undefined then
		(
			local child
			for child in root.Children do
				bone_arr = add_bone_object child bone_arr
		)
		return bone_arr
	),
	

	fn build skinned_as_chunked:false Load_Mesh:true = (
		descriptor = dummy boxsize:[0.3, 0.3, 0.3]
		descriptor.name = "dr_" + descName
		setUserProp descriptor "type" "drawable"		
		
		ofioLog.print ("building drawable " + descName)
		local mtls = #()
		local shader
		mat_i = 1
		for shader in shadinggroup_shaders do
		(
			local mtl = btlcMaterial.SetMaterialData shader MatId:mat_i
			--mtl = Btlc_GetShaderMaterials mtl shader cur_path TexDir
			--mtl.setInfo shader cur_path
			--mtl.delegate.diffusecolor = random black white
			append mtls mtl
			mat_i = mat_i + 1
		)
		_mtls = mtls

		bone_using_id = #()
		if skel_obj != undefined then
		(
			ofioLog.print "building skel"
			--skel_obj.build descriptor
			--bone_using_id = add_bone_object skel_obj.rootBone #()
			-- if mesh is skinned then skel must be rotated to the default pos
		/*	if (high_obj.count > 0) and (high_obj[1].Skinned == 1) then
			(
				local bone
				for bone in bone_using_id do 
				(
					if bone != undefined and bone.boneObject != undefined then
					(
						in coordsys bone.boneObject.parent 
						(
							local bone_pos = bone.boneObject.pos
							--local r = bone.boneObject.rotation * -1
							--r.w *= -1
							bone.boneObject.rotation = bone.RotationQuaternion
							bone.boneObject.pos = bone_pos
						)
					)
				)			
			)*/
		)
		-- build meshes
		local i, j, obj
		-- build main drawable
		local group_arr = #()
		append group_arr #(high_obj, undefined)
		append group_arr #(med_obj, "med")
		append group_arr #(low_obj, "low")
		append group_arr #(vlow_obj, "vlow")

		if Load_Mesh == true then 
		(
			for j = 1 to group_arr.count do
			(
				local group = group_arr[j][1]
				if group == undefined then continue			
				local lod = group_arr[j][2]
				i = 0
	
				for obj in group do
				(	
					if not skinned_as_chunked then
					(
						if i == 0 then 
						(
							if descName.count >  19 do descName = substring descName 1 19 
							build_mesh obj mtls (descName )
						) 
						else 
						(
							local tmpName =  (descName + "_" + (i as string) )
							if tmpName.count >  19 do tmpName = substring tmpName 1 19 
							build_mesh obj mtls (tmpName )
						)
						
	
						if bone_using_id.count > 0 then
						(
							-- using lodgroup_high, binded bones are the same for every lod group
							-- set positions right and delete the annoying bones directly
							if obj != undefined do (
								local bone_obj = bone_using_id[lodgroup_high[i+1].boneid+1].boneObject
								obj.objs[1].position = bone_obj.position
								if obj.Skinned != 1 then
								(
									obj.objs[1].transform = bone_obj.transform 					
								) 
								delete bone_obj
							) 
						
						) else
						(
							--obj.objs[1].parent = descriptor
						)
						
						i += 1
						if obj != undefined do 
						(
						btlcMaterial.ReshuffleByShader obj.objs[1]
						btlcVertexPaint.PrelightModel obj.objs[1]
						btlcVertexPaint.MoveAlphaChannel obj.objs[1]
						)
					
					) else
					(
						if obj.Skinned == 0 then
						(
							--delete descriptor
							skel_obj.cleanup()
							throw "FRAGMENT ERROR\n\nOnly fragments with skinned meshes can be handled by OFIO\n"
						)
						build_skinned_mesh_as_chunked obj mtls	
						local k
						if obj != undefined do 
						(
							for k = 1 to obj.objs.count do
							(
								if obj.objs[k] == undefined then continue
								local _obj = obj.objs[k][1][1]
								local _lod = ""
								_obj.parent = bone_using_id[k].boneObject	
								
								if lod != undefined then
								(
									_lod = "_" + lod
									setUserProp _obj "lod" lod										
								)
								_obj.name = "cm_" + _obj.parent.name + _lod					
							)
						)
					
					)	
	
					if obj != undefined and  obj.objs[1] != undefined do 
					(
						if i > 1  do obj.objs[1].parent = group[1].objs[1]
						
					)
				
					
				)
				
			)
		)
		
		delete descriptor -- kill the useless descriptor nonesense
		-- build lights
		light_root = undefined
		--lights.count = 0;
		if lights.count > 0 then
		(
			ofioLog.print "building lights"
			
			if Load_Mesh == true then 
			(
				light_root = group_arr[1][1][1].objs[1]
			)
			else 
			(
				light_root =  dummy boxsize:[0.3, 0.3, 0.3]
				light_root.name = descName
			)

				
			--light_root.name = "lights_" + descName
			--setUserProp light_root "type" "lights_root"		
			--light_root.parent = group_arr[1][1][1].objs[1]	
			
			for i = 1 to lights.count do
			(
				local light = freespot()
				light.usefaratten = true
				light.showfaratten = true
				light.farattenstart = 0		
				light.parent = light_root
				
				local light_bone = undefined
				if skel_obj != undefined then
					light_bone = skel_obj.boneObjUsingGameId skel_obj.rootBone lights[i].BoneID
				if light_bone == undefined then
					light_bone = light_root
				
				in coordsys light_bone
				(
					light.dir = lights[i].Direction * -1
					light.pos = lights[i].Position					
				)				
				
				light.color = lights[i].Color
				light.farattenend = lights[i].Distance / 2 
				light.multiplier = lights[i].Range / 8 --originally divided by 10. but its kind weak at times. 
				light.falloff = lights[i].Falloff
				
				local type = ofutils.lowercase(lights[i].Type)
				if type == "omni" then
				(
					light.type = #omni
				) else
				(
					light.type = #freeSpot
					light.hotspot = lights[i].HotSpot
				)
				--light.type = #omni
				setUserProp light "type" "light"
				setUserProp light "typeflags" lights[i].TypeFlags					
				setUserProp light "coronasize" lights[i].CoronaSize
				setUserProp light "coronahash" ("\x22" + lights[i].CoronaHash + "\x22")
				setUserProp light "luminescencehash" ("\x22" + lights[i].LuminescenceHash + "\x22")
				setUserProp light "flags" lights[i].Flags
				setUserProp light "boneid" lights[i].BoneID
				
				setUserProp light "_f28" lights[i]._f28
				setUserProp light "_f2C" lights[i]._f2C
				setUserProp light "_f30" lights[i]._f30
				setUserProp light "_f58" lights[i]._f58
				setUserProp light "_f5C" lights[i]._f5C
				setUserProp light "_f60" lights[i]._f60				
				setUserProp light "_f66" lights[i]._f66
				
				lights[i].obj = light
			)
		)
		
		if group_arr[1][1][1] != undefined do group_arr[1][1][1].objs[1] --return object to make veryones life easier
		
	),
	

	-- cleans up all drawable objects
	fn cleanup = (
		local group, obj, light
		-- clean each lod group
		for group in #(high_obj, med_obj, low_obj, vlow_obj) do
			for obj in group do
				if obj != undefined then 
					obj.cleanup()
		-- clean skel
		if skel_obj != undefined then 
			skel_obj.cleanup()
		-- clean lights
		for light in lights do
			if light != undefined then
				if light.obj != undefined then delete light.obj
		if light_root != undefined then delete light_root
		-- clean descriptor
		try(if descriptor != undefined then delete descriptor) catch() 
	),	
	
	fn write_lights fOutput padding = (
		if lights.count == 0 then 
			return OK
		local out_path = cur_path + descName
		local lights_name = descName + ".light"
		local fLight = CreateFile (out_path + "\\" + lights_name)
		format "Version 1 10\n{\n" to:fLight
		local i = 0
		local light
		for light in lights do
		(
			format ("\x09" + "Attribute %\n\x09{\n") i to:fLight
			format ("\x09\x09" + "Position % % %\n") light.Position[1] light.Position[2] light.Position[3] to:fLight
			format ("\x09\x09" + "Direction % % %\n") light.Direction[1] light.Direction[2] light.Direction[3] to:fLight
			format ("\x09\x09" + "Origin % % %\n") light.Origin[1] light.Origin[2] light.Origin[3] to:fLight
			format ("\x09\x09" + "Color % % % 0\n") (light.Color.r as Integer) (light.Color.g as Integer) (light.Color.b as Integer) to:fLight
			format "\x09\x09_f28 %\n" light._f28 to:fLight
			format "\x09\x09_f2C %\n" light._f2C to:fLight
			format "\x09\x09_f30 %\n" light._f30 to:fLight
			format ("\x09\x09" + "Distance %\n") light.Distance to:fLight
			format ("\x09\x09" + "Range %\n") light.Range to:fLight
			format ("\x09\x09" + "CoronaSize %\n") light.CoronaSize to:fLight
			format ("\x09\x09" + "HotSpot %\n") light.HotSpot to:fLight
			format ("\x09\x09" + "Falloff %\n") light.Falloff to:fLight
			format ("\x09\x09" + "Flags %\n") (light.Flags as Integer) to:fLight
			format ("\x09\x09" + "CoronaHash %\n") light.CoronaHash to:fLight
			format ("\x09\x09" + "LuminescenceHash %\n") light.LuminescenceHash to:fLight
			format "\x09\x09TypeFlags" to:fLight
			local flag
			for flag in light.TypeFlags do
				format " %" flag to:fLight
			format "\n"	to:fLight
			format "\x09\x09Type %\n" light.Type to:fLight
			format "\x09\x09_f58 %\n" light._f58 to:fLight
			format "\x09\x09_f5C %\n" light._f5C to:fLight
			format "\x09\x09_f60 %\n" light._f60 to:fLight
			format ("\x09\x09" + "BoneID %\n") (light.BoneID as Integer) to:fLight
			format "\x09\x09_f66 %\n" (light._f66 as Integer) to:fLight
			format "\x09}\n" to:fLight
			i += 1
		)
		format "}\n" to:fLight			
		close fLight
		
		format "%light\n%{\n" padding padding to:fOutput
		format "%\x09light %\n" padding (descName + "\\" + lights_name) to:fOutput
		format "%}\n" padding to:fOutput			
	),

	fn write_single fOutput dict:false dict_fragments:false = (
		local out_path = cur_path + descName
		makeDir out_path all:true
		local padding = ""
		if dict then padding = "\x09\x09"
		if dict_fragments then padding = "\x09"
		
		-- shaders
		format "%shadinggroup\n%{\n" padding padding to:fOutput
		format "%\x09Shaders %\n%\x09{\n" padding shadinggroup_shaders.count padding to:fOutput
		local shader, i, j
		for shader in shadinggroup_shaders do
		(
			format "%\x09\x09" padding to:fOutput
			for i = 1 to shader.count do
			(				
				-- a way to find textures with absolute path
				if (findString shader[i] ":") != undefined then
				(	
					-- if texture exists then copy it and set it's the path to relative
					if (getFileSize (shader[i])) > 0 then
					(
						local tex_name = ofutils.extractFileName(shader[i])
						copyFile shader[i] (out_path + "\\" + tex_name)
						shader[i] = descName + "\\" + tex_name
					) else -- if texture doesn't exist then make it look like it is external one
					(
						shader[i] = ofutils.removeExt(ofutils.extractFileName(shader[i]))
					)			
				)
				format "% " shader[i] to:fOutput
			)			
			format "\n" to:fOutput
		)
		format "%\x09}\n" padding to:fOutput
		format "%}\n" padding to:fOutput
		
		-- skel
		if skel_obj != undefined then
		(
			local skel_name = descName + ".skel"
			skel_obj.write (out_path + "\\" + skel_name)
			format "%skel\n%{\n" padding padding to:fOutput
			format "%\x09skel %\n" padding (descName + "\\" + skel_name) to:fOutput
			format "%}\n" padding to:fOutput
		)
		
		-- lodgroups
		format "%lodgroup\n%{\n" padding padding to:fOutput	
		for i = 1 to 4 do
		(
			local groupname, lodgroup, obj			
			case i of
			(
				1:
				(	
					groupname = "high"
					lodgroup = lodgroup_high
					obj = high_obj
				)
				2:
				(
					groupname = "med"
					lodgroup = lodgroup_med
					obj = med_obj
				)		
				3:
				(
					groupname = "low"
					lodgroup = lodgroup_low
					obj = low_obj
				)					
				4:
				(
					groupname = "vlow"
					lodgroup = lodgroup_vlow
					obj = vlow_obj
				)					
			)
			format "%\x09% " padding groupname to:fOutput
			if (lodgroup == undefined) or (lodgroup.count == 0) then
			(
				format "none 9999.0\n" to:fOutput
			) else
			(
				format "% " lodgroup.count to:fOutput
				for j = 1 to lodgroup.count do		
				(
					local mesh_name = lodgroup[j].path
					obj[j].write (out_path + "\\" + mesh_name)
					format "% % " (descName + "\\" + mesh_name) lodgroup[j].boneid to:fOutput
				)
				format "9999.0\n" to:fOutput
			)	
		)	
		format ("%\x09" + "center % % %\n") padding lodgroup_center[1] lodgroup_center[2] lodgroup_center[3] to:fOutput
		format ("%\x09" + "AABBMin % % %\n") padding lodgroup_AABBMin[1] lodgroup_AABBMin[2] lodgroup_AABBMin[3] to:fOutput
		format ("%\x09" + "AABBMax % % %\n") padding lodgroup_AABBMax[1] lodgroup_AABBMax[2] lodgroup_AABBMax[3] to:fOutput
		format ("%\x09" + "radius %\n") padding lodgroup_radius to:fOutput
		format "%}\n" padding to:fOutput		
		
		-- light
		if (not dict_fragments) and (lights.count > 0) then
			write_lights fOutput padding	
	),
	
	fn read_lights fInput = (
		lights = #()
		local blockstart = scanline fInput
		if blockstart[1] != "{" then throw "lights start expected"
		local elements = scanline fInput
		while elements[1] != "}" do
		(	
			case ofutils.lowercase(elements[1]) of
			(
				"light":
				(
					local fname = cur_path + elements[2]
					if (getFileSize fname) == 0 then throw ("can't find file " + fname)
					local fLight = openFile fname
					local version = scanline fLight		
					if (version[2] as Integer != 1) or (version[3] as Integer != 10) then
								throw "not supported light, version 1 10 is supported only"								
					local blockstart = scanline fLight
					elements = scanline fLight
					while elements[1] != "}" do
					(
						if ofutils.lowercase(elements[1]) != "attribute" then
							throw "light attribute expected"
						local light = light_attribute()
						blockstart = scanline fLight
						elements = scanline fLight
						while elements[1] != "}" do
						(
							case ofutils.lowercase(elements[1]) of
							(						
								"position": light.Position = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
								"direction": light.Direction = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
								"origin": light.Origin = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
								"color": light.Color = Color (elements[2] as Integer) (elements[3] as Integer) (elements[4] as Integer) (elements[5] as Integer)
								"_f28": light._f28 = elements[2] as Float
								"_f2c": light._f2C = elements[2] as Float
								"_f30": light._f30 = elements[2] as Float
								"distance": light.Distance = elements[2] as Float
								"range": light.Range = elements[2] as Float
								"coronasize": light.CoronaSize = elements[2] as Float
								"hotspot": light.HotSpot = elements[2] as Float
								"falloff": light.Falloff = elements[2] as Float
								"flags": light.Flags = elements[2] as Integer
								"coronahash": light.CoronaHash = elements[2] as String
								"luminescencehash": light.LuminescenceHash = elements[2] as String
								"typeflags": light.TypeFlags = deleteItem elements 1
								"type": light.Type = elements[2]
								"_f58": light._f58 = elements[2] as Float
								"_f5c": light._f5C = elements[2] as Float
								"_f60": light._f60 = elements[2] as Float
								"boneid": light.BoneID = elements[2] as Integer
								"_f66": light._f66 = elements[2] as Integer
								default: throw ("unknown light attribute element " + elements[1])
							)
							elements = scanline fLight
						)
						append lights light
						elements = scanline fLight
					)		
					close fLight
				)
				default: throw "unknown light element"
			)
			elements = scanline fInput
		)	
	),
	
	-- reads drawable
	fn read_single fInput dict:false = (		
		while True do
		(
			if eof fInput then 
				if not dict
					then exit
					else throw ""
					
			local elements = scanline fInput
			if dict then
			(
				if elements[1] == "{" then elements = scanline fInput
				if elements[1] == "}" then exit				 
			)
			
			if elements.count == 0 then continue
			case ofutils.lowercase(elements[1]) of
			(
				"shadinggroup":
				(
					local blockstart = scanline fInput
					if blockstart[1] != "{" then throw "block start expected"
					local shaders_block = scanline fInput
					if ofutils.lowercase(shaders_block[1]) != "shaders" then throw "shaders expected"
					local shader_count = shaders_block[2] as Integer
					local blockstart = scanline fInput
					if blockstart[1] != "{" then throw "block start expected"							
					shadinggroup_shaders = #()
					local i
					for i = 1 to shader_count do
					(
						local shader = scanline fInput
						append shadinggroup_shaders shader
					)
					local blockend = scanline fInput
					if blockend[1] != "}" then throw "block end expected"			
					local blockend = scanline fInput
					if blockend[1] != "}" then throw "block end expected"
				)
				"skel":
				(
					local blockstart = scanline fInput
					if blockstart[1] != "{" then throw "block start expected"
					local skel = scanline fInput
					if ofutils.lowercase(skel[1]) != "skel" then throw "skel expected"
					skel_skel = skel[2]
					local blockend = scanline fInput
					if blockend[1] != "}" then throw "block end expected"				
				)
				"lodgroup":
				(
					local blockstart = scanline fInput
					if blockstart[1] != "{" then throw "block start expected"
					elements = scanline fInput
					while elements[1] != "}" do
					(	
						case ofutils.lowercase(elements[1]) of
						(
							"high": 
							(
								if ofutils.lowercase(elements[2]) != "none" then 
								(
									lodgroup_high = #() 
									local count = elements[2] as Integer
									local i = 3 
									while count > 0 do
									(
										append lodgroup_high (ofio_iv_mesh_decl path:elements[i] boneid:(elements[i+1] as Integer))
										i += 2
										count -= 1 
									)
								)
							)
							"med": 
							(
								if ofutils.lowercase(elements[2]) != "none" then 
								(
									lodgroup_med = #() 
									local count = elements[2] as Integer
									local i = 3 
									while count > 0 do
									(
										append lodgroup_med (ofio_iv_mesh_decl path:elements[i] boneid:(elements[i+1] as Integer))
										i += 2
										count -= 1 
									)
								)
							)							
							"low": 
							(
								if ofutils.lowercase(elements[2]) != "none" then 
								(
									lodgroup_low = #() 
									local count = elements[2] as Integer
									local i = 3 
									while count > 0 do
									(
										append lodgroup_low (ofio_iv_mesh_decl path:elements[i] boneid:(elements[i+1] as Integer))
										i += 2
										count -= 1 
									)
								)
							)							
							"vlow": 
							(
								if ofutils.lowercase(elements[2]) != "none" then 
								(
									lodgroup_vlow = #() 
									local count = elements[2] as Integer
									local i = 3 
									while count > 0 do
									(
										append lodgroup_vlow (ofio_iv_mesh_decl path:elements[i] boneid:(elements[i+1] as Integer))
										i += 2
										count -= 1 
									)
								)
							)							
							"radius": lodgroup_radius = (elements[2] as Float)
							"center": lodgroup_center = (elements[2] as Float)
							"aabbmax": lodgroup_AABBMax = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
							"aabbmin": lodgroup_AABBMin = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
							default: throw "unknown lodgroup element"
						)
						elements = scanline fInput	
					)							
				)
				"light":
				(
					read_lights fInput
				)
				default: throw "unknown drawable element"
			)
		)
		if (skel_skel != undefined) then
		(
			skel_obj = ofio_iv_skeleton()
			skel_obj.read (cur_path + skel_skel)			
		)
		local cur_mesh
		high_obj = #()
		if (lodgroup_high != undefined) and (lodgroup_high.count > 0) then
		(
			for cur_mesh in lodgroup_high do
			(
 				local obj = ofio_iv_mesh()
				obj.read (cur_path + cur_mesh.path)
				append high_obj obj
			)
		)		
		med_obj = #()
		if (lodgroup_med != undefined) and (lodgroup_med.count > 0) then
		(
			for cur_mesh in lodgroup_med do
			(
 				local obj = ofio_iv_mesh()
				obj.read (cur_path + cur_mesh.path)
				append med_obj obj
			)
		)	
		low_obj = #()
		if (lodgroup_low != undefined) and (lodgroup_low.count > 0) then
		(
			for cur_mesh in lodgroup_low do
			(
 				local obj = ofio_iv_mesh()
				obj.read (cur_path + cur_mesh.path)
				append low_obj obj
			)
		)
		vlow_obj = #()
		if (lodgroup_vlow != undefined) and (lodgroup_vlow.count > 0) then
		(
			for cur_mesh in lodgroup_vlow do
			(
 				local obj = ofio_iv_mesh()
				obj.read (cur_path + cur_mesh.path)
				append vlow_obj obj
			)
		)			
	),
	
	fn read fInputName = (
		local fInput = openFile fInputName
		local version = scanline fInput		
		if (version[2] as Integer != 110) or (version[3] as Integer != 12) then
			throw "not supported odr, version 110 12 is supported only"			
		descName = ofutils.removeExt(ofutils.extractFileName fInputName)
		cur_path = ofutils.extractFilePath(fInputName)	
		read_single fInput 
		close fInput
	),

	fn write fOutputName = (
		local fOutput = createFile fOutputName
		format "Version 110 12\n" to:fOutput
		cur_path = ofutils.extractFilePath(fOutputName)
		descName = ofutils.removeExt(ofutils.extractFileName fOutputName)
		write_single fOutput
		close fOutput
	),
	
	fn read_dict fInput desc_name curPath = (
		cur_path = curPath
		descName = desc_name
		read_single fInput dict:true
	),
	
	fn filename_from_scenename objname = (
		local name_contents = filterString (ofutils.lowercase objname) "_"
		if (objname.count < 4) or (name_contents.count < 2) then 
			throw ("NAME ERROR\n\n" + "odr file descriptor has no valid name or descriptor is not selected\n")
		if name_contents[1] != "dr" then 
			throw ("NAME ERROR\n\n" + "odr file descriptor name must start with 'dr_'\n")
		local i, filename = ""
		for i = 4 to objname.count do
			filename += objname[i]
		filename += ".odr"	
		return filename
	)	
)

struct ofio_iv_odd (
	descriptor,
	descName,
	
	drawables = #(),
	drawable_names = #(),
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		l = undefined	
		return s
	),	
	
	fn read fInputName = (
		local fInput = openFile fInputName
		local version = scanline fInput		
		if (version[2] as Integer != 110) or (version[3] as Integer != 12) then
			throw "not supported odd, version 110 12 is supported only"		
		descName = ofutils.removeExt(ofutils.extractFileName fInputName)
		local cur_path = ofutils.extractFilePath(fInputName)	
		
		local elements = scanline fInput
		if elements[1] != "{" then throw "odd start expected"
		elements = scanline fInput
		
		while elements[1] != "}" do
		(
			if ofutils.lowercase(elements[1]) != "gtadrawable" then throw ""
		
			local obj = ofio_iv_odr()
			obj.read_dict fInput elements[2] cur_path
			
			append drawables obj
			
			elements = scanline fInput
		)
		
		close fInput			
	),
	
	fn write fOutputName = (
		local fOutput = createFile fOutputName
		format "Version 110 12\n{\n" to:fOutput
		local i 
		for i = 1 to drawables.count do
		(
			format "\x09gtaDrawable %\n\x09{\n" drawable_names[i] to:fOutput
			drawables[i].cur_path = ofutils.extractFilePath(fOutputName)
			drawables[i].descName = drawable_names[i]
			drawables[i].write_single fOutput dict:true
			format "\x09}\n" to:fOutput
		)
		format "}\n" to:fOutput
		close fOutput	
	),
	
	fn dump obj = (
		if ofutils.lowercase(getUserProp obj "type") != "drawable_dictionary" then
			throw ("DICTIONARY ERROR\n\n" + obj.name + " type is not drawable_dictionary")	
		drawables = #()
		drawable_names = #()
		local child
		for child in obj.Children do
		(
			ofioLog.print("dumping " + child.name + " to dictionary")
			local dr = ofio_iv_odr()
			local dr_name = ofutils.removeExt(dr.filename_from_scenename child.name)
			if ofutils.lowercase(getUserProp child "type") != "drawable" then
				throw ("DICTIONARY ERROR\n\n" + child.name + " type must be drawable")
			dr.dump child
			append drawables dr
			append drawable_names dr_name
		)
		if drawables.count == 0 then
			throw ("DICTIONARY ERROR\n\n" + obj.name + " has no drawable children")
	),	
	
	fn build = (
		ofioLog.print ("building drawable dictionary " + descName)
		--descriptor = dummy boxsize:[0.3, 0.3, 0.3]
		--descriptor.name = "ddict_" + descName
		--setUserProp descriptor "type" "drawable_dictionary" 
		local bone_using_id
		for obj in drawables do
		(
			obj.build()
			--obj.descriptor.parent = descriptor
		)
	),
	
	fn cleanup = (
		local obj
		for obj in drawables do
			if obj != undefined then obj.cleanup()
		if descriptor != undefined then delete descriptor
	),
	
	fn filename_from_scenename objname = (
		local name_contents = filterString (ofutils.lowercase objname) "_"
		if (objname.count < 7) or (name_contents.count < 2) then 
			throw ("NAME ERROR\n\n" + "odd file descriptor has no valid name or descriptor is not selected\n")
		if name_contents[1] != "ddict" then 
			throw ("NAME ERROR\n\n" + "odd file descriptor name must start with 'ddict_'\n")
		local i, filename = ""
		for i = 7 to objname.count do
			filename += objname[i]
		filename += ".odd"	
		return filename
	)		
)


