struct Btlc_2dEffect 
(   
	inipath = "",

	fn Init = 
	(
		scriptPath = (GetDir #userScripts )
		inipath = scriptPath + "\\data\\saparticle.ini"
	),

	fn SetupLightAttr obj = 
	(
		if superclassof(obj) == light then
		(
			--add 2dfx light info
			fxinfo = attributes fxdata_light
			(
				parameters main rollout:params
				(
					sdfxdrawdis type:#float ui:spn_drawdis default:100
					sdfxouterrange type:#float ui:spn_outrng default:0
					sdfxsize type:#float ui:spn_size default:0 --align:#right
					sdfxinnerrange type:#float ui:spn_inrng default:0
					sdfx_corona type:#string ui:edit_corona --default:0
					sdfx_shad type:#string ui:edit_shad --default:0
					sdfx_lighttype type:#integer ui:spn_type default:1
					sdfx_color4 type:#integer default:200 --default should be 200
				)
				
				rollout params "SA Light" width:160 height:400
				(
					spinner spn_drawdis "" pos:[88,4] width:64 height:16 range:[0,300,0]
					spinner spn_outrng "" pos:[88,64] width:64 height:16 range:[0,300,0]
					spinner spn_size "" pos:[88,24] width:64 height:16 range:[0,300,0]
					spinner spn_inrng "" pos:[88,44] width:64 height:16 range:[0,300,0]
					edittext edit_corona "" pos:[64,104] width:89 height:16 --enabled:false
					edittext edit_shad "" pos:[64,124] width:89 height:16 --enabled:false
					label lbl5 "Draw Distance" pos:[8,8] width:76 height:12
					label lbl6 "Outer Range" pos:[8,68] width:76 height:12
					label lbl7 "Size" pos:[8,27] width:76 height:12
					label lbl8 "Inner Range" pos:[8,48] width:76 height:12
					label lbl9 "Corona" pos:[8,104] width:48 height:12
					label lbl10 "Shad" pos:[8,124] width:48 height:12
					label lbl11 "Light Type" pos:[8,88] width:80 height:16
					spinner spn_type "" pos:[88,84] width:64 height:16 range:[0,300,0] type:#integer scale:1 enabled:false
				)
				
			)--end custom attribute
			
			
			custAttributes.add obj fxinfo --add the new set of data
			--obj.sdfxent = 1 --initialize attributes
			obj.sdfxdrawdis = 100.0
			obj.sdfxouterrange = 1.0
			obj.sdfxsize = 1.0
			obj.sdfxinnerrange = 1.0
			obj.sdfx_corona = "coronastar"
			obj.sdfx_shad = "shad_exp"
			obj.sdfx_lighttype = 1						
			--print any info
			format "Added GTA Light info to %\n" obj.name			
		)
	),

	fn SetupParticleAttr obj=
	(
		--restrict object type to Dummy, not any type of helper obj
		if classof(obj) == Dummy then
		(
			--print obj.name
			--add 2dfx particle info				
			fxinfop = attributes fxdata_particle
			(
				parameters main rollout:params
				(
					sdfx_psys type:#string ui:edit_psys --default:0
				)--end parameters
				
				rollout params "SA Particle" width:160 height:400
				(
					edittext edit_psys "" pos:[48,4] width:109 height:16 --enabled:false
					label lbl10 "System" pos:[4,4] width:36 height:12
				)					
			)--end fxdata_particle
			(
				custAttributes.add obj fxinfop --add the new set of data
				--obj.sdfx_psys = "default"
				temppsys = getINISetting inipath "lastpsys" "system" as integer
				obj.sdfx_psys = fx_psystems[temppsys] as string
				--print any info
				format "Added GTA Particle system info to %\n" obj.name
			)
			
		)--end classcheck

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

	)
)