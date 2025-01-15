struct MapFuse
(
    VanillaFolder ="",
    DLCFolder = "",
    fn CombineSingleIde VanillaPath DLCPath =
    (

    ),

    fn CombineAllIde = 
    (
        vanillafiles = getFiles "F:\Modding\BTLC\02_GameData\IVnew\data\maps\*.ide" recurse:true;
        DLCFiles = getFiles "F:\Modding\BTLC\02_GameData\IVtbogt\data\maps\*.ide" recurse:true;
        oldCombfiles =  getFiles "F:\Modding\BTLC\02_GameData\IV\data\maps\*.ide" recurse:true;
        --for f in vanillafiles do print f
        
        
        for f in oldCombfiles do deleteFile f -- cleanup all ides currently sitting in the files first.
        
        for f in vanillafiles do 
        (
            NewPath =  substituteString f "IVnew" "IV"
            if doesFileExist NewPath do 
            (
                print ("deleted:" + NewPath)
                deleteFile NewPath
                
            )
            copyFile f NewPath
        )
        
        for f in DLCFiles do 
        (
            NewPath =  substituteString f "IVtbogt" "IV"
            if doesFileExist NewPath then 
            (
                print ("exists:" + NewPath)
                DlcIde = btlc_IV_IDE()
                DlcIde.thePath = f;
                DlcIde.Load();
                
                IVIde = btlc_IV_IDE()
                IVIde.thePath = NewPath;
                IVIde.Load();
                
                for aLine in DlcIde.objsorg do 
                (
                    fl = filterString aLine  ","
                    
                    isNew = true
                    for iLine = 1 to   IVIde.objsorg.count do 
                    (
                        IVfl = filterString IVIde.objsorg[iLine]  ","
                        if matchpattern IVfl[1] pattern:fl[1] then 
                        (
                            print fl[1]
                            IVIde.objsorg[iLine] =  aLine;
                            isNew = false
                        )					              
                    )
                    if isNew == true do 
                    (
                        append IVIde.objsorg aLine
                        print ("appended: " + fl[1]) 
                    )
                )
                print ("tobjs") 
                for aLine in DlcIde.tobjsorg do 
                (
                    fl = filterString aLine  ","
                    
                    isNew = true
                    for iLine = 1 to   IVIde.tobjsorg.count do 
                    (
                        IVfl = filterString IVIde.tobjsorg[iLine]  ","
                        if matchpattern IVfl[1] pattern:fl[1] then 
                        (
                            print fl[1]
                            IVIde.tobjsorg[iLine] =  aLine;
                            isNew = false
                        )					              
                    )
                    if isNew == true do 
                    (
                        append IVIde.tobjsorg aLine
                        print ("appended" + fl[1]) 
                    )
                )
                print ("anim") 
                for aLine in DlcIde.animorg do 
                (
                    fl = filterString aLine  ","
                    
                    isNew = true
                    for iLine = 1 to   IVIde.animorg.count do 
                    (
                        IVfl = filterString IVIde.animorg[iLine]  ","
                        if matchpattern IVfl[1] pattern:fl[1] then 
                        (
                            print fl[1]
                            IVIde.animorg[iLine] =  aLine;
                            isNew = false
                        )					              
                    )
                    if isNew == true do 
                    (
                        append IVIde.animorg aLine
                        print ("appended" + fl[1]) 
                    )
                )

                print ("txdp") 
                for aLine in DlcIde.txdporg do 
                (
                    fl = aLine  
                    
                    isNew = true
                    for iLine = 1 to   IVIde.txdporg.count do 
                    (
                        IVfl =  IVIde.txdporg[iLine] 
                        if matchpattern IVfl pattern:fl then 
                        (
                            print fl
                            IVIde.txdporg[iLine] =  aLine;
                            isNew = false
                        )					              
                    )
                    if isNew == true do 
                    (
                        append IVIde.txdporg aLine
                        print ("appended" + fl) 
                    )
                )



                IVIde.SaveOrg()
            )
            else
            (
                copyFile f NewPath
            )
        )
    )
) 

-- Fuser = MapFuse()
--Fuser.CombineAllIde()