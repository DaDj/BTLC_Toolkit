struct btlc_utils 
(
	function  GetMaxIDFromIDE IDEFile = 
	(
		theFile = openfile IDEFile
		myIds = #()
		if theFile != undefined then
		(
			while not eof theFile do
			(
				mystring = readline theFile
				mystring = filterString  mystring ", "
				
				if mystring[1] != undefined and mystring[1] != "objs" and mystring[1] != "tobj" and  mystring[1] != "end" and  mystring[1] != "txdp" do 
				(
					if mystring.count == 5 or mystring.count == 7 do append myIds (mystring[1] as integer)
					
				)
				
			)
			close theFile
			gc()
			free theFile
			TheID =  (amax myIds)
		)
		TheID
	),

	fn CutNameAdv TheName = 
	( -- Cut Names in a more advanced way.
		/* Testfucntion:
        thename =  "ABCDEFGHIJKLMNOPQRSTU";
        thename.count
        thename =  btlcUtil.CutNameAdv thename;
        thename.count
        */
		
		-- 1. delete underscores in name to reduce character count
		if TheName.count >  19 then 
		(
			TheName = substituteString TheName  "_" ""
		) 

		-- 2. if its still too long try to delete every second character till it fits
		if TheName.count >  19 then 
		(
			iOverMax = TheName.count - 19

			for idx = 1 to iOverMax do 
			(
				TheName =  replace TheName (idx + 1) 1 ""
			)
		)
		
		-- 3. if that doesnt help..cut the end characters..should never happen. lol
		/*if TheName.count >  19 then 
		(
			TheName = substring TheName 1 19
		)*/
		TheName
	),

	fn attachMeshKeepMatIds obj1 obj2 = 
	(
		matIds = #()
		
		faceIndex = 0
		
		for i=1 to getNumFaces obj1 do
		(
			faceIndex = faceIndex + 1
			matIds[faceIndex] = getFaceMatID obj1 i
		)
		
		for i=1 to getNumFaces obj2 do
		(
			faceIndex = faceIndex + 1
			matIds[faceIndex] = getFaceMatID obj2 i
		)
		
		meshop.attach obj1 obj2
		
		for i=1 to getNumFaces obj1 do
		(
			setFaceMatID obj1 i matIds[i]
		)	
	),

	fn SetLightDataGlobal = 
	(
		-- helper function to set light data do all lights
		for TheLight in Lights do 
        (
            if classof TheLight == GTA_Light do 
            ( 
             -- TheLight.shadowSize =    TheLight.shadowSize * 0.0
		--	  TheLight.coronaSize = 1.0
		--	if TheLight.pointlightRange > 2 do TheLight.pointlightRange = 2
                TheLight.shadowColorMultiplier = 65.0
           --     TheLight.flag22 = true
			--	TheLight.flag10 = false
			--	TheLight.shadowZDistance = 0.0
			--	TheLight.flag23 = false
         	)
        )
	),

	fn SetObjDataGlobal = 
	(
		Myobjlist = #()
		for aModel in objects where aModel.parent == undefined do append Myobjlist aModel

		for theobj in Myobjlist do 
		(
			if 	(custattributes.get theobj gtaDynObject != undefined) do 
			(

				ObjDat = (custattributes.get theobj gtaDynObject)
				ObjDat.Mass = 350
				ObjDat.TurnMass = 340

				
				ObjDat.Uproot = 0.0
				if ObjDat.CDEff == 200 do 
				(
				--	print theobj.name
					--ObjDat.SpCDR = 0 --1: lampost
				--	ObjDat.FX_TYPE = 2 --play when destroyed
					--ObjDat.FX_NAME = "prt_spark_3"
				--	ObjDat.CDMult = 0.9--damager multiplier
				
				)
				/* ObjDat.Mass ObjDat.TurnMass ObjDat.AirResistance ObjDat.Elasticity ObjDat.PercSubmerged ObjDat.Uproot \
				ObjDat.CDMult ObjDat.CDEff ObjDat.SpCDR ObjDat.CamAv ObjDat.Expl ObjDat.FX_TYPE \
				ObjDat.FX_OFFSETx ObjDat.FX_OFFSETy ObjDat.FX_OFFSETz ObjDat.FX_NAME \
				ObjDat.B_SM ObjDat.B_VX ObjDat.B_VY ObjDat.B_VZ ObjDat.B_VR ObjDat.B_GUN ObjDat.B_SPK */
			)
		)
	),

	fn WeldVertices obj thresh  = 
	(
		if classof obj == Editable_mesh do 
		(
		--thresh = 0.01 -- weld threshold
		allVerts = #{1..(obj.numVerts)} -- get all verts list
		meshop.weldVertsByThreshold obj allVerts thresh -- Weld
		meshop.deleteIsoVerts obj
		)
			
	),

	fn GetModelsinScene = 
	(
		 MyObjs = #()
        for i in objects as array  do 
        (
            if (btlcCol.isCol i) == false and (i.parent == undefined) do append MyObjs i
        ) 
        MyObjs =  makeUniqueArray MyObjs
	),

	fn ReduceVertsforAllModels = 
	(
		Objs = GetModelsinScene();
		btlcVertexPaint.ReduceMapVertsObjects Objs
	)
)
btlcUtil = btlc_utils();

--btlcUtil.SetLightDataGlobal()
--btlcUtil.SetObjDataGlobal()
fn get_all_nodes nodes =
(
	allnodes = #()
	
	for n in nodes do
	(
		append allnodes n
		join allnodes (get_all_nodes (n.children))
	)
	
	allnodes
)