-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: navmesh grid slicer
-- Last changed: Jun 2013

-- original implementation (c) Andrew Romanenkov, 2006

------------- grid slicer ---------------

struct grid_slicer (
	Xmax,
	Xmin,
	Ymax,
	Ymin,
	--SPlane,
	--selFace,
	--VertsArray,
	RayPlus,
	SliceValue,
	
	fn round_f val n:3 = (
		local mult = 10.0 ^ n
		return (floor ((val * mult) + 0.5)) / mult
	),

	fn CreateGrid pos:[0,0,0] lsegs:4 = (
		SLPlane  = plane name:"SLPlane" length:(4*SliceValue) width:(4*SliceValue) lengthsegs:lsegs widthsegs:4 wirecolor:red
	 	setTransformLockFlags $SLPlane  #{4,5,7,8,9}
		try (delete $InvisDummy) catch true
		InvisDummy  = box name:"InvisDummy" length:1 width:1  height:10
		setTransformLockFlags $InvisDummy  #{4,6}
		$InvisDummy.dir = [1,0,0]
		$InvisDummy.parent = $SLPlane
		hide $InvisDummy
	),
	
	fn SliceExcpt = (
		throw "Exception in slicer garbage collection, use 64 bit 3dsMax"
	),

	fn SliceGrid A = (
		local i, selFace, SPlane, e = false
		If A == 1 then  --Negative X direction, if slice direction will go from Xmin, Ymax and up
		(
			SPlane  = (ray [Xmax,Ymin,0]  RayPlus)
			SPlane.pos = $SLPlane.pos - ((RayPlus*SliceValue)*(floor (distance $SLPlane.pos [Xmax,Ymin,0]/SliceValue)+1))
			for i=1 to (floor (distance [Xmin,Ymax,0] [Xmax,Ymin,0]/SliceValue)+1) do 
		 	(
				SPlane.pos=SPlane.pos+(SPlane.dir*SliceValue)
				selFace = polyop.getFaceSelection $ as array
				PolyOp.slice $ selFace SPlane 
				
				try ( gc() ) catch ( e = true )
				if e then SliceExcpt()
			)
			selFace = polyop.getFaceSelection $ as array
		) 

		If A == 2 then 	--Positive X direction...from Xmin, Ymin, and up
		(
			SPlane  = (ray [Xmin,Ymin,0]  RayPlus)
			SPlane.pos = $SLPlane.pos - ((RayPlus*SliceValue)*(floor (distance $SLPlane.pos [Xmin,Ymin,0]/SliceValue)+1))
			for i=1 to (floor (distance [Xmin,Ymin,0] [Xmax,Ymax,0]/SliceValue)+1) do 
			(
				SPlane.pos=SPlane.pos+(SPlane.dir*SliceValue)
				selFace = polyop.getFaceSelection $ as array
				PolyOp.slice $ selFace SPlane 

				try ( gc() ) catch ( e = true )
				if e then SliceExcpt()				
			)
			selFace = polyop.getFaceSelection $ as array
		) 

		If A == 3 then  -- X ==0
		(
			SPlane  = (ray [Xmin,Ymin,0]  RayPlus)
			SPlane.pos  = [$SLPlane.pos[1] - ((floor ((distance [Xmin,0,0]  [$SLPlane.pos[1],0,0])/SliceValue)+1)*SliceValue),$SLPlane.pos[2] - ((floor ((distance [0,Ymin,0]  [0,$SLPlane.pos[2],0])/SliceValue)+1)*SliceValue),0]
			while SPlane.pos[2]<Ymax do 
		 	(
				SPlane.pos=SPlane.pos+(SPlane.dir*SliceValue)
				selFace = polyop.getFaceSelection $ as array
				PolyOp.slice $ selFace SPlane 

				try ( gc() ) catch ( e = true )
				if e then SliceExcpt()				
			)
		) 

		If A == 4 then  -- Y ==0  
		(
			SPlane  = (ray [Xmin,YMin,0]  RayPlus)
			SPlane.pos  = [$SLPlane.pos[1] - ((floor ((distance [Xmin,0,0]  [$SLPlane.pos[1],0,0])/SliceValue)+1)*SliceValue),$SLPlane.pos[2] - ((floor ((distance [0,Ymin,0]  [0,$SLPlane.pos[2],0])/SliceValue)+1)*SliceValue),0]
			while SPlane.pos[1]<Xmax do 
		 	(
				SPlane.pos=SPlane.pos+(SPlane.dir*SliceValue)
				selFace = polyop.getFaceSelection $ as array
				PolyOp.slice $ selFace SPlane 

				try ( gc() ) catch ( e = true )
				if e then SliceExcpt()				
			)
		) 
	),
	
	fn PrepSlice = (	
		ResetXForm $
		collapsestack $
		SliceValue = 100.0
		------computing min/max points
		local VertsArray = polyOp.getVertsUsingFace $ (polyOp.getFaceSelection $) as array
		Xmax = (PolyOp.getvert $ VertsArray[1] )[1]
		Xmin = (PolyOp.getvert $ VertsArray[1] )[1]
		Ymin = (PolyOp.getvert $ VertsArray[1] )[2]
		Ymax = (PolyOp.getvert $ VertsArray[1] )[2]
		for v=1 to VertsArray.count do (  if (PolyOp.getvert $ VertsArray[v])[1] > Xmax  then Xmax = (PolyOp.getvert $ VertsArray[v])[1] )
		for v=1 to VertsArray.count do (  if (PolyOp.getvert $ VertsArray[v])[2] > Ymax  then Ymax = (PolyOp.getvert $ VertsArray[v])[2] )
		for v=1 to VertsArray.count do (  if (PolyOp.getvert $ VertsArray[v])[1] < Xmin  then Xmin = (PolyOp.getvert $ VertsArray[v])[1] )
		for v=1 to VertsArray.count do (  if (PolyOp.getvert $ VertsArray[v])[2] < Ymin  then Ymin = (PolyOp.getvert $ VertsArray[v])[2] )
		VertsArray = undefined
		---------computing positive Y only ray--------------
		--names = for i in objects collect i.name
		/*if findItem names "InvisDummy" == 0 then */ CreateGrid lsegs:4
	   	RayPlus=$InvisDummy.dir
		RayPlus = [round_f RayPlus[1], round_f RayPlus[2],0]
		if (RayPlus[1]<=0 and RayPlus[2]<=0) then
		( 
			--messagebox "3!"
			RayPlus = [abs RayPlus[1], abs RayPlus[2],0]
		)
		else
		If (RayPlus[1]>0; RayPlus[2]<0) then
		(
			--messagebox "4!"
			RayPlus = [-RayPlus[1], -RayPlus[2],0]
		)
		RayPlus = [round_f RayPlus[1], round_f RayPlus[2],0]
		--print RayPlus
		if true then
 		(
			case of 
			(
				(RayPlus[1] == 0) : SliceGrid 3
				(RayPlus[2] == 0) : SliceGrid 4
				(RayPlus[1]<0 and RayPlus[2] !=0) :SliceGrid 1
				(RayPlus[1]>0 and RayPlus[2] !=0) : SliceGrid 2
			)
		
			--rotating vector
			If RayPlus[1]>0 
				then RayPlus = [-RayPlus[2], RayPlus[1],0]
				else RayPlus = [RayPlus[2],-RayPlus[1],0]
							
			case of 
			(
				(RayPlus[1] == 0) : SliceGrid 3
				(RayPlus[2] == 0) : SliceGrid 4
				(RayPlus[1]<0 and RayPlus[2] !=0) : SliceGrid 1
				(RayPlus[1]>0 and RayPlus[2] !=0) : SliceGrid 2
			)
		)
		redrawViews()
	),

	fn slice obj = (
		local faceSel = #() -- select faces
		local i
		for i = 1 to obj.numfaces do append faceSel i
		setFaceSelection obj faceSel
		update obj -- update the mesh
		max modify mode -- switch to modify mode
		select obj -- select the mesh
		subObjectLevel = 4 -- switch to face sub-object level		
		
		if classof $ == Editable_Poly then
		(
			if subObjectLevel == 4 then
			(
				if (PolyOp.getfaceselection $ as array).count != 0 
					then PrepSlice() 
					else throw "no faces selected"
			) else throw "no face level selected"
		) else	
		if classof $ == Editable_Mesh then
		(
			if subObjectLevel == 4 then
			( 
				if (getfaceselection $ as array).count !=0 then
				(
					convertTo $ PolyMeshObject
					subObjectLevel = 4
					if (PolyOp.getfaceselection $ as array).count != 0 
						then PrepSlice() 
						else throw "no face level selected"
					convertTo $ TriMeshGeometry
					subObjectLevel = 4
				) else throw "no faces selected"
			) throw "no face level selected"
		) else throw "no proper object selected, Mesh or Poly only"
		
		try (delete $SLPlane) catch ()
		faceSel = undefined
	)
)

