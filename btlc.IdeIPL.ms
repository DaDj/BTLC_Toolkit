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
		TheIde.thePath = TheIde.thePath 
		TheIde.Save() -- Overwrites the original .ide later
	),

	fn WriteDynObjData  idePath:undefined = --finds dynamic objectdata and writes them in correct format to listener
	(
		Myobjlist = #()
		for aModel in objects where aModel.parent == undefined do append Myobjlist aModel

		for theobj in Myobjlist do 
		(
			if 	(custattributes.get theobj gtaDynObject != undefined) do 
			(
				ObjDat = (custattributes.get theobj gtaDynObject)
				format "%, %, %, %, %, %, %, %, %, %, %, %, %, %, %, %, %, %, %, %, %, %, %, % \n" \
				theobj.name ObjDat.Mass ObjDat.TurnMass ObjDat.AirResistance ObjDat.Elasticity ObjDat.PercSubmerged ObjDat.Uproot \
				ObjDat.CDMult ObjDat.CDEff ObjDat.SpCDR ObjDat.CamAv ObjDat.Expl ObjDat.FX_TYPE \
				ObjDat.FX_OFFSETx ObjDat.FX_OFFSETy ObjDat.FX_OFFSETz ObjDat.FX_NAME \
				ObjDat.B_SM ObjDat.B_VX ObjDat.B_VY ObjDat.B_VZ ObjDat.B_VR ObjDat.B_GUN ObjDat.B_SPK 
			)
		)
		format "\n"

		if idePath != undefined do 
		(
			TheIde = btlc_SA_IDE() 
			TheIde.thePath = idePath  
			TheIde.Load()
	
			for theobj in Myobjlist do 
			(
				if 	(custattributes.get theobj gtaDynObject != undefined) do 
				(
					for Item in TheIde.objs do 
					(
						if matchpattern Item.name pattern:theobj.name  do 
						(
							ObjDat = (custattributes.get theobj gtaDynObject)
							format "%, %, %, %, %, % \n" (Item.Id as string) Item.Name ObjDat.MassPType  ObjDat.MassPx ObjDat.MassPy	ObjDat.MassPz	
						)
					)
				
				)
			)
		)
	)

)
btlcIDEUtils = btlc_IDETools()



if gtaDynObject==undefined then(

	global gtaDynObject = attributes "DynObject" attribID:#(0x59d1c458, 0xd290803)
	(
		parameters main rollout:params
		(

			Mass type:#Float  default:100.0 ui:spin_Mass
			TurnMass type:#Float  default:150.0 ui:spin_TurnMass
			AirResistance type:#Float  default:0.99 ui:spinAirRes
			Elasticity type:#Float  default:0.03 ui:spinElas
			PercSubmerged type:#Float  default:50.0 ui:spinPerSubmrgd
			Uproot type:#Float  default:20.0 ui:spinUproot
			CDMult type:#Float  default:2.0 ui:spinCdMult
			CDEff type:#Integer  default:0 ui:spinEff -- 0: none, 1:changemdl , 20:smash , 21: changthensmash , 200:breakable, 202:breakable ansd remove forever
			SpCDR type:#Integer  default:0 ui:spinSpCDR-- 0: none, 1: lampost, 2:smallbox, 3: bigbox, 4:fencepart,5:grenade,6:swingdoor,7:Lockdoor, 8:Hanging, 9:ob_col_poolball
			CamAv type:#Integer  default:1 ui:chbCAv
			Expl type:#Integer  default:0 ui:chbExpl
			FX_TYPE type:#Integer  default:0 ui:spinFxSysType -- 0 - no FxSystem, 1 - play when hit, 2 - play when destroyed, 3 - play when hit or destroyed
			FX_OFFSETx type:#Float  default:0.0 ui:spinOffsx
			FX_OFFSETy type:#Float  default:0.0 ui:spinOffsy
			FX_OFFSETz type:#Float  default:0.0 ui:spinOffsz
			FX_NAME type:#string  default:"none" ui:edtxtFxNAme
			B_SM type:#Float  default:100.0 ui:spinSmshMult--if set to 2.0 then it will take twice the force to smash as opposed to break an object (1.0 - smash only - never break, set very large if it only breaks and never smashes)
			B_VX type:#Float  default:0.0 ui:spinbrkVelX
			B_VY type:#Float  default:0.0 ui:spinbrkVelY
			B_VZ type:#Float  default:0.1 ui:spinbrkVelZ
			B_VR type:#Float  default:0.07 ui:spinbrkVelRand
			B_GUN type:#Integer  default:0 ui:spinGunBrkM
			B_SPK type:#Integer  default:1 ui:chbSprk
			MassPType  type:#Integer  default:1 ui:spinMassp
			MassPx	type:#Float  default:0.0  ui:spinMasspCx
			MassPy	type:#Float  default:0.0  ui:spinMasspCy
			MassPz	type:#Float  default:0.0  ui:spinMasspCz
		)
		rollout params "GTA Dynamic Object"
		(
			spinner spin_Mass "Mass" range:[0.0,10000.0,100.0] tooltip:"1 to 50000 inclusive. Unit is kilograms."
			spinner spin_TurnMass "Turn Mass" range:[0.0,10000.0,150.0] tooltip:".. "
			spinner spinAirRes "Air Resistance" range:[0.0,1.0,0.99] tooltip:"Normalised  0 = complete air resistance, 1 = no air resistance."
			spinner spinElas "Elasticity" range:[0.0,1.0,0.03] tooltip:"Bounciness. Normalised. 0 is least bouncy, 1 is the most."
			spinner spinPerSubmrgd "PercSubmerged" range:[0.0,120,50.0] tooltip:"10 to 120. Most objects have a value of 50.0 for this attribute."
			spinner spinUproot "Uproot" range:[0.0,5000,20.0] tooltip:"force magnitude required to uproot"
			spinner spinCdMult "CDMult" range:[0.0,10.0,2.0] tooltip:"how much damage a collision should do to vehicles. 0.1 - 5.0 ish according to the file."
			spinner spinEff "CDEff" range:[0,202,0] enabled:false type:#integer
			dropDownList ddlEffect "CDEff" items:#("0: none", "1:changemdl ", "20:smash ", "21: changthensmash ", "200:breakable", "202:breakable and remove forever") 
			on ddlEffect selected TheEff do 
			(
				if TheEff == 1 do CDEff = 0
				if TheEff == 2 do CDEff = 1
				if TheEff == 3 do CDEff = 20
				if TheEff == 4 do CDEff = 21
				if TheEff == 5 do CDEff = 200
				if TheEff == 6 do CDEff = 202
			) 
			spinner spinSpCDR "Special Response" range:[0,10,0] enabled:false type:#integer
			dropDownList ddlSpCDR "Special Response" items:#("0: none", "1: lampost", "2:smallbox", "3: bigbox", "4:fencepart","5:grenade","6:swingdoor","7:Lockdoor", "8:Hanging", "9:ob_col_poolball") 
			on ddlSpCDR selected TheResp do 
			(
				if TheResp == 1 do SpCDR = 0
				if TheResp == 2 do SpCDR = 1
				if TheResp == 3 do SpCDR = 2
				if TheResp == 4 do SpCDR = 3
				if TheResp == 5 do SpCDR = 4
				if TheResp == 6 do SpCDR = 5
				if TheResp == 7 do SpCDR = 6
				if TheResp == 8 do SpCDR = 7
				if TheResp == 9 do SpCDR = 8
				if TheResp == 10 do SpCDR = 9
			) 
			checkbox chbCAv "Cam avoid Obj" type:#boolean
			checkbox chbExpl "Cause Explosion" type:#boolean

			group "Fx System"
			( 
				spinner spinFxSysType "Fx Type" range:[0,202,0] enabled:false type:#integer
				dropDownList ddlFXType "Fx Type" items:#(" 0 - no FxSystem", "1 - play when hit", "2 - play when destroyed", "3 - play when hit or destroyed") 
				on ddlFXType selected TheEff do 
				(
					if TheEff == 1 do FX_TYPE = 0
					if TheEff == 2 do FX_TYPE = 1
					if TheEff == 3 do FX_TYPE = 2
					if TheEff == 4 do FX_TYPE = 3
				) 
				spinner spinOffsx "Fx Offset x" range:[0,1000,0]  type:#float
				spinner spinOffsy "Fx Offset y" range:[0,1000,0]  type:#float
				spinner spinOffsz "Fx Offset z" range:[0,1000,0]  type:#float

				edittext edtxtFxNAme "Fx Name" 
			)

			group "Breakable"
			(
				spinner spinSmshMult "Smash Mult" range:[0.0,10000.0,100.0] 
				spinner spinbrkVelx "Break Vel. X" range:[0.0,10000.0,0.0]
				spinner spinbrkVely "Break Vel. Y" range:[0.0,10000.0,0.0]  
				spinner spinbrkVelZ "Break Vel. Z" range:[0.0,10000.0,0.1]  
				spinner spinbrkVelRand "Break Vel. Rand" range:[0.0,10000.0,0.07]  

				spinner spinGunBrkM "GunBrkMode" range:[0,202,0] enabled:false type:#integer
				dropDownList ddlGunBrkM "GunBrkMode" items:#(" 0 - Immune to Gun", "1 - Breakable", "2 - Smashable") 
				on ddlGunBrkM selected TheEff do 
				(
					if TheEff == 1 do B_GUN = 0
					if TheEff == 2 do B_GUN = 1
					if TheEff == 3 do B_GUN = 2
				) 

				checkbox chbSprk "Sparks on impact" type:#boolean
			)

			group "Custom Masspoint"
			(
				spinner spinMassp "MassPoint" range:[0,3,0] enabled:false type:#integer
				dropDownList ddlMassp "MassPoint" items:#(" 0 - Pivot", "1 - Middle", "2 - Custom")  selection:2
				on ddlMassp selected TheEff do 
				( 
					if TheEff == 1 do MassPType = 0
					if TheEff == 2 do MassPType = 1
					if TheEff == 3 do MassPType = 2
				) 
				label mylabl "Type 3 coords:"
				spinner spinMasspCx "Custom X" range:[0.0,10000.0,0.0]
				spinner spinMasspCy "Custom Y" range:[0.0,10000.0,0.0]  
				spinner spinMasspCz "Custom Z" range:[0.0,10000.0,0.1]  

			)

			hyperlink btnhelp "Help/Info" address:"https://gtamods.com/wiki/Object.dat"

			
			
		)
	)
	
	)