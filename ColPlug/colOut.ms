fileIn ("io.ms") quiet:true
fileIn ("utils.ms") quiet:true

fn writeColBoxes f boxes col= (
	for box in boxes do 
	(
		m=snapshotasmesh box
		pos1 = m.verts[1].pos- col.pos
		pos2 = m.verts[8].pos-col.pos
		writeVertex f (pos1)
		writeVertex f (pos2)
		writeByteIndex f (box.matID +1 )
		writePadding f 3
	)
)

fn writeColSpheres f spheres reverse col = (	
	for sphere in spheres do 
	(
		if reverse then 
		(
			writeFloat f (sphere.delegate.radius)
			writeVertex f (sphere.position)
		)
		else
		(
			writeVertex f (sphere.position-col.pos)
			writeFloat f (sphere.delegate.radius)
		)
		writeByteIndex f (sphere.matID + 1)
		writeByteIndex f (sphere.flag)
		writeShort f 0
	)
)

fn hasPadding m = 
(
	((mod (m.numverts) 2)!=0)
)

fn writeColMesh f m isShadow = (
	--for vert in m.verts do writeFixPointVertex f 128 (vert.pos)
	---	for vert in V = in coordsys local (getVert m i) do writeFixPointVertex f 128 (vert.pos)
	
	NVerts =  m.NumVerts
	for i = 1 to NVerts do (
	V = in coordsys local (getVert m i)
	writeFixPointVertex f 128 (V)
	)
 
	
	if (hasPadding m) then writeShort f 0
	m2=snapshotasmesh m
	meshop.flipNormals m2 #all
	objmat = m.material
	for i=1 to m2.numfaces do 
	(
		writeShortFace f (getFace m2 i)
		if isShadow then writeShort f 0xff00 
		else(
			--writeShortIndex f (getFaceMatID m2 i)
				mmm = getFaceMatID m2 i
				  if objmat!=undefined then
					if isKindOf objmat MultiMaterial then
					  if isKindOf objmat[getFaceMatID m i] GTA_COLSurface then mat = objmat[getFaceMatID m i].surface
					  else mat = (mmm-1)-- (getFaceMatID obj i) - 1
					else
					  if isKindOf m GTA_COLSurface then mat = objmat.surface
					  else mat = (mmm-1)  -- ((getFaceMatID obj i) -1)
				  else 
				   mat = 0
				  
				WriteByte f mat
				--WriteByte f 254 -- we should Get face brightness from vertex paint instead

				--Get brightness with by vertex color of face
				ch_Day = 0 -- (0 - vertex color)
				ch_Night = -1 --  (-1 - vert illum)

			
				try 
				(
					MyMapFace = meshop.getMapFace m ch_Day i  
					MyNightMapFace = meshop.getMapFace m ch_Night i  
	
					MyDayBrightness = 0
					MyNightBrightness = 0
					
						for i2 = 1 to MyMapFace.count do 
						(
							THECOLOUR = meshop.getMapVert m ch_Day MyMapFace[i2] as color
							MyDayBrightness = MyDayBrightness + THECOLOUR.value 
						)
						MyDayBrightness = MyDayBrightness /3;
					
					--	MyDayBrightness = 1;
					
					
					try 
					(
						for i2 = 1 to MyMapFace.count do 
						(
						THECOLOUR = meshop.getMapVert m ch_Night MyMapFace[i2] as color
						MyNightBrightness = MyNightBrightness + THECOLOUR.value 	
						)	
						MyNightBrightness = MyNightBrightness/3
					) catch 
					(
						MyNightBrightness = 1.0
					)
				
					MyDayBrightness = amin #(ceil((MyDayBrightness^2*4) * 15),15) as integer
					MyNightBrightness = amin #(ceil((MyNightBrightness^2 * 10) * 15),15) as integer
					MyNightBrightness = bit.shift MyNightBrightness 4
					MyCompletBright = MyDayBrightness + MyNightBrightness
					WriteByte f MyCompletBright
				)
				catch 
				(
					WriteByte f 254 
				)
		

			/*	thing = 0 https://gtaforums.com/topic/989107-sa-about-collision-lightning/
				thing = bit.set thing 1 true
				thing = bit.set thing 8 true */
			)
	)
)

fn writeColL f bounds spheres boxes m = 
(
	writeFloat f (bounds[4])
	writeVertex f (bounds[3])
	writeVertex f (bounds[1])
	writeVertex f (bounds[2])
	writeLong f (spheres.count)
	writeColSpheres f spheres true
	writeLong f 0
	writeLong f (boxes.count)
	writeColBoxes f boxes
	if m==undefined then
	(
		for i=1 to 2 do writeLong f 0
	)
	else
	(
		writeLong f (m.numverts)
		for vert in m.verts do writeVertex f (vert.pos)
		writeLong f (m.numfaces)
		m2=snapshotasmesh m
		meshop.flipNormals m2 #all
		for i=1 to m2.numfaces do 
		(
			writeLongFace f (getFace m2 i)
			writeLongIndex f (getFaceMatID m i)
		)
	)
)

fn writeColX f bounds spheres boxes m is3 sm col= 
(
	for i=1 to 3 do writeVertex f (bounds[i])
	writeFloat f (bounds[4])
	writeShort f (spheres.count)
	writeShort f (boxes.count)
	faces=0
	if m!=undefined then faces=m.numfaces
	writeShort f faces
	writeShort f 0
	hasCol=(spheres.count>0)or(boxes.count>0)or(m!=undefined)
	hasShadow=(is3)and(sm!=undefined)
	writeLong f (bitMask #(false, hasCol, false, false, hasShadow))
	startOffset=104
	if is3 then startOffset+=12
	spheresOffset=0
	boxesOffset=0
	vertsOffset=0
	facesOffset=0
	if (spheres.count>0) then
	(
		spheresOffset=startOffset
		startOffset+=((spheres.count)*20)
	)
	if (boxes.count>0) then
	(
		boxesOffset=startOffset
		startOffset+=((boxes.count)*28)
	)
	if (m!=undefined) then
	(
		vertsOffset=startOffset
		startOffset+=((m.numverts)*6)
		if (hasPadding m) then startOffset+=2
		facesOffset=startOffset
		startOffset+=((m.numfaces)*8)
	)
	writeLong f spheresOffset
	writeLong f boxesOffset
	writeLong f 0
	writeLong f vertsOffset
	writeLong f facesOffset
	writeLong f 0
	if is3 then 
	(
		shadowFaces=0
		shadowVertsOffset=0
		shadowFacesOffset=0
		if sm!=undefined then
		(
			shadowFaces=sm.numfaces
			shadowVertsOffset=startOffset
			startOffset+=((sm.numverts)*6)
			if (hasPadding sm) then startOffset+=2
			shadowFacesOffset=startOffset
		)
		writeLong f shadowFaces
		writeLong f shadowVertsOffset
		writeLong f shadowFacesOffset
	)
	writeColSpheres f spheres false col
	writeColBoxes f boxes col
	if (m!=undefined) then writeColMesh f m false 
	if hasShadow then writeColMesh f sm true
)


fn writeCol f col version = 
(
	colVersion="L"
	if version>1 then colVersion=version as string
	fourCC="COL"+colVersion
	bounds=#()
	spheres=#()
	boxes=#()
	m=undefined
	sm=undefined
	clearSelection()
	
   	objRotation = col.rotation
	col.rotation = quat 0 0 0 1
	for c in col.children do
	(
		--print(c.name)
		case (classof c) of 
		(
			Collision_Sphere: 
			(
				append spheres c
				selectmore c
			)
			Collision_Box: 
			(
				append boxes c
				selectmore c
			)
			Editable_mesh: 
			(
				if (isCol c == true) then
				(
					if (c.isShadow) then
					(
						if (sm==undefined)and(version==3) then
						(
							sm=c
							selectmore c
						)
					)
					else
					(
						if m==undefined then
						(
							m=c
							selectmore c
						)
					)
				)
			) 
		)
	)
	bounds[1]=col.min - col.pos
	bounds[2]=col.max - col.pos
	bounds[3]=[0,0,0]
	thing = bounds[1]- bounds[2]
	bounds[4]=0.5*(distance  bounds[1] bounds[2])
	clearSelection()

	if(m != undefined) do 
	(		
		mbounds=#()
		mbounds[1]=m.min - m.pos
		mbounds[2]=m.max - m.pos
		--Check if any axis is above 255 units
		SizeLimit = false
		if abs(mbounds[1].x) > 255 or  abs(mbounds[1].y) > 255  or  abs(mbounds[1].z) > 255 do SizeLimit = true
		if abs(mbounds[2].x) > 255 or  abs(mbounds[2].y) > 255  or  abs(mbounds[1].z) > 255 do SizeLimit = true
		
		
		if SizeLimit == true do 
		(
			for v = getNumVerts m to 1 by -1 do--loop through all vertices
			(
					vert = getVert m v --get the v-th vertex
					vbounds=#()
					vbounds[1]=vert - m.pos
					if abs(vbounds[1].x) > 255 or  abs(vbounds[1].y) > 255  or  abs(vbounds[1].z) > 255 do  
					(
						deleteVert m v
						update m
					)
			)

			format "ColWarning: Too Big --> We trimmed the mesh! Model: % Min: % Max: % \n" col.name  bounds[1] bounds[2]
		)
	)
	
	
	
	size=64+(spheres.count)*20+(boxes.count)*28
	if version>1 then
	(
		size+=36
		if m!=undefined then
		( 
			size+=((m.numverts)*6+(m.numfaces)*8)
			if (hasPadding m) then size+=2
		)
		if version>2 then
		(
			size+=12
			if sm!=undefined then (
				size+=((sm.numverts)*6+(sm.numfaces)*8)
				if (hasPadding sm) then size+=2
			)
		)
	)
	else
	(
		size+=20
		if m!=undefined then size+=((m.numverts)*12+(m.numfaces)*16)
	)
	
	writeString f fourCC
	fseek f -1 #seek_cur
	writeLong f size
	writeLimitedString f col.name 24 -- model id sind die letzten zwei nummern
	
	if version>1 then writeColX f bounds spheres boxes m (version>2) sm col
	else writeColL f bounds spheres boxes m
	
	col.rotation = objRotation
)