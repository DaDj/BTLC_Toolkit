-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: material for gta iv navmeshes
-- Last changed: Jan 2013

plugin material iv_nv_material name:"OF IV Navmesh" classID:#(0x55550000, 0x55550001) extends:Standard replaceUI:true version:1
(
	parameters main rollout:params 
	(
		border		type:#boolean	ui:cb_border
		crossing	type:#boolean	ui:cb_crossing
		sidewalk	type:#boolean	ui:cb_sidewalk
		covered		type:#boolean	ui:cb_covered
		ladder		type:#boolean	ui:cb_ladder
		landfall	type:#boolean	ui:cb_landfall
		water		type:#boolean	ui:cb_water

		ped_walks	type:#boolean	ui:cb_ped_walks
		ped_stands	type:#boolean	ui:cb_ped_stands
		ped_unk		type:#boolean	ui:cb_ped_unk
		
		color 		type:#color 	ui:cp_color
		
		on color set val do delegate.diffuse_color = val		
	)
	rollout params  "Navmesh Poly Parameters"
	(
		colorpicker		cp_color 	""	align:#center 
		group "Surface Settings"
		(
			checkbox 		cb_border		"edged      |   surface is curved and not balanced"		pos:[15, 50] 
			checkbox 		cb_crossing		"crossing   |   surface crosses other path"				pos:[15, 70] 
			checkbox 		cb_sidewalk		"sidewalk  |   footway surface"							pos:[15, 90]
			checkbox 		cb_covered		"covered   |   surface is covered from rain"			pos:[15, 110]
			checkbox 		cb_ladder		"ladder      |   surface is attached to a ladder"		pos:[15, 130]
			checkbox 		cb_landfall		"landfall     |   extremly inclined surface"			pos:[15, 150]
			checkbox 		cb_water		"water       |   surface is a water"					pos:[15, 170]
		)
		group "Pedgen Settings"
		(
			checkbox 		cb_ped_walks	"walking    |   can create walking peds here"		pos:[15, 215]
			checkbox 		cb_ped_stands	"standing   |  can create standing peds here"		pos:[15, 235]
			checkbox 		cb_ped_unk		"unk          |   -?-"				pos:[15, 255]
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
