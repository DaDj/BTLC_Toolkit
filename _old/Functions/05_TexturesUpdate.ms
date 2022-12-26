

function CutTextureNames obj optional_param:unsupplied =
(
	
)

function GetTextureList GenericDir TexturesDir =
(	
	progressStart "Generating Texture List" 	

	MyTexList =#()

	-- Get generic textures
	tmppath = GenericDir +"\*" ;
	for d in getDirectories tmppath do
	for f in getFiles (d + "*.*") do
	appendIfUnique MyTexList f

	-- Append Current texturesDir textures
	tmppath = TexturesDir +"\*" ;
	for d in getDirectories tmppath do
	for f in getFiles (d + "*.*") do
	appendIfUnique MyTexList f
	progressEnd() 
	MyTexList

)
  
/*Update the paths of textures to converted and shotend paths */
function UpdateTexturepathofObj i TextureList  TexturenameList optional_param:unsupplied =
(	
	--progressStart "Update texture Paths to Sa Format" 	
	disablesceneredraw()

	if  i.Material != undefined do (
		for MtlID = 1 to i.Material.MaterialList.Count do 
		(
			if  i.Material.MaterialList[MtlID] != undefined do
			(
				if i.Material.MaterialList[MtlID].diffuseMap != undefined do
				(

					/*Cut Texturenames */
					texture_name = (filterString i.Material.MaterialList[MtlID].diffuseMap.filename	"\\")
					texture_name_1= i.Material.MaterialList[MtlID].diffuseMap.filename	
						
					if texture_name[texture_name.count].count < 26 + 5 do
					(
						test = texture_name[texture_name.count].count  
						test  = test - 4
						texture_name_3 = substring 	texture_name[texture_name.count] 1 test
					)
					if texture_name[texture_name.count].count > 26 + 4 do
					(	
						texture_name_3 = substring 	texture_name[texture_name.count] 1 26
					)
					append texture_name_3 ".dds"
					texture_name_new = substituteString texture_name_1 texture_name[texture_name.count] texture_name_3 
					i.Material.MaterialList[MtlID].diffuseMap.filename = texture_name_new
					

					/* Update to new Texture paths */
					texture_PathSource = i.Material.MaterialList[MtlID].diffuseMap.filename	
					TxtName = 	filenameFromPath texture_PathSource
					TxtName = toLower TxtName
					index = findItem TexturenameList TxtName 
				
					if index > 0  then
					(
						i.Material.MaterialList[MtlID].diffuseMap.filename = TextureList[index] 
						
					)
					else 
					(
						enablesceneredraw()
						print ("Couldn't find Texture for : " + TxtName)
						disablesceneredraw
					)


				)

				/* Cut Material Name */
				material_name = ( i.Material.MaterialList[MtlID].name)
				if material_name.count > 26 do i.Material.MaterialList[MtlID].name = (substring material_name 1 26)
			)
		)
	)
	--progressEnd() 
	enablesceneredraw()
	--redrawviews()
)

function MassUpdateTextures =
(
	TextureList = GetTextureList  MyConfig.GenericSATexDir (MyConfig.CurrentSACityPart + "\\txd") -- we always assume that the parts have an txd folder inside!
	TexturenameList = #()
	for texpath in TextureList do 
	(
		TxtName = 	filenameFromPath texpath
		TxtName = toLower TxtName
		append TexturenameList TxtName		
	) 

	for obj in objects do 
	(	
		UpdateTexturepathofObj obj TextureList  TexturenameList
	)

)