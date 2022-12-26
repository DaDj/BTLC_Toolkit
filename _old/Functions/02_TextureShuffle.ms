fn SetMeshFace_MatID node matID newID = if iskindof node Editable_Mesh do
(
	if canconvertto node Editable_Mesh do converttomesh node
	faces = for f=1 to node.numfaces where (getFaceMatID node f) == matID do setfaceMatID node f newID
	update node
)

fn ReshuffleTexture obj MtlID =
(
	if MtlID < obj.Material.MaterialList.Count  do 
	(
		obj.Material.MaterialList.Count = obj.Material.MaterialList.Count +1
		obj.Material.MaterialList[obj.Material.MaterialList.Count] =  copy obj.Material.MaterialList[MtlID]
		SetMeshFace_MatID obj MtlID obj.Material.MaterialList.Count
		--obj.Material.MaterialList[MtlID]  = undefined	
	)
)

/*
Go trough the Materials and find materials with shadernames which are transparent.
Set this material as the last in the list(and change the face id to if ofc)
*/
fn ReshuffleTexturebyIVShader obj  = 
(
	for MtlID= 1 to obj.Material.MaterialList.Count do
	(
		if obj.Material.MaterialList[MtlID] != undefined then
		(   
			try
			(
				Shader = custAttributes.get obj.Material.MaterialList[MtlID] BTLC_MatShader 
				if ((findstring Shader.MyShaderName "decal") != undefined) or ((findstring Shader.MyShaderName "alpha")  != undefined) or ((findstring Shader.MyShaderName "glass")  != undefined) then
				(					
					--print Shader.MyShaderName
					ReshuffleTexture obj MtlID
				)
			)
			catch
			(
				format "***Error In ReshuffleTexturebyIVShader:  % ***   % \n " obj.name (getCurrentException()) 
			)
		)
	)
)