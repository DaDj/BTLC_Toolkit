function sortFaces TheObjFace obj=
(
	
	MySortedone = #()

	for i= 2 to  TheObjFace.count do
	(
		FaceA =  meshop.getFaceCenter obj i
		FaceB =  meshop.getFaceCenter obj i-1
		
		if FaceA.x >  FaceB.x then
		(
			MySortedone[i-1] = TheObjFace[i] 
			MySortedone[i] = TheObjFace[i-1] 
		)
		else	if FaceA.y >  FaceB.y then 
		(
			MySortedone[i-1] = TheObjFace[i] 
			MySortedone[i] = TheObjFace[i-1] 
		)
		else 
		(
			MySortedone[i-1] = TheObjFace[i-1] 
			MySortedone[i] = TheObjFace[i] 
		)
	)	
	
	MySortedone
)	


obj = selection[1]
TheObjFace = obj.Faces

NumGroups = TheObjFace.count/50

TheObjFace = obj.Faces
MySortedone = TheObjFace
MySortedone = sortFaces MySortedone obj

for i_groups =  1 to NumGroups do 
(
	MyFaces = #()
	currentstart = (i_groups*50)-48
	
	-- Get the first vert as Start BB
	vertsSel = meshop.getVertsUsingFace  obj MySortedone[currentstart] as array

	vPosStart=  (in coordsys world (getVert obj vertsSel[2]))
	BBmax = copy vPosStart
	BBmin = copy vPosStart	
		
	for i_Face = currentstart to (currentstart+50) do 
	(
	--print	MySortedone[i_Face]
		vertsSel = meshop.getVertsUsingFace  obj MySortedone[i_Face] as array
		
		for i_vert in vertsSel do
		(
			vPos =  (in coordsys world (getVert obj i_vert))
				
			BBmax.x =  amax BBmax.x vPos.x
			BBmax.y =  amax BBmax.y vPos.y
			BBmax.z =  amax BBmax.z vPos.z
				
			BBmin.x =  amin BBmin.x vPos.x
			BBmin.y =  amin BBmin.y vPos.y
			BBmin.z =  amin BBmin.z vPos.z
		)
	)
	
		MyDummy = Dummy();
		Pos = [0,0,0]
		Pos.x = 	(BBmax.x - BBmin.x)/2+BBmin.x
		Pos.y = (BBmax.y - BBmin.y)/2+BBmin.y
		Pos.z = 	(BBmax.z - BBmin.z)/2+BBmin.z	
		
		MyDummy.Pos = 		Pos
		TheLength = [0,0,0]
		TheLength.x =(BBmax.x - BBmin.x)
		TheLength.y =(BBmax.y - BBmin.y)
		TheLength.z = (BBmax.z - BBmin.z)
		MyDummy.boxsize = TheLength
)


