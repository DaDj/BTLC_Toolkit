function BuildImg_WirteIni thePath =
(
    f =  openFile thePath mode:"w+"
    format   "[Attribs] \n" to:f
    format   "version=NEWIMG \n" to:f
    format   "\n" to:f
    format  "[Dirs] \n" to:f
    format  "img \n" to:f
    close f
)

function BuildImg IniPath OutPath =
(
    Command =    "\"" + IniPath + "\"" + " \"" + OutPath + "\""

    print Command
    Program =  scriptPath + "\\BTLC\\Tools\\imgbuilder.exe"
	ShellLaunch Program Command
)