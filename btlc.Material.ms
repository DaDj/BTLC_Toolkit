fileIn "RW_Material.ms"

BTLC_MatShader = attributes "BTLC_MatShader"  attribID:#(0x3c0e6f, 0xb139b19)
(
	parameters main
	(
		MYShaderID type:#integer default:0;
		MyShaderType type:#integer default:0;
		MyShaderName type:#string	default:"";
    MyShaderOrgMatId type:#integer default:0
    MyShaderIsAnim type:#integer default:0
	)
	rollout params "BTLC MaterialData"
	(
		spinner lblShaderID  "ShaderID" type:#integer
		spinner lnlShaderType  "ShaderType"  type:#integer
		edittext lnShaderName  "ShaderName" type:#string
    spinner lblOrgMatID "OrgMatId" type:#integer
    spinner lblisANim "Is Animated" type:#integer
		on params open do 
		(
			lblShaderID.value = MYShaderID
			lnlShaderType.value = MyShaderType
			lnShaderName.text = MyShaderName
      lblOrgMatID.value = MyShaderOrgMatId
      lblisANim.value = MyShaderIsAnim
		)
	)
)

struct Btlc_TextureDB  --Setup after OPL reader read all used files
(
  Folders = #(), --Main folder to search for textures.
  TexturesList = #(), -- Full Filepaths to all Textures
  TexNameList = #(), -- Names to all Textures in same Order
  
  fn FindAllTextures = 
  (
    for MyFolder in Folders do 
    (
      if MyFolder != "" do 
      (
        for d in getDirectories (MyFolder + "\*") do
        (
          for f in getFiles (d + "*.*") do appendIfUnique TexturesList f
        )
      )
    ) 
   local i = 1
    for TexPath in TexturesList do 
    (
      TexNameList[i] = getFilenameFile TexPath
      TexNameList[i] = toLower TexNameList[i] 
      i += 1
    )
  )
)
 = Btlc_TextureDB();

struct Btlc_Material 
(
  EnableReflections = true,

  fn CondenseMaterialIds obj =(
    mat = obj.material

    if mat != undefined and isKindOf mat Multimaterial and isKindOf obj editable_mesh do (

        subs = mat.materiallist
        count = subs.count
        sub_materials = #() 
        sub_material_names = #()
        old_ids = #()

        for i = 1 to subs.count where subs[i] != undefined do (
            sub_mat = subs[i]
            append sub_materials sub_mat
            append sub_material_names sub_mat.name
            append old_ids i
        )

        new_count = sub_materials.count

        for f = 1 to obj.numfaces do (
            old_f_mat_id = getFaceMatID obj f
            
            index = findItem old_ids old_f_mat_id

            if index > 0 then (
                new_f_mat_id = index
            )
            else (
                new_f_mat_id = new_count
            )

            setFaceMatID obj f new_f_mat_id
        )

        new_mat = MultiMaterial numsubs:new_count materiallist:sub_materials names:sub_material_names
        obj.material = new_mat
    )
  ),
  fn FindEnvTexId Shadername= 
  (
    Shader = getFilenameFile Shadername
    idx = finditem ofio_iv_shaders Shader
    idx2 =  finditem  ofio_iv_shader_params[idx] "environmentsampler_spTexture"
    idx2
  ),

  fn SetMaterialData  shader MatId:0 =
  (
    TheName =  toLower (shader[2]) 
    TheName = getFilenameFile TheName
    rw = RW_Mtl()
    rw.sp_ambient  = 1.0
    rw.sp_specular = 1.0 
    rw.sp_diffuse  = 1.0
    rw.color = color 255 255 255 255
    
    /* std map */
    if TheName.count >  26 do TheName = substring TheName 1 26
    local  idx = finditem BtlcTextDB.TexNameList TheName
    FilePath = TheName
    if idx != 0 do  FilePath = BtlcTextDB.TexturesList[idx]
    if idx == 0 and FilePath != "null" do 
    ( 
      print "Not Found:"  
      print FilePath
    )
    rw.texmap_texture = bitmaptexture filename:Filepath
    rw.name =  TheName

    rw.delegate.shaderType = 1;
    if rw.texmap_texture != undefined do
    (
      rw.delegate.diffuseMap.color1 = rw.color*rw.sp_diffuse
    )
    rw.delegate.diffuse = rw.color*rw.sp_diffuse

    /* Reflection map */
    envId = -1
    if btlcMaterial.EnableReflections == true do 
    (
      if ((findstring shader[1] "reflect") != undefined) do envId = FindEnvTexId shader[1]
    )
  
    if envId != -1 do 
    (
      TheTexName = getFilenameFile shader[envId + 1]
      TheTexName = toLower TheTexName
      idxEnv = finditem BtlcTextDB.TexNameList TheTexName
      if idxEnv != 0 do  
      (
        FilePath = BtlcTextDB.TexturesList[idxEnv]
        rw.enEnv = true
        rw.shininess = 0.5
        rw.matfxeffect = 3
        rw.texmap_envmap = bitmaptexture filename:Filepath
        rw.envmap_amount = 0.65
      )
    ) 

    /* Opacity */
    rw.delegate.opacityMap = undefined
    if ((findstring shader[1] "decal") != undefined) or ((findstring shader[1] "alpha")  != undefined) or ((findstring shader[1] "glass")  != undefined) or ((findstring shader[1] "cutout")) != undefined then
    (					
        alphamap = copy  rw.texmap_texture 
				alphamap.monoOutput = 1
				rw.delegate.opacityMap = alphamap
				rw.delegate.opacityMap.output.invert = false
    )
 
    custAttributes.add rw BTLC_MatShader
    rw.MyShaderID = 0
    rw.MyShaderType = 2
    rw.MyShaderName = shader[1]
    rw.MyShaderOrgMatId = MatId
    rw.showInViewport = true
    rw
  ),

  fn SetMeshFace_MatID node matID newID = if iskindof node Editable_Mesh do
  (
    if canconvertto node Editable_Mesh do converttomesh node
    faces = for f=1 to node.numfaces where (getFaceMatID node f) == matID do setfaceMatID node f newID
    update node
  ),

  fn ShuffleThisMaterial obj MtlID =
  (
    if MtlID < obj.Material.MaterialList.Count  do 
    (
      obj.Material.MaterialList.Count = obj.Material.MaterialList.Count +1
      obj.Material.MaterialList[obj.Material.MaterialList.Count] =  copy obj.Material.MaterialList[MtlID]
      SetMeshFace_MatID obj MtlID obj.Material.MaterialList.Count
      obj.Material.MaterialList[MtlID]  = undefined
      --obj.Material.MaterialList[MtlID].name = "Useless"
    )
  ),

  fn ReshuffleByShader obj  = 
  (
    if (classof obj.Material) != Multimaterial do return() -- no need to reshuffle if its only one anyway. lol

    for MtlID= 1 to obj.Material.MaterialList.Count do
    (
      if obj.Material.MaterialList[MtlID] != undefined then
      (   
        try
        (
          Shader = custAttributes.get obj.Material.MaterialList[MtlID] BTLC_MatShader 
        
          if Shader != undefined do
          (
            if ((findstring Shader.MyShaderName "decal") != undefined) or ((findstring Shader.MyShaderName "alpha")  != undefined) or ((findstring Shader.MyShaderName "glass")  != undefined) then
            (					
              ShuffleThisMaterial obj MtlID
            )
          )
      
        )
        catch
        (
          format "***Error In ReshuffleTexturebyIVShader:  % ***   % \n " obj.name (getCurrentException()) 
        )
      )
    )

    CondenseMaterialIds obj;
  )


)
btlcMaterial = Btlc_Material();