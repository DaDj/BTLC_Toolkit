-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: odr/odd material
-- Last changed: May 2013

ofio_iv_shaders = #("gta_alpha", "gta_cubemap_reflect", "gta_cutout", "gta_cutout_fence", "gta_decal", "gta_decal_amb_only", 
					"gta_decal_dirt", "gta_decal_glue", "gta_decal_normal_only", "gta_default", "gta_emissive", "gta_emissive_alpha", 
					"gta_emissivenight", "gta_emissivenight_alpha", "gta_emissivestrong", "gta_emissivestrong_alpha", "gta_glass", 
					"gta_glass_emissive", "gta_glass_emissive_alpha", "gta_glass_emissivenight", "gta_glass_emissivenight_alpha", 
					"gta_glass_normal_spec_reflect", "gta_glass_reflect", "gta_glass_spec", "gta_hair_sorted_alpha", 
					"gta_hair_sorted_alpha_expensive", "gta_mirror", "gta_normal", "gta_normal_alpha", "gta_normal_cubemap_reflect",
					"gta_normal_cutout", "gta_normal_decal", "gta_normal_reflect", "gta_normal_reflect_alpha", "gta_normal_reflect_decal",
					"gta_normal_spec", "gta_normal_spec_alpha", "gta_normal_spec_cubemap_reflect", "gta_normal_spec_decal", 
					"gta_normal_spec_reflect", "gta_normal_spec_reflect_alpha", "gta_normal_spec_reflect_decal", 
					"gta_normal_spec_reflect_emissive", "gta_normal_spec_reflect_emissive_alpha", "gta_normal_spec_reflect_emissivenight", 
					"gta_normal_spec_reflect_emissivenight_alpha", "gta_parallax", "gta_parallax_specmap", "gta_ped", "gta_ped_alpha", 
					"gta_ped_reflect", "gta_ped_reflect_alpha", "gta_ped_skin", "gta_ped_skin_blendshape", "gta_radar", "gta_reflect", 
					"gta_reflect_alpha", "gta_reflect_decal", "gta_rmptfx_mesh", "gta_spec", "gta_spec_alpha", "gta_spec_const", 
					"gta_spec_decal", "gta_spec_reflect", "gta_spec_reflect_alpha", "gta_spec_reflect_decal", "gta_terrain_va_2lyr", 
					"gta_terrain_va_3lyr", "gta_terrain_va_4lyr", "gta_trees", "gta_vehicle_badges", "gta_vehicle_chrome", 
					"gta_vehicle_generic", "gta_vehicle_interior", "gta_vehicle_interior2", "gta_vehicle_lights", 
					"gta_vehicle_lightsemissive", "gta_vehicle_mesh", "gta_vehicle_nosplash", "gta_vehicle_nowater", "gta_vehicle_paint1", 
					"gta_vehicle_paint2", "gta_vehicle_paint3", "gta_vehicle_rims2", "gta_vehicle_rubber", "gta_vehicle_shuts", 
					"gta_vehicle_tire", "gta_vehicle_vehglass", "gta_wire", "null")

ofio_iv_shader_params = #(
					#("texturesampler_spTexture"),
					#("texturesampler_spTexture", "reflectivepower_spFloat", "environmentsampler_spTexture"),
					#("texturesampler_spTexture"),
					#("texturesampler_spTexture"),
					#("texturesampler_spTexture"),
					#("texturesampler_spTexture"),
					#("texturesampler_spTexture", "dirtdecalmask_spVector4", "specularfactor_spFloat", "specularcolorfactor_spFloat"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "bumpsampler_spTexture"),
					#("texturesampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "reflectivepower_spFloat", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture"),
					#("texturesampler_spTexture", "bumpsampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture", "bumpiness_spFloat"),
					#("texturesampler_spTexture", "bumpsampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture", "bumpiness_spFloat"),
					#("texturesampler_spTexture", "reflectivepower_spFloat", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "bumpsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "bumpsampler_spTexture"),
					#("texturesampler_spTexture", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "bumpsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "bumpsampler_spTexture"),
					#("texturesampler_spTexture", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "zshift_spFloat", "emissivemultiplier_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "reflectivepower_spFloat", "bumpsampler_spTexture", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "parallaxscalebias_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "bumpsampler_spTexture"),
					#("texturesampler_spTexture", "parallaxscalebias_spFloat", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "bumpiness_spFloat", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "bumpsampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture", "bumpiness_spFloat"),
					#("texturesampler_spTexture", "bumpsampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture", "bumpiness_spFloat"),
					#("texturesampler_spTexture", "reflectivepower_spFloat", "environmentsampler_spTexture", "bumpsampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture", "bumpiness_spFloat"),
					#("texturesampler_spTexture", "reflectivepower_spFloat", "environmentsampler_spTexture", "bumpsampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture", "bumpiness_spFloat"),
					#("texturesampler_spTexture", "subcolor_spVector4", "bumpsampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture", "bumpiness_spFloat"),
					#("texturesampler_spTexture", "subcolor_spVector4", "bumpsampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture", "bumpiness_spFloat"),
					#("specularfactor_spFloat", "specularcolorfactor_spFloat", "bumpiness_spFloat", "texturesampler_spTexture", "bumpsampler_spTexture"),
					#("texturesampler_spTexture", "reflectivepower_spFloat", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "reflectivepower_spFloat", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "reflectivepower_spFloat", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "specsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "reflectivepower_spFloat", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "reflectivepower_spFloat", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat", "specmapintmask_spVector4", "reflectivepower_spFloat", "specsampler_spTexture", "environmentsampler_spTexture"),
					#("texturesampler_layer0_spTexture", "texturesampler_layer1_spTexture"),
					#("texturesampler_layer0_spTexture", "texturesampler_layer1_spTexture", "texturesampler_layer2_spTexture"),
					#("texturesampler_layer0_spTexture", "texturesampler_layer1_spTexture", "texturesampler_layer2_spTexture", "texturesampler_layer3_spTexture"),
					#("texturesampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "bumpiness_spVector4", "reflectivepowered_spFloat", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "bumpiness_spVector4", "reflectivepowered_spFloat", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "emissivemultiplier_spFloat", "dimmerset_spArray15OfVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "specular2factored_spVector4", "specular2colorintensityed_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "specular2factored_spVector4", "specular2colorintensityed_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "specular2factored_spVector4", "specular2colorintensityed_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "specular2factored_spVector4", "specular2colorintensityed_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "specular2factored_spVector4", "specular2colorintensityed_spVector4", "reflectivepowered_spFloat", "diffuse2specmod_spVector4", "texturesampler2_spTexture", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "specular2factored_spVector4", "specular2colorintensityed_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "bumpsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "matdiffusecolor_spVector4", "specularfactored_spFloat", "specularcolorfactored_spFloat", "specmapintmask_spVector4", "reflectivepowered_spFloat", "dirtsampler_spTexture", "specsampler_spTexture"),
					#("texturesampler_spTexture", "fade_thickness_spFloat"),
					#("texturesampler_spTexture", "specularfactor_spFloat", "specularcolorfactor_spFloat")
				)


plugin material iv_drawable_material name:"OF IV Drawable" classID:#(0x55550030, 0x55550031) extends:Standard replaceUI:true version:1
(
	fn select_id id = (
		local name_prefix = ofio_iv_shaders[id] + "__"
		local control
		local y = 40
		local i
		local params = ofio_iv_shader_params[id]
		for control in this.params.controls do
		(
			control.visible = false					
			control.pos = [0, 0]		
		)
		for i = 1 to params.count do
		(
			for control in this.params.controls do
			(
				if (params[i] == control.name) or ("lbl_" + params[i] == control.name) then
				(
					control.visible = true
					control.pos = [12, y]
					y += 15
					if params[i] == control.name then 
					(
						y += 8
						local btn = undefined
						local btn_name = "btn_" + control.name
						for btn in this.params.controls do
						(
							if control.width == undefined \
							or control.height == undefined \
							or control.pos == undefined \
								then continue
 							if btn.name == btn_name then
							(
								btn.visible = true
								btn.pos = [control.width - 8, control.pos.y - control.height]								
								exit
							)
						)						
					)
				)
			)			
		)
		if y < 500 then y = 500
		this.params.height = y + 5
		if this.params.dl_shader != undefined then 
		(
			this.params.dl_shader.visible = true
			this.params.dl_shader.pos = [12, 10]	
		)
		return id
	)
	
	fn alphaShaderSelected = (
		local shader
		for shader in #("decal", "alpha", "glass", "cutout") do
			if (findString ofio_iv_shaders[this.mtlid] shader) != undefined then
				return true 
		return false
	)
	
	fn reloadTextures = (
		try (
			if (getFileSize this._texturesampler_spTexture) > 0 then
			(
				if alphaShaderSelected() then
				(
					local tex = bitmaptexture bitmap:(openbitmap this._texturesampler_spTexture)
					tex.coords.realWorldScale = false
					tex.alphasource = 0					
					tex.RGBOutput = 1
					tex.monoOutput = 1
					delegate.opacityMap = undefined
					gc()
					delegate.opacityMap = tex
				) 
				local tex = bitmaptexture bitmap:(openbitmap this._texturesampler_spTexture)
				tex.coords.realWorldScale = false
				tex.alphasource = 0					
				tex.preMultAlpha = false
				delegate.diffuseMap = undefined
				gc()
				delegate.diffuseMap = tex	
			)
		) catch
		(
			format "failed loading diffuse texture\n"
		)
	)
	
	fn setInfo shader path = (
		local i
		local name = ofutils.lowercase(ofutils.removeExt(shader[1]))
		local shader_num = 0
		for i = 1 to ofio_iv_shaders.count do
		(
			if name == ofio_iv_shaders[i] then
			(
				shader_num = i
				exit
			)
		)
		if shader_num == 0 then throw ("unknown shader " + shader[1] + " used")
		
		select_id shader_num
		this.mtlid = shader_num
		
		i = 2
		for name in ofio_iv_shader_params[shader_num] do
		(
			local control
			for control in this.params.controls do
			(
				if control.name == name then
				(
					if (findString name "spTexture") != undefined then 
					(
						local fname = path + shader[i]
						if (getFileSize fname) > 0 
							then control.text = fname
							else control.text = ofutils.removeExt(ofutils.extractFileName(shader[i]))
						if name == texturesampler_spTexture then
							reloadTextures()
					) else control.text = shader[i]
					exit
				)
			)
			i += 1
		)
	)
	
	fn getInfo = (
		local result = #(ofio_iv_shaders[this.mtlid] + ".sps")
		local params = ofio_iv_shader_params[this.mtlid]
		local param
		global _mtl_this = this
		for param in params do
			append result (execute("_mtl_this._" + param) as String)
		_mtl_this = undefined
		return result
	)

	parameters main rollout:params 
	(
		mtlid		type:#integer	default:10 ui:dl_shader
		_texturesampler_spTexture type:#string default:"" ui:texturesampler_spTexture
		_reflectivepower_spFloat type:#string default:"" ui:reflectivepower_spFloat
		_environmentsampler_spTexture type:#string default:"" ui:environmentsampler_spTexture
		_dirtdecalmask_spVector4 type:#string default:"" ui:dirtdecalmask_spVector4
		_specularfactor_spFloat type:#string default:"" ui:specularfactor_spFloat
		_specularcolorfactor_spFloat type:#string default:"" ui:specularcolorfactor_spFloat
		_bumpiness_spFloat type:#string default:"" ui:bumpiness_spFloat
		_bumpsampler_spTexture type:#string default:"" ui:bumpsampler_spTexture
		_zshift_spFloat type:#string default:"" ui:zshift_spFloat
		_emissivemultiplier_spFloat type:#string default:"" ui:emissivemultiplier_spFloat
		_specmapintmask_spVector4 type:#string default:"" ui:specmapintmask_spVector4
		_specsampler_spTexture type:#string default:"" ui:specsampler_spTexture
		_parallaxscalebias_spFloat type:#string default:"" ui:parallaxscalebias_spFloat
		_subcolor_spVector4 type:#string default:"" ui:subcolor_spVector4
		_texturesampler_layer0_spTexture type:#string default:"" ui:texturesampler_layer0_spTexture
		_texturesampler_layer1_spTexture type:#string default:"" ui:texturesampler_layer1_spTexture
		_texturesampler_layer2_spTexture type:#string default:"" ui:texturesampler_layer2_spTexture
		_texturesampler_layer3_spTexture type:#string default:"" ui:texturesampler_layer3_spTexture
		_matdiffusecolor_spVector4 type:#string default:"" ui:matdiffusecolor_spVector4
		_specularfactored_spFloat type:#string default:"" ui:specularfactored_spFloat
		_specularcolorfactored_spFloat type:#string default:"" ui:specularcolorfactored_spFloat
		_bumpiness_spVector4 type:#string default:"" ui:bumpiness_spVector4
		_reflectivepowered_spFloat type:#string default:"" ui:reflectivepowered_spFloat
		_dirtsampler_spTexture type:#string default:"" ui:dirtsampler_spTexture
		_dimmerset_spArray15OfVector4 type:#string default:"" ui:dimmerset_spArray15OfVector4
		_specular2factored_spVector4 type:#string default:"" ui:specular2factored_spVector4
		_specular2colorintensityed_spVector4 type:#string default:"" ui:specular2colorintensityed_spVector4
		_diffuse2specmod_spVector4 type:#string default:"" ui:diffuse2specmod_spVector4
		_texturesampler2_spTexture type:#string default:"" ui:texturesampler2_spTexture
		_fade_thickness_spFloat type:#string default:"" ui:fade_thickness_spFloat	

		on _texturesampler_spTexture set texname do
		(
			reloadTextures()
		)	
	)	
	
	rollout delegate_params "Delegate Parameters"
	(
		button			btn_delegate	"Open delegate material"	
		
		on btn_delegate pressed do
		(
			try
			(
				if (maxVersion())[1] >= 13000 then
				(
					MatEditor.Close()
					MatEditor.mode = #basic					
				)
			) catch
			(
			)
			MatEditor.Open()
			medit.PutMtlToMtlEditor this.delegate 24 
			medit.SetActiveMtlSlot 24 true
		)	
	)
	
	rollout params "Drawable Parameters"
	(
		label lbl_texturesampler_spTexture "texturesampler:spTexture" pos:[12, 500]
		label lbl_reflectivepower_spFloat "reflectivepower:spFloat" pos:[0, 0]
		label lbl_environmentsampler_spTexture "environmentsampler:spTexture" pos:[0, 0]
		label lbl_dirtdecalmask_spVector4 "dirtdecalmask:spVector4" pos:[0, 0]
		label lbl_specularfactor_spFloat "specularfactor:spFloat" pos:[0, 0]
		label lbl_specularcolorfactor_spFloat "specularcolorfactor:spFloat" pos:[0, 0]
		label lbl_bumpiness_spFloat "bumpiness:spFloat" pos:[0, 0]
		label lbl_bumpsampler_spTexture "bumpsampler:spTexture" pos:[0, 0]
		label lbl_zshift_spFloat "zshift:spFloat" pos:[0, 0]
		label lbl_emissivemultiplier_spFloat "emissivemultiplier:spFloat" pos:[0, 0]
		label lbl_specmapintmask_spVector4 "specmapintmask:spVector4" pos:[0, 0]
		label lbl_specsampler_spTexture "specsampler:spTexture" pos:[0, 0]
		label lbl_parallaxscalebias_spFloat "parallaxscalebias:spFloat" pos:[0, 0]
		label lbl_subcolor_spVector4 "subcolor:spVector4" pos:[0, 0]
		label lbl_texturesampler_layer0_spTexture "texturesampler_layer0:spTexture" pos:[0, 0]
		label lbl_texturesampler_layer1_spTexture "texturesampler_layer1:spTexture" pos:[0, 0]
		label lbl_texturesampler_layer2_spTexture "texturesampler_layer2:spTexture" pos:[0, 0]
		label lbl_texturesampler_layer3_spTexture "texturesampler_layer3:spTexture" pos:[0, 0]
		label lbl_matdiffusecolor_spVector4 "matdiffusecolor:spVector4" pos:[0, 0]
		label lbl_specularfactored_spFloat "specularfactored:spFloat" pos:[0, 0]
		label lbl_specularcolorfactored_spFloat "specularcolorfactored:spFloat" pos:[0, 0]
		label lbl_bumpiness_spVector4 "bumpiness:spVector4" pos:[0, 0]
		label lbl_reflectivepowered_spFloat "reflectivepowered:spFloat" pos:[0, 0]
		label lbl_dirtsampler_spTexture "dirtsampler:spTexture" pos:[0, 0]
		label lbl_dimmerset_spArray15OfVector4 "dimmerset:spArray15OfVector4" pos:[0, 0]
		label lbl_specular2factored_spVector4 "specular2factored:spVector4" pos:[0, 0]
		label lbl_specular2colorintensityed_spVector4 "specular2colorintensityed:spVector4" pos:[0, 0]
		label lbl_diffuse2specmod_spVector4 "diffuse2specmod:spVector4" pos:[0, 0]
		label lbl_texturesampler2_spTexture "texturesampler2:spTexture" pos:[0, 0]
		label lbl_fade_thickness_spFloat "fade_thickness:spFloat" pos:[0, 0]
		
		edittext texturesampler_spTexture align:#center visible:false pos:[12, 55]
		button	btn_texturesampler_spTexture "..." visible:false width:20 height:15
		
		edittext reflectivepower_spFloat align:#center visible:false pos:[0, 0]
		edittext environmentsampler_spTexture align:#center visible:false pos:[0, 0]
		button	btn_environmentsampler_spTexture "..." visible:false width:20 height:15
		
		edittext dirtdecalmask_spVector4 align:#center visible:false pos:[0, 0]
		edittext specularfactor_spFloat align:#center visible:false pos:[0, 0]
		edittext specularcolorfactor_spFloat align:#center visible:false pos:[0, 0]
		edittext bumpiness_spFloat align:#center visible:false pos:[0, 0]
		edittext bumpsampler_spTexture align:#center visible:false pos:[0, 0]
		button	btn_bumpsampler_spTexture "..." visible:false width:20 height:15
		
		edittext zshift_spFloat align:#center visible:false pos:[0, 0]
		edittext emissivemultiplier_spFloat align:#center visible:false pos:[0, 0]
		edittext specmapintmask_spVector4 align:#center visible:false pos:[0, 0]
		edittext specsampler_spTexture align:#center visible:false pos:[0, 0]
		button	btn_specsampler_spTexture "..." visible:false width:20 height:15
		
		edittext parallaxscalebias_spFloat align:#center visible:false pos:[0, 0]
		edittext subcolor_spVector4 align:#center visible:false pos:[0, 0]
		edittext texturesampler_layer0_spTexture align:#center visible:false pos:[0, 0]
		button	btn_texturesampler_layer0_spTexture "..." visible:false width:20 height:15
		
		edittext texturesampler_layer1_spTexture align:#center visible:false pos:[0, 0]
		button	btn_texturesampler_layer1_spTexture "..." visible:false width:20 height:15
		
		edittext texturesampler_layer2_spTexture align:#center visible:false pos:[0, 0]
		button	btn_texturesampler_layer2_spTexture "..." visible:false width:20 height:15
		
		edittext texturesampler_layer3_spTexture align:#center visible:false pos:[0, 0]
		button	btn_texturesampler_layer3_spTexture "..." visible:false width:20 height:15
		
		edittext matdiffusecolor_spVector4 align:#center visible:false pos:[0, 0]
		edittext specularfactored_spFloat align:#center visible:false pos:[0, 0]
		edittext specularcolorfactored_spFloat align:#center visible:false pos:[0, 0]
		edittext bumpiness_spVector4 align:#center visible:false pos:[0, 0]
		edittext reflectivepowered_spFloat align:#center visible:false pos:[0, 0]
		edittext dirtsampler_spTexture align:#center visible:false pos:[0, 0]
		button	btn_dirtsampler_spTexture "..." visible:false width:20 height:15
		
		edittext dimmerset_spArray15OfVector4 align:#center visible:false pos:[0, 0]
		edittext specular2factored_spVector4 align:#center visible:false pos:[0, 0]
		edittext specular2colorintensityed_spVector4 align:#center visible:false pos:[0, 0]
		edittext diffuse2specmod_spVector4 align:#center visible:false pos:[0, 0]
		edittext texturesampler2_spTexture align:#center visible:false pos:[0, 0]
		button	btn_texturesampler2_spTexture "..." visible:false width:20 height:15
		
		edittext fade_thickness_spFloat align:#center visible:false pos:[0, 0]
		
		dropdownlist	dl_shader		""		pos:[12, 10] items:ofio_iv_shaders selection:(select_id this.mtlid)
		
		on dl_shader selected id do
		(	
			select_id id
		)
		
		on texturesampler_spTexture changed text do
		(	
			this._texturesampler_spTexture = text
		)
		
		fn select_texture texname = (
			if texname == undefined then texname = ""
			texname = getOpenFileName filename:texname caption:"Select texture" types:"All|*.dds;*.tga;*.png;*.gif;*.jpg;*.bmp|dds|*.dds|tga|*.tga|png|*.png|gif|*.gif|jpg|*.jpg|bmp|*.bmp"
			return texname
		)

		on btn_texturesampler_spTexture pressed do
		(
			local texname = select_texture texturesampler_spTexture.text
			if texname != undefined then texturesampler_spTexture.text = texname
		)	

		on btn_environmentsampler_spTexture pressed do
		(
			local texname = select_texture environmentsampler_spTexture.text
			if texname != undefined then environmentsampler_spTexture.text = texname
		)

		on btn_bumpsampler_spTexture pressed do
		(
			local texname = select_texture bumpsampler_spTexture.text
			if texname != undefined then bumpsampler_spTexture.text = texname
		)	
		
		on btn_specsampler_spTexture pressed do
		(
			local texname = select_texture specsampler_spTexture.text
			if texname != undefined then specsampler_spTexture.text = texname
		)	

		on btn_texturesampler_layer0_spTexture pressed do
		(
			local texname = select_texture texturesampler_layer0_spTexture.text
			if texname != undefined then texturesampler_layer0_spTexture.text = texname
		)	
		
		on btn_texturesampler_layer1_spTexture pressed do
		(
			local texname = select_texture texturesampler_layer1_spTexture.text
			if texname != undefined then texturesampler_layer1_spTexture.text = texname
		)		
		
		on btn_texturesampler_layer2_spTexture pressed do
		(
			local texname = select_texture texturesampler_layer2_spTexture.text
			if texname != undefined then texturesampler_layer2_spTexture.text = texname
		)		
		
		on btn_texturesampler_layer3_spTexture pressed do
		(
			local texname = select_texture texturesampler_layer3_spTexture.text
			if texname != undefined then texturesampler_layer3_spTexture.text = texname
		)	
		
		on btn_dirtsampler_spTexture pressed do
		(
			local texname = select_texture dirtsampler_spTexture.text
			if texname != undefined then dirtsampler_spTexture.text = texname
		)		

		on btn_texturesampler2_spTexture pressed do
		(
			local texname = select_texture texturesampler2_spTexture.text
			if texname != undefined then texturesampler2_spTexture.text = texname
		)	
	)
)