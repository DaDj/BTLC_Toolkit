-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- dev-c.com, openiv.com

-- Description: oft
-- Last changed: Jan 2015

fileIn "ofio.iv.drawable.ms"

global g_ft_drawable = undefined
global g_ft_skel = undefined
global g_ft_is_veh = undefined
global g_ft_is_bike = undefined
global g_ft_children = #()
global g_ft_child_meshes = #()
global g_ft_child_bounds = #()

global cur_path
global files_written

struct ofio_iv_ft_child_file (
	lodgroup,
	dumped_lodgroup,
	boundTransform,
	bound,
	dumped_bound
)

struct ofio_iv_ft_child (
	normalForm,
	damagedForm,
	pristineMass,
	damagedMass,
	f8,
	f50,
	
	normalFile,
	damagedFile,
	
	group_name,
	group_bone_index,
	
	descriptor,	
	
	fn get_parent_bone_names_for_child_meshes_using_group_name name = (
		case ofutils.lowercase(name) of
		(
			"wheel_lf": 
			(
				if g_ft_is_bike 
					then return #("wheelmeshbk_f", "wheelmeshbk_f_l1") 
					else return #("wheelmesh_lf", "wheelmesh_lf_l1")
			)
			"wheel_lr": -- bikes only
			(
				if g_ft_is_bike
					then return #("wheelmeshbk_r", "wheelmeshbk_r_l1")
					else return #(name) 
			)
			"static_rotor1": return #("static_rotor1", "moving_rotor1")
			"static_rotor2": return #("static_rotor2", "moving_rotor2")
			default: return #(name)
		)
	),
	
	fn get_child_mesh_parent_obj_using_bone_names_arr names mesh_index = (
		local name = undefined
		if names.count == 1 then
		(
			name = names[1]
		) else
		(
			name = names[mesh_index]
		)
		if name == undefined then throw ""	
		--format "searching for bone name %\n" name
		return g_ft_skel.boneObjUsingName g_ft_skel.rootBone name
	),
	
	fn build_file childFile child_index damaged:false = (
		if childFile == undefined then 
			return undefined
		-- bound	

		if not childFile.bound.is_empty	then
		(
			local obj = childFile.bound.build()
	
			if obj == undefined then
				throw ("fragment child bound build error in group " + group_name + "\n")
			obj.parent = g_ft_skel.boneObjUsingName g_ft_skel.rootBone group_name
			if obj.parent != undefined do 
			(
				obj.transform *= childFile.boundTransform * obj.parent.transform
				obj.name = group_name + "_" + (child_index as string) + (if damaged then "d" else "")
			)
			
		
			setUserProp obj "fragment_child_name" descriptor.name
			if damaged then setUserProp obj "damaged" true
		)
		
		-- drawable meshes
		local mesh_parent_names = get_parent_bone_names_for_child_meshes_using_group_name group_name	
		
		local lodgroup = childFile.lodgroup, meshes = #(), mesh
		for mesh in lodgroup.high_obj do append meshes #(mesh, undefined)
		for mesh in lodgroup.med_obj do append meshes #(mesh, "med")
		for mesh in lodgroup.low_obj do append meshes #(mesh, "low")
		for mesh in lodgroup.vlow_obj do append meshes #(mesh, "vlow")
		
		if meshes.count > 0 then
		(				
			local i
			for i = 1 to meshes.count do
			(
				local obj = meshes[i][1]
				local lod = meshes[i][2]
				local parent = get_child_mesh_parent_obj_using_bone_names_arr mesh_parent_names i
			--	if parent == undefined then throw "get_child_mesh_parent_obj_using_bone_names_arr() returned undefined"
				if parent  != undefined do 
				(
					g_ft_drawable.build_mesh obj g_ft_drawable._mtls (parent.name + "_" + (i as string) + (if damaged then "d" else ""))				
					obj.objs[1].parent = parent								
					obj.objs[1].transform = parent.transform
				)
		
				
				-- world orient presence means that all meshes must be additionally rotated
				if g_ft_skel.HaveBoneWorldOrient then
				(
					local orient = g_ft_skel.getBoneObjectWorldOrient (Point3 0 0 0) parent
					local roteuler = obj.objs[1].rotation as eulerangles
					roteuler = Point3 roteuler.x roteuler.y roteuler.z
					roteuler += orient
					roteuler = eulerangles roteuler.x roteuler.y roteuler.z
					local pos = obj.objs[1].pos
					obj.objs[1].rotation = roteuler
					obj.objs[1].pos = pos
				)				
				if obj.objs[1] != undefined do 
				(
	
					if lod != undefined then setUserProp obj.objs[1] "lod" lod								
					setUserProp obj.objs[1] "fragment_child_name" descriptor.name
					setUserProp obj.objs[1] "priority" i
					if damaged then setUserProp obj.objs[1] "damaged" true
				)
			
			)
		)	
	),
	
	fn build group child_index = (
		descriptor = dummy boxsize:[0.03, 0.03, 0.03] 
		descriptor.parent = group
		descriptor.transform = f50
		descriptor.name = "ftc_" + group_name + "_" + (child_index as string)
		setUserProp descriptor "type" "fragment_child"
		setUserProp descriptor "pristineMass" pristineMass
		setUserProp descriptor "damagedMass" damagedMass
		if normalFile == undefined then
			throw "child has no normal form\n"
		build_file normalFile child_index
		if damagedFile != undefined then
			build_file damagedFile child_index damaged:true
	),
	
	fn dump_file damaged:false = (
		-- damaged children are not allowed for vehicles
		if g_ft_is_veh and damaged 
			then return undefined
			
		-- result file	
		local resultFile = ofio_iv_ft_child_file()
		resultFile.lodgroup = ofio_iv_additional_lodgroup()	
		
		-- collect meshes by lodgroup	
		local lodgroups = #(#(), #(), #(), #()), childMesh
		for childMesh in g_ft_child_meshes do
		(
			local name = getUserProp childMesh "fragment_child_name"
			if name != descriptor.name then continue
			local prop_damaged = getUserProp childMesh "damaged"
			if prop_damaged == undefined then prop_damaged = false
			if (damaged and not prop_damaged) \
			or (not damaged and prop_damaged) 
				then continue
			local lod = getUserProp childMesh "lod"
			case lod of
			(
				"med": append lodgroups[2] childMesh
				"low": append lodgroups[3] childMesh
				"vlow": append lodgroups[4] childMesh
				default: append lodgroups[1] childMesh
			)
		)
		-- sort each lodgroup by mesh priority
		local i, j
		for i = 1 to lodgroups.count do
		(
			local n = lodgroups[i].count
			if n > 1 then
			(
				local bMoved
				do
				(
					bMoved = false
					if n > 1 then
						for j = 1 to n-1 do
						(
							priority1 = (getUserProp lodgroups[i][j] "priority")
							if priority1 == undefined then priority1 = 255
							priority2 = (getUserProp lodgroups[i][j+1] "priority")
							if priority2 == undefined then priority2 = 255
							if priority1 > priority2 then
							(
								local t = lodgroups[i][j]
								lodgroups[i][j] = lodgroups[i][j+1]
								lodgroups[i][j+1] = t
								bMoved = true
							)
						)
					n -= 1
				) while bMoved				
			) 
		)
		-- dump meshes
		local meshes_dumped = false
		for i = 1 to lodgroups.count do
			if lodgroups[i].count > 0 then
				for j = 1 to lodgroups[i].count do
				(
					local ofio_mesh = ofio_iv_mesh()
					local cur_transform = lodgroups[i][j].transform
					local e = undefined
					try (
						-- if skel has world orient flag set for bones that all meshes must be rotated, so making default transform
						if g_ft_skel.HaveBoneWorldOrient then 
							lodgroups[i][j].transform = Matrix3 1					
						ofio_mesh.dump lodgroups[i][j] g_ft_drawable._mtl_hashes skel:undefined
						meshes_dumped = true
					) catch (
						e = getcurrentexception()
					)
					lodgroups[i][j].transform = cur_transform
					ofio_mesh.cleanup() -- cleans up mesh scene objects if any
					if e != undefined then throw e					
					lodgroups[i][j] = ofio_mesh
				)
		resultFile.dumped_lodgroup = lodgroups
				
		-- collect bounds
		local bound_dumped = false		
		local _bound = undefined, childBound
		for childBound in g_ft_child_bounds do
		(
			local name = getUserProp childBound "fragment_child_name"
			if name != descriptor.name then continue
			local prop_damaged = getUserProp childBound "damaged"
			if prop_damaged == undefined then prop_damaged = false
			if (damaged and not prop_damaged) \
			or (not damaged and prop_damaged) 
				then continue			
			_bound = childBound
			exit
		)
		if _bound != undefined then
		( 
			-- calc transform
			local type = ofutils.lowercase(getUserProp _bound "type")
			local cur_transform = _bound.transform -- save trsnaltion matrix
			local boundTransform = Matrix3 0
			local move_pos = undefined							
			if type == "boundgeometry" then
			(
				boundTransform[1] = [1, 0, 0]
				boundTransform[2] = [0, 1, 0]
				boundTransform[3] = [0, 0, 1]	
				boundTransform[4] = [0, 0, 0]					
			) else
			(
				local t = Matrix3 0
				t[1] = [1, 0, 0]
				t[2] = [0, 1, 0]
				t[3] = [0, 0, 1]
				t[4] = [0, 0, 0]
				boundTransform = _bound.transform * inverse(t) * inverse(_bound.parent.transform)
				move_pos = t[4]
			)
	
			_bound.transform *= inverse(boundTransform) * inverse(_bound.parent.transform)
			if move_pos != undefined then _bound.pos = move_pos
			
			-- f8
			if f8 == undefined then f8 = boundTransform * inverse(f50) * _bound.parent.transform
			
			-- group_bone_index
			if group_bone_index == undefined then
				if g_ft_is_veh 
					then group_bone_index = 0
					else group_bone_index = getUserProp _bound.parent "_ignore_this_autogenerated_index"
			
			-- dump
			resultFile.bound = ofio_iv_bound_container()
			resultFile.boundTransform = boundTransform
			local e = undefined
			try (
				resultFile.bound.dump _bound
				bound_dumped = true
			) catch (
				e = getcurrentexception()
			)				
			_bound.transform = cur_transform -- restore translation matrix
			if e != undefined then throw e	
			
		) else
		(
			if g_ft_is_veh 
				then throw ("FRAGMENT ERROR\n\n" + "child " + descriptor.name + " has no bound\n")
			resultFile.bound = ofio_iv_bound_container()
			resultFile.bound.is_empty = true
			local t = Matrix3 0
			t[1] = [1, 0, 0]
			t[2] = [0, 1, 0]
			t[3] = [0, 0, 1]
			resultFile.boundTransform = t
		)		
	
		-- return dumped
		if damaged 
			then return (if meshes_dumped or bound_dumped then resultFile else undefined)
			else return resultFile
	),
	
	fn dump obj = (
		if ofutils.lowercase(getUserProp obj "type") != "fragment_child" then 
			throw ("FRAGMENT ERROR\n\n" + obj.name + " is not fragment_child\n")
		descriptor = obj
		f50 = descriptor.transform
		-- props
		pristineMass = getUserProp descriptor "pristineMass" 
		damagedMass = getUserProp descriptor "damagedMass" 		
		-- check props
		if pristineMass == undefined or damagedMass == undefined 
			then throw ("FRAGMENT ERROR\n\nFragment child " + descriptor.name + " has incorrect or missing props\n")
		
		-- dump files
		normalFile = dump_file()
		if not g_ft_is_veh then
			damagedFile = dump_file damaged:true
	),
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		l = undefined	
		return s
	),		
	
	fn read_file fInputName = (
		local result = ofio_iv_ft_child_file()
		local fInput = openFile (cur_path + fInputName)
		local _path = ofutils.extractFilePath(cur_path + fInputName)
		local version = scanline fInput		
		if (version[2] as Integer != 112) or (version[3] as Integer != 2) then
			throw "not supported child, version 112 2 is supported only"
		-- drawable
		local elements = scanline fInput
		if ofutils.lowercase(elements[1]) != "drawable" then throw "child drawable expected"
		elements = scanline fInput
		if elements[1] != "{" then throw "drawable start expected"
		elements = scanline fInput
		if ofutils.lowercase(elements[1]) != "lodgroup" then throw "lodgroup expected"
		
		result.lodgroup = ofio_iv_additional_lodgroup()
		result.lodgroup.name = group_name
		result.lodgroup.read fInput _path
		
		elements = scanline fInput
		if elements[1] != "}" then throw "drawable end expected"
		
		-- bounds
		elements = scanline fInput
		if ofutils.lowercase(elements[1]) != "boundtransform" then throw "child boundTransform expected"
		elements = scanline fInput
		if elements[1] != "{" then throw "boundTransform start expected"
		result.boundTransform = Matrix3 0
		local i
		for i = 1 to 4 do
		(			
			elements = scanline fInput
			result.boundTransform[i] = [elements[1] as Float, elements[2] as Float, elements[3] as Float]
		)				
		elements = scanline fInput
		if elements[1] != "}" then throw "boundTransform end expected"
		
		ofio_iv_opened_blocks = 0
		result.bound = ofio_iv_bound_container()
		result.bound.read fInput

		close fInput
		
		return result
	),

	fn read = (
		normalFile = read_file normalForm
		if damagedForm != "null" then
			damagedFile = read_file damagedForm
	),

	fn write_file childFile fOutputName = (
		local cur_path = ofutils.extractFilePath(fOutputName)
		local name_prefix = ofutils.removeExt(ofutils.extractFileName fOutputName)
		
		local fOutput = createFile fOutputName
		format "Version 112 2\n" to:fOutput
		
		-- lodgroup
		local dumped_lodgroup = childFile.dumped_lodgroup
		format "drawable\n{\n" to:fOutput
		format "\x09lodgroup\n\x09{\n" to:fOutput
		local i, group_names = #("high", "med", "low", "vlow"), bbox = undefined
		for i = 1 to 4 do
		(
			format "\x09\x09% " group_names[i] to:fOutput
			if dumped_lodgroup[i].count > 0 then
			(
				format "% " dumped_lodgroup[i].count to:fOutput
				for j = 1 to dumped_lodgroup[i].count do
				(
					local mesh_name = name_prefix + "_" + group_names[i] + "__" + (files_written as string) + ".mesh"
					format "% % " mesh_name group_bone_index to:fOutput
					if bbox == undefined then bbox = dumped_lodgroup[i][j].m_Boundbox
					dumped_lodgroup[i][j].write (cur_path + mesh_name) -- catch exception					
					files_written += 1
				)
				format "9999.0\n" to:fOutput
			) else
			(
				if bbox != undefined 
					then format "none 9999.0\n" to:fOutput
					else format "none 0.0\n" to:fOutput
			)
		)
		if bbox != undefined then
		(
			local center = (bbox[1] + bbox[2]) / 2
			local radius = distance bbox[2] center 
			format ("\x09\x09" + "center % % %\n") (center.x as Float) (center.y as Float) (center.z as Float) to:fOutput
			format ("\x09\x09" + "AABBMin % % %\n") (bbox[1].x as Float) (bbox[1].y as Float) (bbox[1].z as Float) to:fOutput
			format ("\x09\x09" + "AABBMax % % %\n") (bbox[2].x as Float) (bbox[2].y as Float) (bbox[2].z as Float) to:fOutput
			format ("\x09\x09" + "radius %\n") (radius as Float) to:fOutput			
		) else
		(
			format ("\x09\x09" + "center 0.0 0.0 0.0\n") to:fOutput
			format ("\x09\x09" + "AABBMin 0.0 0.0 0.0\n") to:fOutput
			format ("\x09\x09" + "AABBMax 0.0 0.0 0.0\n") to:fOutput
			format ("\x09\x09" + "radius 0.0\n") to:fOutput
		)		
		format "\x09}\n" to:fOutput
		format "}\n" to:fOutput		
		
		-- boundTransform
		local t = childFile.boundTransform
		format "boundTransform\n{\n" to:fOutput
		for i = 1 to 4 do
			format ("\x09% % %\n")  (t[i].x as Float) (t[i].y as Float) (t[i].z as Float) to:fOutput
		format "}\n" to:fOutput
		
		-- bound
		childFile.bound.write fOutput "" is_fragment:true
		
		close fOutput
	),

	-- folders must have trailing slashes
	fn write padding fOutput folder_out folder_out_full = (
		makeDir folder_out_full all:true
		format ("%\x09" + "child ") padding to:fOutput
		if normalFile != undefined then
		(
			local child_name = descriptor.name + "__" + (files_written as string) + ".child"
			files_written += 1
			format "% " (folder_out + child_name) to:fOutput
			write_file normalFile (folder_out_full + child_name)
		) else
		(
			format "null " to:fOutput
		)
		if damagedFile != undefined then
		(
			local child_name = descriptor.name + "_d__" + (files_written as string) + ".child"
			files_written += 1
			format "%" (folder_out + child_name) to:fOutput
			write_file damagedFile (folder_out_full + child_name)
		) else
		(
			format "null" to:fOutput
		)			
		format ("\n%\x09{\n") padding to:fOutput
		format ("%\x09\x09" + "pristineMass %\n") padding (pristineMass as Float) to:fOutput
		format ("%\x09\x09" + "damagedMass %\n") padding (damagedMass as Float) to:fOutput
		
		format ("%\x09\x09" + "f50 [Temporarily|Unknown]\n") padding to:fOutput
		format ("%\x09\x09{\n") padding to:fOutput
		for i = 1 to 4 do
			format ("%\x09\x09\x09% % %\n") padding (f50[i].x as Float) (f50[i].y as Float) (f50[i].z as Float) to:fOutput
		format ("%\x09\x09}\n") padding to:fOutput		
		format ("%\x09}\n") padding to:fOutput
	)	
)

struct ofio_iv_ft_group (
	name,
	strength,
	forceTransmissionScaleUp,
	forceTransmissionScaleDown,
	jointStiffness,
	minSoftAngle1,
	maxSoftAngle1,
	maxSoftAngle2,
	maxSoftAngle3,
	rotationSpeed,
	rotationStrength,
	restoringStrength,
	restoringMaxTorque,
	latchStrength,
	disappearsWhenDead,
	minDamageForce,
	damageHealth,
	children = #(),
	groups = #(),
	
	descriptor,
	
	fn write padding fOutput folder_out folder_out_full = (
		format "%\x09group %\n" padding name to:fOutput
		format "%\x09{\n" padding to:fOutput
		
		format ("%\x09\x09" + "strength %\n") padding (strength as Float) to:fOutput
		format ("%\x09\x09" + "forceTransmissionScaleUp %\n") padding (forceTransmissionScaleUp as Float) to:fOutput
		format ("%\x09\x09" + "forceTransmissionScaleDown %\n") padding (forceTransmissionScaleDown as Float) to:fOutput
		format ("%\x09\x09" + "jointStiffness %\n") padding (jointStiffness as Float) to:fOutput
		format ("%\x09\x09" + "minSoftAngle1 %\n") padding (minSoftAngle1 as Float) to:fOutput
		format ("%\x09\x09" + "maxSoftAngle1 %\n") padding (maxSoftAngle1 as Float) to:fOutput
		format ("%\x09\x09" + "maxSoftAngle2 %\n") padding (maxSoftAngle2 as Float) to:fOutput
		format ("%\x09\x09" + "maxSoftAngle3 %\n") padding (maxSoftAngle3 as Float) to:fOutput
		format ("%\x09\x09" + "rotationSpeed %\n") padding (rotationSpeed as Float) to:fOutput
		format ("%\x09\x09" + "rotationStrength %\n") padding (rotationStrength as Float) to:fOutput
		format ("%\x09\x09" + "restoringStrength %\n") padding (restoringStrength as Float) to:fOutput
		format ("%\x09\x09" + "restoringMaxTorque %\n") padding (restoringMaxTorque as Float) to:fOutput
		format ("%\x09\x09" + "latchStrength %\n") padding (latchStrength as Float) to:fOutput
		format ("%\x09\x09" + "disappearsWhenDead %\n") padding (disappearsWhenDead as Integer) to:fOutput
		format ("%\x09\x09" + "minDamageForce %\n") padding (minDamageForce as Float) to:fOutput
		format ("%\x09\x09" + "damageHealth %\n") padding (damageHealth as Float) to:fOutput		
		
		local _padding = padding + "\x09"
		local i
		if children.count > 0 then
			for i = 1 to children.count do
				children[i].write _padding fOutput folder_out folder_out_full to:fOutput
		if groups.count > 0 then
			for i = 1 to groups.count do		
				groups[i].write _padding fOutput folder_out folder_out_full to:fOutput
				
		format "%\x09}\n" padding to:fOutput				
	),
	
	fn dump obj = (
		if ofutils.lowercase(getUserProp obj "type") != "fragment_group" then 
			throw ("FRAGMENT ERROR\n\n" + obj.name + " is not fragment_group\n")
		descriptor = obj
		name = descriptor.parent.name
		-- props
		strength = getUserProp descriptor "strength" 
		forceTransmissionScaleUp = getUserProp descriptor "forceTransmissionScaleUp" 
		forceTransmissionScaleDown = getUserProp descriptor "forceTransmissionScaleDown" 
		jointStiffness = getUserProp descriptor "jointStiffness" 
		minSoftAngle1 = getUserProp descriptor "minSoftAngle1" 
		maxSoftAngle1 = getUserProp descriptor "maxSoftAngle1" 
		maxSoftAngle2 = getUserProp descriptor "maxSoftAngle2" 
		maxSoftAngle3 = getUserProp descriptor "maxSoftAngle3" 
		rotationSpeed = getUserProp descriptor "rotationSpeed" 
		rotationStrength = getUserProp descriptor "rotationStrength" 
		restoringStrength = getUserProp descriptor "restoringStrength" 
		restoringMaxTorque = getUserProp descriptor "restoringMaxTorque" 
		latchStrength = getUserProp descriptor "latchStrength" 
		disappearsWhenDead = getUserProp descriptor "disappearsWhenDead" 
		minDamageForce = getUserProp descriptor "minDamageForce" 
		damageHealth = getUserProp descriptor "damageHealth" 	
		
		-- check props
		if strength == undefined \	
		or forceTransmissionScaleUp == undefined \
		or forceTransmissionScaleDown == undefined \
		or jointStiffness == undefined \
		or minSoftAngle1 == undefined \
		or maxSoftAngle1 == undefined \
		or maxSoftAngle2 == undefined \
		or maxSoftAngle3 == undefined \
		or rotationSpeed == undefined \
		or rotationStrength == undefined \
		or restoringMaxTorque == undefined \
		or latchStrength == undefined \
		or disappearsWhenDead == undefined \
		or minDamageForce == undefined \
		or damageHealth == undefined
			then throw ("FRAGMENT ERROR\n\nFragment group " + descriptor.name + " has incorrect or missing props\n")
		
		groups = #()
		children = #()
		local child
		for child in obj.children do
		(
			if ofutils.lowercase(getUserProp child "type") != "fragment_child" then 
				throw ("FRAGMENT ERROR\n\n" + child.name + " is not fragment_child\n")
			local _child = ofio_iv_ft_child()
			append children _child
			_child.dump child
			append g_ft_children _child
		)
	),
	
	fn build = (
		if g_ft_skel == undefined then throw ""
		local group_parent_bone = g_ft_skel.boneObjUsingName g_ft_skel.rootBone name
		descriptor = dummy boxsize:[0.05, 0.05, 0.05]
		setUserProp descriptor "type" "fragment_group"
		descriptor.parent = group_parent_bone
		descriptor.name = "ftg_" + name
		
		local child, child_index = 1
		for child in children do
		(
			child.build descriptor child_index
			child_index += 1
		)
		
		local group
		for group in groups do
			group.build()
		
		setUserProp descriptor "strength" strength
		setUserProp descriptor "forceTransmissionScaleUp" forceTransmissionScaleUp
		setUserProp descriptor "forceTransmissionScaleDown" forceTransmissionScaleDown
		setUserProp descriptor "jointStiffness" jointStiffness
		setUserProp descriptor "minSoftAngle1" minSoftAngle1
		setUserProp descriptor "maxSoftAngle1" maxSoftAngle1
		setUserProp descriptor "maxSoftAngle2" maxSoftAngle2
		setUserProp descriptor "maxSoftAngle3" maxSoftAngle3
		setUserProp descriptor "rotationSpeed" rotationSpeed
		setUserProp descriptor "rotationStrength" rotationStrength
		setUserProp descriptor "restoringStrength" restoringStrength
		setUserProp descriptor "restoringMaxTorque" restoringMaxTorque
		setUserProp descriptor "latchStrength" latchStrength
		setUserProp descriptor "disappearsWhenDead" disappearsWhenDead
		setUserProp descriptor "minDamageForce" minDamageForce
		setUserProp descriptor "damageHealth" damageHealth	
	),
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		l = undefined	
		return s
	),	
	
	fn read fInput = (
		local elements = scanline fInput
		if elements[1] != "{" then throw "group start expected"
		
		children = #()
		groups = #()
		
		elements = scanline fInput
		while elements[1] != "}" do
		(		
			case ofutils.lowercase(elements[1]) of
			(
				"strength": strength = elements[2] as Float
				"forcetransmissionscaleup": forceTransmissionScaleUp = elements[2] as Float
				"forcetransmissionscaledown": forceTransmissionScaleDown = elements[2] as Float
				"jointstiffness": jointStiffness = elements[2] as Float
				"minsoftangle1": minSoftAngle1 = elements[2] as Float
				"maxsoftangle1": maxSoftAngle1 = elements[2] as Float
				"maxsoftangle2": maxSoftAngle2 = elements[2] as Float
				"maxsoftangle3": maxSoftAngle3 = elements[2] as Float
				"rotationspeed": rotationSpeed = elements[2] as Float
				"rotationstrength": rotationStrength = elements[2] as Float
				"restoringstrength": restoringStrength = elements[2] as Float
				"restoringmaxtorque": restoringMaxTorque = elements[2] as Float
				"latchstrength": latchStrength = elements[2] as Float
				"disappearswhendead": disappearsWhenDead = elements[2] as Integer
				"mindamageforce": minDamageForce = elements[2] as Float
				"damagehealth": damageHealth = elements[2] as Float
				"child":
				(
					local child = ofio_iv_ft_child()
					append children child
					append g_ft_children child					
					child.group_name = name
					child.normalForm = elements[2]
					child.damagedForm = elements[3]					
					elements = scanline fInput
					if elements[1] != "{" then throw "child start expected"					
					elements = scanline fInput
					while elements[1] != "}" do
					(		
						case ofutils.lowercase(elements[1]) of
						(
							"pristinemass": child.pristineMass = elements[2] as Float
							"damagedmass": child.damagedMass = elements[2] as Float
							"f50":
							(
								elements = scanline fInput
								child.f50 = Matrix3 0
								local i
								for i = 1 to 4 do
								(
									elements = scanline fInput
									child.f50[i] = [elements[1] as Float, elements[2] as Float, elements[3] as Float]
								)
								elements = scanline fInput
							)
							default: throw ("unknown child element " + elements[1])
						)
						elements = scanline fInput
					)
					child.read()
				)
				"group":
				(
					local group = ofio_iv_ft_group()
					group.name = elements[2]
					group.read fInput
					append groups group
				)
				default: throw ("unknown group element " + elements[1])
			)
			elements = scanline fInput
		)
	)
)

struct ofio_iv_oft (
	unbrokenCGOffset,
	dampingLinearC,
	dampingLinearV,
	dampingLinearV2,
	dampingAngularC,
	dampingAngularV,
	dampingAngularV2,
	estimatedCacheSize,
	estimatedArticulatedCacheSize,
	becomeRope,
	artAssetID,
	attachBottomEnd,
	minMoveForce,
	CenterOfMass,
	gravityFactor,
	buoyancyFactor,
	groups = #(),
	flags = #(),	
	drawable,
	
	descName,
	
	fn write fOutputName = (
		files_written = 0
	),
	
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
		if (version[2] as Integer != 112) or (version[3] as Integer != 2) then
			throw "not supported oft, version 112 2 is supported only"	
		descName = ofutils.removeExt(ofutils.extractFileName fInputName)
		cur_path = ofutils.extractFilePath(fInputName)
		
		local elements = scanline fInput
		if ofutils.lowercase(elements[1]) != "fragments" then throw "fragments expected"
		elements = scanline fInput
		if elements[1] != "{" then throw "fragments start expected"
		
		-- read fragments
		groups = #()
		g_ft_children = #()
		elements = scanline fInput
		while elements[1] != "}" do
		(		
			case ofutils.lowercase(elements[1]) of
			(
				"unbrokencgoffset": unbrokenCGOffset = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"dampinglinearc": dampingLinearC = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"dampinglinearv": dampingLinearV = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"dampinglinearv2": dampingLinearV2 = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"dampingangularc": dampingAngularC = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"dampingangularv": dampingAngularV = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"dampingangularv2": dampingAngularV2 = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"estimatedcachesize": estimatedCacheSize = elements[2] as Integer
				"estimatedarticulatedcachesize": estimatedArticulatedCacheSize = elements[2] as Integer
				"becomerope": becomeRope = elements[2] as Integer
				"artassetid": artAssetID = elements[2] as Integer
				"attachbottomend": attachBottomEnd = elements[2] as Integer
				"minmoveforce": minMoveForce = elements[2] as Float
				"centerofmass": CenterOfMass = Point3 (elements[2] as Float) (elements[3] as Float) (elements[4] as Float)
				"gravityfactor": gravityFactor = elements[2] as Float
				"buoyancyfactor": buoyancyFactor = elements[2] as Float
				"group":
				(
					local group = ofio_iv_ft_group()
					append groups group
					group.name = elements[2]
					group.read fInput										
				)
				"flags":
				(
					flags = #()
					if elements.count > 1 then
					(
						local i
						for i = 2 to elements.count do
							append flags elements[i]
					)
				)
				default: throw ("unknown fragments element " + elements[1])
			)
			elements = scanline fInput
		)
		
		-- read drawable
		elements = scanline fInput
		if ofutils.lowercase(elements[1]) != "drawable" then throw "drawable expected"
		drawable = ofio_iv_odr() 
		g_ft_drawable = drawable
		drawable.read_dict fInput "common_drawable" cur_path		
		print "hmm"
		-- f8
		elements = scanline fInput
		if ofutils.lowercase(elements[1]) != "f8" then throw "f8 expected"	
		elements = scanline fInput
		
		local i
		for i = 1 to g_ft_children.count do	
		(
			elements = scanline fInput
			if elements[1] != ((i - 1) as string) then throw ""			
			elements = scanline fInput
			
			g_ft_children[i].f8 = Matrix3 0
			local j
			for j = 1 to 4 do
			(			
				elements = scanline fInput
				g_ft_children[i].f8[j] = [elements[1] as Float, elements[2] as Float, elements[3] as Float]
			)
			
			elements = scanline fInput
		)
		elements = scanline fInput
		if elements[1] != "}" then throw ""
		
		-- ligts
		if not eof(fInput) then
		(
			elements = scanline fInput
			if ofutils.lowercase(elements[1]) == "light" then
			(
				drawable.read_lights fInput
			)
		)
		
		close fInput
	),
	
	fn write fOutputName = (
		files_written = 0
		
		local cur_path = ofutils.extractFilePath(fOutputName)
		local name = ofutils.removeExt(ofutils.extractFileName fOutputName)
	
		local fOutput = createFile fOutputName	
		format "Version 112 2\n" to:fOutput
		
		-- fragments
		format "fragments\n{\n" to:fOutput		
		format ("\x09" + "unbrokenCGOffset % % %\n") (unbrokenCGOffset.x as Float) (unbrokenCGOffset.y as Float) (unbrokenCGOffset.z as Float) to:fOutput
		format ("\x09" + "dampingLinearC % % %\n") (dampingLinearC.x as Float) (dampingLinearC.y as Float) (dampingLinearC.z as Float) to:fOutput
		format ("\x09" + "dampingLinearV % % %\n") (dampingLinearV.x as Float) (dampingLinearV.y as Float) (dampingLinearV.z as Float) to:fOutput
		format ("\x09" + "dampingLinearV2 % % %\n") (dampingLinearV2.x as Float) (dampingLinearV2.y as Float) (dampingLinearV2.z as Float) to:fOutput
		format ("\x09" + "dampingAngularC % % %\n") (dampingAngularC.x as Float) (dampingAngularC.y as Float) (dampingAngularC.z as Float) to:fOutput
		format ("\x09" + "dampingAngularV % % %\n") (dampingAngularV.x as Float) (dampingAngularV.y as Float) (dampingAngularV.z as Float) to:fOutput
		format ("\x09" + "dampingAngularV2 % % %\n") (dampingAngularV2.x as Float) (dampingAngularV2.y as Float) (dampingAngularV2.z as Float) to:fOutput
		format ("\x09" + "estimatedCacheSize %\n") (estimatedCacheSize as Integer) to:fOutput
		format ("\x09" + "estimatedArticulatedCacheSize %\n") (estimatedArticulatedCacheSize as Integer) to:fOutput
		format ("\x09" + "becomeRope %\n") (becomeRope as Integer) to:fOutput
		format ("\x09" + "artAssetID %\n") (artAssetID as Integer) to:fOutput
		format ("\x09" + "attachBottomEnd %\n") (attachBottomEnd as Integer) to:fOutput
		format ("\x09" + "minMoveForce %\n") (minMoveForce as Float) to:fOutput
		format ("\x09" + "CenterOfMass % % %\n") (CenterOfMass.x as Float) (CenterOfMass.y as Float) (CenterOfMass.z as Float) to:fOutput
		format ("\x09" + "gravityFactor %\n") (gravityFactor as Float) to:fOutput
		format ("\x09" + "buoyancyFactor %\n") (buoyancyFactor as Float) to:fOutput
		local i
		for i = 1 to groups.count do
			groups[i].write "" fOutput (name + "\\") (cur_path + name + "\\")
		format ("\x09" + "flags ") to:fOutput
		local flag
		for flag in flags do 
			format "% " flag to:fOutput
		format "\n" to:fOutput		
		format "}\n" to:fOutput
		
		-- drawable
		drawable.cur_path = cur_path
		drawable.descName = name
		format "drawable\n{\n" to:fOutput
		drawable.write_single fOutput dict:true dict_fragments:true
		format "}\n" to:fOutput
		
		-- f8
		format "f8 [Temporarily|Unknown]\n{\n" to:fOutput
		for i = 1 to g_ft_children.count do
		(
			format "\x09%\n\x09{\n" (i - 1) to:fOutput
			local j, t = g_ft_children[i].f8
			for j = 1 to 4 do
				format ("\x09\x09% % %\n") (t[j].x as Float) (t[j].y as Float) (t[j].z as Float) to:fOutput
			format "\x09}\n" to:fOutput
		)
		format "}\n" to:fOutput
		
		if drawable.lights.count > 0 then
			drawable.write_lights fOutput ""
		
		close fOutput
	),
	
	fn collect_child_elements obj = (
		local t = ofutils.lowercase(getUserProp obj "type")
		case of
		(
			(t == "bone" or t == "common_mesh" or t == "fragment_group" or t == "fragment_child"):()
			(t == "mesh"): append g_ft_child_meshes obj
			(t == "boundbox" or t == "boundsphere" or t == "boundcapsule" or \
			 t == "boundcurvedgeometry" or t == "boundgeometry"): append g_ft_child_bounds obj
			default: throw ("FRAGMENT ERROR\n\nunknown type for fragments " + t + "\n")
		)
		local child
		for child in obj.children do
			collect_child_elements child
	),
	
	fn dump_group obj _groups = (
		if ofutils.lowercase(getUserProp obj "type") != "bone" then 
			return undefined

		local child
		for child in obj.children do
			if ofutils.lowercase(getUserProp child "type") == "fragment_group" then
			(
				local group = ofio_iv_ft_group()
				group.dump child
				append _groups group
				_groups = group.groups	
				gc()			
				exit
			)
		for child in obj.children do
			if ofutils.lowercase(getUserProp child "type") == "bone" then
				dump_group child _groups
	),
	
	fn dump descriptor = (
		if ofutils.lowercase(getUserProp descriptor "type") != "fragments" then 
			throw ("FRAGMENT ERROR\n\n" + descriptor.name + " type is not fragments\n")
		local d = descriptor
		-- get props
		unbrokenCGOffset = execute(getUserProp d "unbrokenCGOffset") 
		dampingLinearC = execute(getUserProp d "dampingLinearC")
		dampingLinearV = execute(getUserProp d "dampingLinearV")
		dampingLinearV2 = execute(getUserProp d "dampingLinearV2")
		dampingAngularC = execute(getUserProp d "dampingAngularC")
		dampingAngularV = execute(getUserProp d "dampingAngularV")
		dampingAngularV2 = execute(getUserProp d "dampingAngularV2")
		estimatedCacheSize = getUserProp d "estimatedCacheSize" 
		estimatedArticulatedCacheSize = getUserProp d "estimatedArticulatedCacheSize" 
		becomeRope = getUserProp d "becomeRope" 
		artAssetID = getUserProp d "artAssetID" 
		attachBottomEnd = getUserProp d "attachBottomEnd" 
		minMoveForce = getUserProp d "minMoveForce" 
		CenterOfMass = execute(getUserProp d "CenterOfMass")
		gravityFactor = getUserProp d "gravityFactor" 
		buoyancyFactor = getUserProp d "buoyancyFactor" 
		flags = execute(getUserProp d "flags")
		
		-- check props
		if unbrokenCGOffset == undefined \
		or dampingLinearC == undefined \ 
		or dampingLinearV == undefined \
		or dampingLinearV2 == undefined \
		or dampingAngularC == undefined \ 
		or dampingAngularV == undefined \
		or dampingAngularV2 == undefined \		
		or estimatedCacheSize == undefined \
		or estimatedArticulatedCacheSize == undefined \
		or becomeRope == undefined \
		or artAssetID == undefined \
		or attachBottomEnd == undefined \
		or minMoveForce == undefined \
		or CenterOfMass == undefined \
		or gravityFactor == undefined \
		or buoyancyFactor == undefined \
		or flags == undefined 
			then throw ("FRAGMENT ERROR\n\nFragment root " + descriptor.name + " has incorrect or missing props\n")
	
		drawable = ofio_iv_odr() 
		
		local e = undefined
		try (		
			drawable.dump descriptor chunked_as_skinned:true
		) catch
		(
			e = getcurrentexception()
			drawable = undefined
		)
		if e != undefined then throw e

		g_ft_drawable = drawable			
		g_ft_skel = drawable.skel_obj
		
		g_ft_children = #()
		g_ft_child_meshes = #()
		g_ft_child_bounds = #()
		local root_bone = descriptor.children[1]
		local root_bone_name = ofutils.lowercase(root_bone.name)
		g_ft_is_veh = (root_bone_name == "chassis") or (root_bone_name == "bodyshell")
		g_ft_is_bike = g_ft_is_veh and (g_ft_skel.boneObjExists g_ft_skel.rootBone "wheelmeshbk_r")
		collect_child_elements root_bone
		
		groups = #()
		dump_group root_bone groups
	),
	
	fn build = (	
		print "aha"
		drawable.build skinned_as_chunked:true Load_Bones:true
		print "mm"
		g_ft_skel = drawable.skel_obj
		
		local root_bone_name = g_ft_skel.rootBone.name
		g_ft_is_veh = (root_bone_name == "chassis") or (root_bone_name == "bodyshell")
		g_ft_is_bike = g_ft_is_veh and (g_ft_skel.boneObjExists g_ft_skel.rootBone "wheelmeshbk_r")
		print "to"
		local group		
		for group in groups do
			group.build()
			print "jko"
		local d = drawable.descriptor
		d.name = "ft_" + descName
		setUserProp d "type" "fragments"
		setUserProp d "unbrokenCGOffset" unbrokenCGOffset
		setUserProp d "dampingLinearC" dampingLinearC
		setUserProp d "dampingLinearV" dampingLinearV
		setUserProp d "dampingLinearV2" dampingLinearV2
		setUserProp d "dampingAngularC" dampingAngularC
		setUserProp d "dampingAngularV" dampingAngularV
		setUserProp d "dampingAngularV2" dampingAngularV2
		setUserProp d "estimatedCacheSize" estimatedCacheSize
		setUserProp d "estimatedArticulatedCacheSize" estimatedArticulatedCacheSize
		setUserProp d "becomeRope" becomeRope 
		setUserProp d "artAssetID" artAssetID
		setUserProp d "attachBottomEnd" attachBottomEnd
		setUserProp d "minMoveForce" minMoveForce
		setUserProp d "CenterOfMass" CenterOfMass
		setUserProp d "gravityFactor" gravityFactor
		setUserProp d "buoyancyFactor" buoyancyFactor
		setUserProp d "flags" flags
		
		select d
	),
	
	fn clean_globals = (
		g_ft_drawable = undefined
		g_ft_skel = undefined
		g_ft_children = undefined
		g_ft_child_meshes = undefined
		g_ft_child_bounds = undefined			
		g_ft_is_veh = undefined
		g_ft_is_bike = undefined
		gc()	
	),	
	
	fn cleanup = (
	),
	
	fn filename_from_scenename objname = (
		local name_contents = filterString (ofutils.lowercase objname) "_"
		if (objname.count < 4) or (name_contents.count < 2) then 
			throw ("NAME ERROR\n\n" + "oft file descriptor has no valid name or descriptor is not selected\n")
		if name_contents[1] != "ft" then 
			throw ("NAME ERROR\n\n" + "oft file descriptor name must start with 'ft_'\n")
		local i, filename = ""
		for i = 4 to objname.count do
			filename += objname[i]
		filename += ".oft"	
		return filename
	)	
)
