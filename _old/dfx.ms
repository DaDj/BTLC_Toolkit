
plugin light GTA_Light
name:"GTA Light"
classID:#(0x7f14579e, 0x5caf6eb9)
extends:omnilight
category:"GTA 2dfx"
replaceUI:true
(
	parameters main rollout:params
	(
		color	type:#color default:white ui:pccol
		coronaTex type:#TextureMap ui:corona
		shadowTex type:#TextureMap ui:shadow
		coronaFarClip	type:#float default:0 ui:clip
		pointlightRange	type:#float default:0 ui:range
		coronaSize	type:#float default:0 ui:cSize
		shadowSize	type:#float default:0 ui:sSize
		coronaShowMode	type:#integer default:1 ui:mode
		coronaEnableReflection	type:#boolean default:false ui:ref
		coronaFlareType	type:#integer default:1 ui:flare
		shadowColorMultiplier	type:#integer default:40 ui:mul
		flag10 type:#boolean default:false ui:c10 --CORONA_CHECK_OBSTACLES
		flag11 type:#boolean default:false ui:c11 --FOG_TYPE1
		flag12 type:#boolean default:false ui:c12 --FOG_TYPE2
		flag13 type:#boolean default:false ui:c13 --WITHOUT_CORONA
		flag14 type:#boolean default:false ui:c14 --CORONA_ONLY_AT_LONG_DISTANCE
		flag15 type:#boolean default:false ui:c15 --AT_DAY
		flag16 type:#boolean default:false ui:c16 --AT_NIGHT
		flag17 type:#boolean default:false ui:c17 --BLINKING1
		shadowZDistance	type:#integer default:0 ui:zDistance
		flag20 type:#boolean default:false ui:c20 --CORONA_ONLY_FROM_BELOW
		flag21 type:#boolean default:false ui:c21 --BLINKING2
		flag22 type:#boolean default:false ui:c22 --UDPDATE_HEIGHT_ABOVE_GROUND
		flag23 type:#boolean default:false ui:c23 --CHECK_DIRECTION
		flag24 type:#boolean default:false ui:c24 --BLINKING3
		enLookDirection type:#boolean default:true ui:en
		lookDirection_x	type:#integer default:0 ui:x
		lookDirection_y	type:#integer default:0 ui:y
		lookDirection_z	type:#integer default:0 ui:z
		
		dfxType	type:#integer default:0
			
		on color set val do delegate.rgb=val
		
	)
	rollout params "Light Parameters"
	(
		colorpicker		pccol 		"Color " 	pos:[10,10] 
		group "Maps" (
			label			prlbl	"Corona " pos:[10,50]
			mapbutton		corona	"None" 		width:90 pos:[60,50]
			label			prlb2	"Shadow " pos:[10,80]			
			mapbutton		shadow	"None" 		width:90 pos:[60,80]
			button dft "SA default" width:80 pos:[10,110]
		)
		spinner clip	"Corona far clip  "	fieldwidth:50 range:[0,100,0]	pos:[10,150] 
		spinner range	"Pointlight range "	fieldwidth:50 range:[0,100,0]	pos:[10,180]
		spinner cSize	"Corona size      "	fieldwidth:50 range:[0,100,0]	pos:[10,210]
		spinner sSize	"Shadow size      "	fieldwidth:50 range:[0,100,0]	pos:[10,240]
		spinner	mul	    "Shadow color multiplier"	fieldwidth:30 type:#integer range:[0,255,40] pos:[10,270]
		dropDownList mode "Corona show mode" pos:[10,300] width:110 items:#("DEFAULT", "FLASHING", "WET", "SPEED 4X", "SPEED 2X", "SPEED 1X", "UNKNOWN", "TRAFFICLIGHT", "TRAINCROSSLIGHT", "INVALID", "RAIN", "5S ON 5S OFF", "6S ON 4S OFF", "6S ON 4S OFF 2")
		group "Flags 1" (
			checkbox c10 "CHECK OBSTACLES" pos:[10,370]
			checkbox c11 "FOG TYPE1" pos:[10,390]
			checkbox c12 "FOG TYPE2" pos:[10,410]
			checkbox c13 "WITHOUT CORONA" pos:[10,430]
			checkbox c14 "AT LONG DISTANCE" pos:[10,450]
			checkbox c15 "AT DAY" pos:[10,470]
			checkbox c16 "AT NIGHT" pos:[10,490]
			checkbox c17 "BLINKING1" pos:[10,510]
		)
		group "Flags 2" (
			checkbox c20 "FROM BELOW" pos:[10,550]
			checkbox c21 "BLINKING2" pos:[10,570]
			checkbox c22 "UDPDATE HEIGHT" pos:[10,590]
			checkbox c23 "CHECK DIRECTION" pos:[10,610]
			checkbox c24 "BLINKING3" pos:[10,630]
		)
		group "Look direction" (
			checkbox en "Enable" pos:[10,680]
			spinner	x "X" fieldwidth:30 type:#integer range:[-128,127,0] pos:[7,710]
			spinner	y "Y" fieldwidth:30 type:#integer range:[-128,127,0] pos:[57,710]
			spinner	z "Z" fieldwidth:30 type:#integer range:[-128,127,0] pos:[107,710]
		)
		checkbox ref "Corona enable reflection" pos:[10,740]
		dropDownList flare "Corona flare type" pos:[10,770] items:#("No lens", "Yelow lens", "White lens")
		spinner	zDistance "Shadow Z distance" fieldwidth:30 type:#integer range:[0,255,0] pos:[10,820]
		
		on dft pressed do 
		(
			coronaTex=getTexture "coronastar"
			shadowTex=getTexture "shad_exp"
		)
	)
	
	fn getSize= (
		if enLookDirection then return 80
		return 76
	)
	
	tool create
	(
		on mousePoint click do
		(
			nodeTM.translation = gridPoint;#stop
		)
	)
	

)

if effects==undefined then
(
	global effects=#("prt_blood", "prt_boatsplash", "prt_bubble", "prt_cardebris",
"prt_collisionsmoke", "prt_glass", "prt_gunshell", "prt_sand",
"prt_sand2", "prt_smokeII_3_expand", "prt_smoke_huge", "prt_spark",
"prt_spark_2", "prt_splash", "prt_wake", "prt_watersplash",
"prt_wheeldirt", "boat_prop", "camflash", "exhale", "explosion_fuel_car",
"explosion_large", "explosion_medium", "explosion_molotov", "explosion_small",
"explosion_tiny", "extinguisher", "fire", "fire_bike", "fire_car",
"fire_large", "fire_med", "flamethrower", "gunflash", "gunsmoke",
"heli_dust", "jetpack", "jetthrust", "molotov_flame", "nitro",
"overheat_car", "overheat_car_electric", "riot_smoke", "spraycan",
"tank_fire", "teargas", "teargasAD", "water_hydrant", "water_ripples",
"water_speed", "water_splash", "water_splash_big", "water_splsh_sml",
"water_swim", "cigarette_smoke", "Flame", "insects", "smoke30lit",
"smoke30m", "smoke50lit", "vent", "vent2", "waterfall_end",
"water_fnt_tme", "water_fountain", "tree_hit_fir", "tree_hit_palm",
"blood_heli", "carwashspray", "cement", "cloudfast", "coke_puff", "coke_trail", 
"explosion_barrel", "explosion_crate", "explosion_door",
"petrolcan", "puke", "shootlight", "smoke_flare", "wallbust", "ws_factorysmoke")
	global selectedEffect=undefined
)


plugin helper GTA_Particle
name:"GTA Particle"
classID:#(0x7f14579d, 0x5caf6eb8)
extends:dummy
category:"GTA 2dfx"
replaceUI:true
(
	parameters main rollout:params
	(
		effectName       type:#string    default:"" ui:edt1
		dfxType	type:#integer default:1
	)
	
	rollout params "Particle Parameters"
	(
		editText edt1 "name: " width:150 pos:[5,5]
		button sel "select effect" width:100
		
		on sel pressed do 
		(
			selectedEffect=undefined
			
			rollout selectEffectRollout "Select Effect" width:180 height:300
			(
				listBox lbx2 "" items:(effects) selection:1 width:160 height:18
				button sel "Select" pos:[10,270] width:60
				button cancel "Cancel" pos:[90,270] width:60
				
				on sel pressed do
				(
					selectedEffect=lbx2.selected
					DestroyDialog selectEffectRollout
				)
				
				on cancel pressed do DestroyDialog selectEffectRollout
			)
			
			createDialog selectEffectRollout modal:true
			if selectedEffect!=undefined then effectName=selectedEffect
		)
	)
	
	fn getSize= (return 24)
	
	tool create
	(
		on mousePoint click do
		(
			nodeTM.translation = gridPoint;#stop
		)
	)
	
	on attachedToNode theNode do ( 
		setIgnored theNode
		theNode.wirecolor=green
		disableBox theNode 
	)
)


plugin simpleManipulator GTA_Sign
name:"GTA Sign"
classID:#(0x1967, 0x2227058a)
category:"GTA 2dfx"
(
	parameters pblock rollout:params
	(
		length type:#float ui:length default:1
		width type:#float ui:width default:1
		rot_x type:#float ui:x default:0
		rot_y type:#float ui:y default:0
		rot_z type:#float ui:z default:0
		line1       type:#string    default:"" ui:edt1
		line2       type:#string    default:"" ui:edt2
		line3       type:#string    default:"" ui:edt3
		line4       type:#string    default:"" ui:edt4
		linesUsed	type:#integer default:4 ui:used
		symbols	type:#integer default:1 ui:symbols
		color	type:#integer default:1 ui:color
		
		dfxType	type:#integer default:7
		fix type:#boolean default:false 
	)
	rollout params "Street sign Parameters"
	(
		Spinner width "Width:" range:[0, 1e9, 1]
		Spinner length "Length:" range:[0, 1e9, 1]
		group "Rotation" (
			Spinner y "Y:" range:[-90, 90, 0]
			Spinner x "X:" range:[-90, 90, 0]
			Spinner z "Z:" range:[-90, 90, 0]
		)
		editText edt1 "Line 1: "
		editText edt2 "Line 2: "
		editText edt3 "Line 3: "
		editText edt4 "Line 4: "
		Spinner used "Lines used:" type:#integer range:[1, 4, 4]
		dropDownList symbols "Symbols:" items:#("16", "2", "4", "8")
		dropDownList color "Color:" items:#("white", "black", "grey", "red")
	)
	tool create
	(
		on mousePoint click do case click of
		(
			1: nodeTM.translation = gridPoint
			2:
			(
				fix=true
				#stop
			)
		)

		on mouseMove click do case click of
		(
			2: 
			(
				length = abs gridDist.y
				width = abs gridDist.x
			)
		)
		
		
	)
	
	on updateGizmos do(
		if fix then
		(
			nodes=for o in (refs.dependents this) where (isvalidnode o) collect o
			n=nodes[1]
			n.transform=matrix3 x_axis y_axis z_axis n.position
			fix=false
		)
		this.clearGizmos()
		m=(createInstance plane length:length width:width lengthsegs:1 widthsegs:1).mesh
		rotate m ((quat -rot_z z_axis)*(quat -rot_x x_axis)*(quat -rot_y y_axis))
		this.addGizmoMesh m 0 [0,1,0] (colorMan.getColor #manipulatorsSelected)
		giz = manip.makeGizmoShape()
		giz.startNewLine()
		giz.addPoint [0, 0, 0]
		giz.addPoint m.verts[3].pos
		this.addGizmoShape giz 0 (colorMan.getColor #manipulatorsSelected) (colorMan.getColor #manipulatorsActive)
	)
	
	fn getSize= (return 88)
	
	on attachedToNode theNode do(
		setIgnored theNode
		setInheritanceFlags theNode #none
		setTransformLockFlags theNode #{4..9}
	)
)


plugin helper GTA_Slotmachine
name:"GTA Slotmachine"
classID:#(0x7f14579c, 0x5caf6eb7)
extends:dummy
category:"GTA 2dfx"
replaceUI:true
(
	parameters main rollout:params
	(
		index  type:#integer default:0 ui:idx
		dfxType	type:#integer default:8
	)
	rollout params "Slotmachine Parameters"
	(
		Spinner idx "Wheelindex: " pos:[10,16] type:#integer range:[0, 100, 0]
	)
	
	fn getSize= (return 4)
	
	tool create
	(
		on mousePoint click do
		(
			nodeTM.translation = gridPoint
			#stop
		)
	)
	
	on attachedToNode theNode do ( 
		setIgnored theNode
		theNode.wirecolor=blue 
		disableBox theNode
	)
)

plugin simpleManipulator GTA_Escalator
name:"GTA Escalator"
classID:#(0x1968, 0x2227058a)
category:"GTA 2dfx"
(
	parameters pblock rollout:params
	(
		b_x type:#float ui:b_x default:0
		b_y type:#float ui:b_y default:0
		b_z type:#float ui:b_z default:0
		
		t_x type:#float ui:t_x default:0
		t_y type:#float ui:t_y default:0
		t_z type:#float ui:t_z default:0
		
		e_x type:#float ui:e_x default:0
		e_y type:#float ui:e_y default:0
		e_z type:#float ui:e_z default:0
		
		d type:#integer default:2 ui:direction
		
		offsets type:#point3tab tabsize:3
		dfxType	type:#integer default:10
		fix type:#boolean default:false
		
	)
	rollout params "Escalator Parameters"
	(
		group "Bottom offset" 
		(
			Spinner b_x "X:" range:[-1000, 1000, 0]
			Spinner b_y "Y:" range:[-1000, 1000, 0]
			Spinner b_z "Z:" range:[0, 1000, 0]
		)
		group "Top offset" 
		(
			Spinner t_x "X:" range:[-1000, 1000, 0]
			Spinner t_y "Y:" range:[-1000, 1000, 0]
			Spinner t_z "Z:" range:[0, 1000, 0]
		)
		group "End offset" (
			Spinner e_x "X:" range:[-1000, 1000, 0]
			Spinner e_y "Y:" range:[-1000, 1000, 0]
			Spinner e_z "Z:" range:[0, 1000, 0]
		)
		radioButtons direction "Direction:" labels:#("down", "up") columns:2
		
	)
	tool create
	(
		on mousePoint click do case click of
		(
			1: nodeTM.translation = gridPoint
			5:
			(
				fix=true
				#stop
			)
		)

		on mouseMove click do case click of
		(
			2: 
			(
				e_y = t_y = b_y = gridDist.y
				e_x = t_x = b_x = gridDist.x
			)
			3: e_z=t_z = abs gridDist.z
			4: 
			(
				e_y=t_y = gridDist.y
				e_x=t_x = gridDist.x
			)
			5: 
			(
				e_y = gridDist.y
				e_x = gridDist.x
			)
		)
		
		
	)
	
	on updateGizmos do(
		if fix then
		(
			nodes=for o in (refs.dependents this) where (isvalidnode o) collect o
			n=nodes[1]
			n.transform=matrix3 x_axis y_axis z_axis n.position
			fix=false
		)
		s=[0, 0, 0]
		offsets[1]=[b_x, b_y, b_z]
		offsets[2]=[t_x, t_y, t_z]
		offsets[3]=[e_x, e_y, e_z]
		this.clearGizmos()
		giz = manip.makeGizmoShape()
		giz.startNewLine()
		this.addGizmoMarker #bigBox s 0 (colorMan.getColor #manipulatorsSelected) (colorMan.getColor #manipulatorsActive)
		this.addGizmoMarker #plusSign s 0 (colorMan.getColor #manipulatorsSelected) (colorMan.getColor #manipulatorsActive)
		giz.addPoint s
		for o in offsets do
		(
			this.addGizmoMarker #plusSign o 0 (colorMan.getColor #manipulatorsSelected) (colorMan.getColor #manipulatorsActive)
			giz.addPoint o
		)		
		this.addGizmoShape giz 0 (colorMan.getColor #manipulatorsSelected) (colorMan.getColor #manipulatorsActive)
	)
	
	fn getSize= (return 40)
	
	on attachedToNode theNode do(
		setIgnored theNode
		setInheritanceFlags theNode #{1..6}
		setTransformLockFlags theNode #{4..9}
	)
)
