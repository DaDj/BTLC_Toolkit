fileIn "RW_Material.ms"

struct Btlc_Effect2D
(
	fx_numimages,
	fx_numpsystems,
 	fx_images = #(),
 	fx_psystems = #(),

	fn LoadIni = 
	(
		scriptPath = (GetDir #userScripts )
		inipath = scriptPath + "\\BTLC\\data\\saparticle.ini"
		inisetup = "particlesetup"
		--load the 2dfx info from the ini file, read ini string, to tell how many textures to be loaded
		gettexcount = getINISetting inipath inisetup "numtextures"
		getpsysount = getINISetting inipath inisetup "numparticlesys"
		numimages = gettexcount as integer
		numpsys = getpsysount as integer
		imgstring = "texture" --look for this string, the number will be appended automatically.
		psysstring = "psys"
		initexname = "texturenames"
		inipssytems = "particlesystems"
		
		--read texturename and add to array, then increment. repeat until reached limit defined above
		for texcounter=1 to numimages do
		(
			imagename = imgstring + (texcounter as string)
			texname = getINISetting inipath initexname imagename
			append fx_images texname
		--	format "Read particle texture %: %\n" texcounter texname
			texcounter=texcounter+1
		)
		--...and do it again, for particle systems
		for pcounter=1 to numpsys do
		(
			imagename = psysstring + (pcounter as string)
			parname = getINISetting inipath inipssytems imagename
			append fx_psystems parname
		--	format "Read particle system %: %\n" pcounter parname
			pcounter=pcounter+1
		)
	),

	
	fn write2dfxLight f light = (
		pad=1
		if (light.enLookDirection) then pad+=1
		writeColor f (light.color) 200
		writeFloat f light.coronaFarClip
		writeFloat f light.pointlightRange
		writeFloat f light.coronaSize
		writeFloat f light.shadowSize
		writeByteIndex f light.coronaShowMode
		refl=0
		if light.coronaEnableReflection then refl=1
		writeByte f refl
		writeByteIndex f light.coronaFlareType
		writeByte f light.shadowColorMultiplier
		writeByte f (bitMask #(light.CHECK_OBSTACLES, light.FOG_TYPE, light.FOG_TYPE2, light.WITHOUT_CORONA, light.CORONALONG_DISTANCE, light.AT_DAY, light.AT_NIGHT, light.BLINKING1))
		writeLimitedString f light.coronaTexName 24
		writeLimitedString f light.shadowTexName 24
		writeByte f light.shadowZDistance
		writeByte f (bitMask #(light.CORONA_ONLY_FROM_BELOW, light.BLINKING2, light.UDPDATE_HEIGHT, light.CHECK_DIRECTION, light.BLINKING3))
		if (light.enLookDirection) then (
			writeByte f light.lookDirection_x
			writeByte f light.lookDirection_y
			writeByte f light.lookDirection_z
		)
		writePadding f pad
	),

	fn write2dfx f effects = (
		--start=writeHeader f 39056120 0x1803FFFF
		writeLong f effects.count
		for e in effects do (
			pos=(in coordsys parent e.position)
			writeVertex f pos
			type=e.dfxType
			writeLong f type
			writeLong f (e.getSize())
			case type of (
				0: write2dfxLight f e
				1: writeLimitedString f e.effectName 24 --Particles
				7: write2dfxSign f e
				8: writeLong f e.index -- trigger point
				10: write2dfxEscalator f e pos
			)
		)
		--rewriteSectionSize f start
	)
)

btlcEffect2D = Btlc_Effect2D()
btlcEffect2D.LoadIni()


plugin light GTA_OmniLight
name:"GTA OmniLight"
classID:#(0x6b8c0112, 0x56eb092d)
extends:freespot
category:"GTA 2dfx"
replaceUI:false
(
	parameters main rollout:params
	(
		coronaFarClip  type:#float ui:spcoronaFarClip default:120
		pointlightRange type:#float ui:sppointlightRange default:8
		coronaSize  type:#float ui:spcoronaSize default:0.5
		shadowSize  type:#float ui:spshadowSize default:12
		coronaShowMode  type:#integer ui:spcoronaShowMode default:0
		coronaEnableReflection  type:#integer ui:spcoronaEnableReflection default:1
		coronaFlareType  type:#float ui:spcoronaFlareType default:1
		shadowColorMultiplier	type:#integer default:40 ui:mul

		CHECK_OBSTACLES type:#boolean default:true ui:chCORONA_CHECK_OBSTACLE --CORONA_CHECK_OBSTACLES
		FOG_TYPE type:#boolean default:false ui:chFOG_TYPE --FOG_TYPE1
		FOG_TYPE2 type:#boolean default:false ui:chFOG_TYPE2 --FOG_TYPE2
		WITHOUT_CORONA type:#boolean default:false ui:chWITHOUT_CORONA --WITHOUT_CORONA
		CORONALONG_DISTANCE type:#boolean default:false ui:chCORONALONG_DISTANCE --CORONA_ONLY_AT_LONG_DISTANCE
		AT_DAY type:#boolean default:false ui:chAT_DAY --AT_DAY
		AT_NIGHT type:#boolean default:true ui:chAT_NIGHT --AT_NIGHT
		BLINKING1 type:#boolean default:false ui:chBLINKING1 --BLINKING1 

		coronaTexName type:#string default:"coronastar" ui:spcoronaTexName
		shadowTexName type:#string default:"shad_exp" ui:spshadowTexName

		shadowZDistance	type:#integer default:0 ui:spDistance

		CORONA_ONLY_FROM_BELOW type:#boolean default:false ui:chCORONA_FROM_BELOW --CORONA_ONLY_FROM_BELOW
		BLINKING2 type:#boolean default:false ui:chBLINKING2 --BLINKING2
		UDPDATE_HEIGHT type:#boolean default:true ui:chUDPDATE_HEIGHTGROUND --UDPDATE_HEIGHT_ABOVE_GROUND
		CHECK_DIRECTION type:#boolean default:false ui:chCHECK_DIRECTION--CHECK_DIRECTION
		BLINKING3 type:#boolean default:false ui:chBLINKING3 --BLINKING3

		enLookDirection type:#boolean default:false ui:en
		lookDirection_x	type:#integer default:0 ui:x
		lookDirection_y	type:#integer default:0 ui:y
		lookDirection_z	type:#integer default:0 ui:z

		dfxType	type:#integer default:0
	)
	
	rollout params "GTA Light Parameters"
	(
		spinner spcoronaFarClip "coronaFarClip" type: #float fieldwidth:30
		spinner sppointlightRange "pointlightRange" type: #float fieldwidth:30
		spinner spcoronaSize "coronaSize" type: #float fieldwidth:30
		spinner spshadowSize "shadowSize" type: #float fieldwidth:30
		spinner	mul	  "Shadowcolor mult" fieldwidth:30 type:#integer range:[0,255,40]
		
		spinner spcoronaFlareType "coronaFlareType" type: #integer range:[0,1,0] fieldwidth:30
		spinner spDistance "shadowZDistance" type: #float fieldwidth:30
		dropdownlist spcoronaTexName "coronaTexName" selection:25 items:btlcEffect2D.fx_images
		dropdownlist spshadowTexName "shadowTexName" selection:11 items:btlcEffect2D.fx_images

		dropdownlist spcoronaShowMode "coronaShowMode" \ 
		items:#("DEFAULT","RANDOM_FLASHING","RANDOM_FLASHIN_ALWAYS_AT_WET_WEATHER", \
		"LIGHTS_ANIM_SPEED_4X","LIGHTS_ANIM_SPEED_2X","LIGHTS_ANIM_SPEED_1X", \
		"not supported","TRAFFICLIGHT","TRAINCROSSLIGHT", \ 
		"not supported", "AT_RAIN_ONLY", "BlINK_5S", "BlINK_6SON_4SOFF","BlINK_6SON_4SOFF" )

		checkbox  spcoronaEnableReflection "coronaEnableReflection"
		group "Flags1" 
		(
			checkbox  chCORONA_CHECK_OBSTACLE "CHECK_OBSTACLES" tooltip:"CORONA_CHECK_OBSTACLES"
			checkbox  chFOG_TYPE "FOG_TYPE" tooltip:"FOG_TYPE"
			checkbox  chFOG_TYPE2 "FOG_TYPE2" tooltip:"Also just a FOG_TYPE"
			checkbox  chWITHOUT_CORONA "WITHOUT_CORONA" tooltip:"Don't display Corona"
			checkbox  chCORONALONG_DISTANCE "ONLY_LONG_DISTANCE" tooltip:"CORONA_ONLY_AT_LONG_DISTANCE"
			checkbox  chAT_DAY "AT_DAY" tooltip:"AT_DAY"
			checkbox  chAT_NIGHT "AT_NIGHT" tooltip:"AT_NIGHT"
			checkbox  chBLINKING1 "BLINKING1" tooltip:"BLINKING1"
		)

		group "Flags2" 
		(
			checkbox  chCORONA_FROM_BELOW "ONLY_FROM_BELOW" tooltip:"CORONA_ONLY_FROM_BELOW"
			checkbox  chBLINKING2 "BLINKING2" tooltip:"BLINKING2"
			checkbox  chUDPDATE_HEIGHTGROUND "UDPDATE_HEIGHT" tooltip:"UDPDATE_HEIGHT_ABOVE_GROUND "
			checkbox  chCHECK_DIRECTION "CHECK_DIRECTION" tooltip:"CHECK_DIRECTION"
			checkbox  chBLINKING3 "BLINKING3" tooltip:"BLINKING3"
		)
		
		group "Look direction" (
			checkbox en "Enable"
			spinner	x "X" fieldwidth:30 type:#integer range:[-128,127,0] 
			spinner	y "Y" fieldwidth:30 type:#integer range:[-128,127,0] 
			spinner	z "Z" fieldwidth:30 type:#integer range:[-128,127,0] 
		)
		on params open do 
		(
			spcoronaShowMode.selection = coronaEnableReflection 
			spcoronaTexName.selection = finditem btlcEffect2D.fx_images coronaTexName
			spshadowTexName.selection = finditem btlcEffect2D.fx_images shadowTexName
		)

		on spcoronaTexName selected i do
		(
			coronaTexName = btlcEffect2D.fx_images[i] as string			
		)

		on spshadowTexName selected i do
		(
			shadowTexName = btlcEffect2D.fx_images[i] as string
		)		

	)

	fn getSize= (
		if enLookDirection then return 80
		return 76
	)
	
	tool create
	(
		on mousePoint click do
		(
			nodeTM.translation = gridPoint;#stop
		)
	)
	

)



