-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: collision primitives
-- Last changed: Mar 2013

-- using code by 3Doomer (C) 

ofio_iv_box_aligned_mesh = #(
	#([-0.5,-0.5,-0.5], [0.5,-0.5,-0.5], [-0.5,0.5,-0.5], [0.5,0.5,-0.5], [-0.5,-0.5,0.5], [0.5,-0.5,0.5], [-0.5,0.5,0.5], [0.5,0.5,0.5]),
	#([1,3,4], [4,2,1], [5,6,8], [8,7,5], [1,2,6], [6,5,1],	[2,4,8], [8,6,2], [4,3,7], [7,8,4], [3,1,5],[5,7,3])
)

ofio_iv_cylinder_mesh = #(
	#(	[0,0,-0.5], [0.5,0,-0.5], [0.46194,0.191342,-0.5], [0.353553,0.353553,-0.5], [0.191342,0.46194,-0.5], 
		[0,0.5,-0.5], [-0.191342,0.46194,-0.5], [-0.353553,0.353553,-0.5], [-0.46194,0.191342,-0.5], [-0.5,0,-0.5], 
		[-0.46194,-0.191342,-0.5], [-0.353554,-0.353553,-0.5], [-0.191342,-0.46194,-0.5], [0,-0.5,-0.5], [0.191342,-0.46194,-0.5], 
		[0.353554,-0.353553,-0.5], [0.46194,-0.191341,-0.5], [0.5,0,0.5], [0.46194,0.191342,0.5], [0.353553,0.353553,0.5], 
		[0.191342,0.46194,0.5], [0,0.5,0.5], [-0.191342,0.46194,0.5], [-0.353553,0.353553,0.5], [-0.46194,0.191342,0.5], 
		[-0.5,0,0.5], [-0.46194,-0.191342,0.5], [-0.353554,-0.353553,0.5], [-0.191342,-0.46194,0.5], [0,-0.5,0.5], 
		[0.191342,-0.46194,0.5], [0.353554,-0.353553,0.5], [0.46194,-0.191341,0.5], [0,0,0.5]
	),
	#(	[1,3,2], [1,4,3], [1,5,4], [1,6,5], [1,7,6], [1,8,7], [1,9,8], [1,10,9], [1,11,10], [1,12,11], 
		[1,13,12], [1,14,13], [1,15,14], [1,16,15], [1,17,16], [1,2,17], [2,19,18], [2,3,19], [3,20,19], [3,4,20], 
		[4,21,20], [4,5,21], [5,22,21], [5,6,22], [6,23,22], [6,7,23], [7,24,23], [7,8,24], [8,25,24], [8,9,25], 
		[9,26,25], [9,10,26], [10,27,26], [10,11,27], [11,28,27], [11,12,28], [12,29,28], [12,13,29], [13,30,29], [13,14,30], 
		[14,31,30], [14,15,31], [15,32,31], [15,16,32], [16,33,32], [16,17,33], [17,18,33], [17,2,18], [34,18,19], [34,19,20], 
		[34,20,21], [34,21,22], [34,22,23], [34,23,24], [34,24,25], [34,25,26], [34,26,27], [34,27,28], [34,28,29], [34,29,30], 
		[34,30,31], [34,31,32], [34,32,33], [34,33,18]
	)
)

ofio_iv_sphere_mesh = #(
	#(	[0,0,0.5], [0.5,0,0], [0,0.5,0], [-0.5,0,0], [0,-0.5,0], 
		[0,0,-0.5], [0.191342,0,0.46194], [0.353553,0,0.353553], [0.46194,0,0.191342], [0,0.191342,0.46194], 
		[0,0.353553,0.353553], [0,0.46194,0.191342], [-0.191342,0,0.46194], [-0.353553,0,0.353553], [-0.46194,0,0.191342], 
		[0,-0.191342,0.46194], [0,-0.353553,0.353553], [0,-0.46194,0.191342], [0.191342,0,-0.46194], [0.353553,0,-0.353553], 
		[0.46194,0,-0.191342], [0,0.191342,-0.46194], [0,0.353553,-0.353553], [0,0.46194,-0.191342], [-0.191342,0,-0.46194], 
		[-0.353553,0,-0.353553], [-0.46194,0,-0.191342], [0,-0.191342,-0.46194], [0,-0.353553,-0.353553], [0,-0.46194,-0.191342], 
		[0.46194,0.191342,0], [0.353553,0.353553,0], [0.191342,0.46194,0], [-0.191342,0.46194,0], [-0.353553,0.353553,0], 
		[-0.46194,0.191342,0], [-0.46194,-0.191342,0], [-0.353553,-0.353553,0], [-0.191342,-0.46194,0], [0.191342,-0.46194,0], 
		[0.353553,-0.353553,0], [0.46194,-0.191342,0], [0.204124,0.204124,0.408248], [0.379631,0.213402,0.245642], [0.213402,0.379631,0.245642], 
		[-0.204124,0.204124,0.408248], [-0.213402,0.379631,0.245642], [-0.379631,0.213402,0.245642], [-0.204124,-0.204124,0.408248], [-0.379631,-0.213402,0.245642], 
		[-0.213402,-0.379631,0.245642], [0.204124,-0.204124,0.408248], [0.213402,-0.379631,0.245642], [0.379631,-0.213402,0.245642], [0.204124,0.204124,-0.408248], 
		[0.213402,0.379631,-0.245642], [0.379631,0.213402,-0.245642], [-0.204124,0.204124,-0.408248], [-0.379631,0.213402,-0.245642], [-0.213402,0.379631,-0.245642], 
		[-0.204124,-0.204124,-0.408248], [-0.213402,-0.379631,-0.245642], [-0.379631,-0.213402,-0.245642], [0.204124,-0.204124,-0.408248], [0.379631,-0.213402,-0.245642], 
		[0.213402,-0.379631,-0.245642]
	),
	#(	[1,7,10], [7,8,43], [7,43,10], [10,43,11], [8,9,44], [8,44,43], [43,44,45], [43,45,11], [11,45,12], [9,2,31], 
		[9,31,44], [44,31,32], [44,32,45], [45,32,33], [45,33,12], [12,33,3], [1,10,13], [10,11,46], [10,46,13], [13,46,14], 
		[11,12,47], [11,47,46], [46,47,48], [46,48,14], [14,48,15],	[12,3,34], [12,34,47], [47,34,35], [47,35,48], [48,35,36], 
		[48,36,15], [15,36,4], [1,13,16], [13,14,49], [13,49,16], [16,49,17], [14,15,50], [14,50,49], [49,50,51], [49,51,17], 
		[17,51,18], [15,4,37], [15,37,50], [50,37,38], [50,38,51], [51,38,39], [51,39,18], [18,39,5], [1,16,7], [16,17,52], 
		[16,52,7], [7,52,8], [17,18,53], [17,53,52], [52,53,54], [52,54,8], [8,54,9], [18,5,40], [18,40,53], [53,40,41], 
		[53,41,54], [54,41,42], [54,42,9], [9,42,2], [6,22,19], [22,23,55], [22,55,19], [19,55,20], [23,24,56], [23,56,55], 
		[55,56,57], [55,57,20], [20,57,21], [24,3,33], [24,33,56], [56,33,32], [56,32,57], [57,32,31], [57,31,21], [21,31,2], 
		[6,25,22], [25,26,58], [25,58,22], [22,58,23], [26,27,59], [26,59,58], [58,59,60], [58,60,23], [23,60,24], [27,4,36], 
		[27,36,59], [59,36,35], [59,35,60], [60,35,34], [60,34,24], [24,34,3], [6,28,25], [28,29,61], [28,61,25], [25,61,26], 
		[29,30,62], [29,62,61], [61,62,63], [61,63,26], [26,63,27], [30,5,39], [30,39,62], [62,39,38], [62,38,63], [63,38,37], 
		[63,37,27], [27,37,4], [6,19,28], [19,20,64], [19,64,28], [28,64,29], [20,21,65], [20,65,64], [64,65,66], [64,66,29], 
		[29,66,30], [21,2,42], [21,42,65], [65,42,41], [65,41,66], [66,41,40], [66,40,30], [30,40,5]
	)
)
		
fn ofio_iv_vertex_array_op arr addF:undefined rotF:undefined mulF:undefined = (
	local i, vert, res = #()

	for vert in arr do
		append res (copy vert)
		
	if mulF != undefined then
		for i = 1 to res.count do
			res[i] *= mulF
		
	if rotF != undefined then
		for i = 1 to res.count do
			res[i] *= (rotF as Quat)
			
	if addF != undefined then
		for i = 1 to res.count do
			res[i] += addF			
	
	return res
)			
			
plugin SimpleObject ofio_iv_col_box	Category:"OFIO IV" Name:"Box" ClassID:#(0x55551000, 0x55551001) Version:1 
(
	parameters params rollout:params 
	(
		width 	type:#worldUnits 	ui:width 	default:0
		depth 	type:#worldUnits 	ui:depth 	default:0
		height 	type:#worldUnits 	ui:height 	default:0
	)
	rollout params "Collision box" 
	(
		spinner width 	"X           " type:#worldunits 	range:[0,10000,0]
		spinner depth 	"Y           " type:#worldunits 	range:[0,10000,0]
		spinner height 	"Z           " type:#worldunits 	range:[0,10000,0]
	)
	on buildMesh do
	(
		setMesh mesh Vertices:(ofio_iv_vertex_array_op ofio_iv_box_aligned_mesh[1] mulF:[width, depth, height]) Faces:ofio_iv_box_aligned_mesh[2]
	)
	tool create 
	(
		on mousePoint click do 
		(
			case click of 
			(
				1: nodeTM.translation = gridPoint
				3: #stop
			)
		)
		on mouseMove click do (
			case click of 
			(
				2: 
				(
					width = (abs gridDist.x*2)
					depth = (abs gridDist.y*2)
				)
				3: height = (abs gridDist.z*2)
			)
		)
	)
)	

plugin SimpleObject ofio_iv_col_sphere Category:"OFIO IV" Name:"Sphere"	ClassID:#(0x55551010, 0x55551011) Version:1 
(
	parameters params rollout:rol 
	(	
		radius type:#worldUnits ui:radius default:0
	)
	rollout rol "Collision sphere" 
	(
		spinner radius "Radius" type:#worldunits range:[0, 10000, 0]
	)
	on buildMesh do
	(
		setMesh mesh Vertices:(ofio_iv_vertex_array_op ofio_iv_sphere_mesh[1] mulF:(radius * 2)) Faces:ofio_iv_sphere_mesh[2]
	)
	tool create 
	(
		on mousePoint click do 
		(
			case click of 
			(
				1: nodeTM.translation = gridPoint
				3: #stop
			)
		)
		on mouseMove click do 
		(
			case click of 
			(
				2: radius = (Length gridDist)
				3: #stop
			)
		)
	)
)	

plugin SimpleObject ofio_iv_col_capsule	Category:"OFIO IV" Name:"Capsule" ClassID:#(0x55551020, 0x55551021)	Version:1
(
	parameters params rollout:rol 
	(
		Radius type:#worldUnits ui:Radius default:0
		Height type:#worldUnits ui:Height default:0
	)
	rollout rol "Collision capsule" 
	(
		spinner Radius "Radius" type:#worldunits range:[0, 10000, 0]
		spinner Height "Height" type:#worldunits range:[0, 10000, 0]
	)
	on buildMesh do 
	(
		local Faces, Verts
		Verts = (
			(ofio_iv_vertex_array_op ofio_iv_sphere_mesh[1] addF:[0, Height/2, 0] mulF:(radius * 2)) +
			(ofio_iv_vertex_array_op ofio_iv_sphere_mesh[1] addF:[0, -1*Height/2, 0] mulF:(radius * 2)) +
			(ofio_iv_vertex_array_op ofio_iv_cylinder_mesh[1] mulF:[radius*2, radius*2, Height] rotF:(EulerAngles 90 0 0))
		)
		Faces = (
			ofio_iv_sphere_mesh[2] +
			(ofio_iv_vertex_array_op ofio_iv_sphere_mesh[2] addF:ofio_iv_sphere_mesh[1].Count) +
			(ofio_iv_vertex_array_op ofio_iv_cylinder_mesh[2] addF:(ofio_iv_sphere_mesh[1].Count * 2))
		)		
		setMesh mesh Faces:Faces Vertices:Verts
	)
	tool create 
	(
		on mousePoint click do 
		(
			case click of (
				1: nodeTM.translation = gridPoint
				3: #stop
			)
		)
		on mouseMove click do 
		(
			case click of
			(
				2:
					Radius = (Length gridDist)
				3:
					Height = ((Length gridDist)*2)
			)
		)
	)
)
