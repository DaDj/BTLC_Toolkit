-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: animations
-- Last changed: Aug 2013

global ofio_iv_opened_blocks

struct ofio_iv_anim_ch (
	static, -- is static
	values = #() -- data, when static has 1 element
)

struct ofio_iv_anim_seq (
	multich, -- is multichannel
	static, -- is static
	channels = #(), -- for multichannel channels
	values = #() -- for singlechannel data, when static this array has 1 element
)

struct ofio_iv_anim_block (
	name,
	type,
	boneid,
	sequences = #()
)

struct ofio_iv_anim (
	Flags = #(),
	Frames,
	SequenceFrameLimit,
	Duration,
	_f10,
	ExtraFlags = #(),
	Sequences = #(),
	MaterialID,
	Animation = #(), -- array of ofio_iv_anim_block
	
	ACTION_FLAGS = #("f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", \
					 "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20", \
 					 "f21", "f22", "f23", "f24", "f25", "f26", "f27", "f28", "f29", "f30", \
					 "f31", "f32"),
					 
	UNK_FLAGS = #("u1", "u2", "u3", "u4", "u5", "u6", "u7", "u8", "u9", "u10", \
					 "u11", "u12", "u13", "u14", "u15", "u16", "u17", "u18", "u19", "u20", \
 					 "u21", "u22", "u23", "u24", "u25", "u26", "u27", "u28", "u29", "u30", \
					 "u31", "u32"),					 
	
	fn add_bone_object root bone_arr = (
		if (getUserProp root "type" == "bone") then
		(
			local id = getUserProp root "id"
			if id == undefined then 
				throw "bone with unknown id"
			bone_arr[id+1] = root
			if root.Children != undefined then
			(
				local child
				for child in root.Children do
					bone_arr = add_bone_object child bone_arr
			)
		)
		return bone_arr
	),	
	
	fn sc_seq_try_make_static seq = (
		local can_be_staic = true
		local first_value = seq.values[1]
		local value
		for value in seq.values do
		(
			if value != first_value then
			(
				can_be_staic = false
				exit
			)
		)
		if can_be_staic then
		(
			seq.static = true
			seq.values = #(seq.values[1])
		)
		return seq
	),
	
	fn sc_seqs_is_empty seqs = (
		local first_value = seqs[1].values[1]
		if first_value != 0 then 
			return false
		local seq
		for seq in seqs do
		(
			if not seq.static then 
				return false
			if seq.values[1] != first_value then
				return false
		)
		print seqs
		return true
	),
	
	fn round_f val n:3 = (
		local mult = 10.0 ^ n
		return (floor ((val * mult) + 0.5)) / mult
	),
	
	fn round_f3 val n:3 = (
		return (Point3 (round_f val.x) (round_f val.y) (round_f val.z))
	),	
	
	fn round_f4 val n:3 = (
		return (Quat (round_f val.x) (round_f val.y) (round_f val.z) (round_f val.w))
	),		
	
	fn dump root uv:false = (
		if root == undefined then
			throw "in order to export animation root bone or mesh must be selected"	
		Frames = (animationRange.end.Frame as Integer) + 1
		SequenceFrameLimit = 127
		Duration = (Frames as Float) / frameRate
		_f10 = 0
		ExtraFlags = #()
		Sequences = #()
		if Frames > SequenceFrameLimit then
		(
			local fullSeqCount = (Frames / SequenceFrameLimit) as Integer
			local fullSeqFrameCount = fullSeqCount * SequenceFrameLimit 
			local endSeqFrameCount = Frames - fullSeqFrameCount
			while fullSeqCount > 0 do
			(
				append Sequences (SequenceFrameLimit + 1)
				fullSeqCount -= 1
			)
			append Sequences endSeqFrameCount
		) else
		(
			if (mod (Frames + 1) 16) == 0 
				then SequenceFrameLimit = Frames
				else SequenceFrameLimit = (((Frames + 1) / 16) as Integer) * 16 + 15
			append Sequences Frames			
		)
		--format "Frames % SequenceFrameLimit % Duration % Sequences %\n" Frames SequenceFrameLimit Duration Sequences
		
		if uv then
		(
			format "dumping uv animation\n"
			if (classof root != iv_drawable_material) and (classof root != Standard) then
				throw ("selected mtl isn't iv_drawable_material or Standard")
			
			local mtl
			if classof root == iv_drawable_material
				then mtl = root.delegate
				else mtl = root
			if mtl.diffuseMap == undefined then
				throw ("selected mtl diffuse map isn't set")				
			local texture = mtl.diffuseMap
			if classof texture != bitmaptexture then
				throw ("selected mtl diffuse map isn't a bitmap texture")			
			
			Flags = #("FLAG_0", "FLAG_6", "FLAG_8")
			
			MaterialID = undefined
				
			local blockU = ofio_iv_anim_block()
			blockU.name = "UV0"
			blockU.type = "Float3"
			blockU.boneid = 0
			blockU.sequences = #()

			local blockV = ofio_iv_anim_block()
			blockV.name = "UV1"
			blockV.type = "Float3"
			blockV.boneid = 0
			blockV.sequences = #()				
				
			local i, j, curFrame = 1
			for j in Sequences do
			(
				local seqU = ofio_iv_anim_seq()
				seqU.multich = false
				seqU.static = false
				seqU.values = #()
					
				local seqV = ofio_iv_anim_seq()
				seqV.multich = false
				seqV.static = false
				seqV.values = #()						
					
				local f
				for f = 1 to j do
				(
					with animate on at time (curFrame - 1)
					(
						append seqU.values (Point3 1.0 0.0 texture.coords.u_offset)
						append seqV.values (Point3 0.0 1.0 texture.coords.v_offset)
					)
					-- the frame in the end of each FrameData in the same frame as the first one of the next
					if f <= SequenceFrameLimit then
						curFrame += 1
				)
					
				append blockU.sequences (sc_seq_try_make_static seqU)
				append blockV.sequences (sc_seq_try_make_static seqV)			
			)
			
			Animation = #(blockU, blockV)
		) else
		(
			format "dumping skel animation\n"
			if ofutils.lowercase(getUserProp root "type") != "bone" then
				throw "selected object type is not bone"
			if getUserProp root "id" != 0 then
				throw "selected root bone id isn't 0"
			local bone_using_id = add_bone_object root #()
			local is_ped = bone_using_id[1202 + 1] != undefined
			if is_ped 
				then Flags = #("FLAG_0", "FLAG_4", "FLAG_5", "FLAG_6", "FLAG_7", "FLAG_8")
				else Flags = #("FLAG_0", "FLAG_6", "FLAG_7", "FLAG_8")
			local optimize = queryBox ("Do you need to optimize an animation (highly recommended) ?\n\n" + \ 
				  					  "* In order to do optimization every bone must have " + \ 
									  "orig_pos and orig_param props (skel import writes this params)\n" + \
									  "* Ped animations must be always optimized\n") \
							 title:"Animation optimization"
			MaterialID = -1
			Animation = #()
			local i, j
			-- bone positions and rotations
			for i = 1 to bone_using_id.count do
			(
				local bone = bone_using_id[i]
				if bone == undefined then continue
				
				local blockPos = ofio_iv_anim_block()
				blockPos.name = "BonePosition"
				blockPos.type = "Float3"
				blockPos.boneid = i - 1
				blockPos.sequences = #()

				local blockR = ofio_iv_anim_block()
				blockR.name = "BoneRotation"
				blockR.type = "Float4"
				blockR.boneid = i - 1
				blockR.sequences = #()				
				
				local curFrame = 1
				for j in Sequences do
				(
					local seqPos = ofio_iv_anim_seq()
					seqPos.multich = false
					seqPos.static = false
					seqPos.values = #()
					
					local seqR = ofio_iv_anim_seq()
					seqR.multich = false
					seqR.static = false
					seqR.values = #()						
					
					local f
					for f = 1 to j do
					(
						with animate on at time (curFrame - 1)
						(
							local pos, r
							in coordsys parent
							(
								pos = round_f3 bone.position
								r = round_f4 bone.rotation
							)								 
							append seqPos.values pos
							append seqR.values r
						)
						-- the frame in the end of each FrameData in the same frame as the first one of the next
						if f <= SequenceFrameLimit then
							curFrame += 1
					)
					
					append blockPos.sequences (sc_seq_try_make_static seqPos)
					append blockR.sequences (sc_seq_try_make_static seqR)
				)
				
				-- optimization removes blocks which have the same static data as the default skel
				local seq, static_block = true, add_block = true
				-- position
				if optimize then
				(
					for seq in blockPos.sequences do
					(
						if (seq.static != true) or (seq.values[1] != blockPos.sequences[1].values[1]) then
						(
							static_block = false
							exit
						)
					)
					if static_block then
					(
						local pos = getUserProp bone "orig_position"
						if pos == undefined then 
							throw ("bone " + bone.name + " has no orig_position param,\n" + \ 
								   "use not optimized export or retry after importing odr with the same skel")
						pos = execute pos
						if (round_f3 pos) == blockPos.sequences[1].values[1] then
						(
							--format "% position skipped\n" bone.name
							add_block = false
						)
					)	
				)
				if add_block then append Animation blockPos
				-- rotation
				add_block = true
				if optimize then
				(
					static_block = true
					for seq in blockR.sequences do
					(
						if (seq.static != true) or (seq.values[1] != blockR.sequences[1].values[1]) then
						(
							static_block = false
							exit
						)
					)
					if static_block then
					(
						local rot = getUserProp bone "orig_rotation"
						if rot == undefined then 
							throw ("bone " + bone.name + " has no orig_rotation param,\n" + \
								   "use not optimized export or retry after importing odr with the same skel")
						rot = execute rot
						if (round_f4 rot) == blockR.sequences[1].values[1] then
						(
							--format "% rotation skipped\n" bone.name
							add_block = false
						)
					)		
				)
				if add_block then append Animation blockR
			)
			-- model positions, rotations, actions, audio event, facial anims (used only in ped anims)
			if is_ped then
			(
				local blockPos = ofio_iv_anim_block()
				blockPos.name = "ModelPosition"
				blockPos.type = "Float3"
				blockPos.boneid = 0
				blockPos.sequences = #()

				local blockR = ofio_iv_anim_block()
				blockR.name = "ModelRotation"
				blockR.type = "Float4"
				blockR.boneid = 0
				blockR.sequences = #()		

				local blockAction = ofio_iv_anim_block()
				blockAction.name = "ActionFlags"
				blockAction.type = "UInt"
				blockAction.boneid = 0
				blockAction.sequences = #()	

				local blockFlag = ofio_iv_anim_block()
				blockFlag.name = "UV0"
				blockFlag.type = "UInt"
				blockFlag.boneid = 0
				blockFlag.sequences = #()		
				
				local blockAudio = ofio_iv_anim_block()
				blockAudio.name = "AudioEvent"
				blockAudio.type = "UInt"
				blockAudio.boneid = 0
				blockAudio.sequences = #()	

				local blockFaceanim = ofio_iv_anim_block()
				blockFaceanim.name = "FacialAnimation"
				blockFaceanim.type = "UInt"
				blockFaceanim.boneid = 0
				blockFaceanim.sequences = #()			
				
				local curFrame = 1
				for j in Sequences do
				(
					local seqPos = ofio_iv_anim_seq()
					seqPos.multich = false
					seqPos.static = false
					seqPos.values = #()
					
					local seqR = ofio_iv_anim_seq()
					seqR.multich = false
					seqR.static = false
					seqR.values = #()	

					local seqAction = ofio_iv_anim_seq()
					seqAction.multich = false
					seqAction.static = false
					seqAction.values = #()	
					
					local seqFlag = ofio_iv_anim_seq()
					seqFlag.multich = false
					seqFlag.static = false
					seqFlag.values = #()					

					local seqAudio = ofio_iv_anim_seq()
					seqAudio.multich = false
					seqAudio.static = false
					seqAudio.values = #()		

					local seqFaceanim = ofio_iv_anim_seq()
					seqFaceanim.multich = false
					seqFaceanim.static = false
					seqFaceanim.values = #()			
					
					local f
					for f = 1 to j do
					(
						-- model pos and rotation
						with animate on at time (curFrame - 1)
						(
							append seqPos.values (round_f3 root.parent.position)
							append seqR.values (round_f4 root.parent.rotation)
						)
						
						-- collect frames from noteTracks
						local keyFrameValues = #() -- key for the current frame from each notetrack
						if hasNoteTracks root then
						(
							local ct, num = numNoteTracks root
							for ct = 1 to num do
							(
								local track = getNoteTrack root ct
								local ctframeIndex = getNoteKeyIndex track (curFrame - 1)
								if ctframeIndex == undefined then continue
								append keyFrameValues track.keys[ctframeIndex].value
							)
						)
						global ActionFlags = undefined
						global UnkFlags = undefined
						global AudioEvent = undefined
						global FaceAnim = undefined
						local keyValue, curValue
						for keyValue in keyFrameValues do
						(
							try (execute keyValue) catch ()
						)
						
						-- action flags
						if ActionFlags == undefined then ActionFlags = #()
						local value = 0
						for curValue in ActionFlags do
						(
							local curBit = findItem ACTION_FLAGS (ofutils.lowercase(curValue))
							if curBit == 0 then continue
							value = bit.set value curBit true
						)
						append seqAction.values value
						
						-- unk flags
						if UnkFlags == undefined then UnkFlags = #()
						value = 0
						for curValue in UnkFlags do
						(
							local curBit = findItem UNK_FLAGS (ofutils.lowercase(curValue))
							if curBit == 0 then continue
							value = bit.set value curBit true
						)
						append seqFlag.values value						
						
						-- audio events
						if AudioEvent == undefined then AudioEvent = "0x00000000"
						value = AudioEvent
						append seqAudio.values value
						
						-- face anim
						if FaceAnim == undefined then FaceAnim = "0x00000000"
						value = FaceAnim
						append seqFaceanim.values value						
						
						-- the frame in the end of each FrameData in the same frame as the first one of the next
						if f <= SequenceFrameLimit then
							curFrame += 1
					)
					
					append blockPos.sequences (sc_seq_try_make_static seqPos)
					append blockR.sequences (sc_seq_try_make_static seqR)
					append blockAction.sequences (sc_seq_try_make_static seqAction)
					append blockFlag.sequences (sc_seq_try_make_static seqFlag)
					append blockAudio.sequences (sc_seq_try_make_static seqAudio)
					append blockFaceanim.sequences (sc_seq_try_make_static seqFaceanim)
				)
				append Animation blockPos
				append Animation blockR
				append Animation blockAction
				ExtraFlags = #("FLAG_1")
				if not sc_seqs_is_empty blockFlag.sequences then
				(
					append ExtraFlags "FLAG_8"
					append Animation blockFlag				
				)
				if not sc_seqs_is_empty blockAudio.sequences then
				(
					append ExtraFlags "FLAG_3"
					append Animation blockAudio
				)
				if not sc_seqs_is_empty blockFaceanim.sequences then	
				(
					append ExtraFlags "FLAG_6"
					append Animation blockFaceanim					
				)
			)
		)
	),
	
	fn build root = (
		if root == undefined then
			throw "in order to import animation root bone or material must be selected"
	
		sliderTime = 0
		
		-- clean dup frames
		local i
		for i = 1 to Sequences.count do
		(
			if Sequences[i] > SequenceFrameLimit then
				Sequences[i] -= 1
		)
			
		if MaterialID != -1 then -- uv animation
		(
			if (classof root != iv_drawable_material) and (classof root != Standard) then
				throw ("selected for animation material isn't iv_drawable_material or Standard,\nselect correct material in Material Editor")
				
			local texture
			if classof root == Standard 
				then texture = root.diffuseMap
				else texture = root.delegate.diffuseMap

			if (texture == undefined) or (classof texture != bitmaptexture) then
				throw ("selected in Material Editor material diffuse map isn't set or is not a bitmap texture")
		
			local block, i, j
			frameRate = Frames / Duration
			animationRange = Interval 0 (Frames - 1)
			
			for i = 1 to Frames do
			(
				for block in Animation do
				(
					local seq, seq_id = 1, seq_start = 1
					for seq in block.sequences do
					(
						if (i >= seq_start) and (i < seq_start + Sequences[seq_id]) then exit
						seq_start += Sequences[seq_id]
						seq_id += 1
					)
					local seq = block.sequences[seq_id]
					local value = #()
					if seq.multich then
					(
						for j = 1 to seq.channels.count do
						(
							if seq.channels[j].static 
								then append value seq.channels[j].values[1]
								else append value seq.channels[j].values[i - seq_start + 1]
						)
					) else
					(
						if seq.static 
							then value = seq.values[1]
							else value = seq.values[i - seq_start + 1]	
					)
					
					if classof value == array then
					(
						for j = 1 to value.count do
							if value[j] == undefined then throw "undefined array element"
						
						case value.count of
						(
							3: value = Point3 value[1] value[2] value[3]
							default: throw "array size mismatch"
						)
					) else
					(
						throw "value is not an array"
					)
						
					with animate on at time (i - 1)
					(
						case ofutils.lowercase(block.name) of
						(	
							"uv0": texture.coords.u_offset = value[3]
							"uv1": texture.coords.v_offset = value[3]
							default: throw ("uknown uv block " + block.name)
						)
					)					
				)
			)
		) else -- skel animation
		(
			if (classof root != Dummy) or (getUserProp root "type" != "bone") then
				throw "root object isn't a bone"
			if getUserProp root "id" != 0 then
				throw "selected root bone id isn't 0"
			bone_using_id = add_bone_object root #()
			local block, i, j
			frameRate = Frames / Duration
			animationRange = Interval 0 (Frames - 1)
			
			-- create note track for frame flags
			if (hasNoteTracks root) then
			(
				local num = numNoteTracks root
				for i = 1 to num do
				(
					deleteNoteTrack root (getNoteTrack root i)
				)
			)
			local trackAction = notetrack "ActionNoteTrack"
			local trackFlag = notetrack "FlagNoteTrack"
			local trackAudio = notetrack "AudioNoteTrack"
			local trackFace = notetrack "FaceNoteTrack"			
			addNoteTrack root trackAction
			addNoteTrack root trackFlag
			addNoteTrack root trackAudio
			addNoteTrack root trackFace			
			
			for i = 1 to Frames do
			(
				for block in Animation do
				(
					case ofutils.lowercase(block.name) of
					(
						"boneposition":	()
						"bonerotation":	()
						"modelposition": ()
						"modelrotation": ()
						"actionflags": ()
						"uv0": ()
						"audioevent": ()
						"facialanimation": ()
						default: continue
					)
					
					local bone = bone_using_id[block.boneid+1]
					if bone == undefined then 
						continue
						--throw ("selected skel has no bone " + block.boneid as String + " used in anim")
					if bone.parent == undefined then
						throw ("selected skel has no parent object")					
					
					local seq, seq_id = 1, seq_start = 1
					for seq in block.sequences do
					(
						if (i >= seq_start) and (i < seq_start + Sequences[seq_id]) then exit
						seq_start += Sequences[seq_id]
						seq_id += 1
					)
					local seq = block.sequences[seq_id]
					local value = #()
					if seq.multich then
					(
						for j = 1 to seq.channels.count do
						(
							if seq.channels[j].static 
								then append value seq.channels[j].values[1]
								else append value seq.channels[j].values[i - seq_start + 1]
						)
					) else
					(
						if seq.static 
							then value = seq.values[1]
							else value = seq.values[i - seq_start + 1]					
					)
					
					if classof value == array then
					(
						for j = 1 to value.count do
							if value[j] == undefined then throw "undefined array value"
						
						case value.count of
						(
							3: value = Point3 value[1] value[2] value[3]
							4: value = Quat value[1] value[2] value[3] value[4]
							default: throw "array size mismatch"
						)
					) else
					(
						--throw ("value is not an array, type " + block.type)
					)
						
					with animate on at time (i - 1)
					(
						case ofutils.lowercase(block.name) of
						(					
							"boneposition":	in coordsys parent bone.position = value
							"bonerotation":	
							(
								local pos = bone.pos
								in coordsys parent bone.rotation = value
								bone.pos = pos
							)
							"modelposition": bone.parent.position = value
							"modelrotation": bone.parent.rotation = value
							"actionflags": 
							(
								if value > 0 then
								(
									local str = "ActionFlags = #("
									local flag, flagCount = 0
									for flag = 1 to 32 do
									(
										if (bit.get value flag) then 
										(
											str += ("\"" + ACTION_FLAGS[flag] + "\", ")
											flagCount += 1
										)
									)		
									if flagCount > 0 then str = substring str 1 (str.count - 2)
									str += ")"
									addNewNoteKey trackAction.keys (i - 1)
									trackAction.keys[trackAction.keys.count].value = str
								)
							)
							"uv0": -- unknown flags
							(
								if value > 0 then
								(
									local str = "UnkFlags = #("
									local flag, flagCount = 0
									for flag = 1 to 32 do
									(
										if (bit.get value flag) then 
										(
											str += ("\"" + UNK_FLAGS[flag] + "\", ")
											flagCount += 1
										)
									)		
									if flagCount > 0 then str = substring str 1 (str.count - 2)
									str += ")"
									addNewNoteKey trackFlag.keys (i - 1)
									trackFlag.keys[trackFlag.keys.count].value = str
								)
							)							
							"audioevent": 
							(
								if value != "0x00000000" then
								(
									local str = "AudioEvent = \"" + (value as String) + "\""
									addNewNoteKey trackAudio.keys (i - 1)
									trackAudio.keys[trackAudio.keys.count].value = str
								)
							)
							"facialanimation": 
							(
								if value != "0x00000000" then
								(
									local str = "FaceAnim = \"" + (value as String) + "\""
									addNewNoteKey trackFace.keys (i - 1)
									trackFace.keys[trackFace.keys.count].value = str
								)
							)							
							default: throw ("uknown block type " + block.name)
						)
					)					
				)
			)
		) 
	),
	
	fn scanline fInput = (
		if eof(fInput) then throw "unexpected eof"	
		local l = readLine(fInput)
		local s = filterString l "\x20\x09"
		if s.count == 1 then
			if s[1] == "{" then ofio_iv_opened_blocks += 1 else
				if s[1] == "}" then ofio_iv_opened_blocks -= 1
		l = undefined	
		return s
	),	
	
	fn write fOutputName = (
		local fOutput = createFile fOutputName
		format "Version 8 2\n{\n" to:fOutput
		format ("\x09" + "Flags") to:fOutput
		local i
		for i in Flags do format " %" i to:fOutput
		format "\n" to:fOutput
		format ("\x09" + "Frames %\n") Frames to:fOutput
		format "\x09SequenceFrameLimit %\n" SequenceFrameLimit to:fOutput
		format ("\x09" + "Duration %\n") Duration to:fOutput
		format "\x09_f10 %\n" _f10 to:fOutput
		format ("\x09" + "ExtraFlags") to:fOutput
		for i in ExtraFlags do format " %" i to:fOutput
		format "\n" to:fOutput
		format "\x09Sequences" to:fOutput
		for i in Sequences do format " %" i to:fOutput
		format "\n" to:fOutput
		if MaterialID != undefined then format "\x09MaterialID %\n" MaterialID to:fOutput
		format ("\x09" + "Animation\n\x09{\n") to:fOutput
		local block, seq
		for block in Animation do
		(
			local block_type
			case ofutils.lowercase(block.type) of
			(				
				"uint": block_type = 0
				"float": block_type = 0
				"float3": block_type = 1
				"float4": block_type = 2
				default: 
				(
					close fOutput
					throw ("unsupported block type " + block.type)
				)
			)		
			format "\x09\x09% % %\n\x09\x09{\n" block.name block.type block.boneid to:fOutput
			for seq in block.sequences do
			(
				if seq.multich != False then
					throw "only single channel export is supported"
				format ("\x09\x09\x09" + "FramesData SingleChannel") to:fOutput
				if seq.static then 
					format " Static" to:fOutput				
				format "\n\x09\x09\x09{\n" to:fOutput
				local value
				for value in seq.values do
				(
					case block_type of
					(
						0: format "\x09\x09\x09\x09%\n" value to:fOutput
						1: format "\x09\x09\x09\x09% % %\n" value.x value.y value.z to:fOutput
						2: format "\x09\x09\x09\x09% % % %\n" value.x value.y value.z value.w to:fOutput
					)
				)
				format "\x09\x09\x09}\n" to:fOutput
			)
			format "\x09\x09}\n" to:fOutput
		)
		format "\x09}\n" to:fOutput
		format "}\n" to:fOutput
		close fOutput
	),
	
	fn isUintBlockUsesNames name = (
		local n = ofutils.lowercase(name)
		return (n == "audioevent" or n == "facialanimation")
	),
	
	fn read fInputName = (
		local fInput = openFile fInputName
		ofio_iv_opened_blocks = 0
		local version = scanline fInput
		if (version[2] as Integer != 8) or (version[3] as Integer != 2) then
		(
			close fInput
			throw "not supported *.onim, version 8 2 is supported only"		
		)
		local blockStart = scanline fInput
		if blockStart[1] != "{" then throw "block start expected"
		local i, elements = scanline fInput
		while elements[1] != "}" do
		(
			case ofutils.lowercase(elements[1]) of
			(
				"flags":
				(
					Flags = #()
					for i = 2 to elements.count do
						append Flags elements[i]				
				)
				"frames": Frames = elements[2] as Integer
				"sequenceframelimit": SequenceFrameLimit = elements[2] as Integer
				"duration": Duration = elements[2] as Float
				"_f10": _f10 = elements[2] as Integer
				"extraflags":
				(
					ExtraFlags = #()
					if elements.count > 1 then
						for i = 2 to elements.count do
							append ExtraFlags elements[i]				
				)
				"sequences":
				(
					Sequences = #()
					for i = 2 to elements.count do
						append Sequences (elements[i] as Integer)
				)
				"materialid": MaterialID = elements[2] as Integer
				"animation":
				(
					Animation = #()
					elements = scanline fInput
					if elements[1] != "{" then throw "animation start expected"							
					elements = scanline fInput
					while (elements[1] != "}") do
					(
						local block = ofio_iv_anim_block()
						block.name = elements[1]
						block.type = elements[2]
						block.boneid = elements[3] as Integer
						
						local name = ofutils.lowercase(block.name)						
						if (name != "boneposition") and (name != "bonerotation") \
						and (name != "modelposition") and (name != "modelrotation") \
						and (name != "actionflags") and (name != "facialanimation") \
						and (name != "audioevent") \
						and (name != "uv0") and (name != "uv1") \
						and (name != "type132") and (name != "type133") and (name != "type135") 
							then throw ("unsupported *.onim block " + block.name)
						case ofutils.lowercase(block.type) of
						(
							"float3": 
							(
								elements = scanline fInput
								if elements[1] != "{" then throw "block start expected"
								block.sequences = #()
								for i = 1 to Sequences.count do
								(
									elements = scanline fInput
									if elements[1] != "FramesData" then throw "FramesData expected"
									local seq = ofio_iv_anim_seq()
									seq.multich = (elements[2] == "MultiChannel")
									seq.static = (elements[3] == "Static")
									elements = scanline fInput
									if elements[1] != "{" then throw "FramesData start expected"									
									if seq.multich then -- multichannel
									(
										seq.channels = #()
										local j
										for j = 1 to 3 do
										(
											elements = scanline fInput
											if ofutils.lowercase(elements[1]) != "channel" then throw "channel expected"
											local ch = ofio_iv_anim_ch()
											ch.values = #()
											ch.static = (ofutils.lowercase(elements[2]) == "static")
											elements = scanline fInput
											if elements[1] != "{" then throw "channel start expected"
											if ch.static then
											(
												elements = scanline fInput
												append ch.values (elements[1] as Float)
											) else
											(
												-- channel has Sequences[i] values
												local frame
												for frame = 1 to Sequences[i] do
												(
													elements = scanline fInput
													append ch.values (elements[1] as Float)													
												)
											)
											elements = scanline fInput
											if elements[1] != "}" then throw "channel end expected"
											append seq.channels ch
										)
									) else -- singlechannel
									(
										seq.values = #()
										if seq.static then -- static single channel, one Float3 value
										(
											elements = scanline fInput
											append seq.values #(elements[1] as Float, elements[2] as Float, elements[3] as Float)
										) else -- single channel, Sequences[i] values
										(
											local frame
											for frame = 1 to Sequences[i] do
											(
												elements = scanline fInput
												append seq.values #(elements[1] as Float, elements[2] as Float, elements[3] as Float)
											)										
										)
									)
									elements = scanline fInput
									if elements[1] != "}" then throw "FramesData end expected"
									append block.sequences seq
								)																
								elements = scanline fInput
								if elements[1] != "}" then throw "block end expected"								
							)
							"float4":
							(
								elements = scanline fInput
								if elements[1] != "{" then throw "block start expected"
								block.sequences = #()
								for i = 1 to Sequences.count do
								(
									elements = scanline fInput
									if elements[1] != "FramesData" then throw "FramesData expected"
									local seq = ofio_iv_anim_seq()
									seq.multich = (elements[2] == "MultiChannel")
									seq.static = (elements[3] == "Static")
									elements = scanline fInput
									if elements[1] != "{" then throw "FramesData start expected"									
									if seq.multich then -- multichannel
									(
										seq.channels = #()
										local j
										for j = 1 to 4 do
										(
											elements = scanline fInput
											if elements[1] != ofutils.lowercase("channel") then throw "channel expected"
											local ch = ofio_iv_anim_ch()
											ch.values = #()
											ch.static = (ofutils.lowercase(elements[2]) == "static")
											elements = scanline fInput
											if elements[1] != "{" then throw "channel start expected"
											if ch.static then
											(
												elements = scanline fInput
												append ch.values (elements[1] as Float)
											) else
											(
												-- channel has Sequences[i] values
												local frame
												for frame = 1 to Sequences[i] do
												(
													elements = scanline fInput
													append ch.values (elements[1] as Float)													
												)
											)
											elements = scanline fInput
											if elements[1] != "}" then throw "channel end expected"
											append seq.channels ch
										)
									) else -- singlechannel
									(
										seq.values = #()
										if seq.static then -- static single channel, one Float4 value
										(
											elements = scanline fInput
											append seq.values #(elements[1] as Float, elements[2] as Float, elements[3] as Float, elements[4] as Float)
										) else -- single channel, Sequences[i] values
										(
											local frame
											for frame = 1 to Sequences[i] do
											(
												elements = scanline fInput
												append seq.values #(elements[1] as Float, elements[2] as Float, elements[3] as Float, elements[4] as Float)
											)										
										)
									)
									elements = scanline fInput
									if elements[1] != "}" then throw "FramesData end expected"
									append block.sequences seq
								)																
								elements = scanline fInput
								if elements[1] != "}" then throw "block end expected"								
							)							
							"uint": 
							(
								block.sequences = #()
								elements = scanline fInput
								if elements[1] != "{" then throw "block start expected"
								local useNames = isUintBlockUsesNames block.name
								for i = 1 to Sequences.count do
								(
									local seq = ofio_iv_anim_seq()
									elements = scanline fInput
									if elements[1] != "FramesData" then throw "FramesData expected"
									seq.multich = (elements[2] == "MultiChannel")
									if seq.multich then throw "UInt FramesData can't be multichannel"
									seq.static = (elements[3] == "Static")
									seq.values = #()
									
									elements = scanline fInput
									if elements[1] != "{" then throw "Static UInt FramesData start expected"	
									if seq.static then
									(									
										elements = scanline fInput
										if useNames
											then append seq.values elements[1]
											else append seq.values (elements[1] as Integer)
									) else
									(
										local frame
										for frame = 1 to Sequences[i] do
										(
											elements = scanline fInput
											if useNames
												then append seq.values elements[1]
												else append seq.values (elements[1] as Integer)
										)									
									)
									elements = scanline fInput
									if elements[1] != "}" then throw "Static UInt FramesData end expected"								
									
									print seq
									append block.sequences seq
								)
								
								elements = scanline fInput
								if elements[1] != "}" then throw "block end expected"								
							)
							default: throw ("unsupported *.onim block type " + block.type)
						)
						append Animation block
						elements = scanline fInput
					)
				)
				default: throw ("unknown *.onim data " + elements[1])
			)
			elements = scanline fInput
		)
		close fInput
		if ofio_iv_opened_blocks != 0 then throw "file parsing error"		
	),

	fn ApplyAnimtoMaterial TheMat = 
    (
        local texture
        texture = TheMat.texmap_texture

        local block, i, j
        frameRate = Frames / Duration
        animationRange = Interval 0 (Frames - 1)
        
        for i = 1 to Frames do
        (
            for block in Animation do
            (
                local seq, seq_id = 1, seq_start = 1
                for seq in block.sequences do
                (
                    if (i >= seq_start) and (i < seq_start + Sequences[seq_id]) then exit
                    seq_start += Sequences[seq_id]
                    seq_id += 1
                )
                local seq = block.sequences[seq_id]
                local value = #()
                if seq.multich then
                (
                    for j = 1 to seq.channels.count do
                    (
                        if seq.channels[j].static 
                            then append value seq.channels[j].values[1]
                            else append value seq.channels[j].values[i - seq_start + 1]
                    )
                ) else
                (
                    if seq.static 
                        then value = seq.values[1]
                        else value = seq.values[i - seq_start + 1]	
                )
                
                if classof value == array then
                (
                    for j = 1 to value.count do
                        if value[j] == undefined then throw "undefined array element"
                    
                    case value.count of
                    (
                        3: value = Point3 value[1] value[2] value[3]
                        default: throw "array size mismatch"
                    )
                ) else
                (
                    throw "value is not an array"
                )
                    
                with animate on at time (i - 1)
                (
                    case ofutils.lowercase(block.name) of
                    (	
                        "uv0": texture.coords.u_offset = value[3]
                        "uv1": texture.coords.v_offset = value[3]
                        default: throw ("uknown uv block " + block.name)
                    )
                )					
            )
        )
    )
)

