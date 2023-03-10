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
	)
)

btlcEffect2D = Btlc_Effect2D()
btlcEffect2D.LoadIni()


Btlc_2dfxLight =  attributes "Effect2d_Light"  attribID:#(0x4b285f86, 0x18daf1df)
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
	)
	
	rollout params "GTA Light Parameters"
	(
		spinner spcoronaFarClip "coronaFarClip" type: #float
		spinner sppointlightRange "pointlightRange" type: #float
		spinner spcoronaSize "coronaSize" type: #float
		spinner spshadowSize "shadowSize" type: #float
		
		spinner spcoronaFlareType "coronaFlareType" type: #integer range:[0,1,0]
		spinner spDistance "shadowZDistance" type: #float
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
)



struct Btlc_2dEffect 
(   
	inipath = "",

	fn Init = 
	(
		scriptPath = (GetDir #userScripts )
		inipath = scriptPath + "\\data\\saparticle.ini"
	),
	fn IsEffect obj = 
	(
		Is2dfx = false;
		--make sure only appropriate objects are selected, and that they have parameters to export
		if superclassof(obj) == light then
		(
			numattribs = custAttributes.count obj --count em up!
			if numattribs != 0 then --more than 0!
			(
				for a=1 to numattribs do
				(
					--check the attribute type
					custAttributes.get obj a
					attribtype = (custAttributes.getDef obj a).name
					if attribtype != undefined then --it HAS to have a name!
					(
						if attribtype == #fxdata_light then   Is2dfx = true;
					)--end undefined attribtype name (attributes added with paramter editor)
				)--end for
			)--end if
		)
		else
		if classof(obj) == Dummy then
		(
			numattribs = custAttributes.count obj --count em up!
			if numattribs != 0 then --more than 0!
			(
				for a=1 to numattribs do
				(
					--check the attribute type
					custAttributes.get obj a
					attribtype = (custAttributes.getDef obj a).name
					if attribtype != undefined then --it HAS to have a name!
					(
						if attribtype == #fxdata_particle then   Is2dfx = true;	
					)--end undefined attribtype name (attributes added with paramter editor)
				)--end for
			)--end if
		)

	),

	fn GetforObject Theobj  = 
	(
		objtoexp = #()
		for obj in Theobj.children do 
		(
			if  IsEffect obj == true then append objtoexp obj
		)
		objtoexp
	),
	
	fn Exportsection TheSec Filename =  
	(
		--effect types
		local effectlight = 0x00 --light info
		local effectparticle = 0x01 --particle system name
		--0x02 n/a
		local effectcard = 0x03 --for playing cards? also photo op places?
		--0x04 n/a
		--0x05 n/a
		local effect_6 = 0x06 --unknown
		local effecttext = 0x07 --2d sign text
		local effect_8 = 0x08 --used by slot machine wheels/scripted objects?
		local effect_9 = 0x09 --unknown, used alot (carter-column, stadium_sfse)
		local effectescalator = 0x0a --seems to be used only on escalators
		
		--objects have been collected, time to start the export process
		effectstream=fopen Filename "wb"
		--write file header info here
		writelong effectstream TheSec.count

		for obj in TheSec do
		(
			--print obj.name
			--determine object type, to know which info to write
			if superclassof(obj) == light then
			(
				--gather light info
				--declare data size for later use
				datsize = 0
				local tex1 = obj.sdfx_corona
				local tex2 = obj.sdfx_shad
				--determine light type
				local lightparam1
				local lightparam2
				local lightparam3
				(
					--format "Light Type: % \n" obj.sdfx_lighttype
					--do as a for loop
					--for light=1 to num light types
					for light = 1 to lightcount do
					(
						if obj.sdfx_lighttype == light then
						(
							--0 = mlampost
							lightparam1 = (getINISetting inipath lighttypes ("type" + (light as string) + "_param1")) as integer
							lightparam2 = (getINISetting inipath lighttypes ("type" + (light as string) + "_param2")) as integer
							lightparam3 = (getINISetting inipath lighttypes ("type" + (light as string) + "_param3")) as integer
						)
					)
				)
				--position
				posx = in coordsys parent obj.pos.x
				posy = in coordsys parent obj.pos.y
				posz = in coordsys parent obj.pos.z
				--colour
				lightred=obj.rgb.r
				lightgreen=obj.rgb.g
				lightblue=obj.rgb.b
				lightcolx = obj.sdfx_color4
				datsize = datsize + 4
				--draw dist, size, etc
				drawdist = obj.sdfxdrawdis
				outerrange = obj.sdfxouterrange
				lightsize = obj.sdfxsize
				innerrange = obj.sdfxinnerrange
				lightparam1 = lightparam1--light1
				lightparam2 = lightparam2 --light2
				datsize = datsize + 21
				--image1
				datsize = datsize + (tex1.count)
				padding = 13 --write 14 bytes, subtract one byte for text
				datsize = datsize + 14
				--image2
				datsize = datsize + (tex2.count)
				padding2 = 14 --write 15 bytes, subtract one byte for text
				datsize = datsize + 19
				lightparam3 = lightparam3 --light2
				datsize = datsize + 4
				
				--write light info
				writefloat effectstream posx
				writefloat effectstream posy
				writefloat effectstream posz
				writelong effectstream effectlight
				writelong effectstream datsize
				datsizepos = ftell effectstream
				--write light data
				writebyte effectstream lightred
				writebyte effectstream lightgreen
				writebyte effectstream lightblue
				writebyte effectstream lightcolx
				writefloat effectstream drawdist
				writefloat effectstream outerrange
				writefloat effectstream lightsize
				writefloat effectstream innerrange
				writelong effectstream lightparam1
				writebyte effectstream lightparam2
				writestring effectstream tex1
				for pad1=1 to padding do
				(
					writebyte effectstream 0
				)
				writestring effectstream tex2
				for pad2=1 to padding2 do
				(
					writebyte effectstream 0
				)
				writelong effectstream lightparam3
				writelong effectstream 25600
				
				format "Exported GTA light info on %\n" obj.name
			)
			else
			if classof(obj) == Dummy then
			(
				--get type info, need to determine what attributes are on dummy
				numattribs = custAttributes.count obj --count em up!
				if numattribs != 0 then --more than 0!
				(
					for a=1 to numattribs do
					(
						--check the attribute type
						custAttributes.get obj a
						attribtype = (custAttributes.getDef obj a).name
						if attribtype != undefined then --it HAS to have a name!
						(
							if attribtype == #fxdata_particle then
							(
								--append objtoexp obj
								--position
								posx = in coordsys parent obj.pos.x
								posy = in coordsys parent obj.pos.y
								posz = in coordsys parent obj.pos.z
								datsize = 0 --zero it to clear size data from last object
								--string info
								pstring = obj.sdfx_psys
								datsize = obj.sdfx_psys.count
								--datsize = datsize + pstring.count --string + terminator + garbage data is max 24 characters in length
								--garbage
								garbagesize = 24 - datsize
								--write particle info
								--write light info
								writefloat effectstream posx
								writefloat effectstream posy
								writefloat effectstream posz
								writelong effectstream effectparticle
								--writelong effectstream datsize
								writelong effectstream 24 --fixed size, don't do any more work than necessary?
								datsizepos = ftell effectstream
								writestring effectstream pstring --is also writing terminating 00
								for a=1 to (garbagesize - 1) do
								(
									writebyte effectstream 00
								)
								format "Exported GTA Particle info on %\n" obj.name
							)
						)--end undefined attribtype name (attributes added with paramter editor)
					)--end for
				)
			)
			fclose effectstream
		)
	),

	fn ExportModel obj Dirname = 
	(
		Obj_Effectsection  =  GetforObject obj
	),

	fn Exportall DirName = 
	(

	),

	fn dfxRollout = 
	(

	)
)