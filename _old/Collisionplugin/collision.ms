				collisionWirecolor = color 50 210 250
-- plugin helper Collision_Model
-- name:"ColModel"
-- classID:#(0x7f14589d, 0x5caf6fb8)
-- extends:dummy
-- category:"Collision"
-- (
-- 	tool create
-- 	(
-- 		on mousePoint click do
-- 		(
-- 			nodeTM.translation = [0, 0, 0]
-- 			#stop
-- 		)
-- 	)
-- 	
-- 	on attachedToNode theNode do 
-- 	( 
-- 		theNode.wirecolor=white
-- 		disableBox theNode 
-- 	)
-- )


plugin geometry  Collision_Sphere
name:"ColSphere"
classID:#(0xcaddeb1, 0x6ed290ce)
category:"Collision"
extends:Sphere
(
	parameters pblock rollout:params
	(
		matID type:#integer ui:m default:1
		flag type:#integer ui:f default:1
		
	)
	rollout params "Collision Sphere Parameters"
	(
		spinner m "Material: " type:#integer range:[1, 256, 1]
		dropDownList f "Flag" items:#("Default", "Bonnet", "Boot", "Front Bumper", "Rear Bumper", "Left Front Door", "Right Front Door", "Left Rear Door", "Right Rear Door", "Left Front Wing", "Right Front Wing", "Left Rear Wing", "Right Rear Wing", "ID 13", "ID 14", "ID 15", "ID 16",	"Windscreen") selection:1
	)
	local initialPos = [0,0,0]
	local selfnode
	
	tool create (
		
		on start do (
			
			selfnode = (refs.dependentnodes this)[1]

			if selfnode != undefined do (				
				selfnode.castShadows = off
				selfnode.backfacecull = off
				selfnode.receiveshadows = off
				at time 0 (selfnode.visibility = 0 )
				(addNewKey selfnode.visibility.controller 30).value = 0.3
				selfnode.wirecolor = collisionWirecolor

			)
			
		)
		
		on mousePoint click do (
			case click of (
				1: (
					nodeTM = matrix3 [1,0,0] [0,1,0] [0,0,1] gridPoint
					initialPos = gridPoint
				)
				2: (#stop
					--resetxform selfnode
				)
			)
		)
		
		on mouseMove click do (
			case click of (
				2: (
					delegate.radius = amax #(abs(gridDist.x), abs(gridDist.y))
					)
			)
		)
	)
)

plugin simpleObject Collision_Box
name:"ColBox"
classID:#(0x6c8e94b1, 0x2d188754)
category:"Collision"
--replaceUI:true
(
	parameters pblock rollout:params
	(
		len type:#float ui:l default:0
		width type:#float ui:w default:0
		height type:#float ui:h default:0
		matID type:#integer ui:m default:1
	)
	rollout params "Collision Box Parameters"
	(
		Spinner l "Length:" range:[0, 1e9, 0]
		Spinner w "Width:" range:[0, 1e9, 0]
		Spinner h "Height:" range:[0, 1e9, 0]
		spinner m "Material: " type:#integer range:[1, 256, 1]
	)
	
	on buildMesh do 
	(
		mesh=(createInstance box length:len width:width height:height mapCoords:false).mesh
		move mesh [0, 0, -height/2]
		for i = 1 to 12 do setFaceMatID mesh i matID 
			
	)
	tool create
	(
		
		on start do (
			
			selfnode = (refs.dependentnodes this)[1]

			if selfnode != undefined do (				
				selfnode.castShadows = off
				selfnode.backfacecull = off
				selfnode.receiveshadows = off
				at time 0 (selfnode.visibility = 0 )
				(addNewKey selfnode.visibility.controller 30).value = 0.3
				selfnode.wirecolor = collisionWirecolor
			)
			
		)
		
		
		on mousePoint click do case click of
		(
			1: nodeTM.translation = gridPoint
			3: #stop
		)

		on mouseMove click do case click of
		(
			2: 
			(
				len = abs gridDist.y
				width = abs gridDist.x
			)
			3: height = length (gridDist)
		)
		
		
	)
	
-- 	on attachedToNode theNode do(
-- 		setInheritanceFlags theNode #{4..9}
-- 		setTransformLockFlags theNode #{4..9}
-- 	)
	
)

if ColMesh==undefined then(

global ColMesh = attributes TheColMesh attribID:#(0x47db14fe, 0x4e9b5f91)
(
	parameters main rollout:params
	(
		isShadow type:#boolean ui:alpha    default:false
	)
	rollout params "Collision Mesh"
	(
		checkbox alpha    "Shadow" align:#left type:#boolean
	)
)

)--collision