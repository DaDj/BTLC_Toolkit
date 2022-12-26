-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- dev-c.com, openiv.com

-- Description: rollout in the Utilities panel
-- Last changed: Jan 2015

global ofgui

-- if main gui rollout already exists then it must be deleted
if ofgui != undefined then
(
	-- in order to delete anything from Utilities panel the panel must be active itself
	ofutils.openUtilities()	
	try (removeRollout ofgui) catch ()
)
	
-- create new rollout 
rollout ofgui "OPEN FORMATS I/O" 
(
	------------------- GTA IV FRAGMENTS ---------------------
	
	group " \\ FRAGMENTS \\ OFT " 
	(
		button btn_IV_FT_Import "Import Single" width:120 align:#center
		button btn_IV_FT_Export "Export Single" width:120 align:#center
		label margin_IV_FT "" height:0 
	)	
	
	on btn_IV_FT_Import pressed do
	(
		local input_oft_file_name = getOpenFileName caption:"Select GTA IV *.oft file" types:"gta iv open formats fragments (*.oft)|*oft"
		if (input_oft_file_name != undefined) and (getFileSize input_oft_file_name) > 0 then
		(
			with undo off
			(
				with redraw off
				(
					local oft = ofio_iv_oft()
				--ofioLog.start()
					try ( 
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						oft.read(input_oft_file_name)
						ofioLog.print "building"
						print "read oft success"
						oft.build()
						ofioLog.print ("oft import succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						gc()
					) catch
					(
						ofutils.showException()
						oft.cleanup()
						ofioLog.print "IMPORT ERROR !"
					)
					--ofioLog.finish()
					oft = undefined
				)
			)			
		)		
	)	
	
	on btn_IV_FT_Export pressed do
	(
		local oft = ofio_iv_oft()
		local fname 
		try (
			if selection.count != 1 then 
				throw ("SELECTION ERROR\n\n" + "In order to export single oft you must select oft descriptor scene object (ft_*)\n")
			fname = oft.filename_from_scenename selection[1].name
		) catch
		(
			ofutils.showException()
			oft = undefined
			return OK
		)
		local pathOut = getSavePath caption:("Select directory for exporting '" + fname + "'.")					
		if pathOut != undefined then
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					ofioLog.print ("dumping " + selection[1].name)
					oft.dump(selection[1])
					ofioLog.print ("writing " + fname)
					oft.write(pathOut + "\\" + fname)
					ofioLog.print ("oft export succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					gc()
				) catch
				(
					ofutils.showException()
					ofioLog.print "EXPORT ERROR !"
				)
				oft.clean_globals()
				ofioLog.finish()
			)
		)
		oft = undefined
	)		

	------------------- GTA IV DRAWABLES ---------------------

	group " \\ DRAWABLE \\ ODR " 
	(
		button btn_IV_DR_Import "Import Single" width:120 align:#center
		button btn_IV_DR_Export "Export Single" width:120 align:#center
		button btn_IV_DR_ExportAll "Export All" width:120 align:#center		
		label margin_IV_DR "" height:0 
	)	
	
	on btn_IV_DR_Import pressed do
	(
		local input_odr_file_name = getOpenFileName caption:"Select GTA IV *.odr file" types:"gta iv open formats drawable (*.odr)|*odr"
		if (input_odr_file_name != undefined) and (getFileSize input_odr_file_name) > 0 then
		(
			with undo off
			(
				with redraw off
				(
					local dr = ofio_iv_odr()
				--	ofioLog.start()
					try ( 
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						dr.read(input_odr_file_name)
						dr.TexDir  = @"F:\Modding\BTLC\02_GameData\IV\data\maps\manhat\manhat01\wtd\"
						ofioLog.print "building"
						dr.build()
						ofioLog.print ("odr import succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						gc()
					) catch
					(
						ofutils.showException()
						dr.cleanup()
						ofioLog.print "IMPORT ERROR !"
					)
					--ofioLog.finish()
					dr = undefined
				)
			)			
		)		
	)	
	
	on btn_IV_DR_Export pressed do
	(
		local dr = ofio_iv_odr()
		local fname 
		try (
			if selection.count != 1 then 
				throw ("SELECTION ERROR\n\n" + "In order to export single odr you must select odr descriptor scene object (dr_*)\n")
			fname = dr.filename_from_scenename selection[1].name
		) catch
		(
			ofutils.showException()
			dr = undefined
			return OK
		)
		local pathOut = getSavePath caption:("Select directory for exporting '" + fname + "'.")					
		if pathOut != undefined then
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					ofioLog.print ("dumping " + selection[1].name)
					dr.dump(selection[1])
					ofioLog.print ("writing " + fname)
					dr.write(pathOut + "\\" + fname)
					ofioLog.print ("odr export succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					gc()
				) catch
				(
					ofutils.showException()
					ofioLog.print "EXPORT ERROR !"
				)
				ofioLog.finish()
			)
		)
		dr = undefined
	)	
	
	on btn_IV_DR_ExportAll pressed do
	(
		local names = #()
		local objs = #()
		local dr = ofio_iv_odr()
		try (
			local obj, fname			
			for obj in objects do
			(
				try (
					fname = dr.filename_from_scenename obj.name
					if ofutils.lowercase(getUserProp obj "type") != "drawable" then	throw ""
					if obj.parent != undefined then
						if ofutils.lowercase(getUserProp obj.parent "type") == "drawable_dictionary" then throw ""
				) catch (
					continue
				)
				append objs obj
				append names fname
			)
			if names.count == 0 then
				throw ("OBJECT ERROR\n\n" + "No odr to export.\n")
		) catch
		(
			ofutils.showException()
			dr = undefined
			return OK
		)
		dr = undefined
		
		local pathOut = getSavePath caption:("Select directory for exporting *.odr files.\n" + (names as String))					
		if pathOut != undefined then
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					local i, exported = 0
					for i = 1 to objs.count do
					(
						try (
							dr = ofio_iv_odr()
							ofioLog.print ("dumping " + objs[i].name)
							dr.dump(objs[i])
							ofioLog.print ("writing " + names[i])
							dr.write(pathOut + "\\" + names[i])
							dr = undefined
							exported += 1
						) catch
						(
							ofutils.showException()
							ofioLog.print "EXPORT ERROR !"						
						)
						ofioLog.progress (100.0 * i / objs.count)
					)
					ofioLog.print ("odr export finished, " + (exported as String) + "/" + (objs.count as String) + " succeded, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					if exported < objs.count then
						messagebox ("WARNING: NOT ALL ODR FILES ARE EXPORTED")
					gc()
				) catch
				(
					ofutils.showException()
					ofioLog.print "EXPORT ALL ERROR !"
				)
				ofioLog.finish()
			)
		)
		dr = undefined
	)	

	group " \\ DRAWABLE \\ ODD " 
	(
		button btn_IV_DD_Import "Import Single" width:120 align:#center
		button btn_IV_DD_Export "Export Single" width:120 align:#center
		label margin_IV_DD "" height:0 
	)	
	
	on btn_IV_DD_Import pressed do
	(
		local input_odd_file_name = getOpenFileName caption:"Select GTA IV *.odd file" types:"gta iv open formats drawable dict (*.odd)|*odd"
		if (input_odd_file_name != undefined) and (getFileSize input_odd_file_name) > 0 then
		(
			with undo off
			(
				with redraw off
				(
					local dd = ofio_iv_odd()
					ofioLog.start()
					try ( 
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						dd.read(input_odd_file_name)
						ofioLog.print "building"
						dd.build()
						ofioLog.print ("odd import succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						gc()
					) catch
					(
						ofutils.showException()
						dd.cleanup()
						ofioLog.print "IMPORT ERROR !"
					)
					ofioLog.finish()
					dd = undefined
				)
			)			
		)		
	)	
	
	on btn_IV_DD_Export pressed do
	(
		local dd = ofio_iv_odd()
		local fname 
		try (
			if selection.count != 1 then 
				throw ("SELECTION ERROR\n\n" + "In order to export single odd you must select odd descriptor scene object (ddict_*)\n")
			fname = dd.filename_from_scenename selection[1].name
		) catch
		(
			ofutils.showException()
			dd = undefined
			return OK
		)
		local pathOut = getSavePath caption:("Select directory for exporting '" + fname + "'.")					
		if pathOut != undefined then
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					ofioLog.print ("dumping " + selection[1].name)
					dd.dump(selection[1])
					ofioLog.print ("writing " + fname)
					dd.write(pathOut + "\\" + fname)
					ofioLog.print ("odd export succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					gc()
				) catch
				(
					ofutils.showException()
					ofioLog.print "EXPORT ERROR !"
				)
				ofioLog.finish()
			)
		)
		dd = undefined
	)		
	
	------------------- GTA IV BOUNDS ---------------------
	
	group " \\ BOUND \\ OBN " 
	(
		button btn_IV_BN_Import "Import Single" width:120 align:#center
		button btn_IV_BN_Export "Export Single" width:120 align:#center
		button btn_IV_BN_ExportAll "Export All" width:120 align:#center
		label margin_IV_BN "" height:0 
	)	
	
	on btn_IV_BN_Import pressed do
	(
		local input_obn_file_name = getOpenFileName caption:"Select GTA IV *.obn file" types:"gta iv open formats static bound (*.obn)|*obn"
		if (input_obn_file_name != undefined) and (getFileSize input_obn_file_name) > 0 then
		(
			with undo off
			(
				with redraw off
				(
					local bn = ofio_iv_obn()
					ofioLog.start()
					try ( 
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						bn.read(input_obn_file_name)
						ofioLog.print "building mesh"
						bn.build()
						ofioLog.print ("obn import succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						gc()
					) catch
					(
						ofutils.showException()
						bn.cleanup()
						ofioLog.print "IMPORT ERROR !"
					)
					ofioLog.finish()
					bn = undefined
				)
			)			
		)		
	)		
	
	on btn_IV_BN_Export pressed do
	(
		local bn = ofio_iv_obn()
		local fname 
		try (
			if selection.count != 1 then 
				throw ("SELECTION ERROR\n\n" + "In order to export single obn you must select obn descriptor scene object (bn_*)\n")
			fname = bn.filename_from_scenename selection[1].name
		) catch
		(
			ofutils.showException()
			bn = undefined
			return OK
		)
		local pathOut = getSavePath caption:("Select directory for exporting '" + fname + "'.")					
		if pathOut != undefined then
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					ofioLog.print ("dumping " + selection[1].name)
					bn.dump(selection[1])
					ofioLog.print ("writing " + fname)
					bn.write(pathOut + "\\" + fname)
					ofioLog.print ("obn export succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					gc()
				) catch
				(
					ofutils.showException()
					bn.cleanup()
					ofioLog.print "EXPORT ERROR !"
				)
				ofioLog.finish()
			)
		)
		bn = undefined
	)		
	
	on btn_IV_BN_ExportAll pressed do
	(
		local names = #()
		local objs = #()
		local bn = ofio_iv_obn()
		try (
			local obj, fname			
			for obj in objects do
			(
				try (
					fname = bn.filename_from_scenename obj.name
				) catch (
					continue
				)
				append objs obj
				append names fname
			)
			if names.count == 0 then
				throw ("OBJECT ERROR\n\n" + "No obn objects to export.\n")
		) catch
		(
			ofutils.showException()
			bn = undefined
			return OK
		)
		bn = undefined
		
		local pathOut = getSavePath caption:("Select directory for exporting *.obn files.\n" + (names as String))					
		if pathOut != undefined then
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					local i, exported = 0
					for i = 1 to objs.count do
					(
						try (
							bn = ofio_iv_obn()
							ofioLog.print ("dumping " + objs[i].name)
							bn.dump(objs[i])
							ofioLog.print ("writing " + names[i])
							bn.write(pathOut + "\\" + names[i])
							bn.cleanup()
							bn = undefined
							exported += 1
						) catch
						(
							ofutils.showException()
							bn.cleanup()
							ofioLog.print "EXPORT ERROR !"						
						)
						ofioLog.progress (100.0 * i / objs.count)
					)
					ofioLog.print ("obn export finished, " + (exported as String) + "/" + (objs.count as String) + " succeded, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					if exported < objs.count then
						messagebox ("WARNING: NOT ALL OBN FILES ARE EXPORTED")
					gc()
				) catch
				(
					ofutils.showException()
					bn.cleanup()
					ofioLog.print "EXPORT ALL ERROR !"
				)
				ofioLog.finish()
			)
		)
		bn = undefined
	)			
	
	group " \\ BOUND \\ OBD " 
	(
		button btn_IV_BD_Import "Import Single" width:120 align:#center
		button btn_IV_BD_Export "Export Single" width:120 align:#center
		button btn_IV_BD_ExportAll "Export All" width:120 align:#center
		label margin_IV_BD "" height:0 
	)	
	
	on btn_IV_BD_Import pressed do
	(
		local input_obd_file_name = getOpenFileName caption:"Select GTA IV *.obd file" types:"gta iv open formats bound dictionary (*.obd)|*obd"
		if (input_obd_file_name != undefined) and (getFileSize input_obd_file_name) > 0 then
		(
			with undo off
			(
				with redraw off
				(
					local bd = ofio_iv_obd()
					ofioLog.start()
					try ( 
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						bd.read(input_obd_file_name)
						ofioLog.print "building meshes"
						bd.build()
						ofioLog.print ("obd import succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						gc()
					) catch
					(
						ofutils.showException()
						bd.cleanup()
						ofioLog.print "IMPORT ERROR !"
					)
					ofioLog.finish()
					bd = undefined
				)
			)			
		)		
	)		
	
	on btn_IV_BD_Export pressed do
	(
		local bd = ofio_iv_obd()
		local fname 
		try (
			if selection.count != 1 then 
				throw ("SELECTION ERROR\n\n" + "In order to export single obd you must select obd descriptor scene object (bd_*)\n")
			fname = bd.filename_from_scenename selection[1].name
		) catch
		(
			ofutils.showException()
			bd = undefined
			return OK
		)
		local pathOut = getSavePath caption:("Select directory for exporting '" + fname + "'.")					
		if pathOut != undefined then
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					ofioLog.print ("dumping " + selection[1].name)
					bd.dump(selection[1])
					ofioLog.print ("writing " + fname)
					bd.write(pathOut + "\\" + fname)
					ofioLog.print ("obd export succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					gc()
				) catch
				(
					ofutils.showException()
					bd.cleanup()
					ofioLog.print "EXPORT ERROR !"
				)
				ofioLog.finish()
			)
		)
		bd = undefined
	)		
	
	on btn_IV_BD_ExportAll pressed do
	(
		local names = #()
		local objs = #()
		local bd = ofio_iv_obd()
		try (
			local obj, fname			
			for obj in objects do
			(
				try (
					fname = bd.filename_from_scenename obj.name
				) catch (
					continue
				)
				append objs obj
				append names fname
			)
			if names.count == 0 then
				throw ("OBJECT ERROR\n\n" + "No obd dictionaries to export.\n")
		) catch
		(
			ofutils.showException()
			bd = undefined
			return OK
		)
		bd = undefined
		
		local pathOut = getSavePath caption:("Select directory for exporting *.obd files.\n" + (names as String))					
		if pathOut != undefined then
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					local i, exported = 0
					for i = 1 to objs.count do
					(
						try (
							bd = ofio_iv_obd()
							ofioLog.print ("dumping " + objs[i].name)
							bd.dump(objs[i])
							ofioLog.print ("writing " + names[i])
							bd.write(pathOut + "\\" + names[i])
							bd.cleanup()
							bd = undefined
							exported += 1
						) catch
						(
							ofutils.showException()
							bd.cleanup()
							ofioLog.print "EXPORT ERROR !"						
						)
						ofioLog.progress (100.0 * i / objs.count)
					)
					ofioLog.print ("obd export finished, " + (exported as String) + "/" + (objs.count as String) + " succeded, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					if exported < objs.count then
						messagebox ("WARNING: NOT ALL OBD FILES ARE EXPORTED")
					gc()
				) catch
				(
					ofutils.showException()
					bd.cleanup()
					ofioLog.print "EXPORT ALL ERROR !"
				)
				ofioLog.finish()
			)
		)
		bd = undefined
	)		
	
	------------------- GTA IV NAVMESH ---------------------

	group " \\ NAVMESH \\ ONV " 
	(
		button btn_IV_NV_Import "Import Single" width:120 align:#center
		button btn_IV_NV_Export "Export Multiple" width:120 align:#center
		button btn_IV_NV_KillLinks "Remove Orig Links" width:120 align:#center
		label margin_IV_NV "" height:0 
	)
	
	on btn_IV_NV_Import pressed do
	(
		local input_onv_file_name = getOpenFileName caption:"Select GTA IV *.onv file" types:"gta iv open formats navmesh (*.onv)|*onv"
		if (input_onv_file_name != undefined) and (getFileSize input_onv_file_name) > 0 then
		(
			with undo off
			(
				with redraw off
				(
					local nv = ofio_iv_nv_descriptor()
					ofioLog.start()
					try ( 
						--clearListener()
						--ofutils.showListener()
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						nv.read(input_onv_file_name)
						ofioLog.print "building mesh"
						nv.build()
						--format "elapsed % seconds\n" ( (timeStamp() - start_time) / 1000.0 )
						ofioLog.print ("navmesh import succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						gc()
					) catch
					(
						ofutils.showException()
						nv.cleanup()
						ofioLog.print "IMPORT ERROR !"
					)
					ofioLog.finish()
					nv = undefined
				)
			)			
		)		
	)	
	
	on btn_IV_NV_Export pressed do
	(
		with undo off
		(
			with redraw off		
			(
				local nv = ofio_iv_nv_dump()
				try (
					local path = getSavePath caption:"Select output directory for *.onv files which were built from scratch using current scene."
					if path != undefined then 
					(
						ofioLog.start()
						--clearListener()
						--ofutils.showListener()						
						local start_time = timeStamp()						
						nv.full_scene(path)
						--format "elapsed % seconds\n" ( (timeStamp() - start_time) / 1000.0 )
						ofioLog.print ("navmesh export succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					)					
				) catch
				(
					ofutils.showException()
					nv.cleanup()
					ofioLog.print "EXPORT ERROR !"
				)			
				ofioLog.finish()	
				nv = undefined
			)
		)
	)
	
	on btn_IV_NV_KillLinks pressed do
	(
		with undo off
		(
			with redraw off		
			(
				local nv = ofio_iv_nv_dump()
				try (
					local pathIn = getSavePath caption:"Select input GTA IV *.onv files directory. Directory must have all original *.onv files inside in order to remove external links to the sectors from current scene."					
					if pathIn != undefined then
					(
						local pathOut = getSavePath caption:"Select output directory for patched *.onv files, this patched files will have no links to the sectors from current scene, you must use them too."
						if pathOut != undefined then 
						(
							ofioLog.start()
							--clearListener()
							--ofutils.showListener()							
							local start_time = timeStamp()
							nv.full_scene_surround_kill_links pathIn pathOut
							--format "elapsed % seconds\n" ( (timeStamp() - start_time) / 1000.0 )
							ofioLog.print ("navmesh original links removing succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						)
					)					
				) catch
				(
					ofutils.showException()
					nv.cleanup()
					ofioLog.print "REMOVE ORIG LINKS ERROR !"					
				)			
				ofioLog.finish()	
				nv = undefined				
			)
		)		
	)	
	
	------------------- GTA IV ANIM ---------------------
	
	group " \\ ANIMATION \\ ONIM " 
	(
		button btn_IV_ONIM_Import "Import Single" width:120 align:#center
		button btn_IV_ONIM_Export_UV "Export UV" width:120 align:#center
		button btn_IV_ONIM_Export_Skel "Export Skel" width:120 align:#center
		label margin_IV_ONIM "" height:0 
	)	
	
	on btn_IV_ONIM_Import pressed do
	(
		local obj
		try (
			if selection.count == 1 and (getUserProp selection[1] "type" == "bone")
				then obj = selection[1]
				else obj = medit.GetCurMtl()
			if (obj == undefined) or ((classof obj != iv_drawable_material) and (classof obj != Standard) and (classof obj != Dummy)) then
				throw ("SELECTION ERROR\n\n" + "In order to import animation you must select root bone for skel anim or\nopen target material in Material Editor for uv anim\n")
		) catch
		(
			ofutils.showException()
			return OK
		)		
		local input_onim_file_name = getOpenFileName caption:"Select GTA IV *.onim file" types:"gta iv open formats animation (*.onim)|*onim"
		if (input_onim_file_name != undefined) and (getFileSize input_onim_file_name) > 0 then
		(
			with undo off
			(
				with redraw on				(
					local onim = ofio_iv_anim()
					ofioLog.start()
					try ( 
						local start_time = timeStamp()
						ofioLog.print "reading input file"
						onim.read(input_onim_file_name)
						ofioLog.print "building animation"
						onim.build obj
						ofioLog.print ("animation import succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
						gc()
					) catch
					(
						ofutils.showException()
						ofioLog.print "IMPORT ERROR !"
					)
					ofioLog.finish()
					onim = undefined
				)
			)			
		)		
	)	

	on btn_IV_ONIM_Export_UV pressed do
	(
		local mtl = medit.GetCurMtl()		
		try (
			if (mtl == undefined) or ((classof mtl != iv_drawable_material) and (classof mtl != Standard)) then
				throw "SELECTION ERROR\n\nSelected (opened in mtl editor) material doesn't exist or it's type is not the iv_drawable_material or Standard\n"
		) catch
		(
			ofutils.showException()
			return OK
		)
		local fname = mtl.name + "_uv_0.onim"
		local pathOut = getSavePath caption:("Select directory for exporting '" + fname + "'.")
		if pathOut == undefined then return OK
		
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					local onim = ofio_iv_anim()					
					ofioLog.print ("dumping " + mtl.name)
					onim.dump mtl uv:true
					ofioLog.print ("writing " + fname)
					onim.write(pathOut + "\\" + fname)
					ofioLog.print ("UV onim export succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					messagebox "After exporting UV animation you must manully correct it's name\nincluding corresponding ODR material id which is set as '_uv_0' in the end of the *.onim name\n"
					gc()
				) catch
				(
					ofutils.showException()
					ofioLog.print "EXPORT ERROR !"
				)
				ofioLog.finish()
			)
		)
	)	
	
	on btn_IV_ONIM_Export_Skel pressed do
	(
		local fname
		try (
			if (Selection.Count != 1) or (getUserProp Selection[1] "id" != 0) or (ofutils.lowercase(getUserProp Selection[1] "type") != "bone") then
				throw "SELECTION ERROR\n\nOnly root bone of the skel must be selected in order to export skel bone animation\n"
			if (Selection[1].parent == undefined) or (ofutils.lowercase(getUserProp Selection[1].parent "type") != "drawable") then
				throw "SELECTION ERROR\n\nRoot bone must have parent drawable\n"
			local odr = ofio_iv_odr()
			fname = ofutils.removeExt(odr.filename_from_scenename Selection[1].parent.name) + ".onim"
		) catch
		(
			ofutils.showException()
			return OK
		)
		local pathOut = getSavePath caption:("Select directory for exporting '" + fname + "'.")
		if pathOut == undefined then return OK
		
		with undo off
		(
			with redraw off
			(
				ofioLog.start()
				try ( 
					local start_time = timeStamp()
					local onim = ofio_iv_anim()					
					ofioLog.print ("dumping " + Selection[1].name)
					onim.dump Selection[1]
					ofioLog.print ("writing " + fname)
					onim.write(pathOut + "\\" + fname)
					ofioLog.print ("Skel onim export succeed, elapsed " + ( ( (timeStamp() - start_time) / 1000.0 ) as String ) + " seconds")
					gc()
				) catch
				(
					ofutils.showException()
					ofioLog.print "EXPORT ERROR !"
				)
				ofioLog.finish()
			)
		)
	)	
	
	------------------------------------------------------

	group " \\ UTILS \\ " 
	(
		button btn_utils_tesselate "Adv Tesselate" width:120 align:#center
		button btn_utils_select_bound_bad_polys "Sel Bound Bad Polys" width:120 align:#center
		button btn_utils_convert_std_mats_to_drawable "Std mats to Drawable" width:120 align:#center
		label margin_utils "" height:0 
	)	
	
	on btn_utils_convert_std_mats_to_drawable pressed do
	(
		try (
			local obj
			for obj in selection do
				ofutils.std_mats_to_drawable(obj)
		) catch (
			ofutils.showException()
		)
	)	
	
	on btn_utils_select_bound_bad_polys pressed do
	(
		try (
			if selection.count != 1 then
				throw "SELECTION ERROR\n\nIn order to select bad polygons single bound mesh must be selected\n"
			if classof selection[1] != Editable_Poly and classof selection[1] != Editable_Mesh then
				throw "SELECTION ERROR\n\nSelected bound object must be Editable Mesh or Editable Poly\n"
			ofutils.select_bound_bad_polys(selection[1])
		) catch (
			ofutils.showException()
		)
	)

	on btn_utils_tesselate pressed do
	(
		local obj, objs = #()
		for obj in selection do
			if (classof obj == Editable_Poly) or (classof obj == Editable_Mesh) then
				append objs obj	
		if objs.count == 0 then
		(
			messagebox "Nothing to tesselate"
			return OK
		)
		ofioLog.start()
		try (
			local tesselated = 0						
			for obj in objs do
			(		
				ofioLog.print("tesselating '" + obj.name + "'")
				local res = ofutils.try_cut_big_faces_to_traingles obj
				if res then 
				(
					ofioLog.print("tesselating SUCCEDED")
					tesselated += 1
				) else ofioLog.print("tesselating FAILED")
			)			
			if tesselated != objs.count then messagebox "WARNING: TESSELATION FAILED FOR SOME OBJECTS"
		) catch
		(
			ofutils.showException()
		)
		ofioLog.finish()	
	)	

	label info1 "-    Alexander Blade    -" align:#center
	label info2 "-         MIXAZZZ         -" align:#center
	label info3 "-    http://dev-c.com   -" align:#center
	label info4 "-       15 Mar 2015     -" align:#center		
)
addRollout ofgui
