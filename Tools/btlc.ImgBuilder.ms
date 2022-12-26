struct btlc_ImgBuilder 
(
        function BuildImg_WirteIni thePath =
    (
        f =  openFile thePath mode:"w+"
        format   "[Attribs] \n" to:f
        format   "version=NEWIMG \n" to:f
        format   "\n" to:f
        format  "[Dirs] \n" to:f
        format  "img \n" to:f
        close f
    ),

    function BuildImg IniPath OutPath =
    (
        BuildImg_WirteIni IniPath
        
        Command =    "\"" + IniPath + "\"" + " \"" + OutPath + "\""
        scriptPath = (GetDir #userScripts )
       print Command
        Program =  scriptPath + "\\BTLC\\Tools\\imgbuilder.exe"
        ShellLaunch Program Command
    )
)
btlcImgBuild = btlc_ImgBuilder();