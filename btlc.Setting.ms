struct BTLCConfig 
(
	ConfigDir = GetDir #plugcfg+ @"\BTLCToolkit",
	ConfigFile = ConfigDir + @"\Btlc_Cfg.ini",
    IntialDirs = "F:\Modding\BTLC\02_GameData",
	-- Generic Settings
	GenericTexDir = "", -- Generic texture 

	-- Current Settings
	CurrentCityPart = "", -- Path to the wdr,wtd,wpl etc files (original IV)
	CurrentExpoSaPAth = "", -- Path to the "Output" Folder
	MainGameDataDir = "",
	CurrentModelConvPath = "",
	CurrentModelConvPathSA = "",
	CurrentID = 1000,
	function Save  = 
	(
		try 
		(
			makedir ConfigDir
		)
		catch 
		(
			messageBox title:"Permission Error while creating the Settings File"
		)
		setINISetting ConfigFile "Directories" "MainGameDataDir" MainGameDataDir
		setINISetting ConfigFile "Directories" "GenericTexDir" GenericTexDir
		setINISetting ConfigFile "Directories" "CurrentCityPart" CurrentCityPart
		setINISetting ConfigFile "Directories" "CurrentExpoSaPAth" CurrentExpoSaPAth
		setINISetting ConfigFile "Directories" "CurrentModelConvPath" CurrentModelConvPath
		setINISetting ConfigFile "Directories" "CurrentModelConvPathSA" CurrentModelConvPathSA
		setINISetting ConfigFile "Data" "CurrentID" (CurrentID as string)
	),

	function Load = 
	(
		GenericTexDir 	= if (tmp = getINISetting ConfigFile "Directories" "GenericTexDir") != undefined then tmp else "" 
		CurrentCityPart =  if (tmp = getINISetting ConfigFile "Directories" "CurrentCityPart") != undefined then tmp else ""
		CurrentExpoSaPAth = if (tmp = getINISetting ConfigFile "Directories" "CurrentExpoSaPAth") != undefined then tmp else ""
		MainGameDataDir = if (tmp = getINISetting ConfigFile "Directories" "MainGameDataDir") != undefined then tmp else ""
		CurrentModelConvPath = if (tmp = getINISetting ConfigFile "Directories" "CurrentModelConvPath") != undefined then tmp else ""
		CurrentModelConvPathSA = if (tmp = getINISetting ConfigFile "Directories" "CurrentModelConvPathSA") != undefined then tmp else ""
		CurrentID = if (tmp = getINISetting ConfigFile "Data" "CurrentID") != undefined then tmp else "1000"
	),

	function UpdateCurrentID IdeFile = 
	(
		CurrentID = btlcUtil.GetMaxIDFromIDE IdeFile;
		print CurrentID
		Save();
	)
)
btlcConfig = BTLCConfig()
btlcConfig.Load()