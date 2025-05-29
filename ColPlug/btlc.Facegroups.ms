-- https://gtamods.com/wiki/Collision_File#Face_Groups

-- Struct for a single facegroup
struct SAColFaceGroup 
(
    minPos,        -- TVector: Minimum bounds of the facegroup
    maxPos,        -- TVector: Maximum bounds of the facegroup
    StartFace,     -- Integer: Start face index (uint16)
    EndFace        -- Integer: End face index (uint16)
)

-- Struct for managing facegroups in a GTA collisionfile
struct SAColFaceGroups 
(
    TheMesh,      -- Mesh: The mesh object
    Groups = #(), -- Array of SAColFaceGroup: List of facegroups

    fn aminPoint3 a b = [ (if a.x < b.x then a.x else b.x), (if a.y < b.y then a.y else b.y), (if a.z < b.z then a.z else b.z) ],

    fn amaxPoint3 a b = [ (if a.x > b.x then a.x else b.x), (if a.y > b.y then a.y else b.y), (if a.z > b.z then a.z else b.z) ],

    -- Clusters faces by distance with max faces per cluster and a distance threshold.
    fn clusterFacesByDistance maxPerCluster threshold =
    (
        local total = getNumFaces TheMesh
        local unprocessed = for i = 1 to total collect i
        local clusters = #()
    
        while unprocessed.count > 0 do
        (
            local seed = unprocessed[1]
            deleteItem unprocessed 1
    
            local cluster = #(seed)
            local seedPos = meshop.getFaceCenter TheMesh seed
    
            local i = 1
            while i <= unprocessed.count and cluster.count < maxPerCluster do
            (
                local fid = unprocessed[i]
                local pos = meshop.getFaceCenter TheMesh fid
    
                if (distance seedPos pos) <= threshold then
                (
                    append cluster fid
                    deleteItem unprocessed i
                    i = 1
                )
                else
                (
                    i += 1
                )
            )
            append clusters cluster
        )
        clusters
    ),

    -- Reorders mesh face Ids based on cluster.
    fn reorderMeshFacesByClusters clusters = 
    (
        NewMesh = copy TheMesh.mesh
        GlobalID = 1
        NewClusters = #()
        NewClusters[clusters.count] = #()
        for iCluster = 1 to clusters.count do
        (
            aNewCluster = #()
            local FaceIds = clusters[iCluster]
            for Faceidx = 1 to FaceIds.count do 
            (
                TempVerts = getFace TheMesh.mesh FaceIds[Faceidx] 
                setface NewMesh GlobalID TempVerts
                append aNewCluster GlobalID
                
                
                
                VertsVc = meshop.getMapFace TheMesh.mesh 0 FaceIds[Faceidx] 
                meshop.setMapFace NewMesh 0 GlobalID VertsVc
                
                VertsVc = meshop.getMapFace TheMesh.mesh -1 FaceIds[Faceidx] 
                meshop.setMapFace NewMesh -1 GlobalID VertsVc
                
                
                GlobalID = GlobalID + 1
                
            )
            NewClusters[iCluster] = aNewCluster 
        )
        TheMesh.mesh = copy NewMesh
        update TheMesh
        NewClusters
    ),

    fn GetBBofCluster Cluster = 
    (
        local bbMin = [1e9,1e9,1e9]
        local bbMax = [-1e9,-1e9,-1e9]

        for FaceIds in Cluster do
        (
            local f = getFace obj FaceIds
            local p1 = getVert obj f.x
            local p2 = getVert obj f.y
            local p3 = getVert obj f.z

            bbMin = aminPoint3 bbMin p1
            bbMin = aminPoint3 bbMin p2
            bbMin = aminPoint3 bbMin p3

            bbMax = amaxPoint3 bbMax p1
            bbMax = amaxPoint3 bbMax p2
            bbMax = amaxPoint3 bbMax p3
        )
        [bbMin, bbMax]
    ),

    fn ShowDebugDummies = 
    (
        for i = 1 to Groups.count do
        (
            local startFace = Groups[i].StartFace
            local endFace = Groups[i].EndFace

            local faceIDs = for faceID = startFace to endFace collect faceID
            local bbMin = [1e9,1e9,1e9]
            local bbMax = [-1e9,-1e9,-1e9]

            BBox = GetBBofCluster faceIDs
            bbMin = BBox[1]
            bbMax = BBox[2]

            local center = (bbMin + bbMax) / 2
            local size = bbMax - bbMin

            local d = Dummy name:("Cluster_" + i as string)
            d.position = center
            d.boxsize = size
            d.wirecolor = yellow
        )
    ),

        fn DoesMeshNeed mesh = 
    (
        local faceCount = getNumFaces mesh
        return (faceCount > 80)
    ),

    fn GenerateGroups = 
    (
        local clusters = clusterFacesByDistance TheMesh 50 10.0
        NewClusters = reorderMeshFacesByClusters TheMesh clusters

        for idGrp = 1 to NewClusters.count do
        (
            local Cluster = NewClusters[idGrp]
            local SingleGroup = SAColFaceGroup()
            SingleGroup.StartFace = Cluster[1] 
            SingleGroup.EndFace = Cluster[Cluster.count]

            BBox = GetBBofCluster Cluster
            SingleGroup.minPos = BBox[1]
            SingleGroup.maxPos = BBox[2]
            append Groups SingleGroup
        )
    )

)   