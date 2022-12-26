-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: material for gta iv collisions
-- Last changed: Feb 2013

-- using code by 3Doomer

iv_col_material_mtlgrp = #(
	#(
		"generic", "void", "concrete", "stone", "brick_cobble", "marble", "paving_slabs", "ceramics", "wood", "laminate", "gravel", "sand", "dirt_dry", "bushes", "mud_soft", "grass", "flowers", "leaves_pile", "tree_bark_dark",
		"tree_bark_light", "tree_bark_medium", "metal", "glass", "car_metal", "car_plastic", "windscreen", "plastic", "linoleum", "carpet_fabric", "rubber", "paper", "cardboard", "mattress_foam", "pillow_feathers", "water", 
		"ped_torso", "ped_limb", "ped_foot", "ped_head", "tvscreen", "videowall"),
	#(	(color 125 125 125), (color 255 0 0), (color 110 110 110), (color 150 150 150), (color 150 150 150), (color 150 150 150), (color 150 150 150), (color 230 230 230), (color 175 125 50), (color 170 130 0), (color 160 150 120), (color 255 220 170), (color 160 100 0), (color 0 130 0), (color 150 110 80), 
		(color 0 180 0), (color 255 255 0), (color 200 230 0), (color 130 90 0), (color 200 160 80), (color 160 130 50), (color 200 200 200), (color 190 250 250), (color 200 200 200), (color 100 100 100), 
		(color 190 250 250), (color 100 100 100), (color 170 130 0), (color 170 130 0), (color 90 70 30), (color 255 255 255), (color 130 80 0), (color 170 130 0), (color 255 255 255), (color 0 190 255), 
		(color 255 220 190), (color 255 220 190), (color 255 220 190), (color 255 220 190), (color 90 90 90), (color 90 90 90)
	),
	#(
		#("default"), 
		#("nofriction", "car_void", "lowfriction_wheel"), 
		#("concrete", "concrete_freeway", "painted_road", "plaster_board", "rumble_strip", "tarmac", "pothole", "clay_court"), 
		#("breeze_block", "mossy_rock", "rock", "stone"), 
		#("brick_cobble", "brick_wall"), 
		#("marble"), 
		#("paving_slabs"), 
		#("ceramics", "rooftile", "pooltable_ball", "fx_ceramic_water_hi_pressure"), 
		#("rail_sleeper", "wood_board", "wood_counter", "wood_fence", "wood_handrail", "wood_section", "wood_wall_old", "wooden_garage_door", "hollow_wood", "pooltable_cushion", "fx_wood_water_glug", "pooltable_pocket"), 
		#("laminate", "polished_court"), 
		#("gravel", "railway_gravel"), 
		#("sand"), 
		#("dirt_dry"), 
		#("twigs", "bushes"), 
		#("mud_soft"), 
		#("grass", "short_grass", "grass_patchy", "grass_long"), 
		#("flowers"), 
		#("leaves_pile"), 
		#("bark_chipping", "tree_bark_dark"), 
		#("tree_bark_light"), 
		#("tree_bark_med"), 
		#("aircon_duct", "aircon_vent", "billboard_frame", "corrugated_iron", "electricity_box", "hollow_metal_panel", "hollow_metal_rail", "hollow_rust_metal", "lead_roofing", "metal_awning", "metal_cellar", "metal_drainage", 
		"metal_garage_door", "metal_grill", "metal_helipad", "metal_lattice", "metal_manhole", "metal_railing", "metal_roller_door", "metal_tread_plate", "metal_vent_subway", "rail_crossing", "rail_track", "roller_door", 
		"solid_metal_panel", "solid_rust_metal", "treadplate_on_wood", "fx_metal_gas_pipe_flame", "fx_metal_water_pipe", "fx_metal_steam_pipe", "fx_metal_oil_glug", "fx_metal_electric_sparks", "fx_spare_1", "fx_spare_2", "fx_spare_3"), 
		#("glass_brick", "glass_medium", "glass_strong", "glass_weak", "perspex", "skylights", "emissive_glass", "glass_strong_shoot_thru"), 
		#("car_metal"), 
		#("car_plastic"), 
		#("windscreen", "windscreen_weak", "windscreen_med_weak", "windscreen_med_strong", "windscreen_strong", "windscreen_side_weak", "windscreen_side_med", "windscreen_rear", "windscreen_front"), 
		#("corrugated_plastic", "fibreglass", "plastic", "tarpaulin", "hollow_plastic", "hollow_fibreglass", "emissive_plastic"), 
		#("linoleum"), 
		#("carpet", "fabric_cloth", "roofing_felt", "rug", "pooltable_surface", "carpet_fabric"), 
		#("rubber"), 
		#("paper"), 
		#("cardboard", "hollow_cardboard"), 
		#("mattress_foam"), 
		#("pillow_feathers"), 
		#("pothole_puddle", "puddles", "water"), 
		#("ped", "buttocks", "spine0", "spine1", "spine2", "spine3", "clavicle_left", "clavicle_right"), 
		#("thigh_left", "shin_left", "thigh_right", "shin_right", "upper_arm_left", "lower_arm_left", "hand_left", "upper_arm_right", "lower_arm_right", "hand_right"), 
		#("foot_left", "foot_right"), 
		#("neck", "head"), 
		#("tvscreen"), 
		#("videowall")
	),
	#(
		"none","ext_pavement_litter","ext_weeds_rocks","ext_wasteground_debris","ext_woodland_plants","ext_rubble_bricks_weeds", "ext_alleyway_litter","ext_junkyard_rubbish","ext_bushes_lush","ext_bushes_dry","ext_flowerbed_plants","ext_bushes_mixed",
		"ext_grass_dryplants_stones","ext_grass_dryplants_med","ext_grass_lushplants_short","ext_pavingslabs_debris", "ext_fastfood_litter","ext_litter_paper_leaf","ext_dirt_rubble_weeds","ext_woodplanks_breezeblocks","int_fastfood_litter",
		"ext_docks_rubble_wood_rope","ext_industrial_debris","ext_roadside_litter","ext_grass_dryplants_short","ext_meadow_plants", "ext_flowers_plants_sparse","ext_grass_dryplants_long","ext_grass_lushplants_long","int_skanky_litter","int_laundry_clothing",
		"int_laundry_socks","int_711_litter","ext_wasteground_weeds","ext_wasteground_bushy","ext_bushy_low","ext_bushy_med", "ext_weeds_tall","ext_weeds_dense","ext_weeds_tall_dense","proc_wtr_floating_scum","proc_urb_floating","proc_indus_floating"),
	#(
		#(0), 
		#(1, 2, 121), 
		#(3, 4, 5, 6, 7, 8, 30, 33), 
		#(9, 10, 11, 12), 
		#(13, 14), 
		#(15), 
		#(16), 
		#(17, 18, 134, 144), 
		#(19, 20, 21, 22, 23, 24, 25, 26, 122, 133, 143, 155), 
		#(27, 28), 
		#(29, 31), 
		#(32), 
		#(34), 
		#(35, 39), 
		#(36), 
		#(37, 38, 152, 153), 
		#(40), 
		#(41), 
		#(42, 43), 
		#(44), 
		#(45), 
		#(46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 139, 140, 141, 142, 145, 146, 147, 148), 
		#(73, 74, 75, 76, 77, 78, 149, 151), 
		#(79), 
		#(80), 
		#(81, 126, 127, 128, 129, 135, 136, 137, 138), 
		#(82, 83, 84, 85, 123, 125, 150), 
		#(86), 
		#(87, 88, 89, 90, 132, 154), 
		#(91), 
		#(92), 
		#(93, 124), 
		#(94), 
		#(95), 
		#(96, 97, 98), 
		#(99, 100, 107, 108, 109, 110, 113, 117), 
		#(101, 102, 104, 105, 114, 115, 116, 118, 119, 120), 
		#(103, 106), 
		#(111, 112), 
		#(130), 
		#(131)
	)
)

global func_result -- 3dsmax2012 fix

plugin material iv_col_material name:"OF IV Collision" classID:#(0x55550010, 0x55550011) extends:Standard replaceUI:true version:1
(
	fn iv_col_getmtlselection mtlid mtl:false = (
		local i, j, doexit = false
		for i = 1 to iv_col_material_mtlgrp[1].count do
			for j = 1 to iv_col_material_mtlgrp[5][i].count do
				if iv_col_material_mtlgrp[5][i][j] == mtlid then
				(
					func_result = (if mtl then j else i)
					return func_result
				)
		func_result = 1
		return func_result
	)

	parameters main rollout:params 
	(
		mtlid		type:#integer	default:0
		mtlprocid	type:#integer	default:0		
		flags		type:#integer	default:0
		f6			type:#boolean	ui:cb_f6
		f7			type:#boolean	ui:cb_f7
		f9			type:#boolean	ui:cb_f9
		f10			type:#boolean	ui:cb_f10
		f11			type:#boolean	ui:cb_f11
		f12			type:#boolean	ui:cb_f12
		f13			type:#boolean	ui:cb_f13
		f14			type:#boolean	ui:cb_f14
		f15			type:#boolean	ui:cb_f15
		
		on mtlid set val do 
		(
			delegate.diffuse_color = iv_col_material_mtlgrp[2][iv_col_getmtlselection val mtl:false]				
			this.params.lb_mtlgroup.selection = iv_col_getmtlselection val mtl:false
			this.params.lb_mtl.items = iv_col_material_mtlgrp[3][iv_col_getmtlselection val mtl:false]
			this.params.lb_mtl.selection = iv_col_getmtlselection val mtl:true
		)
		on mtlprocid set val do
		(
			this.params.dl_proc.items = iv_col_material_mtlgrp[4]
			this.params.dl_proc.selection = val + 1
		)
		on flags set val do
		(
			f6 = bit.get val 6
			f7 = bit.get val 7
			f9 = bit.get val 9
			f10 = bit.get val 10
			f11 = bit.get val 11
			f12 = bit.get val 12
			f13 = bit.get val 13
			f14 = bit.get val 14
			f15 = bit.get val 15
		)
		on flags get val do
		(
			val = 0
			val = bit.set val 6 f6
			val = bit.set val 7 f7
			val = bit.set val 9 f9
			val = bit.set val 10 f10
			val = bit.set val 11 f11
			val = bit.set val 12 f12
			val = bit.set val 13 f13
			val = bit.set val 14 f14
			val = bit.set val 15 f15
		)
	)
	rollout params  "Collision Poly Parameters"
	(
		group "Surface Settings"
		(
			label			lbl_main	"Main"	pos:[150, 20] 
			listbox			lb_mtlgroup ""		width:145 height:10 pos:[15, 35] items:iv_col_material_mtlgrp[1] selection:(iv_col_getmtlselection this.mtlid mtl:false)
			listbox			lb_mtl		""		width:145 height:10 pos:[165, 35] items:iv_col_material_mtlgrp[3][iv_col_getmtlselection this.mtlid mtl:false]  selection:(iv_col_getmtlselection this.mtlid mtl:true)
			label			lbl_proc	"Procedural" height:11
			dropdownlist	dl_proc		""		items:iv_col_material_mtlgrp[4] selection:(this.mtlprocid + 1)
			label			lbl_flags	"Flags  " height:14
			checkbox 		cb_f9		"stairs" pos:[15, 235]
			checkbox 		cb_f12		"shot thru" pos:[15, 255]
			checkbox 		cb_f15		"see thru" pos:[15, 275]
			checkbox 		cb_f10		"block grip" pos:[110, 235]
			checkbox 		cb_f11		"block climb" pos:[110, 255]
			checkbox 		cb_f13		"block jump over" pos:[110, 275]
			checkbox 		cb_f6		"sidewalk spec 1" pos:[210, 235]
			checkbox 		cb_f7		"sidewalk spec 2" pos:[210, 255]
			checkbox 		cb_f14		"sidewalk spec 3" pos:[210, 275]
			label			lbl_padding	""	height:0		
		)
		on lb_mtlgroup selected id do
		(
			lb_mtl.items = iv_col_material_mtlgrp[3][id]
			lb_mtl.selection = 1
			this.mtlid = iv_col_material_mtlgrp[5][id][1]
			delegate.diffuse_color = iv_col_material_mtlgrp[2][id]
		)
		on lb_mtl selected id do
		(
			this.mtlid = iv_col_material_mtlgrp[5][lb_mtlgroup.selection][id]
		)
		on dl_proc selected id do
		(
			this.mtlprocid = id - 1
		)
 	)

	on create do (
		this.name = delegate.name
	)
	on load do (
		this.name = delegate.name
	)
	on update do (

	)	            
)
