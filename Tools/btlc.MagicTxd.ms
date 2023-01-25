struct btlc_MagicTxd 
(
	function GenTXD_PrepareIniFile TxdPath OutPath =
	(
        scriptPath = (GetDir #userScripts )
		path =  (scriptPath + "\\BTLC\\Tools\\Magic.TxdBuilder.ini")
		f =  openFile path mode:"w+"
		format   "[MAIN] \n" to:f
		format   ("lastPath=" +  TxdPath + "\n") to:f
		format   ("lastOutPath=" + OutPath +"\n") to:f
		format  "lastCheckOutput=0 \n" to:f
		format  "lastCheckChild=1 \n" to:f
		format  "lastMipGen=1 \n" to:f
		format  "lastAnisot=8 \n" to:f
		format  "lastGame=0 \n" to:f
		format  "lastCompression=1 \n" to:f
		format  "lastCompressionAlpha=5 \n" to:f
		format  "lastDDS=1 \n" to:f
		format  "lastPNG=1 \n" to:f
		format  "lastBMP=1 \n" to:f
		format  "lastTGA=1 \n" to:f
		close f
	),

	function GenTXD_RunMagicTxdPresser = 
	(
        scriptPath = (GetDir #userScripts )
		Program =  scriptPath + "\\BTLC\\Tools\\MAgicTxdPresser.exe"
		ShellLaunch  Program ""
	),

	function RunMagicTxd TxdPath OutPath = 
	(
		GenTXD_PrepareIniFile TxdPath OutPath
		scriptPath = (GetDir #userScripts )
		Program =  scriptPath + "\\BTLC\\Tools\\Magic.TxdBuilder.exe"
		ShellLaunch  Program ""
	),

	function GenerateTxds TxdPath OutPath =
	(
		GenTXD_PrepareIniFile TxdPath OutPath
		GenTXD_RunMagicTxdPresser()
	)
)

btlcMagicTxd = btlc_MagicTxd();