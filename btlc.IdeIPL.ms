struct btlc_IV_Obj(Name = "", Txd = "", DrawDist = 100, Flag = 0)

struct btlc_IV_TObj(Name = "", Txd = "", DrawDist = 100, Flag = 0, TOn = 0, TOff = 0)

struct btlc_IV_ObjAnim(Name = "",  Txd = "",  Anim = "",  DrawDist = 100,  Flag = 0)

struct btlc_IV_2dfxParticle(Modelname,  Position, FxName = "")

struct btlc_IV_2dfxSpawn(Modelname,    Position, Rotation, Flags)

struct btlc_Txdp( Txd = "", TxdParent = "")

struct btlc_SA_Obj( Id = 0, Name = "", Txd = "", DrawDist = 100, Flag = 0)

struct btlc_SA_TObj( Id = 0, Name = "", Txd = "", DrawDist = 100, Flag = 0, TOn = 0, TOff = 0)

struct btlc_SA_ObjAnim( Id = 0,  Name = "",  Txd = "",  Anim = "",  DrawDist = 100,  Flag = 0)

struct btlc_SA_2dfxParticle( Modelname,  Position, FxName = "")

struct btlc_SA_IDE 
(
    thePath = "",
    Name = "",
    objs = #(),
    tobjs = #(),
    anim = #(),
    Effects = #(),
    txdp = #(),
    
    fn Load  = 
    (
        fs = openFile thePath
		while not eof fs do
		(
			l = readline fs
			if l == "objs" do 
			(
                IdObj= objs.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					objs[IdObj] = btlc_SA_Obj();
					objs[IdObj].Id = trimLeft(trimRight fl[1]) as Integer 
					objs[IdObj].Name = (trimLeft(trimRight fl[2]))
					objs[IdObj].Txd =  (trimLeft(trimRight fl[3])) 
					objs[IdObj].DrawDist =  (trimLeft(trimRight fl[4])) as integer 
                    objs[IdObj].Flag =  (trimLeft(trimRight fl[5])) as integer 
					IdObj = IdObj + 1
				)
			)

            if l == "tobj" do 
			(
                IdObj = tobjs.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					tobjs[IdObj] = btlc_SA_TObj();
					tobjs[IdObj].Id = (trimLeft(trimRight fl[1])) as Integer 
					tobjs[IdObj].Name = (trimLeft(trimRight fl[2]))
					tobjs[IdObj].Txd =  (trimLeft(trimRight fl[3])) 
					tobjs[IdObj].DrawDist =  (trimLeft(trimRight fl[4])) as integer 
                    tobjs[IdObj].Flag =  (trimLeft(trimRight fl[5])) as integer 
                    tobjs[IdObj].TOn =  (trimLeft(trimRight fl[6])) as integer 
                    tobjs[IdObj].TOff =  (trimLeft(trimRight fl[7])) as integer 
					IdObj = IdObj + 1
				)
			)

            if l == "anim" do 
			(
                IdObj = anim.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					anim[IdObj] = btlc_SA_ObjAnim();
					anim[IdObj].Id = (trimLeft(trimRight fl[1])) as Integer 
					anim[IdObj].Name = (trimLeft(trimRight fl[2]))
					anim[IdObj].Txd =  (trimLeft(trimRight fl[3])) 
                    anim[IdObj].Anim =  (trimLeft(trimRight fl[4])) 
					anim[IdObj].DrawDist =  (trimLeft(trimRight fl[5])) as integer 
                    anim[IdObj].Flag =  (trimLeft(trimRight fl[6])) as integer 
					IdObj = IdObj + 1
				)
			)

            if l == "txdp" do 
			(
                IdObj = txdp.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					txdp[IdObj] = btlc_Txdp();
					txdp[IdObj].Txd = (trimLeft(trimRight fl[1]))
					txdp[IdObj].TxdParent =  (trimLeft(trimRight fl[2])) 
					IdObj = IdObj + 1
				)
			)
        )
        close fs
    ),

    fn Save = 
    (
        fs = openFile thePath mode:"wb"
		format "objs\n" to:fs
		for Item in objs do 
		(
			format "%, %, %, %, %\r\n" (Item.Id as string) Item.Name Item.Txd (Item.DrawDist as string) (Item.Flag as string)  to:fs
		)
		format "end\n" to:fs

		format "tobj\n" to:fs
		for Item in tobjs do 
		(
			format "%, %, %, %, %, %, %\r\n" (Item.Id as string) Item.Name Item.Txd (Item.DrawDist as string) (Item.Flag as string) (Item.TOn as string) (Item.TOff as string)  to:fs
		)
		format "end\n" to:fs

		format "anim\n" to:fs
		for Item in anim do 
		(
			format "%, %, %, %, %, %\r\n" (Item.Id as string) Item.Name Item.Txd  Item.Anim (Item.DrawDist as string) (Item.Flag as string)  to:fs
		)
		format "end\n" to:fs

		format "txdp\n" to:fs
		for Item in txdp do 
		(
			format "%, %\r\n" Item.Txd Item.TxdParent  to:fs
		)
		format "end\n" to:fs
		close fs
    )
)

struct btlc_IV_IDE 
(
    thePath = "",
    Name = "",
    objs = #(),
    tobjs = #(),
    anim = #(),
    fxParticle = #(),
	fxSpawn = #(),
    txdp = #(),

    fn Load = 
    (
        fs = openFile thePath
		while not eof fs do
		(
			l = readline fs
			if l == "objs" do 
			(
                IdObj= objs.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					objs[IdObj] = btlc_IV_Obj();
					objs[IdObj].Name = (trimLeft(trimRight fl[1]))
					objs[IdObj].Txd =  (trimLeft(trimRight fl[2])) 
					objs[IdObj].DrawDist =  (trimLeft(trimRight fl[3])) as integer 
                    objs[IdObj].Flag =  (trimLeft(trimRight fl[4])) as integer 
					IdObj = IdObj + 1
				)
			)

            if l == "tobj" do 
			(
                IdObj = tobjs.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					tobjs[IdObj] = btlc_IV_TObj();
					tobjs[IdObj].Name = (trimLeft(trimRight fl[1]))
					tobjs[IdObj].Txd =  (trimLeft(trimRight fl[2])) 
					tobjs[IdObj].DrawDist =  (trimLeft(trimRight fl[3])) as integer 
                    tobjs[IdObj].Flag =  (trimLeft(trimRight fl[4])) as integer 
                    tobjs[IdObj].TOn =  19
                    tobjs[IdObj].TOff =  6
					IdObj = IdObj + 1
				)
			)

            if l == "anim" do 
			(
                IdObj = anim.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					anim[IdObj] = btlc_IV_ObjAnim();
					anim[IdObj].Name = (trimLeft(trimRight fl[1]))
					anim[IdObj].Txd =  (trimLeft(trimRight fl[2])) 
                    anim[IdObj].Anim =  (trimLeft(trimRight fl[3])) 
					anim[IdObj].DrawDist =  (trimLeft(trimRight fl[4])) as integer 
                    anim[IdObj].Flag =  (trimLeft(trimRight fl[5])) as integer 
					IdObj = IdObj + 1
				)
			)

            if l == "txdp" do 
			(
                IdObj = txdp.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","
					txdp[IdObj] = btlc_Txdp();
					txdp[IdObj].Txd = (trimLeft(trimRight fl[1]))
					txdp[IdObj].TxdParent =  toLower(trimLeft(trimRight fl[2])) 
					IdObj = IdObj + 1
				)
			)

			if l == "2dfx" do 
			(
                IdObj = fxParticle.count + 1
				while l != "end" do
				(
					l = readline fs
					if l == "end" then exit
					fl = filterString l  ","

					dfxType = toLower(trimLeft(trimRight fl[5])) as integer
					if dfxType == 1 do 
					(
						-- check if it is a normal particle effect which is always displayed
						isvalid2dfx = toLower(trimLeft(trimRight fl[11])) as integer 
						if isvalid2dfx == 0 do 
						(
							--btlc_IV_2dfxParticle
							fxParticle[IdObj] = btlc_IV_2dfxParticle();

							
							fxParticle[IdObj].Modelname = toLower(trimLeft(trimRight fl[1]))
							fxParticle[IdObj].Position = [0,0,0] as point3 
							fxParticle[IdObj].Position[1] =  toLower(trimLeft(trimRight fl[2])) as Float  
							fxParticle[IdObj].Position[2] =  toLower(trimLeft(trimRight fl[3])) as Float  
							fxParticle[IdObj].Position[3] =  toLower(trimLeft(trimRight fl[4])) as Float  
							-- FxName = ""
							fxParticle[IdObj].FxName =  toLower(trimLeft(trimRight fl[10]))
							IdObj = IdObj + 1
						)
					)

					if dfxType == 17 do 
					(
						
					)		
				)
			)
        )
        close fs
    ),

    fn Save = 
    (

    )
)

struct btlc_IDETools
(
    Main = "",
	
	fn MatchIVParticletoSA IVName= 
	(
		TheParticles = #()
		TheParticles[1] = DataPair "AMB_FLIES_CIRCLING" "insects"
		TheParticles[2] = DataPair "AMB_FIRE_GENERIC" "Flame"
		TheParticles[3] = DataPair "AMB_STEAM_HOTDOG" "cigarette_smoke" 
		TheParticles[4] = DataPair "AMB_STEAM_STREET_EXHAUST" "vent"
		TheParticles[5] = DataPair "AMB_STEAM_CHIMNEY" "vent"
		TheParticles[6] = DataPair "AMB_STEAM_WALL_VENT" "vent2"
		TheParticles[7] = DataPair "AMB_STEAM_SLOW" "vent" -- guess thats okay...
		TheParticles[8] = DataPair "AMB_DRIPS_WATER" "prt_splash"
		TheParticles[9] = DataPair "AMB_INDUST_PLUME_SM" "smoke50lit" 
		TheParticles[10] = DataPair "AMB_CASTLE_FOUNTAIN_UP" "water_fountain" 
		TheParticles[11] = DataPair "AMB_CASTLE_FOUNTAIN_LOW" "water_ripples" 
		TheParticles[12] = DataPair "AMB_FOUNTAIN_CITYHALL" "water_fountain"
		TheParticles[13] = DataPair "AMB_STEAM_MANHOLE" "vent" 
		TheParticles[14] = DataPair "AMB_ELECTRICAL_SPARKS" "prt_spark" 
		TheParticles[15] = DataPair "AMB_FOUNTAIN_GENERIC" "water_fountain" 
		TheParticles[16] = DataPair "AMB_WIND_SAND" "prt_sand"  -- we should really check ingame how that feels. I guess very bad. Find better effect
		TheParticles[17] = DataPair "AMB_INDUST_GAS_CONSTANT" "smoke30lit" 
		TheParticles[18] = DataPair "AMB_STEAM_STREET_EXHAUST" "vent2" 
		--TheParticles[9] = DataPair "AMB_WIND_LEAVES_AUTUMN" "tree_hit_fir" --deactived.. its way to intensive 
		--TheParticles[10] = DataPair "AMB_WIND_LEAVES_PALE" "tree_hit_fir" --deactived.. its way to intensive 
		--TheParticles[11] = DataPair "AMB_WIND_ALLEY_LEAVES" "tree_hit_fir" --deactived.. its way to intensive 
		--TheParticles[12] = DataPair "AMB_WIND_ALLEY_LITTER" "tree_hit_fir" --deactived.. its way to intensive 
		--TheParticles[13] = DataPair "AMB_WIND_ALLEY_LEAVES" "tree_hit_fir" --deactived.. its way to intensive 
		--TheParticles[14] = DataPair "AMB_WIND_ALLEY_LITTER" "tree_hit_fir" --deactived.. its way to intensive 
		--TheParticles[3] = DataPair "AMB_RAIN_OVERHANGS_10M" "none"
		

		SaName = undefined
		for aParticle in TheParticles do 
			if (matchpattern aParticle.v1 pattern:IVName) do SaName = aParticle.v2
		
		if SaName == undefined do  print ("Couldn't find a match for IV Particle:" + IVName as string )
		
		SaName
	),

	fn ApplyParticletoModels ParticleList = 
	(
		for TheParticle in ParticleList do 
		(
		 	ParticleName = MatchIVParticletoSA TheParticle.FxName 

			if ParticleName != undefined do 
			(
				EffectID = findItem peffects ParticleName -- Effect in effect array

				for aModel in objects where aModel.parent == undefined do 
				(
					if matchpattern aModel.name pattern:TheParticle.Modelname do 
					(
						TheEffect = GTA_Particle()
						TheEffect.effectName = ParticleName
						TheEffect.parent = aModel
						--TheEffect.pos = aModel.pos
						TheEffect.pos =  (in coordsys parent TheParticle.Position) + aModel.pos
					
					)
				)
			) 
		)
		
	),

	fn IVParticlestoModels IdePath = 
	(
		MyIde = btlc_IV_IDE()
		MyIde.thePath = IdePath;
		MyIde.Load()
		ApplyParticletoModels MyIde.fxParticle
	),

	-- VV Decal obj finder and apply to SA IDE VV ---
	fn isMataDecal TheMat = 
	(
		IsIt = false
		Shader = custAttributes.get TheMat BTLC_MatShader 
		if Shader != undefined do
			  (
				if (matchPattern Shader.MyShaderName pattern:"*decal*")  \
				or  (matchPattern Shader.MyShaderName  pattern:"*alpha*")  \
				or (matchPattern Shader.MyShaderName  pattern:"*glass*")   then
				(					
					IsIt = true
				)
			)
			IsIt
	),

	-- Tries to find all object which could be only decals
	fn findDecalsObjs ObjList = 
	(
		DecalObjs = #()

		for TheObj in ObjList do 
		(	
			isDecalByName = false;
			isDecalByMats = false;
			isDecalMaybe = false;
	
			if (isCol TheObj) or (classof TheObj != Editable_mesh) do return();

			if (matchPattern TheObj.name pattern:"*glue*") \
			or (matchPattern TheObj.name pattern:"*decal*") do 
			(
				isDecalByName = true;
			)

			if (classof TheObj.Material) != Multimaterial then 
			(
			
				  if TheObj.Material != undefined do  isDecalByMats =	isMataDecal TheObj.Material
			) 
			else 
			(
				DecalMatscount = 0;
				for MtlID= 1 to TheObj.Material.MaterialList.Count do
				(
				  if TheObj.Material.MaterialList[MtlID] != undefined do  		
					if (isMataDecal  TheObj.Material.MaterialList[MtlID])	do 	
						DecalMatscount = DecalMatscount + 1		
				)
				Ratio = DecalMatscount/TheObj.Material.MaterialList.Count as float
				if (Ratio > 0.75) then isDecalByMats = true 
				else if (Ratio > 0.49) do isDecalMaybe = true
				--print(TheObj.name + ":" + Ratio as string)
			)
		

			if isDecalByName or isDecalByMats do append DecalObjs TheObj
		

			--if isDecalByName do print("ByName: " + TheObj.name)
			--if isDecalByMats do print("ByMaterial: " + TheObj.name)
			if isDecalMaybe do print("Maybe: " + TheObj.name)
		)
		DecalObjs
	),

	fn ChangeFlagsInIde Ide theObjs newFlag = 
	(
		for TheObj in theObjs do 
		(	
			for Item in Ide.objs do 
			(
				if matchpattern Item.name pattern:TheObj.name  do Item.Flag = newFlag
			)

			for Item in Ide.tobjs do 
			(
				if matchpattern Item.name pattern:TheObj.name  do Item.Flag = newFlag
			)
		) 
		Ide
	),

	fn SetAlphaFlags IdePath=  -- tries to find models wihich could be decals and writes that flag to the ide
	(
		TheIde = btlc_SA_IDE() 
		TheIde.thePath = IdePath  

		TheIde.Load()
		Myobjlist = #()
		for aModel in objects where aModel.parent == undefined do append Myobjlist aModel
		Decalobjs = findDecalsObjs Myobjlist
		print Decalobjs.count
		TheIde = ChangeFlagsInIde TheIde Decalobjs 132
		TheIde.thePath = TheIde.thePath + ".test"
		TheIde.Save() -- Overwrites the original .ide later
	)

)
btlcIDEUtils = btlc_IDETools()