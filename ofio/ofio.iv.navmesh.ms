-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: gta iv *.onv navmeshes i/o
-- Last changed: Jun 2013

------------------ global --------------------

global G_IV_NV_PRINT_TEMP = false
global G_IV_NV_IMPORT_IGNORE_INTERSEGMENT_PORTALS = true
global G_IV_NV_NAME_PREFIX = "nv_"
global G_IV_NV_TEMP_NAME_PRE_PREFIX = "nvtemp_"
global G_IV_NV_MESH_NAME_PREFIX = G_IV_NV_NAME_PREFIX + "m_"
global G_IV_NV_BOUND_NAME_PREFIX = G_IV_NV_NAME_PREFIX + "b_"
global G_IV_NV_PORTAL_NAME_PREFIX = G_IV_NV_NAME_PREFIX + "p_"
global G_IV_NV_DEBUG_NAME_PREFIX = ""
global G_IV_NV_REPAIR_BAD_POLY = false
global G_IV_NV_NAVMESH

----------------- modules --------------------

fileIn "ofio.iv.navmesh.mtl.ms"
fileIn "ofio.iv.navmesh.slice.ms"

----------------- navmesh --------------------

struct iv_nv_version (
	object, 
	formats
)

struct iv_nv_point (
	x, y, z
)

struct iv_nv_edge (
	sector_1,
	poly_1,
	flags_1,
	sector_2,
	poly_2,
	flags_2
)

struct iv_nv_poly (
	start_index,
	index_count,
	flags_1,
	flags_2,
	flags_3
)

struct iv_nv_sector_tree (
	AABBMin,
	AABBMax,
	SectorData,
	SubTree0,
	SubTree1,
	SubTree2,
	SubTree3
)

struct iv_nv_sector_data (
	PolyIndices,
	Bounds
)

struct iv_nv_portal (
	point1_x, point1_y, point1_z, SectorId1, PolyId1,
    point2_x, point2_y, point2_z, SectorId2, PolyId2,
    Direction, Angle
)

struct ofio_iv_nv_descriptor
(
	version, -- iv_nv_version | of | Version 1 1
	sizes, -- of | Sizes 100.00000000 100.00000000 46.32296000
	flags, -- of | Flags 3
	vertices, -- of | Vertices 6582 \n { \n 284 0 8330 ... }
	indices, -- of | Indices 15258 \n { \n 3339 3470 5874 ... }
	edges, -- of | Edges 15258 \n { \n 2539 0 860 2539 860 0 \n ... }
	polys, -- of | Polys 3696 \n { \n 0 5 4 3 0 \n ... }
	sectortree, -- of | SectorTree \n { \n ... \n }
	portals, -- of | Portals 4 \n { \n 16737 62514 23341 2539 2768 16737 ... \n }
	sectorid, -- of | SectorID 2539	
	--------------------------------
	materials,
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		l = undefined
		return s
	),
	
	fn writeSectorTree tabs sector fOutput = (
		local i, padding = ""
		if tabs > 0 then for i = 1 to tabs do padding += "\x09"
		format "%{\n" padding to:fOutput
		-- AABBmin		
		format ("%\x09" + "AABBMin % % %\n") padding sector.AABBMin[1] sector.AABBMin[2] sector.AABBMin[3] to:fOutput
		-- AABBMax
		format ("%\x09" + "AABBMax % % %\n") padding sector.AABBMax[1] sector.AABBMax[2] sector.AABBMax[3] to:fOutput
		-- SectorData
		if sector.SectorData != undefined then
		(
			format "%\x09SectorData\n%\x09{\n" padding padding to:fOutput
			
			-- indices
			format "%\x09\x09PolyIndices %\n" padding sector.SectorData.PolyIndices.count to:fOutput
			if sector.SectorData.PolyIndices.count > 0 then
			(
				format "%\x09\x09{\n%\x09\x09\x09" padding padding to:fOutput
				for i = 1 to sector.SectorData.PolyIndices.count do
				(
					if (mod (i - 1) 15) == 0 and (i > 1) then format "\n%\x09\x09\x09" padding to:fOutput
					format "% " sector.SectorData.PolyIndices[i] to:fOutput
				)
				format "\n%\x09\x09}\n" padding to:fOutput
			)
			
			-- bounds
			format ("%\x09\x09" + "Bounds %\n") padding sector.SectorData.Bounds.count to:fOutput
			if sector.SectorData.Bounds.count > 0 then
			(
				format "%\x09\x09{\n" padding padding to:fOutput
				for i = 1 to sector.SectorData.Bounds.count do
					format "%\x09\x09\x09% % % %\n" padding (sector.SectorData.Bounds[i][1] as Integer) (sector.SectorData.Bounds[i][2] as Integer) \ 
															(sector.SectorData.Bounds[i][3] as Integer) (sector.SectorData.Bounds[i][4] as Integer) to:fOutput
				format "%\x09\x09}\n" padding to:fOutput
			)
			
			format "%\x09}\n" padding to:fOutput			
		) else format "%\x09SectorData null\n" padding to:fOutput
		
		-- SubTree0
		if sector.SubTree0 != undefined then
		(
			format "%\x09SubTree0\n" padding to:fOutput
			writeSectorTree (tabs + 1) sector.SubTree0 fOutput			
		) else format "%\x09SubTree0 null\n" padding to:fOutput		
		-- SubTree1
		if sector.SubTree1 != undefined then
		(
			format "%\x09SubTree1\n" padding to:fOutput
			writeSectorTree (tabs + 1) sector.SubTree1 fOutput			
		) else format "%\x09SubTree1 null\n" padding to:fOutput	
		-- SubTree2
		if sector.SubTree2 != undefined then
		(
			format "%\x09SubTree2\n" padding to:fOutput
			writeSectorTree (tabs + 1) sector.SubTree2 fOutput			
		) else format "%\x09SubTree2 null\n" padding to:fOutput		
		-- SubTree3
		if sector.SubTree3 != undefined then
		(
			format "%\x09SubTree3\n" padding to:fOutput
			writeSectorTree (tabs + 1) sector.SubTree3 fOutput			
		) else format "%\x09SubTree3 null\n" padding to:fOutput		
		
		format "%}\n" padding to:fOutput
	),
	
	fn write fOutputName = (
		local i, fOutput = createFile fOutputName
		
		-- version, sizes, flags
		format "Version 1 1\nSizes % % %\nFlags %\n" sizes[1] sizes[2] sizes[3] flags to:fOutput
		
		-- verts
		format "Vertices %\n{\n" vertices.count to:fOutput
		if vertices.count > 0 then
			for i = 1 to vertices.count do 
				format "\x09% % %\n" (vertices[i][1] as Integer) (vertices[i][2] as Integer) (vertices[i][3] as Integer) to:fOutput
		format "}\n" to:fOutput
		
		-- indices
		format "Indices %\n{\n" indices.count to:fOutput
		if indices.count > 0 then
		(
			format "\x09" to:fOutput
			for i = 1 to indices.count do
			(
				if (mod (i - 1) 15) == 0 and (i > 1) then format "\n\x09" to:fOutput
				format "% " indices[i] to:fOutput
			)
		)
		format "\n}\n" to:fOutput
		
		-- edges
		format "Edges %\n{\n" edges.count to:fOutput
		if edges.count > 0 then
			for i = 1 to edges.count do 
				format "\x09% % % % % %\n" \
					edges[i].sector_1 edges[i].flags_1 edges[i].poly_1 \ 
					edges[i].sector_2 edges[i].poly_2 edges[i].flags_2 to:fOutput
		format "}\n" to:fOutput		
		
		-- polys
		format "Polys %\n{\n" polys.count to:fOutput
		if polys.count > 0 then
			for i = 1 to polys.count do 
				format "\x09% % % % %\n" \
					polys[i].start_index polys[i].index_count polys[i].flags_1 polys[i].flags_2  polys[i].flags_3 to:fOutput
		format "}\n" to:fOutput		

		-- sectors
		format "SectorTree\n" to:fOutput
		writeSectorTree 0 sectortree fOutput	
		
		-- portals
		format "Portals %\n" portals.count to:fOutput
		if portals.count > 0 then
		(
			format "{\n" to:fOutput
			for i = 1 to portals.count do 
				format "\x09% % % % % % % % % % % %\n" \
					portals[i].point1_x portals[i].point1_y portals[i].point1_z portals[i].SectorId1 portals[i].PolyId1 \
				    portals[i].point2_x portals[i].point2_y portals[i].point2_z portals[i].SectorId2 portals[i].PolyId2 \
				    portals[i].Direction portals[i].Angle to:fOutput
			format "}\n" to:fOutput	
		)		
		
		-- sectorid
		format "SectorID %\n" sectorid to:fOutput
		
		close fOutput
	),
	
	-- searches for material by flags inside the "materials" array, adds new if such material doesn't exist
	fn get_material flags pedgen_flags = (
		local border, crossing, sidewalk, covered, ladder, landfall, water, ped_walks, ped_stands, ped_unk
		border = bit.get flags 1
		crossing = bit.get flags 2
		sidewalk = bit.get flags 3
		covered = bit.get flags 4
		ladder = bit.get flags 6
		landfall = bit.get flags 7
 		water = bit.get flags 8
		ped_walks = bit.get pedgen_flags 1		
		ped_stands = bit.get pedgen_flags 2
		ped_unk = bit.get pedgen_flags 3
		
		local result = undefined
		
		if (materials == undefined) then materials = #()
		if (materials.count > 0) then
		(	
			local i, mtl
			for i = 1 to materials.count do
			(
				mtl = materials[i]
				if (mtl.border == border) and (mtl.crossing == crossing) and (mtl.sidewalk == sidewalk) \
				and (mtl.covered == covered) and (mtl.ladder == ladder) and (mtl.landfall == landfall) \
				and (mtl.water == water) \ 
				and (mtl.ped_walks == ped_walks) and (mtl.ped_stands == ped_stands) and (mtl.ped_unk == ped_unk) then
				(
					result = mtl
					exit
				)
			)
		)	

		if (result == undefined) then
		(
			result = iv_nv_material()
			result.name = "iv_nv_material_" + (materials.count as String)
			result.color.r = (random 0 255)
			result.color.g = (random 0 255)
			result.color.b = (random 0 255)
			
			result.border = border
			result.crossing = crossing
			result.sidewalk = sidewalk
			result.covered = covered
			result.ladder = ladder
			result.landfall = landfall
			result.water = water
			
			result.ped_walks = ped_walks
			result.ped_stands = ped_stands
			result.ped_unk = ped_unk
			
			append materials result	
		)
	
		return result	
	),
	
	fn flags_as_str flags = (
		local result = ""
		local i, name
		for i = 1 to 16 do
			if (bit.get flags i) then		
			(
				case i of
				(
					default: name = "f" + (i as String)
				)
				
				if result.count > 0 then name = "+" + name
				result += name
			)
		return result
	),
	
	fn build_bounds sector mul_matrix = (
		if (sector.SectorData != undefined) and (sector.SectorData.Bounds.count > 0) then
		(
			local i
			for i in sector.SectorData.Bounds do
			(
				local bound_data = i * mul_matrix
				local g = sphere()
				g.name = G_IV_NV_BOUND_NAME_PREFIX + "static"
				g.wirecolor = red
				g.segs = 8					
				g.radius = bound_data[4]
				g.pos = sectortree.AABBMin + (Point3 bound_data[1] bound_data[2] bound_data[3])			
			)
		)
		if sector.SubTree0 != undefined then build_bounds sector.SubTree0 mul_matrix
		if sector.SubTree1 != undefined then build_bounds sector.SubTree1 mul_matrix
		if sector.SubTree2 != undefined then build_bounds sector.SubTree2 mul_matrix
		if sector.SubTree3 != undefined then build_bounds sector.SubTree3 mul_matrix
	),	

	fn build = (
		local mul_matrix = sizes / 65536.0
		local scene_vertices = #()
		local i, j
		local poly_points, poly_verts
		for i = 1 to vertices.count do append scene_vertices (vertices[i] * mul_matrix)
		-- create nav mesh
		local navmesh = Editable_Mesh name:(G_IV_NV_MESH_NAME_PREFIX + "imp_" + (sectorid as String))
		convertTo navmesh (Editable_Poly)
		-- create verts
		for i = 1 to scene_vertices.count do polyOp.createVert navmesh scene_vertices[i]

		-- collect materials, building array of material_ref[polyid]
		local poly_mtls = #()
		for i = 1 to polys.count do append poly_mtls (get_material polys[i].flags_1 polys[i].flags_2)
		-- replace material refs with material ids
		for i = 1 to poly_mtls.count do -- materials by poly
			for j = 1 to materials.count do	-- uniq materials		
				if poly_mtls[i] == materials[j] then 
				(									
					poly_mtls[i] = j -- new mtl value is uniq array element num 
					exit
				)
		-- create main mesh multimat
		local mmat = multimaterial numsubs:materials.count -- contains uniq mat refs
		-- assign sub materials using uniq array material refs 
		for i = 1 to materials.count do mmat[i] = materials[i]
		-- set main multimat
		navmesh.material = mmat
		
		-- create polys
		local poly, center, poly_flags
		for i = 1 to polys.count do
		(
			ofioLog.progress (100.0 * i / polys.count)
			
			poly_points = #()
			for j = polys[i].start_index to polys[i].start_index + polys[i].index_count - 1 do append poly_points (indices[j+1]+1)
			
			-- create poly
			poly = polyOp.createPolygon navmesh poly_points
			-- some poly can have duplicated vertexes
			if G_IV_NV_REPAIR_BAD_POLY then
				if poly == undefined then
				(
					local k, _poly_points = #()
					for j = 1 to poly_points.count do
					(
						local uniq = true
						if _poly_points.count > 0 then
							for k = 1 to _poly_points.count do
								if poly_points[j] == _poly_points[k] then 
								(
									uniq = false
									exit
								)
						if uniq then append _poly_points poly_points[j]
					)				
					poly = polyOp.createPolygon navmesh _poly_points
					if poly != undefined then ofioLog.print ("poly " + (i as String) + " repaired !")
				)
			
			-- set poly material by id which equals poly_mtls one
			
			if poly != undefined 			
			 	then polyop.setFaceMatID navmesh poly poly_mtls[i] 
				else ofioLog.print ("warning, can't create poly " + (i as String))
			
		)
		
		navmesh.pos = sectortree.AABBMin
		
		-- bounds
		local bound_mul_sizes = (Point4 sizes[1] sizes[2] sizes[3] 1.0) / 65536.0
		build_bounds sectorTree bound_mul_sizes
		
		-- portals
		for i in portals do
		(
			if G_IV_NV_IMPORT_IGNORE_INTERSEGMENT_PORTALS then
				if (i.SectorId1 != sectorid) or (i.SectorId2 != sectorid) then
				(
					ofioLog.print "warning: can't import portal because it's using other's sector poly"
					continue	
				)
			local coords_1 = ((Point3 i.point1_x i.point1_y i.point1_z) * mul_matrix) + sectortree.AABBMin
			local coords_2 = ((Point3 i.point2_x i.point2_y i.point2_z) * mul_matrix) + sectortree.AABBMin
			local portal = SplineShape pos:coords_1
			portal.wirecolor = yellow
			portal.name = G_IV_NV_PORTAL_NAME_PREFIX + "static_" + (i.Direction as String)
			setuserprop portal "direction" i.Direction
			setuserprop portal "angle" ((i.Angle * 360 / 255) as Integer)
			addNewSpline portal
			addKnot portal 1 #corner #line coords_1
			addKnot portal 1 #corner #line coords_2
			updateShape portal
		)
		
		scene_vertices = undefined
		navmesh = undefined
		mmat = undefined
		poly_mtls = undefined
		materials = undefined
	),

	fn readSectorTree fInput = (
		local sector = iv_nv_sector_tree()
		local elements = scanline(fInput)
		if elements[1] != "{" then throw "incorrect sector tree"	
		elements = scanline(fInput)
		while (elements[1] != "}") do
		(
			if elements.count > 0 then
			case (ofutils.lowercase(elements[1])) of
			(
				"aabbmin":
				(
					sector.AABBMin = point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				)
				"aabbmax":
				(
					sector.AABBMax = point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				)	
				"sectordata":
				(
					if (elements.count != 2) then -- two elements: SectorData null
					(
						sector.sectordata = iv_nv_sector_data()
						elements = scanline(fInput)
						if elements[1] != "{" then throw "incorrect sector data"
						elements = scanline(fInput)
						while (elements[1] != "}") do
						(
							if elements.count > 0 then
							case (ofutils.lowercase(elements[1])) of
							(				
								"polyindices":
								(
									local indices_count = elements[2] as Integer
									sector.SectorData.PolyIndices = #()
									if (indices_count > 0) then
									(
										elements = scanline(fInput)
										if elements[1] != "{" then throw "incorrect sector data"
										elements = scanline(fInput)								
										while (elements[1] != "}") do
										(
											if (elements.count > 0) then
											(
												local i
												for i = 1 to elements.count do append sector.SectorData.PolyIndices (elements[i] as Integer)
											)
											elements = scanline(fInput)
										)
										if (sector.SectorData.PolyIndices.count != indices_count) 
											then throw "expected sector poly count not equals readed"
									)
								)
								"bounds":
								(
									local count = elements[2] as Integer
									sector.SectorData.Bounds = #()
									if (count > 0) then
									(
										elements = scanline(fInput)
										if elements[1] != "{" then throw "incorrect sector data"
										elements = scanline(fInput)	
										while (elements[1] != "}") do
										(
											append sector.SectorData.Bounds ( point4 (elements[1] as Integer) (elements[2] as Integer) \
																					 (elements[3] as Integer) (elements[4] as Integer) )
											elements = scanline(fInput)
										)
										if (sector.SectorData.Bounds.count != count) then throw "sector bounds count not equals expected value"
									)
								)	
								default:
								(
									throw ("unhandled sectordata block" + elements[1])
								)							
							)
							elements = scanline(fInput)
						)
					) else
					(
						sector.sectordata = undefined
					)
				)
				"subtree0":	( if (elements.count != 2) then sector.SubTree0 = readSectorTree fInput else sector.SubTree0 = undefined )
				"subtree1":	( if (elements.count != 2) then sector.SubTree1 = readSectorTree fInput else sector.SubTree1 = undefined )
				"subtree2":	( if (elements.count != 2) then sector.SubTree2 = readSectorTree fInput else sector.SubTree2 = undefined )
				"subtree3":	( if (elements.count != 2) then sector.SubTree3 = readSectorTree fInput else sector.SubTree3 = undefined )
				default:
				(
					throw ("unhandled block for a sector " + elements[1])
				)				
			) 
			elements = scanline(fInput)
		)
		return sector
	),

	fn read fInputName = (
		local fInput = openFile fInputName 
		while not eof(fInput) do
		(
			local elements = scanline(fInput)
			if elements.count == 0 then continue
			case (ofutils.lowercase(elements[1])) of
			(
				"version":
				(
					version = iv_nv_version object:(elements[2] as Integer) formats:(elements[3] as Integer)
				)
				"sizes":
				(
					sizes = point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				)
				"flags":
				(
					flags = elements[2] as Integer
				)
				"sectorid":
				(
					sectorid = elements[2] as Integer
				)				
				"vertices":
				(
					vertices = #()
					local vert_count = elements[2] as Integer
					elements = scanline(fInput)
					if elements[1] != "{" then throw "incorrect vertices block"	
					elements = scanline(fInput)
					while (elements[1] != "}") do
					(
						append vertices (point3 (elements[1] as Integer) (elements[2] as Integer) (elements[3] as Integer))
						elements = scanline(fInput)
					)
					if (vertices.count != vert_count) then throw "expected vertices count not equals readed"
				)
				"indices":
				(
					indices = #()
					local indices_count = elements[2] as Integer
					elements = scanline(fInput)
					if elements[1] != "{" then throw "incorrect indices block"	
					elements = scanline(fInput)
					while (elements[1] != "}") do
					(
						if (elements.count > 0) then
						(
							local i
							for i = 1 to elements.count do append indices (elements[i] as Integer)
						)
						elements = scanline(fInput)
					)
					if (indices.count != indices_count) then throw "expected indices count not equals readed"
				)	
				"edges":
				(
					edges = #()
					local edge_count = elements[2] as Integer
					elements = scanline(fInput)
					if elements[1] != "{" then throw "incorrect edges block"	
					elements = scanline(fInput)
					local edge
					while (elements[1] != "}") do
					(
						edge = iv_nv_edge sector_1:(elements[1] as Integer) poly_1:(elements[3] as Integer) flags_1:(elements[2] as Integer) \
									   sector_2:(elements[4] as Integer) poly_2:(elements[5] as Integer) flags_2:(elements[6] as Integer)
						append edges edge
						elements = scanline(fInput)
					)
					if (edges.count != edge_count) then throw "expected edges count not equals readed"
				)	
				"polys":
				(
					polys = #()
					local poly_count = elements[2] as Integer
					elements = scanline(fInput)
					if elements[1] != "{" then throw "incorrect polys block"	
					elements = scanline(fInput)
					local poly
					while (elements[1] != "}") do
					(
						poly = iv_nv_poly start_index:(elements[1] as Integer) index_count:(elements[2] as Integer) \
									   flags_1:(elements[3] as Integer) flags_2:(elements[4] as Integer) flags_3:(elements[5] as Integer)	
						append polys poly
						elements = scanline(fInput)
					)
					if (polys.count != poly_count) then throw "expected polys count not equals readed"
				)	
				"sectortree":
				(
					sectortree = readSectorTree fInput
				)	
				"portals":
				(
					portals = #()					
					local portals_count = elements[2] as Integer
					if (portals_count > 0) then
					(
						elements = scanline(fInput)
						if elements[1] != "{" then throw "incorrect portals block"	
						elements = scanline(fInput)
						local portal
						while (elements[1] != "}") do
						(
							portal = iv_nv_portal point1_x:(elements[1] as Integer) point1_y:(elements[2] as Integer) point1_z:(elements[3] as Integer) \
									 		   SectorId1:(elements[4] as Integer) PolyId1:(elements[5] as Integer) \
											   point2_x:(elements[6] as Integer) point2_y:(elements[7] as Integer) point2_z:(elements[8] as Integer) \
									 		   SectorId2:(elements[9] as Integer) PolyId2:(elements[10] as Integer) \
											   Direction:(elements[11] as Integer) Angle:(elements[12] as Integer)	
							append portals portal
							elements = scanline(fInput)
						)
						if (portals.count != portals_count) then throw "expected portals count not equals readed"
					)
				)					
				default:
				(
					throw ("unhandled block " + elements[1])
				)
			)
			
		)
		close fInput
	)
)

struct ofio_iv_nv_dump
(
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
		maxOps.cloneNodes obj offset:[0,0,0] expandHierarchy:true cloneType:#instance actualNodeList:#() newNodes:&result 
		local res = result[1]
		return res
	),
	
	fn colapse obj = (
		if (classof obj == Editable_Poly) then 
		( 
			convertTo obj (Editable_Mesh)
			meshOp.weldVertsByThreshold obj obj.verts 0.01
			convertTo obj (Editable_Poly)
		) else throw "poly expected"
	),
	
	fn get_sector_id_from_point p = (
		local sx = ( (p[1] + 3000.0) as Integer) / 100
		local sy = ( (p[2] + 3000.0) as Integer) / 100 
		
		result = sy * 60 + sx + 1
		if result > 0 and result <= 3600 
			then return result 
			else return -1
	),
	
	fn get_sector_id_using_poly navmesh poly_id = (
		local verts = polyop.getFaceVerts navmesh poly_id
		local i
		for i in verts do 
		(
			local sector_id = get_sector_id_from_point (polyop.getVert navmesh i) 
			if sector_id > 0 then return sector_id
		)
		--for i in verts do print (polyop.getVert navmesh i)
		--format "--------------------"
		return -1
	),	
	
	fn get_quadsector_num_using_point sector_coords point = (
		local result = #()
		if (sector_coords[1] + 50.0 <= point[1]) and (sector_coords[2] + 50.0 <= point[2]) then append result 1
		if (sector_coords[1] + 50.0 <= point[1]) and (sector_coords[2] + 50.0 >= point[2]) then append result 2
		if (sector_coords[1] + 50.0 >= point[1]) and (sector_coords[2] + 50.0 >= point[2]) then append result 3
		if (sector_coords[1] + 50.0 >= point[1]) and (sector_coords[2] + 50.0 <= point[2]) then append result 4
		return result
	),
	
	fn get_coords_using_sector_id id = (
		local x = mod (id - 1) 60
		local y = (id - 1) / 60
		return #(x * 100.0 - 3000.0, y * 100.0 - 3000.0)
	),	
	
	fn get_sector_name_using_id id = (
		local x = ((mod (id - 1) 60) * 2) as Integer
		local y = (((id - 1) / 60) * 2) as Integer
		return ("sectors2x2_" + (x as String) + "_" + (y as String) + ".onv")
	),		

	fn cleanup = (
		try (delete G_IV_NV_NAVMESH) catch ()
		local e = false
		try ( gc() ) catch ( e = true )
		if e then throw "Error while performing garbage collection in cleanup"
	),
	
	fn full_scene_surround_kill_links pathIn pathOut = (
		cleanup()
		if objects.count == 0 then throw "scene has no objects"
		-- fill sectors ids used in the scene
		local i, j, k, scene_sectors = #(), surround_sectors = #()
		scene_sectors.count = 3600
		surround_sectors.count = 3600
		for i = 1 to objects.count do
		(				
			local name_contents = filterString objects[i].name "_"
			if name_contents.count > 1 then
				if name_contents[1] == "nv" then
					if name_contents[2] == "m" then
						if superclassof objects[i] == GeometryClass then
						(
							local mesh = snapshot objects[i]
							convertToPoly mesh
							for j = 1 to mesh.faces.count do
							(
								-- get sector id of the poly using it's center
								local face_center = polyop.getFaceCenter mesh j
								local sector_id = get_sector_id_from_point(face_center)
								if sector_id == -1 then 
								(
									print face_center
									throw "incorrect poly for a sector surround search"
								)
								-- add scene sector
								scene_sectors[sector_id] = true
								-- get sector coords
								local coords = get_coords_using_sector_id sector_id
								-- add surround sectors
								if coords[1] > -3000.0 then surround_sectors[sector_id-1] = true
								if coords[1] < 2900.0 then surround_sectors[sector_id+1] = true
								if coords[2] > -3000.0 then surround_sectors[sector_id-60] = true
								if coords[2] < 2900.0 then surround_sectors[sector_id+60] = true
								--print surround_sectors
							)
							delete mesh							
						)
		)
		-- cut duplicated sector ids
		local surround_sectors_new = #()
		for i = 1 to surround_sectors.count do
			if surround_sectors[i] != undefined then
				if scene_sectors[i] == undefined then
					append surround_sectors_new i
		
		-- normalized sector ids 	
		local scene_sectors_new = #()
		for i = 1 to scene_sectors.count do
			if scene_sectors[i] != undefined then append scene_sectors_new (i - 1)

		-- remove edge links from that sectors
		if surround_sectors_new.count > 0 then
		for i = 1 to surround_sectors_new.count do 
		(
			local name = get_sector_name_using_id surround_sectors_new[i]
			if (getFileSize (pathIn + "\\" + name)) > 0 then
			(
				ofioLog.print ("processing " + name + " " + (surround_sectors_new[i] as String))
				local nv = ofio_iv_nv_descriptor()
				nv.read(pathIn + "\\" + name) 
				
				-- edges
				if nv.edges.count > 0 then
					for j = 1 to nv.edges.count do
						for k in scene_sectors_new do
							if nv.edges[j].sector_1 == k then
							(
								nv.edges[j] = iv_nv_edge sector_1:-1 poly_1:-1 flags_1:0 sector_2:-1 poly_2:-1 flags_2:1 
								exit
							)
				-- portals			
				local portals = #()
				for j in nv.portals do
					if ((findItem scene_sectors_new j.SectorId1) == 0) and ((findItem scene_sectors_new j.SectorId2) == 0) then
						append portals j
				nv.portals = portals						
					
				nv.write(pathOut + "\\" + G_IV_NV_DEBUG_NAME_PREFIX + name)
				nv = undefined
			) else throw ("can't locate onv for reading: " + name)
			
			ofioLog.progress (100.0 * i / surround_sectors_new.count)
		)
		local e = false
		try ( gc() ) catch ( e = true )
		if e then throw "Error while performing garbage collection after removing orig links"				
	),

	fn full_scene path collapse_mesh:true = (
		cleanup()
		
		local objs = #()
		local bounds = #()
		local portals = #()
		local i, j
		
		if objects.count == 0 then throw "scene has no objects"
		
		-- collect geometry and bounds
		ofioLog.print "collecting navmesh related objects"
		for i = 1 to objects.count do
		(				
			local name_contents = filterString objects[i].name "_"
			if name_contents.count > 1 then
				if name_contents[1] == "nv" then
				(
					if name_contents[2] == "m" then
					(
						if superclassof objects[i] != GeometryClass then throw (objects[i].name + " must have geometry")
						local obj = makeclone objects[i]
						convertToPoly obj
						obj.name = G_IV_NV_TEMP_NAME_PRE_PREFIX + objects[i].name
						append objs obj			
					) else
					if name_contents[2] == "b" then
					(
						if classof objects[i] != Sphere then throw (objects[i].name + " bound is not a sphere")
						append bounds (Point4 objects[i].pos[1] objects[i].pos[2] objects[i].pos[3] objects[i].radius)
					) else
					if name_contents[2] == "p" then
					(
						if classof objects[i] != SplineShape then throw (objects[i].name + " portal is not a spline")
						append portals objects[i]
					) else 
						throw (objects[i].name + " is unknown navmesh related object")						
				)
		)
		
		if objs.count == 0 then throw "no navmesh geometry found (nv_m_* objects)"
		
		-- create bounds reverse array
		local bounds_reverse_array = #()
		if bounds.count > 0 then
		(
			for i = 1 to bounds.count do
			(
				local sector_id = get_sector_id_from_point(bounds[i])
				local quadnum = get_quadsector_num_using_point (get_coords_using_sector_id sector_id) bounds[i]
				quadnum = quadnum[1]
				if sector_id == -1 then continue
				if bounds_reverse_array[sector_id] == undefined then bounds_reverse_array[sector_id] = #()
				append bounds_reverse_array[sector_id] #(quadnum, i)			
			)
		)
		
		-- create navigation mesh 
		G_IV_NV_NAVMESH = Editable_Mesh name:(G_IV_NV_TEMP_NAME_PRE_PREFIX + "global")
		local navmesh = G_IV_NV_NAVMESH
		convertTo navmesh (Editable_Poly)
		navmesh.pos = [0.0, 0.0, 0.0]
		
		print objs
		if G_IV_NV_PRINT_TEMP then ofioLog.print "--------------------------------------"
		
		ofioLog.print ("bounds: " + (bounds.count as String) + " portals: " + (portals.count as String))
		
		-- attach objects
		ofioLog.print "attaching meshes"
		linearAttach navmesh objs
		ofioLog.print ("total verts: " + (navmesh.verts.count as String))
		
		local e = false
		try ( gc() ) catch ( e = true )
		if e then throw "Error while performing garbage collection after mesh attaching"
		
		-- divide by grid
		ofioLog.print "slicing mesh using grid"
		local s = grid_slicer()
		s.slice(navmesh)
		s = undefined
		ofioLog.print ("total verts after grid division: " + (navmesh.verts.count as String))		
		
		try ( gc() ) catch ( e = true )
		if e then throw "Error while performing garbage collection after grid division"
		
		-- weld verts with the same coords
		if collapse_mesh then 
		(
			ofioLog.print "welding verts"
			colapse navmesh	
			ofioLog.print ("total verts after weld: " + (navmesh.verts.count as String))
		)		
		
		try ( gc() ) catch ( e = true )
		if e then throw "Error while performing garbage collection after weld"
	
		-- check the material
		if classof navmesh.material != multimaterial then throw "no-material geometry is not allowed"
		if navmesh.material.numsubs < 1 then throw "no submaterial geometry is not allowed"		
		
		local sector_poly_ids = #() -- [sector id][sector poly index] = face id in the mesh
		local portal_polys = #() -- polys with ladder flags
		local reverse_sector_poly_ids = #() -- [face id in the mesh] = (sector id, sector poly index)
		sector_poly_ids.count = 3600
		local reverse_edge_poly = #()
		reverse_edge_poly.count = navmesh.edges.count
			
		ofioLog.print ("navmesh.faces.count: " + (navmesh.faces.count as String))
		
		-- when geometry is lowpoly grid can create bad edges on the map borders, 
		local unmatched_polys = 0
		
		ofioLog.print "separating polys by sectors"
		for i = 1 to navmesh.faces.count do
		(
			-- get sector id of the poly using it's center
			local face_center = polyop.getFaceCenter navmesh i
			local sector_id = get_sector_id_from_point(face_center)
			if sector_id < 1 then sector_id = get_sector_id_using_poly navmesh i

			-- init reverse array element
			append reverse_sector_poly_ids (#(-1, -1))

			-- append polys to the sector's poly list
			if sector_id > 0 then
			(
				if sector_poly_ids[sector_id] == undefined then sector_poly_ids[sector_id] = #()
				append sector_poly_ids[sector_id] i
				reverse_sector_poly_ids[i] = (#(sector_id, sector_poly_ids[sector_id].count))			
				--format "sector_id % %\n" sector_id (sector_poly_ids[sector_id].count) 
				
				-- append poly to the edge-poly reverse array
				local _edges = polyop.getFaceEdges navmesh i
				for j in _edges do
				(
					if (j == 0) or (j > reverse_edge_poly.count) then throw "bad edge id"
					if reverse_edge_poly[j] == undefined then reverse_edge_poly[j] = #()
					append reverse_edge_poly[j] i
				)				
			) else 
			(	
				unmatched_polys += 1
				--format "-- poly center coords --\n"
				--print face_center	
				--throw "poly is not valid for a nav mesh - poly center can't be on a grid"			
			)
		)	
		
		if unmatched_polys > 0 then
		(
			ofioLog.print ("warning: unmatched polys " + (unmatched_polys as String))
			messagebox "warning: unmatched polys found\n"
		)
		
		if G_IV_NV_PRINT_TEMP then ofioLog.print "--------------------------------------"
						
		-- read mats
		ofioLog.print "reading mats"
		local mat_flags = #()
		local mat_ids = navmesh.material.materialIDList			
		for i in mat_ids do
		(
			-- get mat
			local mat = navmesh.material[i]
			-- get flags
		    local flags_1 = 0
			local flags_2 = 0
			local flags_3 = 0 -- TODO: unknown flags				
			flags_1 = bit.set flags_1 1 mat.border
			flags_1 = bit.set flags_1 2 mat.crossing
			flags_1 = bit.set flags_1 3 mat.sidewalk
			flags_1 = bit.set flags_1 4 mat.covered
			flags_1 = bit.set flags_1 6 mat.ladder
			flags_1 = bit.set flags_1 7 mat.landfall
			flags_1 = bit.set flags_1 8 mat.water
			flags_2 = bit.set flags_2 1 mat.ped_walks		
			flags_2 = bit.set flags_2 2 mat.ped_stands
			flags_2 = bit.set flags_2 3 mat.ped_unk
			-- add to the flags[mat id] array
			mat_flags[i] = #(flags_1, flags_2, flags_3)				
		)						
						
		local sector_id		
		
		-- calculate real segment count
		local real_segment_count = 0
		for sector_id = 1 to sector_poly_ids.count do
		(
			if sector_poly_ids[sector_id] == undefined \
				or sector_poly_ids[sector_id].count == 0 then continue
			real_segment_count += 1
		)
		
		-- loop all segments
		ofioLog.print "processing sectors"
		local cur_segment = 0
		for sector_id = 1 to sector_poly_ids.count do
		(
			if sector_poly_ids[sector_id] == undefined \
				or sector_poly_ids[sector_id].count == 0 then continue
		
			cur_segment += 1			
		
			local arr_vertices = #() -- array of Point3
			local arr_vertices_mesh_ids = #() -- array of ids inside the mesh
				
			local arr_indices = #() -- array of ids in arr_vertices 
			local arr_indices_edge_ids = #() -- array of edge ids from the mesh
			local arr_indices_poly_ids = #() -- array of poly ids from the mesh
				
			local arr_polys = #() -- array of iv_nv_poly
			local arr_polys_sectors = #() -- sectors used by a poly verts

			local arr_edges = #() -- array of iv_nv_edge 
			
			local arr_portals = #()
			
			local arr_quadsector_z_min = #(0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF) -- sectortree subsectors aabb z min/max
			local arr_quadsector_z_max = #(-0xFFFF, -0xFFFF, -0xFFFF, -0xFFFF)
			
			-- until the index normalization all type indexation uses 1 as the first element position						

			--if sector_poly_ids[sector_id].count > 10 then
			--	ofioLog.print ("processing sector id: " + (sector_id as String) + " polys: " + (sector_poly_ids[sector_id].count as String))
			
			------------------------------ vertices -----------------------------
			local vert_ids = (polyop.getVertsUsingFace navmesh sector_poly_ids[sector_id]) as Array
			if vert_ids.count == 0 then throw "vert_ids.count == 0"
			
			for i in vert_ids do
			(
				append arr_vertices (polyop.getVert navmesh i)
				append arr_vertices_mesh_ids i
			)
			
			if G_IV_NV_PRINT_TEMP then ofioLog.print ("arr_vertices.count: " + (arr_vertices.count as String))
		
			------------------------------- polys --------------------------------
			
			-- read polys
			local sector_coords = get_coords_using_sector_id sector_id
			for i = 1 to sector_poly_ids[sector_id].count do
			(
				local poly_id = sector_poly_ids[sector_id][i]
				-- poly edges
				local poly_edges = polyop.getFaceEdges navmesh poly_id	
				join arr_indices_edge_ids poly_edges	
				-- poly indicies
				local poly_verts = polyop.getFaceVerts navmesh poly_id	
				-- read poly
				local start_index = arr_indices.count
				local index_count = poly_verts.count
				local mat_id = polyop.getFaceMatID navmesh poly_id
				-- flags from mats
				local flags = #(0, 0, 0)
				if mat_id > 0 then 
					if mat_flags[mat_id] != undefined 
						then flags = mat_flags[mat_id]
						else (
								local center = point3 0 0 0
								for j in poly_verts do center += (polyop.getvert navmesh j)
								center *= 1.0 / poly_verts.count
								ofioLog.print ("warning: poly with bad material ignored, coords " + (center[1] as String) + " " + (center[2] as String) + " " + (center[3] as String))
 						)
				-- if poly has the ladder flag then append it to the portal polys list		
				if (bit.get flags[1] 6) then 
					--if (findItem portal_polys #(sector_id, i)) == 0 then 
						append portal_polys #(sector_id, i)				
				-- add normalized poly to the poly arr
				local poly = iv_nv_poly start_index:start_index index_count:index_count flags_1:flags[1] flags_2:flags[2] flags_3:flags[3]
				append arr_polys poly
				append arr_polys_sectors #()
				-- read indexes
				for j in poly_verts do
				(
					local index = findItem arr_vertices_mesh_ids j
					if index == 0 then throw "can't find vertex"
					append arr_indices index
					-- poly id for easy access thru index id
					append arr_indices_poly_ids poly_id
					-- poly vertex sector
					local quadsectors = get_quadsector_num_using_point sector_coords arr_vertices[index]
					for quadsector in quadsectors do
					(
						if (findItem arr_polys_sectors[i] quadsector) == 0 then	append arr_polys_sectors[i] quadsector
						-- min/max point
						local vert_z = arr_vertices[index][3]
						if arr_quadsector_z_min[quadsector] > vert_z then arr_quadsector_z_min[quadsector] = vert_z 
						else if arr_quadsector_z_max[quadsector] < vert_z then arr_quadsector_z_max[quadsector] = vert_z
					)
				)				 				
			)
			
			--print arr_polys
			
			if G_IV_NV_PRINT_TEMP then ofioLog.print ("arr_indices.count: " + (arr_indices.count as String))
			
			--print arr_indices

			--------------------------------- edges ------------------------------------
			local links_self = 0, links_adj = 0, links_dummy = 0
			for i = 1 to arr_indices.count do
			(
				local current_poly = arr_indices_poly_ids[i]
				local edge = arr_indices_edge_ids[i]
				local same_edge_polys = reverse_edge_poly[edge] 
				local nvedge 
				local target_poly 
						
				case same_edge_polys.count of
				(
					0: throw "same_edge_polys.count is empty"
					1: target_poly = same_edge_polys[1]
					2: for j in same_edge_polys do if j != current_poly then target_poly = j
					default: 
					(	
						cleanup()
						throw "same_edge_polys.count > 2" -- can't happen in 3dsmax poly editing mode
					)
				)
						
				--print current_poly
				--print target_poly
				if target_poly != current_poly then
				(
					-- validate that poly is in the global list, collected from the segment
					if reverse_sector_poly_ids[target_poly] == undefined \ 
						or reverse_sector_poly_ids[current_poly] == undefined then 
							throw "used poly is undefined in the global sector poly list"
					if reverse_sector_poly_ids[target_poly][1] < 1 or reverse_sector_poly_ids[target_poly][1] > 3600 \
						or reverse_sector_poly_ids[current_poly][1] < 1 or reverse_sector_poly_ids[current_poly][1] > 3600 then
							throw "global poly list bad item, sector id isn't valid"
							
					-- collect link stats
					if reverse_sector_poly_ids[target_poly][1] != reverse_sector_poly_ids[current_poly][1] then
					(
						links_adj += 1
						
						--local verts = polyop.getEdgeVerts navmesh edge
						--local center = ((navmesh.getvertex verts[1]) + (navmesh.getvertex verts[2])) / 2
						--local s = sphere radius:1.0 pos:center color:red
						
					) else links_self += 1
						
					-- fill iv_nv_edge structure as a normalized one 
					local poly = reverse_sector_poly_ids[target_poly]
					nvedge = iv_nv_edge sector_1:(poly[1]-1) poly_1:(poly[2]-1) flags_1:0 sector_2:(poly[1]-1) poly_2:(poly[2]-1) flags_2:0
				) else
				(
					-- no edge
					links_dummy += 1
					nvedge = iv_nv_edge sector_1:-1 poly_1:-1 flags_1:0 sector_2:-1 poly_2:-1 flags_2:1	
				)
					
				append arr_edges nvedge -- already normalized
			) -- edge loop
			
			if G_IV_NV_PRINT_TEMP then ofioLog.print ("edges self: " + (links_self as String) + " adjacent: " + (links_adj as String) + " dummy: " + (links_dummy as String))	
			
			-------------------------------------- quadsectors -------------------------------------
			local tree = iv_nv_sector_tree AABBmin:undefined AABBmax:undefined SectorData:undefined \
				  SubTree0:(iv_nv_sector_tree AABBmin:undefined AABBmax:undefined SectorData:undefined SubTree0:undefined SubTree1:undefined SubTree2:undefined SubTree3:undefined) \
				  SubTree1:(iv_nv_sector_tree AABBmin:undefined AABBmax:undefined SectorData:undefined SubTree0:undefined SubTree1:undefined SubTree2:undefined SubTree3:undefined) \
				  SubTree2:(iv_nv_sector_tree AABBmin:undefined AABBmax:undefined SectorData:undefined SubTree0:undefined SubTree1:undefined SubTree2:undefined SubTree3:undefined) \
				  SubTree3:(iv_nv_sector_tree AABBmin:undefined AABBmax:undefined SectorData:undefined SubTree0:undefined SubTree1:undefined SubTree2:undefined SubTree3:undefined)
			
			-- aabb min/max 
			-- for main sector
			local coords = get_coords_using_sector_id sector_id
			local coord_z = arr_quadsector_z_min[1]
			for i in arr_quadsector_z_min do if coord_z > i then coord_z = i
			tree.AABBmin = Point3 coords[1] coords[2] coord_z
			coord_z = arr_quadsector_z_max[1]
			for i in arr_quadsector_z_max do if coord_z < i then coord_z = i
			tree.AABBmax = Point3 (coords[1] + 100.0) (coords[2] + 100.0) coord_z
			-- subsector 0
			tree.SubTree0.AABBmin = #(coords[1] + 50.0, coords[2] + 50.0, arr_quadsector_z_min[1])
			tree.SubTree0.AABBmax = #(coords[1] + 100.0, coords[2] + 100.0, arr_quadsector_z_max[1])
			-- subsector 1
			tree.SubTree1.AABBmin = #(coords[1] + 50.0, coords[2], arr_quadsector_z_min[2])
			tree.SubTree1.AABBmax = #(coords[1] + 100.0, coords[2] + 50.0, arr_quadsector_z_max[2])
			-- subsector 2
			tree.SubTree2.AABBmin = #(coords[1], coords[2], arr_quadsector_z_min[3])
			tree.SubTree2.AABBmax = #(coords[1] + 50.0, coords[2] + 50.0, arr_quadsector_z_max[3])			
			-- subsector 3
			tree.SubTree3.AABBmin = #(coords[1], coords[2] + 50.0, arr_quadsector_z_min[4])
			tree.SubTree3.AABBmax = #(coords[1] + 50.0, coords[2] + 100.0, arr_quadsector_z_max[4])
			
			-- sector data 
			tree.SubTree0.SectorData = iv_nv_sector_data PolyIndices:#() Bounds:#()
			tree.SubTree1.SectorData = iv_nv_sector_data PolyIndices:#() Bounds:#()
			tree.SubTree2.SectorData = iv_nv_sector_data PolyIndices:#() Bounds:#()
			tree.SubTree3.SectorData = iv_nv_sector_data PolyIndices:#() Bounds:#()
			-- polys 			
			for i = 1 to arr_polys_sectors.count do 
				for j in arr_polys_sectors[i] do
					case j of
					(
						1: append tree.SubTree0.SectorData.PolyIndices (i - 1) -- normalized
						2: append tree.SubTree1.SectorData.PolyIndices (i - 1)
						3: append tree.SubTree2.SectorData.PolyIndices (i - 1)
						4: append tree.SubTree3.SectorData.PolyIndices (i - 1)
						default: throw "incorrect subsector id"
					)
			
			-- normalization consts
			local Sizes = tree.AABBmax - tree.AABBmin
			if Sizes[3] < 16 then Sizes[3] = 16.0
			local mul_matrix = Point3 (65536.0 / Sizes[1]) (65536.0 / Sizes[2]) (65536.0 / Sizes[3])

			-- bounds
			if bounds_reverse_array[sector_id] != undefined then
				for i in bounds_reverse_array[sector_id] do
				(
					local bound_quadsector = i[1]
					local bound_id = i[2]
					local bound = ((Point3 bounds[bound_id][1] bounds[bound_id][2] bounds[bound_id][3]) - tree.AABBmin) * mul_matrix
					bound = Point4 (bound[1] as Integer) (bound[2] as Integer) (bound[3] as Integer) ( (bounds[bound_id][4] * 65536.0 ) as Integer)
					if bound[1] > 65535 then bound[1] = 65535
					if bound[2] > 65535 then bound[2] = 65535
					if bound[3] > 65535 then bound[3] = 65535
					if bound[4] > 65535 then 
					(
						if bound[4] > 65555 then 
							format "warning: bound % % % radius (%) is bigger than max allowed (1.0), using 1.0 instead of %\n" \
								bounds[bound_id][1] bounds[bound_id][2] bounds[bound_id][3] bounds[bound_id][4] bounds[bound_id][4]
						bound[4] = 65535
					)
					case bound_quadsector of
					(
						1: append tree.SubTree0.SectorData.Bounds bound -- normalized
						2: append tree.SubTree1.SectorData.Bounds bound
						3: append tree.SubTree2.SectorData.Bounds bound
						4: append tree.SubTree3.SectorData.Bounds bound
						default: throw "incorrect bound_quadsector id"
					)
				)	
			
			if G_IV_NV_PRINT_TEMP then print tree
			
			------------------------------- portals ------------------------------- 
			
			for i in portals do
			(
				if (i.numSplines != 1) or ( (numKnots i) != 2 ) then 
				(
					ofioLog.print ("warning: incorrect portal spline " + i.name + " skipped")
					continue
				)
				local coord_1 = getKnotPoint i 1 1
				local coord_2 = getKnotPoint i 1 2
				if (get_sector_id_from_point coord_1) != sector_id then continue

				-- find closest ladder surfaced poly 
				local dist_1 = 100.0, dist_2 = 100.0, poly_1, poly_2
				for j in portal_polys do
				(
					local poly_id = sector_poly_ids[j[1]][j[2]]
					-- points to calc distance with
					local points = #()
					append points (polyop.getFaceCenter navmesh poly_id)
					-- get vert points					
					local poly_verts = polyop.getFaceVerts navmesh poly_id 
					local cur_vert_id					
					for cur_vert_id in poly_verts do append points (polyop.getvert navmesh cur_vert_id) 
					-- find closest point
					local point
					for point in points do
					(
						-- spline start
						local dist = distance coord_1 point
						if dist < dist_1 then 
						(
							dist_1 = dist
							poly_1 = j
						) 		
						
						-- spline end
						dist = distance coord_2 point
						if dist < dist_2 then 
						(
							dist_2 = dist
							poly_2 = j
						)		
					)
				)
				-- check for max distance
				if (dist_1 > 10.0) or (dist_2 > 10.0) then
				(
					ofioLog ("warning: portal spline " + i.name + " start/end is too far from the closest ladder poly, skipped")
					continue				
				)
				-- format "dist_1 % dist_2 %\n" dist_1 dist_2
				
				-- calculate portal data
				local direction = (getuserprop i "direction") as Integer
				local angle = (getuserprop i "angle") as Integer
				if angle < 0 then angle += 360
				angle = (angle * 255 / 360) as Integer
				coord_1 = (coord_1 - tree.AABBmin) * mul_matrix
				if coord_1[1] < 0 then coord_1[1] = 0
				if coord_1[2] < 0 then coord_1[2] = 0
				if coord_1[3] < 0 then coord_1[3] = 0
				if coord_1[1] > 65535 then coord_1[1] = 65535 
				if coord_1[2] > 65535 then coord_1[2] = 65535 
				if coord_1[3] > 65535 then coord_1[3] = 65535 
				coord_2 = (coord_2 - tree.AABBmin) * mul_matrix
				if coord_2[1] < 0 then coord_2[1] = 0
				if coord_2[2] < 0 then coord_2[2] = 0
				if coord_2[3] < 0 then coord_2[3] = 0
				if coord_2[1] > 65535 then coord_2[1] = 65535 
				if coord_2[2] > 65535 then coord_2[2] = 65535 
				if coord_2[3] > 65535 then coord_2[3] = 65535 
				-- add normalized portal
				local portal = iv_nv_portal point1_x:(coord_1[1] as Integer) point1_y:(coord_1[2] as Integer) point1_z:(coord_1[3] as Integer) SectorId1:(poly_1[1] - 1) PolyId1:(poly_1[2] - 1) \
										 point2_x:(coord_2[1] as Integer) point2_y:(coord_2[2] as Integer) point2_z:(coord_2[3] as Integer) SectorId2:(poly_2[1] - 1) PolyId2:(poly_2[2] - 1) \
										 Angle:angle Direction:direction
				if G_IV_NV_PRINT_TEMP then print portal
				append arr_portals portal				
			)
			
			---------------------------- normalization ---------------------------
			
			local Flags = 3 -- TODO 
			local SectorId = sector_id - 1
			
			-- verts
			for i = 1 to arr_vertices.count do 
			(
				arr_vertices[i] = ((arr_vertices[i] - tree.AABBmin) * mul_matrix) 
				for j = 1 to 3 do 
				(
					arr_vertices[i][j] = arr_vertices[i][j] as Integer
					if (arr_vertices[i][j] >= 65536) and (arr_vertices[i][j] < 65536 + /*MAX_COORD_OVERLAP*/ 32) then arr_vertices[i][j] = 65535
					if (arr_vertices[i][j] < 0) and (arr_vertices[i][j] > -32) then arr_vertices[i][j] = 0
					if (arr_vertices[i][j] < 0) or (arr_vertices[i][j] > 65535) then
					(
						print arr_vertices[i]
						print Sizes
						throw "vertex coords overlap"
					)
				)
			)
			
			-- indices
			for i = 1 to arr_indices.count do arr_indices[i] -= 1
		
			-- polys already normalized
			-- edges already normalized
			-- tree already normalized
			
			local nvdesc = ofio_iv_nv_descriptor version:undefined sizes:Sizes flags:Flags vertices:arr_vertices \
 								 		 indices:arr_indices edges:arr_edges polys:arr_polys \
										 sectortree:tree portals:arr_portals sectorid:SectorId
		
			nvdesc.write(path + "\\" + G_IV_NV_DEBUG_NAME_PREFIX + get_sector_name_using_id(sector_id))
				
			nvdesc = undefined
			
			if (mod sector_id 100) == 0 then
			(
				local e = false
				try ( gc() ) catch ( e = true )
				if e then throw "Error while performing garbage collection after sector saving"			
			)
			
			if G_IV_NV_PRINT_TEMP then ofioLog.print "--------------------------------------"
			
			ofioLog.progress (100.0 * cur_segment / real_segment_count)
			
		) -- sector_id loop		

		cleanup()
	) -- full_scene
	
) -- ofio_iv_nv_dump
