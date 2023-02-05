struct BTLC_UVAnim  
(
    myAnims = #(),
    
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
        print Path
        local fInput = openFile Path
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
		while elements[1] != "}" do
        (
            
            myAnims[AnimId] =  ofio_iv_anim()
            OutPath = (pathConfig.removePathLeaf Path)
            MyPath = OutPath + "\\" + elements[2]
            print MyPath
            myAnims[AnimId].read MyPath
            elements = scanline fInput
            AnimId = AnimId + 1
        )
        close fInput
    ),

    fn ApplyAnim Obj = 
    (
       for UvAnim in myAnims do 
       (
            for Mat in Obj.material do
            (
                if Mat.MyShaderOrgMatId  ==  (UvAnim.MaterialID + 1 )  do 
                (
                    UvAnim.ApplyAnimtoMaterial Mat
                )
            )
       )
    )
)
BtlcUVAnim = BTLC_UVAnim()

-- Check if aniamtion is there.
--selection[1].material.diffuseMap.coords.U_Offset.isAnimated