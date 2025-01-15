struct BTLC_UVAnim  
(
    myAnims = #(),
    MyObjs = #(),
    
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

    fn ImportAnim Path =
    (
        local fInput = openFile Path
        if fInput == undefined do return 0;

		ofio_iv_opened_blocks = 0
		local version = scanline fInput
		if (version[2] as Integer != 1) or (version[3] as Integer != 2) then
		(
			close fInput
			throw "not supported *.onim, version 1 2 is supported only"		
		)
		local blockStart = scanline fInput
		if blockStart[1] != "{" then throw "block start expected"
		local i, elements = scanline fInput
        AnimId = 1
        iAnim = 1
		while elements[1] != "}" do
        (
            OutPath = (pathConfig.removePathLeaf Path)
            MyPath = OutPath + "\\" + elements[2]
            AnimObjName = getFilenameFile MyPath
            if matchpattern AnimObjName pattern:"*_uv_*" do 
            (
                myAnims[AnimId] =  ofio_iv_anim()
                myAnims[AnimId].read MyPath
             
                Deletestart = (findString AnimObjName "_uv_") 
                Deletestart = Deletestart - 1
                AnimObjName =  substring AnimObjName 1 Deletestart
                AnimObjName = btlcUtil.CutNameAdv AnimObjName
              
                MyObjs[AnimId] = AnimObjName
                AnimId = AnimId + 1 --only if added..i guess?
            )
            elements = scanline fInput
        )
        close fInput
        MyObjs.count
    ),

    fn ApplyAnim Obj = 
    (
       for  AnimId=1 to MyObjs.count do 
       (
            UvAnim = myAnims[AnimId]
            if (matchpattern MyObjs[AnimId] pattern:Obj.name) == true do
           (
               -- print  Obj.name
               if classof Obj.material != MultiMaterial then 
               (
                    Mat =  Obj.material
                    if Mat.MyShaderOrgMatId  ==  (UvAnim.MaterialID + 1 )  do 
                    (
                        UvAnim.ApplyAnimtoMaterial Mat
                        Mat.matfxeffect = 6
                    )
               )
               else 
               (
                    for Mat in Obj.material do
                    (
                        if Mat.MyShaderOrgMatId  ==  (UvAnim.MaterialID + 1 )  do 
                        (
                            UvAnim.ApplyAnimtoMaterial Mat
                            Mat.matfxeffect = 6
                        )
                    )
               )
              
            ) 
       )
    ),

    fn ApplytoAllObjs = 
    (
        for aObj in objects where aObj.parent == undefined do 
        (
            ApplyAnim aObj
        )
    )
)
BtlcUVAnim = BTLC_UVAnim()

-- Check if aniamtion is there.
--selection[1].material.diffuseMap.coords.U_Offset.isAnimated