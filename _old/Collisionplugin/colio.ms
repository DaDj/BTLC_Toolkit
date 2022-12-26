fileIn ("collision.ms") quiet:true
--fileIn ("colIn.ms") quiet:true
--fileIn ("rwIn.ms") quiet:true
fileIn ("colOut.ms") quiet:true
fileIn ("io.ms") quiet:true

if colMaterialVersion==undefined then
(
global colMaterials=#(#("Default",
 "Street", "Grass", "Soil", "Dirt", "Beton",
 "Aluminum", "Glas", "Metal Pole", "Door", "Metal Sheet",
 "Metal", "Small Metal Post", "Large Metal Post", "Medium Metal Post", "Steel",
 "Fence", "Unused 1", "Sand", "Water", "Wooden Box",
 "Wooden Lathes", "Wood", "Metal Box", "Metal Box 2", "Hedge",
 "Rock", "Metal Container", "Metal Barrel", "Unused 2", "Metal Card Box",
 "Unused 3", "Gate/Bars", "Sand 2", "Grass 2" ),
 #("Default", "Tarmac", "Tarmac (fucked)", "Tarmac (really fucked)", 
"Pavement", "Pavement (fucked)", "Gravel", "Concrete (fucked)", 
"Painted Ground", "Grass (short, lush)", "Grass (medium, lush)", "Grass (long, lush)",
"Grass (short, dry)", "Grass (medium, dry)", "Grass (long, dry)", 
"Golf Grass (rough)", "Golf Grass (smooth)", "Steep Slidy Grass", "Steep Cliff", 
"Flower Bed", "Meadow", "Waste Ground", "Woodland Ground", "Vegetation", 
"Mud (wet)", "Mud (dry)", "Dirt", "Dirt Track", "Sand (deep)", "Sand (medium)", 
"Sand (compact)", "Sand (arid)", "Sand (more)", "Sand (beach)", "Concrete (beach)", 
"Rock (dry)", "Rock (wet)", "Rock (cliff)", "Water (riverbed)", "Water (shallow)", 
"Corn Field", "Hedge", "Wood (crates)", "Wood (solid)", "Wood (thin)", 
"Glass", "Glass Windows (large)", "Glass Windows (small)", "Empty1", "Empty2", 
"Garage Door", "Thick Metal Plate", "Scaffold Pole", "Lamp Post", "Metal Gate", 
"Metal Chain fence", "Girder", "Fire Hydrant", "Container", "News Vendor", "Wheelbase", 
"Cardboard Box", "Ped", "Car", "Car (panel)", "Car (moving component)", 
"Transparent Cloth", "Rubber", "Plastic", "Transparent Stone", "Wood (bench)", 
"Carpet", "Floorboard", "Stairs (wood)", "P Sand", "P Sand (dense)", "P Sand (arid)", 
"P Sand (compact)", "P Sand (rocky)", "P Sand (beach)", "P Grass (short)", 
"P Grass (meadow)", "P Grass (dry)", "P Woodland", "P Wood Dense", "P Roadside", 
"P Roadside Des", "P Flowerbed", "P Waste Ground", "P Concrete", "P Office Desk", 
"P 711 Shelf 1", "P 711 Shelf 2", "P 711 Shelf 3", "P Restuarant Table", 
"P Bar Table", "P Underwater (lush)", "P Underwater (barren)", "P Underwater (coral)", 
"P Underwater (deep)", "P Riverbed", "P Rubble", "P Bedroom Floor", "P Kitchen Floor", 
"P Livingroom Floor", "P corridor Floor", "P 711 Floor", "P Fast Food Floor", 
"P Skanky Floor", "P Mountain", "P Marsh", "P Bushy", "P Bushy (mix)", 
"P Bushy (dry)", "P Bushy (mid)", "P Grass (wee flowers)", "P Grass (dry, tall)", 
"P Grass (lush, tall)", "P Grass (green, mix)", "P Grass (brown, mix)", 
"P Grass (low)", "P Grass (rocky)", "P Grass (small trees)", "P Dirt (rocky)", 
"P Dirt (weeds)", "P Grass (weeds)", "P River Edge", "P Poolside", "P Forest (stumps)", 
"P Forest (sticks)", "P Forest (leaves)", "P Desert Rocks", "Forest (dry)", 
"P Sparse Flowers", "P Building Site", "P Docklands", "P Industrial", 
"P Industrial Jetty", "P Concrete (litter)", "P Alley Rubbish", "P Junkyard Piles", 
"P Junkyard Ground", "P Dump", "P Cactus Dense", "P Airport Ground", "P Cornfield", 
"P Grass (light)", "P Grass (lighter)", "P Grass (lighter 2)", "P Grass (mid 1)", 
"P Grass (mid 2)", "P Grass (dark)", "P Grass (dark 2)", "P Grass (dirt mix)", 
"P Riverbed (stone)", "P Riverbed (shallow)", "P Riverbed (weeds)", "P Seaweed", 
"Door", "Plastic Barrier", "Park Grass", "Stairs (stone)", "Stairs (metal)", 
"Stairs (carpet)", "Floor (metal)", "Floor (concrete)", "Bin Bag", "Thin Metal Sheet", 
"Metal Barrel", "Plastic Cone", "Plastic Dumpster", "Metal Dumpster", 
"Wood Picket Fence", "Wood Slatted Fence", "Wood Ranch Fence", "Unbreakable Glass", 
"Hay Bale", "Gore", "Rail Track"))

global colMaterialVersion=1
global selectedColMaterial=0
)

rollout coltools_rol "COL tools" width:200
(
	button crtb "Make Collision" width:110
	group "COL Material" 
	(
		button extra "Assign Material" width:110
		radioButtons posnRule "Version:" labels:#("VC", "SA") columns:2
	)

	on crtb pressed  do 
	(
		if ((classof $ == Editable_mesh)and((custattributes.get $ ColMesh)==undefined)) then 
		(
			custattributes.add $ ColMesh
			$.wirecolor =  color 50 210 250
		)
	)
	on extra pressed  do
	(
		objects = for obj in $selection where ((classof obj==Collision_Sphere)or(classof obj==Collision_Box)or((classof obj==Editable_mesh)and(custattributes.get obj ColMesh)!=undefined)and(obj.isShadow==false)) collect obj
		if objects.count>0 then 
		(
			colMaterialVersion=posnRule.state
			rollout assignColMaterialRollout "Assign Material" width:180 height:300
			(
				listBox lbx2 "" items:(colMaterials[colMaterialVersion]) selection:1 width:160 height:18
				button assign "Assign" pos:[10,270] width:60
				button cancel "Cancel" pos:[90,270] width:60
				
				on assign pressed do
				(
					selectedColMaterial=lbx2.selection
					DestroyDialog assignColMaterialRollout
				)
				
				on cancel pressed do DestroyDialog assignColMaterialRollout
			)
			
			createDialog assignColMaterialRollout modal:true
			for obj in objects do 
			(
				if (classof obj==Collision_Sphere)or(classof obj==Collision_Box) then obj.matID=selectedColMaterial
				else
				(
					if subobjectLevel>2  then 
					(
						faces=getFaceSelection obj
						for face in faces do setFaceMatID obj face selectedColMaterial
					)
					else
					(
						for i=1 to obj.numfaces do setFaceMatID obj i selectedColMaterial
					)
				)
			)
		)
	)
	
)


rollout colimport_rol "Import COL" width:150
(
	button imp "Import" width:110 
	 
	
	on imp pressed do (
		f = createMultitypeIStream "Read Collision" "DFF File (*.dff)|*.dff|COL File (*.col)|*.col|"
		if f != undefined then 
		(
			clearListener ()
			try
			(
				if f[2]==".col" then
				(
					while (readCol f[1]) do ()					
				)
				else
				(
					if (findCol f[1]) then readCol f[1]
				)
			)
			catch(messageBox (getCurrentException()))
			fclose (f[1])
		)
	)

) -- rollout

fn writeCols f cols version = 
(
	for c in cols do writeCol f c version
)

rollout colexport_rol "Export COL" width:250
(
	button exp "Export" width:110
	spinner	version "Version: " type:#integer range:[1,3,2]
	on exp pressed do (
		 for obj in selection do print(classof obj)
		
		myobjects = for obj in selection where (classof obj == Editable_mesh) and  (obj.parent == undefined) collect obj
		if myobjects.count>0 then 
		(
			f = createOStream "Save Collision File" "COL File (*.col)|*.col|"
			if f != undefined then 
			(
				writeCols f myobjects version.value
				fclose f
			)
		)
	)
	
	


) -- rollout


try (closeRolloutFloater dffio) catch () 
dffio = newRolloutFloater "R* COL" 250 350 20 130 
addRollout coltools_rol dffio
addRollout colimport_rol dffio
addRollout colexport_rol dffio