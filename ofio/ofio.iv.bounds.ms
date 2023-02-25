-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: obn/obd
-- Last changed: Aug 2014

global ofio_iv_opened_blocks

fileIn "ofio.iv.bounds.mtl.ms"
fileIn "ofio.iv.bounds.primitives.ms"

struct ofio_iv_bound_bvh (
	Margin,	
	Polygons = #(),
	VertexScale,
	VertexOffset,
	Vertices = #(),
	Materials = #()	
)

struct ofio_iv_bound_geometry (
	Margin,	
	Polygons = #(),
	VertexScale,
	VertexOffset,
	Vertices = #(),
	Shrunk = #(),
	Materials = #()	
)

struct ofio_iv_bound_curved_geometry (
	Margin,	
	VertexScale,
	VertexOffset,
	Vertices = #(),
	Materials = #(),
	CurvedEdges = #()
)


struct ofio_iv_bound_box (
	Margin,	
	VertexScale,
	VertexOffset,
	Extents,
	Material
)

struct ofio_iv_bound_sphere (
	Material
)

struct ofio_iv_bound_capsule (
	Material,
	CapsuleRadius,
	CapsuleHeight
)

struct ofio_iv_bound_composite (
	Margin,
	Children = #(),
	ChildTransforms
)

struct ofio_iv_bound_common_polygon (
	Material,
	Vertices = #(), -- 4 verts
	Siblings = #()  -- 4 edges
)

struct ofio_iv_bound_curved_edge (
	unk_V,
	unk_V2,
	unk_F,
	Vertices = #()
)

struct ofio_iv_bound_container (
	type,
	name,
	CentroidPresent,
	CGPresent,
	Radius,
	WorldRadius,
	AABBMax,
	AABBMin,
	Centroid,
	CenterOfMass,
	bound, -- type uniq data
	boundObject, -- scene object
	compositeIndependent, -- for obn
	
	is_empty,
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		if s.count == 1 then
			if s[1] == "{" then ofio_iv_opened_blocks += 1 else
				if s[1] == "}" then ofio_iv_opened_blocks -= 1
		l = undefined	
		return s
	),
	
	fn build = (
		boundObject = undefined
		local t = ofutils.lowercase(type)
		case of
		(
			(t == "boundbox"):
			(
				boundObject = ofio_iv_col_box width:(AABBMax.x - AABBMin.x) depth:(AABBMax.y - AABBMin.y) height:(AABBMax.z - AABBMin.z)
				boundObject.name = btlcUtil.CutNameAdv name	
				--boundObject.pos = bound.VertexOffset
				if CentroidPresent == 1 then boundObject.pos = Centroid
				setUserProp boundObject "type" type
				setUserProp boundObject "margin" bound.Margin
				-- mtl
				local material = iv_col_material()
				material.mtlid = bound.Material[1]
				material.mtlprocid = bound.Material[2]	
				material.flags = bound.Material[3]
				boundObject.Material = material
			)
			(t == "boundsphere"):
			(
				boundObject = ofio_iv_col_sphere radius:Radius
				boundObject.name = btlcUtil.CutNameAdv name	
				if CentroidPresent == 1 then boundObject.pos = Centroid
				setUserProp boundObject "type" type
				-- mtl
				local material = iv_col_material()
				material.mtlid = bound.Material[1]
				material.mtlprocid = bound.Material[2]	
				material.flags = bound.Material[3]
				boundObject.Material = material				
			)			
			(t == "boundcapsule"):
			(
				boundObject = ofio_iv_col_capsule radius:bound.CapsuleRadius height:bound.CapsuleHeight
				boundObject.name = btlcUtil.CutNameAdv name	
				if CentroidPresent == 1 then boundObject.pos = Centroid
				setUserProp boundObject "type" type
				-- mtl
				local material = iv_col_material()
				material.mtlid = bound.Material[1]
				material.mtlprocid = bound.Material[2]	
				material.flags = bound.Material[3]
				boundObject.Material = material				
			)
			(t == "boundcurvedgeometry"):
			(
				if (bound.Vertices.count != 2)  \
				or (bound.Materials.count != 2) \
				or (bound.CurvedEdges.count != 2)
					then throw "curved geometry for wheels is supported only"
				local r = bound.Vertices[1].z * bound.VertexScale.z
				if r < 0 then r *= -1				
				boundObject = ofio_iv_col_sphere radius:r
				boundObject.name = btlcUtil.CutNameAdv name	
				setUserProp boundObject "type" type	
				setUserProp boundObject "margin" bound.Margin.z
				setUserProp boundObject "unk1" bound.CurvedEdges[2].unk_V.x
				-- mtl
				local material = iv_col_material()
				material.mtlid = bound.Materials[1][1]
				material.mtlprocid = bound.Materials[1][2]	
				material.flags = bound.Materials[1][3]
				boundObject.Material = material					
			)			
			(t == "boundcomposite"): 
			(
				boundObject = dummy boxsize:[0.1, 0.1, 0.1]
				boundObject.name = btlcUtil.CutNameAdv name
				if compositeIndependent == true then boundObject.pos = Centroid
				setUserProp boundObject "type" type
				setUserProp boundObject "margin" bound.Margin
				setUserProp boundObject "centerofmass" CenterOfMass
				local i
				for i = 1 to bound.Children.count do
				(
					local obj = bound.Children[i]
					local curObj = obj.build()
					curObj.parent = boundObject	
					
					if ofutils.lowercase(obj.type) != "boundbvh" then
					(
						curObj.transform *= bound.ChildTransforms[i] * boundObject.transform
					)										
					
					ofioLog.progress (100.0 * i / bound.Children.count)				
				)
			)
			(t == "boundgeometry" or t == "boundbvh"): 
			(
				boundObject = Editable_Mesh name:(btlcUtil.CutNameAdv name)
				convertTo boundObject (Editable_Poly)
				setUserProp boundObject "type" type
				setUserProp boundObject "margin" bound.Margin
				setUserProp boundObject "centerofmass" CenterOfMass
				local i, j
				-- create materials
				local mmat = multimaterial numsubs:bound.Materials.count
				for i = 1 to bound.Materials.count do
				(
					mmat[i] = iv_col_material()
					mmat[i].mtlid = bound.Materials[i][1]
					mmat[i].mtlprocid = bound.Materials[i][2]	
					mmat[i].flags = bound.Materials[i][3]				
				)
				boundObject.material = mmat
				
				-- set mesh verts
				for i = 1 to bound.Vertices.count do 
					polyOp.createVert boundObject (bound.Vertices[i] * bound.VertexScale)
				-- set mesh polygons
				for i in bound.Polygons do
				(
					local poly_verts = #(), poly_vert_coords = #()				
					for j in i.Vertices do 
					(	
						if (j == 0) and (poly_verts.count == 3) then exit
						append poly_verts (j + 1)
						append poly_vert_coords bound.Vertices[j+1]	
					)								
					-- create polygon
					local poly = polyOp.createPolygon boundObject poly_verts
					if poly == undefined then 
					(
						-- vertex fix
						for j = 1 to poly_verts.count do 
							poly_verts[j] = polyOp.createVert boundObject (poly_vert_coords[j] * bound.VertexScale)
						poly = polyOp.createPolygon boundObject poly_verts
						if poly == undefined then format "can't create polygon %\n" poly_verts
					)
					-- set material
					if poly != undefined then polyop.setFaceMatID boundObject poly (i.Material + 1)
				)
				
				-- world pos
				boundObject.pivot = 	boundObject.pivot - bound.VertexOffset;
				print bound.VertexOffset
				boundObject.pos = bound.VertexOffset
			)
			default: throw ("unknown bound type " + type)		
		)
		return boundObject
	),
	
	fn dump obj = (
		ofioLog.print("dumping " + obj.name)
		type = getUserProp obj "type"
		local t 
		if type != undefined and type.count > 0 
			then t = ofutils.lowercase(type)
			else t = ""
		case of
		(
			(classof obj == ofio_iv_col_sphere and t == "boundcurvedgeometry"):
			(
				type = "BoundCurvedGeometry"
				bound = ofio_iv_bound_curved_geometry()
				-- name
				name = obj.name
				-- margin
				local Margin = getUserProp obj "margin"
				if Margin == undefined 
					then Margin = Point3 0.133 0.133 0.133
					else Margin = Point3 Margin Margin Margin
				bound.Margin = Margin	
				-- centroid
				CentroidPresent = 0
				CGPresent = 0
				-- bounds
				AABBMax = [Margin.x, obj.radius + Margin.y, obj.radius + Margin.z]
				AABBMin = [-Margin.x, -(obj.radius + Margin.y), -(obj.radius + Margin.z)]
				-- radius
				Radius = distance AABBMax [0, 0, 0]
				WorldRadius = 0	
				-- scale
				bound.VertexScale = (AABBmax - AABBMin) / 65535	
				-- pos
				bound.VertexOffset = obj.pos
				-- verts
				bound.Vertices = #([0, 0, -obj.radius] / bound.VertexScale, [0, 0, obj.radius] / bound.VertexScale)
				bound.Materials = #([obj.material.mtlid, obj.material.mtlprocid, obj.material.flags], \
									[obj.material.mtlid, obj.material.mtlprocid, obj.material.flags])
				-- edges
				local e1 = ofio_iv_bound_curved_edge(), e2 = ofio_iv_bound_curved_edge()
				bound.CurvedEdges = #(e1, e2)
				unk1 = getUserProp obj "unk1"
				if unk1 == undefined then unk1 = 0.001
				e1.unk_V = [-unk1, 0, 0.00000522]
				e1.unk_V2 = [1, 0, 0]
				e1.unk_F = obj.radius
				e1.Vertices = #(0, 1)
				e2.unk_V = [unk1, 0, 0.00000522]
				e2.unk_V2 = [1, 0, 0]
				e2.unk_F = obj.radius
				e2.Vertices = #(1, 0)	
			)
			(classof obj == ofio_iv_col_box):
			(
				type = "BoundBox"
				bound = ofio_iv_bound_box()
				-- name
				name = obj.name
				-- margin
				local Margin = getUserProp obj "margin"
				if Margin == undefined or Margin.count != 3 then Margin = Point3 0.025 0.025 0.025
				bound.Margin = Margin
				-- pos
				bound.VertexOffset = obj.pos
				-- bounds
				AABBMin = bound.VertexOffset + [-0.5, -0.5, -0.5] * [obj.width, obj.depth, obj.height]
				AABBMax = bound.VertexOffset + [0.5, 0.5, 0.5] * [obj.width, obj.depth, obj.height]
				-- centroid
				CentroidPresent = 1
				CGPresent = 1
				Centroid = (AABBMin + AABBMax) / 2
				CenterOfMass = Centroid
				-- radius
				Radius = length (AABBmax - Centroid)
				WorldRadius = amax #(length AABBmin, length AABBmax)
				-- scale
				bound.VertexScale = (AABBmax - AABBMin) / 65535
				-- extents
				bound.Extents = [(abs AABBMin.x) + (abs AABBmax.x), (abs AABBMin.y) + (abs AABBmax.y), (abs AABBMin.z) + (abs AABBmax.z)]	
				-- mtl
				if (obj.material == undefined) or (classof obj.material != iv_col_material) then
					throw ("incorrect material for " + obj as String)
				bound.Material = [obj.material.mtlid, obj.material.mtlprocid, obj.material.flags]
			)
			(classof obj == ofio_iv_col_sphere):
			(
				type = "BoundSphere"
				bound = ofio_iv_bound_sphere()
				-- name
				name = obj.name
				-- bounds
				AABBMin = obj.min
				AABBMax = obj.max
				-- centroid
				CentroidPresent = 1
				CGPresent = 1
				Centroid = (AABBMin + AABBMax) / 2
				CenterOfMass = Centroid
				-- radius
				Radius = obj.radius
				WorldRadius = Radius
				-- mtl
				if (obj.material == undefined) or (classof obj.material != iv_col_material) then
					throw ("incorrect material for " + obj as String)
				bound.Material = [obj.material.mtlid, obj.material.mtlprocid, obj.material.flags]
			)	
			(classof obj == ofio_iv_col_capsule):
			(
				type = "BoundCapsule"
				bound = ofio_iv_bound_capsule()
				-- name
				name = obj.name
				-- bounds
				local capsule_point = obj.min
				local coord = capsule_point.z
				capsule_point.z = capsule_point.y
				capsule_point.y = coord				
				AABBMin = capsule_point				
				capsule_point = obj.max
				coord = capsule_point.z
				capsule_point.z = capsule_point.y
				capsule_point.y = coord
				AABBMax = capsule_point
				-- centroid
				CentroidPresent = 1
				CGPresent = 1
				Centroid = (AABBMin + AABBMax) / 2
				CenterOfMass = Centroid
				-- radius
				Radius = length (AABBmax - Centroid)
				WorldRadius = amax #(length AABBmin, length AABBmax)
				-- capsule radius and height
				bound.CapsuleRadius = obj.radius
				bound.CapsuleHeight = obj.height
				-- mtl
				if (obj.material == undefined) or (classof obj.material != iv_col_material) then
					throw ("incorrect material for " + obj as String)
				bound.Material = [obj.material.mtlid, obj.material.mtlprocid, obj.material.flags]
			)		
			(t == "boundcomposite"): 
			(
				bound = ofio_iv_bound_composite()
				name = obj.name
				if name == "composite_root" then name = ""
				
				-- margin
				local Margin = getUserProp obj "margin"
				if Margin == undefined or Margin.count != 3 then Margin = Point3 0.04 0.04 0.04
				bound.Margin = Margin
				
				-- boundbox
				AABBMin = Point3 0xFFFF 0xFFFF 0xFFFF
				AABBMax = Point3 -0xFFFF -0xFFFF -0xFFFF
				local i, j
				for	child in obj.children do
				(
					for j = 1 to 3 do
					(
						if child.min[j] < AABBMin[j] then AABBMin[j] = child.min[j]
						if child.max[j] > AABBMax[j] then AABBMax[j] = child.max[j]
					)
				)			
	
				-- children 
				if obj.children.count == 0 then throw ("BoundComposite " + obj.name + " without children")
				bound.Children = #()
				bound.ChildTransforms = #()				
				local mass_center = 0
				for	i = 1 to obj.children.count do
				(
					local child = ofio_iv_bound_container()	
					-- name
					child.name = (i - 1) as String
					-- orig child pos	
					local child_pos = copy obj.children[i].pos 
					-- is child the one with Matrix3 1 transfrom
					local ct = ofutils.lowercase(getUserProp obj.children[i] "type")	
				
					-- dump
					local change_pos = (ct != "boundbvh") and (ct != "boundgeometry")					
					if change_pos then obj.children[i].pos = [0, 0, 0]
					local e = undefined
					try (
						child.dump obj.children[i]
					) catch	(
						e = getcurrentexception()
					)
					if change_pos then obj.children[i].pos = child_pos
					if e != undefined then throw e
					
					-- center of mass
					if child.CenterOfMass != undefined then
						if change_pos 
							then mass_center += child_pos + child.CenterOfMass
							else mass_center += child.CenterOfMass
				
					-- transform
					local t3 = Matrix3 0
					if not change_pos then
					(
						t3[1] = [1, 0, 0]
						t3[2] = [0, 1, 0]
						t3[3] = [0, 0, 1]
						t3[4] = [0, 0, 0]
					) else
					(
						local trans = (copy obj.children[i].transform)
						local ptrans = (copy obj.transform)
						trans *= inverse ptrans						
						t3 = trans
					)
					
					append bound.Children child
					append bound.ChildTransforms t3
				)	
				mass_center = mass_center / obj.children.count
				
				-- boundbox dependent
				CentroidPresent = 1
				Centroid = (AABBmax + AABBmin) / 2
				CGPresent = 1
				CenterOfMass = mass_center
				Radius = length (AABBmax - Centroid) --Radius = length ((AABBmax - AABBmax * Margin) - Centroid)
				WorldRadius = amax #(length AABBmin, length AABBmax) --WorldRadius = amax #(length (AABBmin + AABBmin * Margin), length (AABBmax - AABBmax * Margin))	
			)	
			(t == "boundbvh" or t == "boundgeometry"): 			
			(
				convertToPoly obj
				
				if t == "boundbvh" 
					then bound = ofio_iv_bound_bvh()
					else bound = ofio_iv_bound_geometry()
				-- name
				name = obj.name
				-- margin
				local Margin = getUserProp obj "margin"
				if Margin == undefined or Margin.count != 3 then Margin = Point3 0.005 0.005 0.005	
							
				-- arrays
				local poly_ids = #()
				local reverse_edge_poly = #()
				reverse_edge_poly.count = obj.edges.count
				local mat_arr_id_by_submat = #()				
				local arr_mats = #() -- array of normalized materials
				local arr_vertices = #()  -- array of normalized vertices
				
				-- init poly dependent arrays	
				local i, j		
				for i = 1 to obj.faces.count do
				(
					append poly_ids i
					-- append poly to the edge-poly reverse array
					local _edges = polyop.getFaceEdges obj i
					for j in _edges do
					(
						if (j == 0) or (j > reverse_edge_poly.count) then throw "bad edge id"
						if reverse_edge_poly[j] == undefined then reverse_edge_poly[j] = #()
						append reverse_edge_poly[j] i
					)					
				)
				
				-- mats
				local singlemtl = false
				if obj.material == undefined then
					throw ("MATERIAL ERROR\n\nMesh " + obj.name + " has no material")
				if classof obj.material == Multimaterial then
				(
					local mat_ids = obj.material.materialIDList	
					j = 1		
					for i in mat_ids do
					(
						-- get mat
						local mat = obj.material[i]	
						if classof mat != iv_col_material then continue
						mat_arr_id_by_submat[i] = j
						j += 1
						-- normalized mat
						append arr_mats (Point3 mat.mtlid mat.mtlprocid mat.flags)					
					)	
				) else
				(
					local mtl = obj.material
					if classof mtl != iv_col_material then
						throw ("MATERIAL ERROR\n\nMesh " + obj.name + " has bad material")					
					append arr_mats (Point3 mtl.mtlid mtl.mtlprocid mtl.flags)
					singlemtl = true
				)
				bound.Materials = arr_mats
 	
				-- verts
				for i = 1 to obj.verts.count do
					append arr_vertices (polyop.getVert obj i)
				-- copy of the first vert (format related)
				append arr_vertices (polyop.getVert obj 1)
	
				-- set bounds	
				AABBMin = Point3 0xFFFF 0xFFFF 0xFFFF
				AABBMax = Point3 -0xFFFF -0xFFFF -0xFFFF				
				for i in arr_vertices do
				(
					for j = 1 to 3 do
					(
						if i[j] < AABBMin[j] then AABBMin[j] = i[j]
						if i[j] > AABBMax[j] then AABBMax[j] = i[j]
					)
				)
				local Sizes = AABBmax - AABBmin
				local scale = Sizes / 65536.0
					
				-- check for threshold vertexes and if any then increase scale
				while True do
				(
					local scale_increase = false
					for i = 1 to arr_vertices.count do
					(
						local vert = (arr_vertices[i] - obj.pos) / scale
						for j = 1 to 3 do
						(
							vert[j] = vert[j] as Integer	
							if vert[j] < -32760 or vert[j] > 32760 then
							(
								scale_increase = true
								exit
							)
						)
						if scale_increase then exit
					)
					if not scale_increase then exit
					if scale[1] > 0.01 or scale[2] > 0.01 or scale[3] > 0.01 
						then scale += 0.01
						else scale *= 2
					--format "increasing scale to %\n" scale					
				)
				
				-- recalculate boundbox
				AABBMin = Point3 0xFFFF 0xFFFF 0xFFFF
				AABBMax = Point3 -0xFFFF -0xFFFF -0xFFFF				
				for i = 1 to arr_vertices.count do
				(
					local vert = (arr_vertices[i] - obj.pos) / scale
					for j = 1 to 3 do 
						vert[j] = vert[j] as Integer
					vert = vert * scale + obj.pos					
					for j = 1 to 3 do
					(
						if vert[j] < AABBMin[j] then AABBMin[j] = vert[j]
						if vert[j] > AABBMax[j] then AABBMax[j] = vert[j]
					)					
				)
					
				-- normalize vertexes
				local shrunk = #()
				for i = 1 to arr_vertices.count do
				(
					local vert = (arr_vertices[i] - obj.pos) / scale
					for j = 1 to 3 do
					(
						vert[j] = vert[j] as Integer
						if vert[j] < -32768 then vert[j] = -32768 else
							if vert[j] > 32767 then vert[j] = 32767				
					)
					arr_vertices[i] = vert
					append shrunk [(vert.x * 0.96) as Integer, (vert.y * 0.96) as Integer, (vert.z * 0.96) as Integer]
				)	
				if t == "boundgeometry" then bound.Shrunk = shrunk							
				bound.VertexOffset = obj.pos
				bound.VertexScale = scale
				bound.Vertices = arr_vertices
				bound.Margin = Margin				
				CentroidPresent = 1
				Centroid = (AABBmax + AABBmin) / 2
				CGPresent = 1
				CenterOfMass = Centroid
				Radius = length (AABBmax - Centroid) --Radius = length ((AABBmax - AABBmax * Margin) - Centroid)
				WorldRadius = amax #(length AABBmin, length AABBmax) --WorldRadius = amax #(length (AABBmin + AABBmin * Margin), length (AABBmax - AABBmax * Margin))
				
				-- polys
				bound.Polygons = #()				
				for i = 1 to poly_ids.count do
				(
					local poly_id = poly_ids[i]
					-- poly edges
					local poly_edges = polyop.getFaceEdges obj poly_id	
					-- poly indicies
					local poly_verts = polyop.getFaceVerts obj poly_id	
					-- normalized poly					
					local poly = ofio_iv_bound_common_polygon()
					-- mat id
					if singlemtl then
					(
						poly.Material = 1
					) else
					(
						local mat_id = polyop.getFaceMatID obj poly_id
						poly.Material = mat_arr_id_by_submat[mat_id]
					)
					if poly.Material == undefined then
					(
						ofioLog.print("warning: bad poly skipped " + (polyop.getFaceCenter obj poly_id) as String + " in " + obj.name)
						continue
					)
					if poly_verts.count != 3 and poly_verts.count != 4 then 
						throw ("MESH ERROR\n\n" + "Only 3 and 4 vert poly can be used in bounds, you must fix '" + obj.name + "' scene object\n\n" + "You can do this:\n" + "1. manualy\n" + "2. using OFIO->Tesselate (preferred) \n" + "3. using Modifiers->Subdivide\n")
					poly.Material -= 1
					poly.Vertices.count = 4
					poly.Siblings.count = 4
					for j = 1 to poly_verts.count do
					(
						poly.Vertices[j] = poly_verts[j] - 1
						if reverse_edge_poly[poly_edges[j]].count == 1 then
						(
							poly.Siblings[j] = -1
						) else
						if reverse_edge_poly[poly_edges[j]].count == 2 then
						(						
							if reverse_edge_poly[poly_edges[j]][1] != poly_id
								then poly.Siblings[j] = reverse_edge_poly[poly_edges[j]][1] - 1
								else poly.Siblings[j] = reverse_edge_poly[poly_edges[j]][2] - 1
						) else throw "incorrect edge-poly array"
					)
					if poly_verts.count == 3 then 
					(
						poly.Vertices[4] = 0
						poly.Siblings[4] = -1
					)	
					if poly_verts.count == 4 and poly.Vertices[4] == 0 then 
					(
						-- format related, using copy of the first vertex
						poly.Vertices[4] = arr_vertices.count - 1
					)
					append bound.Polygons poly
				)
				
			)
			default: throw ("unknown bound type for " + obj.name)
		)			
	),
	
	fn write fOutput padding is_fragment:false = (
		if name == "composite_root" then name = ""
		if is_fragment 
			then format "%bound\n%{\n" padding padding to:fOutput
			else format "%phBound %\n%{\n" padding name padding to:fOutput
		if is_empty == undefined then is_empty = false
		if is_fragment and is_empty then
		(
			format ("%\x09" + "empty\n%}\n") padding padding to:fOutput
			return OK
		)
		format ("%\x09" + "Type %\n") padding Type to:fOutput
		format ("%\x09" + "CentroidPresent %\n") padding (CentroidPresent as Integer) to:fOutput		
		format ("%\x09" + "CGPresent %\n") padding (CGPresent as Integer) to:fOutput
		format ("%\x09" + "Radius %\n") padding (Radius as Float) to:fOutput
		format ("%\x09" + "WorldRadius %\n") padding (WorldRadius as Float) to:fOutput
		-- boundbox size increasing due to float being not preceised and if resaving without dump occures OF can throw exception
		format ("%\x09" + "AABBMax % % %\n") padding (AABBMax[1] + 0.01) (AABBMax[2] + 0.01) (AABBMax[3] + 0.01) to:fOutput
		format ("%\x09" + "AABBMin % % %\n") padding (AABBMin [1] - 0.01) (AABBMin[2] - 0.01) (AABBMin[3] - 0.01) to:fOutput
		if CentroidPresent == 1 then format ("%\x09" + "Centroid % % %\n") padding Centroid[1] Centroid[2] Centroid[3] to:fOutput
		if CGPresent == 1 then format ("%\x09" + "CenterOfMass % % %\n") padding CenterOfMass[1] CenterOfMass[2] CenterOfMass[3] to:fOutput
		local i, t = ofutils.lowercase(type)
		case of
		(
			(t == "boundcomposite"): 
			(
				format ("%\x09" + "Margin % % %\n") padding bound.Margin[1] bound.Margin[2] bound.Margin[3] to:fOutput
				format ("%\x09" + "Children %\n%\x09{\n") padding bound.Children.count padding to:fOutput
				for i = 1 to bound.Children.count do
				(
					bound.Children[i].write fOutput (padding + "\x09\x09")
				)				
				format ("%\x09}\n") padding to:fOutput
				format ("%\x09" + "ChildTransforms %\n%\x09{\n") padding bound.ChildTransforms.count padding to:fOutput
				for i = 1 to bound.ChildTransforms.count do
				(
					format ("%\x09\x09" + "Matrix %\n%\x09\x09{\n") padding (i - 1) padding to:fOutput
					format "%\x09\x09\x09% % %\n" padding bound.ChildTransforms[i][1][1] bound.ChildTransforms[i][1][2] bound.ChildTransforms[i][1][3] to:fOutput
					format "%\x09\x09\x09% % %\n" padding bound.ChildTransforms[i][2][1] bound.ChildTransforms[i][2][2] bound.ChildTransforms[i][2][3] to:fOutput
					format "%\x09\x09\x09% % %\n" padding bound.ChildTransforms[i][3][1] bound.ChildTransforms[i][3][2] bound.ChildTransforms[i][3][3] to:fOutput
					format "%\x09\x09\x09% % %\n" padding bound.ChildTransforms[i][4][1] bound.ChildTransforms[i][4][2] bound.ChildTransforms[i][4][3] to:fOutput
					format ("%\x09\x09}\n") padding to:fOutput
				)
				format ("%\x09}\n") padding to:fOutput				
			)
			(t == "boundbox"):
			(
				format ("%\x09" + "Margin % % %\n") padding bound.Margin[1] bound.Margin[2] bound.Margin[3] to:fOutput
				format ("%\x09" + "VertexScale % % %\n") padding bound.VertexScale[1] bound.VertexScale[2] bound.VertexScale[3] to:fOutput		
				format ("%\x09" + "VertexOffset % % %\n") padding bound.VertexOffset[1] bound.VertexOffset[2] bound.VertexOffset[3] to:fOutput
				format ("%\x09" + "Extents % % %\n") padding bound.Extents[1] bound.Extents[2] bound.Extents[3] to:fOutput
				format ("%\x09" + "Material % % %\n") padding (bound.Material[1] as Integer) (bound.Material[2] as Integer) (bound.Material[3] as Integer) to:fOutput
			)
			(t == "boundsphere"):
			(
				format ("%\x09" + "Material % % %\n") padding (bound.Material[1] as Integer) (bound.Material[2] as Integer) (bound.Material[3] as Integer) to:fOutput
			)			
			(t == "boundcapsule"):
			(
				format ("%\x09" + "Material % % %\n") padding (bound.Material[1] as Integer) (bound.Material[2] as Integer) (bound.Material[3] as Integer) to:fOutput
				format ("%\x09" + "CapsuleRadius %\n") padding bound.CapsuleRadius to:fOutput
				format ("%\x09" + "CapsuleHeight %\n") padding bound.CapsuleHeight to:fOutput
			)		
			(t == "boundcurvedgeometry"):
			(
				format ("%\x09" + "Margin % % %\n") padding bound.Margin[1] bound.Margin[2] bound.Margin[3] to:fOutput
				format ("%\x09" + "Polygons 0\n") padding to:fOutput
				-- verts
				format ("%\x09" + "VertexScale % % %\n") padding bound.VertexScale[1] bound.VertexScale[2] bound.VertexScale[3] to:fOutput		
				format ("%\x09" + "VertexOffset % % %\n") padding bound.VertexOffset[1] bound.VertexOffset[2] bound.VertexOffset[3] to:fOutput
				format ("%\x09" + "Vertices %\n%\x09{\n") padding bound.Vertices.count padding to:fOutput
				for i = 1 to bound.Vertices.count do
				(
					format ("%\x09\x09% % %\n") padding (bound.Vertices[i][1] as Integer) (bound.Vertices[i][2] as Integer) (bound.Vertices[i][3] as Integer) to:fOutput
				)	
				format ("%\x09}\n") padding to:fOutput					
				-- mats
				format ("%\x09" + "Materials %\n%\x09{\n") padding bound.Materials.count padding to:fOutput
				for i = 1 to bound.Materials.count do
				(
					format ("%\x09\x09% % %\n") padding (bound.Materials[i][1] as Integer) (bound.Materials[i][2] as Integer) (bound.Materials[i][3] as Integer) to:fOutput
				)	
				format ("%\x09}\n") padding to:fOutput			
				-- edges
				format ("%\x09" + "CurvedEdges %\n%\x09{\n") padding bound.Materials.count padding to:fOutput
				for i = 1 to bound.CurvedEdges.count do
				(
					format ("%\x09\x09" + "edge\n") padding to:fOutput
					format ("%\x09\x09{\n") padding to:fOutput
					format ("%\x09\x09\x09" + "unk_V % % %\n") padding (bound.CurvedEdges[i].unk_V.x as Float) (bound.CurvedEdges[i].unk_V.y as Float) (bound.CurvedEdges[i].unk_V.z as Float) to:fOutput
					format ("%\x09\x09\x09" + "unk_V2 % % %\n") padding (bound.CurvedEdges[i].unk_V2.x as Float) (bound.CurvedEdges[i].unk_V2.y as Float) (bound.CurvedEdges[i].unk_V2.z as Float) to:fOutput
					format ("%\x09\x09\x09" + "unk_F %\n") padding (bound.CurvedEdges[i].unk_F as Float) to:fOutput
					format ("%\x09\x09\x09" + "Vertices % %\n") padding (bound.CurvedEdges[i].Vertices[1] as Integer) (bound.CurvedEdges[i].Vertices[2] as Integer) to:fOutput
					format ("%\x09\x09}\n") padding to:fOutput
				)		
				format ("%\x09}\n") padding to:fOutput			
			)
			(t == "boundbvh" or t == "boundgeometry"): 
			(
				format ("%\x09" + "Margin % % %\n") padding bound.Margin[1] bound.Margin[2] bound.Margin[3] to:fOutput
				
				-- shrunk for geometry
				if t == "boundgeometry" then
				(
					format ("%\x09" + "Shrunk %\n%\x09{\n") padding bound.Vertices.count padding to:fOutput
					for i = 1 to bound.Vertices.count do
					(
						format ("%\x09\x09% % %\n") padding (bound.Shrunk[i][1] as Integer) (bound.Shrunk[i][2] as Integer) (bound.Shrunk[i][3] as Integer) to:fOutput
					)		
					format ("%\x09}\n") padding to:fOutput		
				)
				
				-- polygons
				format ("%\x09" + "Polygons %\n%\x09{\n") padding bound.Polygons.count padding to:fOutput
				for i = 1 to bound.Polygons.count do
				(
					format ("%\x09\x09" + "Polygon %\n%\x09\x09{\n") padding (i - 1) padding to:fOutput
					format ("%\x09\x09\x09" + "Material %\n") padding bound.Polygons[i].Material to:fOutput
					format ("%\x09\x09\x09" + "Vertices % % % %\n") padding bound.Polygons[i].Vertices[1] bound.Polygons[i].Vertices[2] bound.Polygons[i].Vertices[3] bound.Polygons[i].Vertices[4] to:fOutput
					format ("%\x09\x09\x09" + "Siblings % % % %\n") padding bound.Polygons[i].Siblings[1] bound.Polygons[i].Siblings[2] bound.Polygons[i].Siblings[3] bound.Polygons[i].Siblings[4] to:fOutput
					format ("%\x09\x09}\n") padding to:fOutput
				)	
				format ("%\x09}\n") padding to:fOutput	
				-- verts
				format ("%\x09" + "VertexScale % % %\n") padding bound.VertexScale[1] bound.VertexScale[2] bound.VertexScale[3] to:fOutput		
				format ("%\x09" + "VertexOffset % % %\n") padding bound.VertexOffset[1] bound.VertexOffset[2] bound.VertexOffset[3] to:fOutput
				format ("%\x09" + "Vertices %\n%\x09{\n") padding bound.Vertices.count padding to:fOutput
				for i = 1 to bound.Vertices.count do
				(
					format ("%\x09\x09% % %\n") padding (bound.Vertices[i][1] as Integer) (bound.Vertices[i][2] as Integer) (bound.Vertices[i][3] as Integer) to:fOutput
				)	
				format ("%\x09}\n") padding to:fOutput					
				-- mats
				format ("%\x09" + "Materials %\n%\x09{\n") padding bound.Materials.count padding to:fOutput
				for i = 1 to bound.Materials.count do
				(
					format ("%\x09\x09% % %\n") padding (bound.Materials[i][1] as Integer) (bound.Materials[i][2] as Integer) (bound.Materials[i][3] as Integer) to:fOutput
				)	
				format ("%\x09}\n") padding to:fOutput				
			)			
			default: throw "unknown bound type"
		)
		format ("%}\n") padding to:fOutput
	),
	
	fn read fInput = (
		local elements
		elements = scanline fInput
		if elements[1] == "}" then return False
		if (ofutils.lowercase(elements[1]) != "phbound" and ofutils.lowercase(elements[1]) != "bound") 
			then throw "phBound expected"
		if elements[2] != undefined then name = elements[2] as String else name = "composite_root"
		elements = scanline fInput
		if elements[1] != "{" then throw "phBound start expected"
		is_empty = false
		elements = scanline fInput
		while elements[1] != "}" do
		(
			case ofutils.lowercase(elements[1]) of
			(
				"type": 
				( 
					type = elements[2]
					case ofutils.lowercase(type) of
					(
						"boundcomposite": bound = ofio_iv_bound_composite()
						"boundbvh": bound = ofio_iv_bound_bvh() 
						"boundgeometry": bound = ofio_iv_bound_geometry()
						"boundcurvedgeometry": bound = ofio_iv_bound_curved_geometry()
						"boundbox": bound = ofio_iv_bound_box()
						"boundsphere": bound = ofio_iv_bound_sphere()
						"boundcapsule": bound = ofio_iv_bound_capsule()
						default: throw ("unknown bound type " + elements[2])						
					)
				)
				"centroidpresent": CentroidPresent = (elements[2] as Integer)
				"cgpresent": CGPresent = (elements[2] as Integer)
				"radius": Radius = (elements[2] as Float)
				"worldradius": WorldRadius = (elements[2] as Float)
				"aabbmax": AABBMax = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"aabbmin": AABBMin = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"centroid": Centroid = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"centerofmass": CenterOfMass = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"capsuleradius": bound.CapsuleRadius = (elements[2] as Float)
				"capsuleheight": bound.CapsuleHeight = (elements[2] as Float)
				"margin": bound.Margin = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"extents": bound.Extents = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"material": bound.Material = Point3 (elements[2] as Integer) (elements[3] as Integer) (elements[4] as Integer)
				"vertexscale": bound.VertexScale = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"vertexoffset": bound.VertexOffset = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"children":
				(
					local count = elements[2] as Integer
					elements = scanline fInput
					if elements[1] != "{" then throw "phBound start expected"	
					bound.Children = #()
					while count > 0 do
					(
						local b = ofio_iv_bound_container()
						b.read fInput
						append bound.Children b
						count -= 1
					)
					elements = scanline fInput
					if elements[1] != "}" then throw "phBound end expected"				
				)
				"childtransforms":
				(
					local count = elements[2] as Integer
					elements = scanline fInput
					if elements[1] != "{" then throw "ChildTransforms start expected"
					bound.ChildTransforms = #()
					while count > 0 do
					(
						elements = scanline fInput
						if ofutils.lowercase(elements[1]) != "matrix" then throw "Matrix expected"
						elements = scanline fInput
						if elements[1] != "{" then throw "Matrix start expected"
						
						local t = (Matrix3 0)
						local i
						for i = 1 to 4 do
						(
							elements = scanline fInput						
							t[i] = [(elements[1] as Float), (elements[2] as Float), (elements[3] as Float)]
						)
						append bound.ChildTransforms t
					
						elements = scanline fInput
						if elements[1] != "}" then throw "Matrix end expected"
						count -= 1
					)
					elements = scanline fInput
					if elements[1] != "}" then throw "ChildTransforms end expected"					
				)				
				"polygons":
				(
					local count = elements[2] as Integer
					elements = scanline fInput
					if count == 0 then continue
					if elements[1] != "{" then throw "Polygons start expected"
					bound.Polygons = #()
					while count > 0 do
					(
						elements = scanline fInput
						if ofutils.lowercase(elements[1]) != "polygon" then throw "Polygon expected"
						elements = scanline fInput
						if elements[1] != "{" then throw "Polygon start expected"
						
						local poly = ofio_iv_bound_common_polygon()
						-- mtl
						elements = scanline fInput						
						poly.Material = elements[2] as Integer
						-- verts
						elements = scanline fInput
						poly.Vertices = #((elements[2] as Integer), (elements[3] as Integer), (elements[4] as Integer), (elements[5] as Integer))
						-- edge polys
						elements = scanline fInput
						poly.Siblings = #((elements[2] as Integer), (elements[3] as Integer), (elements[4] as Integer), (elements[5] as Integer))
						
						append bound.Polygons poly
					
						elements = scanline fInput
						if elements[1] != "}" then throw "Polygon end expected"
						count -= 1
					)
					elements = scanline fInput
					if elements[1] != "}" then throw "Polygons end expected"					
				)
				"vertices":
				(
					local count = elements[2] as Integer
					elements = scanline fInput
					if elements[1] != "{" then throw "Vertices start expected"
					bound.Vertices = #()
					while count > 0 do
					(
						elements = scanline fInput
						local vert = Point3 (elements[1] as Integer) (elements[2] as Integer) (elements[3] as Integer)
						append bound.Vertices vert
						count -= 1
					)
					elements = scanline fInput
					if elements[1] != "}" then throw "Vertices end expected"					
				)	
				"shrunk":
				(
					if ofutils.lowercase(elements[2]) != "empty" then
					(
						local count = elements[2] as Integer
						elements = scanline fInput
						if elements[1] != "{" then throw "Shrunk start expected"
						bound.Shrunk = #()
						while count > 0 do
						(
							elements = scanline fInput
							local vert = Point3 (elements[1] as Integer) (elements[2] as Integer) (elements[3] as Integer)
							append bound.Shrunk vert
							count -= 1
						)
						elements = scanline fInput
						if elements[1] != "}" then throw "Shrunk end expected"					
					)
				)				
				"materials":
				(
					local count = elements[2] as Integer
					elements = scanline fInput
					if elements[1] != "{" then throw "Materials start expected"
					bound.Materials = #()
					while count > 0 do
					(
						elements = scanline fInput
						local vert = Point3 (elements[1] as Integer) (elements[2] as Integer) (elements[3] as Integer)
						append bound.Materials vert
						count -= 1
					)
					elements = scanline fInput
					if elements[1] != "}" then throw "Materials end expected"					
				)
				"curvededges":
				(
					local count = elements[2] as Integer
					elements = scanline fInput
					if elements[1] != "{" then throw "CurvedEdges start expected"
					bound.CurvedEdges = #()				
					while count > 0 do
					(
						elements = scanline fInput
						if elements[1] != "edge" then throw "edge expected"
						elements = scanline fInput
						if elements[1] != "{" then throw "edge start expected"
					
						local edge = ofio_iv_bound_curved_edge()
						elements = scanline fInput
						edge.unk_V = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
						elements = scanline fInput
						edge.unk_V2 = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
						elements = scanline fInput
						edge.unk_F = elements[2] as Float
						elements = scanline fInput
						edge.Vertices = #(elements[2] as Integer, elements[3] as Integer)
						
						elements = scanline fInput
						if elements[1] != "}" then throw "edge end expected"					
	
						append bound.CurvedEdges edge
						count -= 1
					)
					elements = scanline fInput
					if elements[1] != "}" then throw "CurvedEdges end expected"					
				)
				"empty": is_empty = true
				default: throw ("unknown bound element " + elements[1])
			)
			elements = scanline fInput
		)
	),
	
	fn cleanup = (
		if boundObject != undefined then
		(
			local obj
			if ofutils.lowercase(type) == "boundcomposite" then
				for obj in bound.Children do obj.cleanup()
			delete boundObject			
		)
	)	
)

struct ofio_iv_obn (
	descriptor,
	descName,
	root,	

	fn read fInputName = (
		local fInput = openFile fInputName
		local version = filterString (readLine fInput) "\x20\x09"
		if (version[2] as Integer != 32) or (version[3] as Integer != 11) then
		(
			close fInput
			throw "not supported obn, version 32 11 is supported only"
		)
		descName = ofutils.removeExt(ofutils.extractFileName fInputName)
		ofio_iv_opened_blocks = 0
		root = ofio_iv_bound_container()
		root.read fInput		
		close fInput
		if ofio_iv_opened_blocks != 0 then throw "file parsing error"
	),
	
	fn write fOutputName = (
		local fOutput = createFile fOutputName
		format "Version 32 11\n" to:fOutput
		root.write fOutput ""	
		close fOutput
	),	
	
	fn dump obj = (
		local result = false
		if obj.children.count == 1 then 
		(
			root = ofio_iv_bound_container()
			root.dump obj.children[1]
			root.name = ""
			result = true		
		) else format "bn must have only 1 composite child, % skipped\n" obj.name
		return result
	),
	
	fn build = (
		descriptor = dummy boxsize:[3, 3, 3]
		descriptor.name = "bn_" + descName
		root.compositeIndependent = true
		root.build()
		root.boundObject.parent = descriptor
		if classof root.boundObject == dummy then
			root.boundObject.boxsize = [2, 2, 2]
	),
	
	fn cleanup = (
		if root != undefined then root.cleanup()
	),
	
	fn filename_from_scenename objname = (
		local name_contents = filterString (ofutils.lowercase objname) "_"
		if (objname.count < 4) or (name_contents.count < 2) then 
			throw ("NAME ERROR\n\n" + "obn file descriptor has no valid name or descriptor is not selected\n")
		if name_contents[1] != "bn" then 
			throw ("NAME ERROR\n\n" + "obn file descriptor name must start with 'bn_'\n")
		local i, filename = ""
		for i = 4 to objname.count do
			filename += objname[i]
		filename += ".obn"	
		return filename
	)
)

struct ofio_iv_obd (
	descriptor,
	descName,
	bounds = #(),	

	fn read fInputName = (
		bounds = #()
		local fInput = openFile fInputName
		local version = filterString (readLine fInput) "\x20\x09"
		local blockstart = filterString (readLine fInput) "\x20\x09"
		if (version[2] as Integer != 32) or (version[3] as Integer != 11) or (blockstart[1] != "{") then
		(
			close fInput
			throw "not supported obd, version 32 11 is supported only"
		)
		descName = ofutils.removeExt(ofutils.extractFileName fInputName)
		ofio_iv_opened_blocks = 1
		local blockend
		do
		(
			local bound = ofio_iv_bound_container()
			blockend = (bound.read fInput) == false
			if not blockend then append bounds bound
		) while (not blockend)
		close fInput
		if ofio_iv_opened_blocks != 0 then throw "file parsing error"
	),
	
	fn write fOutputName = (
		local fOutput = createFile fOutputName
		format "Version 32 11\n{\n" to:fOutput
		for bound in bounds do
			bound.write fOutput "\x09"	
		format "}\n" to:fOutput
		close fOutput
	),		
	
	fn build = (
		descriptor = dummy boxsize:[1, 1, 1]
		descriptor.name = "bd_" + descName
		local bound
		local offset = 0
		for bound in bounds do 
		(
			local radius = bound.Radius * 2
			if radius < 1 then radius = 1
			offset += radius
		)
		offset = -offset / 2		
		for bound in bounds do
		(
			bound.build()
			bound.boundObject.parent = descriptor
			bound.boundObject.pos.x = offset
			local radius = bound.Radius * 2
			if radius < 1 then radius = 1
			offset += radius
		)
		descriptor
	),	
	
	fn dump obj = (
		local result = false
		bounds = #()
		for child in obj.children do
		(
			local bound = ofio_iv_bound_container()
			local pos = child.pos
			child.pos = [0, 0, 0]
			local e = undefined
			try (
				bound.dump child
			) catch (
				e = getcurrentexception()
			)
			child.pos = pos
			if e != undefined then throw e
			
			append bounds bound
			result = true		
		)
		return result
	),
	
	fn cleanup = (
		for bound in bounds do
			bound.cleanup()
	),
	
	fn filename_from_scenename objname = (
		local name_contents = filterString (ofutils.lowercase objname) "_"
		if (objname.count < 4) or (name_contents.count < 2) then 
			throw ("NAME ERROR\n\n" + "obd file descriptor has no valid name or descriptor is not selected\n")
		if name_contents[1] != "bd" then 
			throw ("NAME ERROR\n\n" + "obd file descriptor name must start with 'bd_'\n")
		local i, filename = ""
		for i = 4 to objname.count do
			filename += objname[i]
		filename += ".obd"	
		return filename
	)	
)
