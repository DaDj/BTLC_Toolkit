
-- Get Col Material Ids based on Materialname
fn set_COLMAT texture_name =
(
	COL_MATERIALS = #("grass","pavement","road","metal","dirt","glass","path","water","window","wood","rustedmtl","railing","chrome","meshfencing","mesh","fence","soil","dc_pavement_plainvent01")
	COL_MATERIALS_ID = #(11,4,1,167,26,45,5,39,45,43,167,167,167,55,164,55,26)
	
	GRASS_ID = 80 --11
	PAVEMENT_ID = 4
	ROAD_ID = 1
	ROAD_FUCKED_ID = 2
	METAL_ID = 167
	DIRT_ID = 26
	PATH_ID = 5
	WATER_ID = 39
	GLASS_ID = 45
	WOOD_ID = 43
	
	for i in COL_MATERIALS do
	(
		test_mat = findstring texture_name i
		
		if test_mat != undefined and test_mat > 0 do
		(
			if i == COL_MATERIALS[1] do return GRASS_ID --grass
			if i == COL_MATERIALS[2] do return PAVEMENT_ID --pavement
			if i == COL_MATERIALS[3] do return ROAD_ID--road
			if i == COL_MATERIALS[4] do return METAL_ID --metal
			if i == COL_MATERIALS[5] do return DIRT_ID--dirt
			if i == COL_MATERIALS[6] do return GLASS_ID--glass
			if i == COL_MATERIALS[7] do return PATH_ID--path
			if i == COL_MATERIALS[8] do return WATER_ID --water
			if i == COL_MATERIALS[9] do return GLASS_ID --window
			if i == COL_MATERIALS[10] do return WOOD_ID --wood
			if i == COL_MATERIALS[11] do return METAL_ID--metal	
			if i == COL_MATERIALS[12] do return METAL_ID --metal		
			if i == COL_MATERIALS[13] do return METAL_ID --metal		
			if i == COL_MATERIALS[14] do return METAL_ID --MEtalmeshfence		
			if i == COL_MATERIALS[15] do return METAL_ID --MEtal (flor mesh) 	
			if i == COL_MATERIALS[16] do return METAL_ID --Fence					
			if i == COL_MATERIALS[17] do return DIRT_ID --Dirt/Soil		
			if i == COL_MATERIALS[18] do return METAL_ID --Pavement vent metal	
		)
	)
		return 0
)

-- Delete Meshface if thhe texure hase a certain string
fn deleteMeshFacesByMatID_Mesh node matID = 
(
    if iskindof node Editable_Mesh do
    (
        if canconvertto node Editable_Mesh do converttomesh node
        faces = for f=1 to node.numfaces where (getFaceMatID node f) == matID collect f
        meshop.deletefaces node (faces as bitarray)
        update node
    )
)
 --Find and delte materials of glue and stuff.
fn DeleteForbiddenCollison node MtlID = 
(
    Materialname = node.Material.MaterialList[MtlID].name
    MatsForbidden = #("MC_Glue_01MC_Glue_01_A","DC_Glue_01dc_glue_01_A","swnjdirt1")
    for i in MatsForbidden do
	(   
        test_mat = findstring  Materialname i
		if test_mat != undefined and test_mat > 0 do
		(
            deleteMeshFacesByMatID_Mesh node MtlID
        )
    )
  

)
-- Convert Standard Materials to CollisionMaterial
fn StdMattoColMat  TheObj = 
(
    i = TheObj
    if 	(IsKindOf i  Editable_Mesh) and   (((custattributes.get i ColMesh)!=undefined) or (isProperty obj #isShadow) != undefined)  then (
        i.showVertexColors = false
        
        i.Material = copy i.Material
        
        for MtlID = 1 to i.Material.MaterialList.Count do 
        (
            if iskindof i.Material.MaterialList[MtlID] Standard and  i.Material.MaterialList[MtlID].diffuseMap != undefined do
            (
                texture_path = (filterString i.Material.MaterialList[MtlID].diffuseMap.filename	"\\")
                texture_name = substring 	texture_path[texture_path.count] 1 26
                COL_Material =  GTA_COLSurface name: 	 i.Material.MaterialList[MtlID].name
             

                COL_Material.showInViewport = true;
                COL_Material.part =  -1
                COL_Material.surface =  set_COLMAT texture_name
                i.Material.MaterialList[MtlID] = COL_Material
                --i.Material.MaterialList[MtlID].diffu = 11
                if  i.Material.MaterialList[MtlID].name == "MO_DC_Road_Markings_01MO_D" do deleteMeshFacesByMatID_Mesh i MtlID
                if  i.Material.MaterialList[MtlID].name == "DC_Road_Markings_01DC_Road" do deleteMeshFacesByMatID_Mesh i MtlID
                if  i.Material.MaterialList[MtlID].name == "DC_Road_Markings_01DC_Road" do deleteMeshFacesByMatID_Mesh i MtlID
            )
        )	
    )
)
--------------------------
-- for Clean Col Mesh
fn fn_getNarrowFace obj face degree = 
(
    verts_ = meshop.getVertsUsingFace obj face 
    verts = verts_ as array
    distA = distance (meshop.getVert obj verts[1]) (meshop.getVert obj verts[2])
    distB = distance (meshop.getVert obj verts[2]) (meshop.getVert obj verts[3])
    distC = distance (meshop.getVert obj verts[3]) (meshop.getVert obj verts[1])			
    cosAngleAB = (((distA*distA) + (distB*distB) - (distC*distC)) as double) / ((2*distB*distA) as double)
    --format "A = % A2 = %\nB =  % B2 = %\nC = % C2 = %\n = %\n cos = = %\n angle = %\n" distA (distA*distA) distB (distB*distB) distC (distC*distC) (2*distA*distB) cosAngleAB ((acos cosAngleAB) as float)
    AngleAB = (acos(cosAngleAB) as float)
    --format "angle = %\n"  AngleAB
    cosAngleBC = (((distB*distB) + (distC*distC) - (distA*distA)) as double) / ((2*distC*distB) as double)
    AngleBC = (acos(cosAngleBC) as float)
    --format "angle = %\n"  AngleBC
    cosAngleCA = (((distC*distC) + (distA*distA) - (distB*distB)) as double) / ((2*distA*distC) as double)
    AngleCA = (acos(cosAngleCA) as float)
    --format "angle = %\n"  AngleCA		
    if AngleAB > degree then return true
    if AngleBC > degree then return true
    if AngleCA > degree then return true else return false
)

-- Clean and Simplify Mesh for Collsion
function CleanColMesh obj =
(
    if 	(IsKindOf obj  Editable_Mesh) and  (obj.parent != undefined) and ((custattributes.get obj ColMesh)!=undefined) then 
    (
        thresh = 0.02 -- weld threshold
        allVerts = #{1..(obj.numVerts)} -- get all verts list
        meshop.weldVertsByThreshold obj allVerts thresh -- Weld
        meshop.deleteIsoVerts obj
                f = #{}
                f2 = #{}
                fnarrow = #{}
                for i = 1 to obj.numfaces do (
                    if abs (meshop.getFaceArea obj i) < 0.0001 then append f i
                    if (fn_getNarrowFace obj i 178) == true then  append f2 i
                )
                    if not f.isEmpty then (
                        meshop.deleteFaces obj f
                       -- format "%: % No Area faces deleted\n" obj.name f.numberset
                       -- format "%: % Narrow faces deleted\n" obj.name f2.numberset
                    )
    -- else format "% have no zero-area faces\n" obj.name
    )
    /*
    if IsKindOf Obj Editable_Poly then 
    (
        obj.weldThreshold = 0.015 -- set weld threshold value
        allVerts = #{1..(polyop.getNumVerts obj)} -- get all verts list
        polyop.weldVertsByThreshold obj allVerts -- Weld
            Obj.EditablePoly.deleteIsoVerts ()
    ) */
)

-----------------------

-- Generates Collisionmeshes from the main Mesh
function GenerateColMeshes MyObjs = 
(
   disablesceneredraw()
    for obj in MyObjs do 
    (
        if classof obj == Editable_mesh then
        (
            if obj.parent == undefined do -- checks that the meshes don't have aprent, making sure to get the mainmodel
            (
                thecopy = copy obj
                thecopy.name = obj.name + "_COL" 
                thecopy.parent = obj
            
                if (custattributes.get thecopy ColMesh)==undefined then 
                (
                    custattributes.add thecopy ColMesh
                    thecopy.wirecolor =  color 50 210 250
                )
                StdMattoColMat thecopy
                CleanColMesh thecopy
            ) 
        )
    )
    gc()
	enablesceneredraw()
	redrawviews()
)

fn writeCols f cols version = 
(
	for c in cols do writeCol f c version
)

function isCol obj=
(
    isit = false
    if ((isProperty obj #isShadow ) == true) or ((custattributes.get obj TheColMesh) == true) then isit =true

    isit
)

-- Export Collisions
fn ExportCollisionold Path myobjects =
(
    --myobjects = for obj in selection where (classof obj == Editable_mesh) collect obj
	if myobjects.count>0 then 
	(
		f = createOStream "Save Collision File" "COL File (*.col)|*.col|"
		if f != undefined then 
		(
			writeCols f myobjects 3
			fclose f
		)
	)
)

fn CollisionGUITool =
(
    local SurfAry = #( "DEFAULT",
 "TARMAC", "TARMAC_FUCKED", "TARMAC_REALLYFUCKED", "PAVEMENT", "PAVEMENT_FUCKED",
 "GRAVEL", "FUCKED_CONCRETE", "PAINTED_GROUND", "GRASS_SHORT_LUSH", "GRASS_MEDIUM_LUSH",
 "GRASS_LONG_LUSH", "GRASS_SHORT_DRY", "GRASS_MEDIUM_DRY", "GRASS_LONG_DRY", "GOLFGRASS_ROUGH",
 "GOLFGRASS_SMOOTH", "STEEP_SLIDYGRASS", "STEEP_CLIFF", "FLOWERBED", "MEADOW",
 "WASTEGROUND", "WOODLANDGROUND", "VEGETATION", "MUD_WET", "MUD_DRY",
 "DIRT", "DIRTTRACK", "SAND_DEEP", "SAND_MEDIUM", "SAND_COMPACT",
 "SAND_ARID", "SAND_MORE", "SAND_BEACH", "CONCRETE_BEACH", "ROCK_DRY",
 "ROCK_WET", "ROCK_CLIFF", "WATER_RIVERBED", "WATER_SHALLOW", "CORNFIELD",
 "HEDGE", "WOOD_CRATES", "WOOD_SOLID", "WOOD_THIN", "GLASS",
 "GLASS_WINDOWS_LARGE", "GLASS_WINDOWS_SMALL", "EMPTY1", "EMPTY2", "GARAGE_DOOR",
 "THICK_METAL_PLATE", "SCAFFOLD_POLE", "LAMP_POST", "METAL_GATE", "METAL_CHAIN_FENCE",
 "GIRDER", "FIRE_HYDRANT", "CONTAINER", "NEWS_VENDOR", "WHEELBASE",
 "CARDBOARDBOX", "PED", "CAR", "CAR_PANEL", "CAR_MOVINGCOMPONENT",
 "TRANSPARENT_CLOTH", "RUBBER", "PLASTIC", "TRANSPARENT_STONE", "WOOD_BENCH",
 "CARPET", "FLOORBOARD", "STAIRSWOOD", "P_SAND", "P_SAND_DENSE",
 "P_SAND_ARID", "P_SAND_COMPACT", "P_SAND_ROCKY", "P_SANDBEACH", "P_GRASS_SHORT",
 "P_GRASS_MEADOW", "P_GRASS_DRY", "P_WOODLAND", "P_WOODDENSE", "P_ROADSIDE",
 "P_ROADSIDEDES", "P_FLOWERBED", "P_WASTEGROUND", "P_CONCRETE", "P_OFFICEDESK",
 "P_711SHELF1", "P_711SHELF2", "P_711SHELF3", "P_RESTUARANTTABLE", "P_BARTABLE",
 "P_UNDERWATERLUSH", "P_UNDERWATERBARREN", "P_UNDERWATERCORAL", "P_UNDERWATERDEEP", "P_RIVERBED",
 "P_RUBBLE", "P_BEDROOMFLOOR", "P_KIRCHENFLOOR", "P_LIVINGRMFLOOR", "P_CORRIDORFLOOR",
 "P_711FLOOR", "P_FASTFOODFLOOR", "P_SKANKYFLOOR", "P_MOUNTAIN", "P_MARSH",
 "P_BUSHY", "P_BUSHYMIX", "P_BUSHYDRY", "P_BUSHYMID", "P_GRASSWEEFLOWERS",
 "P_GRASSDRYTALL", "P_GRASSLUSHTALL", "P_GRASSGRNMIX", "P_GRASSBRNMIX", "P_GRASSLOW",
 "P_GRASSROCKY", "P_GRASSSMALLTREES", "P_DIRTROCKY", "P_DIRTWEEDS", "P_GRASSWEEDS",
 "P_RIVEREDGE", "P_POOLSIDE", "P_FORESTSTUMPS", "P_FORESTSTICKS", "P_FORRESTLEAVES",
 "P_DESERTROCKS", "P_FORRESTDRY", "P_SPARSEFLOWERS", "P_BUILDINGSITE", "P_DOCKLANDS",
 "P_INDUSTRIAL", "P_INDUSTJETTY", "P_CONCRETELITTER", "P_ALLEYRUBISH", "P_JUNKYARDPILES",
 "P_JUNKYARDGRND", "P_DUMP", "P_CACTUSDENSE", "P_AIRPORTGRND", "P_CORNFIELD",
 "P_GRASSLIGHT", "P_GRASSLIGHTER", "P_GRASSLIGHTER2", "P_GRASSMID1", "P_GRASSMID2",
 "P_GRASSDARK", "P_GRASSDARK2", "P_GRASSDIRTMIX", "P_RIVERBEDSTONE", "P_RIVERBEDSHALLOW",
 "P_RIVERBEDWEEDS", "P_SEAWEED", "DOOR", "PLASTICBARRIER", "PARKGRASS",
 "STAIRSSTONE", "STAIRSMETAL", "STAIRSCARPET", "FLOORMETAL", "FLOORCONCRETE",
 "BIN_BAG", "THIN_METAL_SHEET", "METAL_BARREL", "PLASTIC_CONE", "PLASTIC_DUMPSTER",
 "METAL_DUMPSTER", "WOOD_PICKET_FENCE", "WOOD_SLATTED_FENCE", "WOOD_RANCH_FENCE", "UNBREAKABLE_GLASS",
 "HAY_BALE", "GORE", "RAILTRACK" )


    try (closeRolloutFloater CollisionGUI) catch ()
		Pos = getMaxWindowSize() 	
		PosX = Pos[1]/2 - 300
		CollisionGUI  = newRolloutFloater  "CollsionTool" 600 450 PosX 250 
		addRollout GenericSettings CollisionGUI
)