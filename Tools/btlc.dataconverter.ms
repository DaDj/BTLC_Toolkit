/* 
Example: 
python = SystemTools.GetEnvVariable "PYTHONPATH"
Dos_Command.run python arg_array:#("C:\path\to\script.py", "--argument 1.0", "-verbose")

*/
global Dos_Command
struct DOSCMD (
	fn run exe_path arg_array:undefined as_string:false =
	(
		local process = dotNetObject "System.Diagnostics.Process"

		process.StartInfo.UseShellExecute = false
		process.StartInfo.RedirectStandardOutput = true
		process.StartInfo.RedirectStandardError = true
		process.StartInfo.FileName = exe_path
		process.StartInfo.Arguments = ""
		
		if arg_array != undefined then
		(
			for arg in arg_array do (process.StartInfo.Arguments += (" " + arg as string))
		)

		process.Start()
		process.WaitForExit()

		local _output = process.StandardOutput.ReadToEnd()
		local _error = process.StandardError.ReadToEnd()

		process.Close()
		process.Dispose()
		
		if _error == "" then
		(
			if as_string then return (trimRight _output "\r\n")
			else return (filterString _output "\r\n" splitEmptyTokens:false)
		)
		else
		(
			if as_string then return (trimRight _error "\r\n")
			else return (filterString _error "\r\n" splitEmptyTokens:false)
		)
	)
)
if Dos_Command == undefined then Dos_Command = DOSCMD()


struct btlc_MapDataConverter 
(
	fn ConvertIDE SrcPath DestPath StartID = 
	(
		scriptPath = (GetDir #userScripts )
		Program =  scriptPath + "\\BTLC\\Tools\\GTAConverter.exe"
		Dos_Command.run Program arg_array:#("-IdeConvert",   SrcPath,  DestPath, StartID)
	),

	fn CopyTextures SrcPath DestPath = 
	(
		scriptPath = (GetDir #userScripts )
		Program =  scriptPath + "\\BTLC\\Tools\\GTAConverter.exe"
		Dos_Command.run Program arg_array:#("-textureconvert",   SrcPath,  DestPath)
	),

	fn ConvertPlacementData SrcPath DestPath = 
	(
		-- Todo : update paths using Scrpath and Destpath
		--SrcPath = IVPath and DestPath = SAPath
		scriptPath = (GetDir #userScripts )
		local Program =  scriptPath + "\\BTLC\\Tools\\GTAConverter.exe"
		local Dirname = (pathConfig.stripPathToLeaf SrcPath)
		local IdeFile = "\"" + DestPath + "\\" + Dirname + ".ide" + "\""
		local ObjFile = "\"" +  SrcPath +  @"\Object.objs" + "\""
		local OPLPath =  "\"" + (SrcPath) + "\\wpl" + "\""
		local MainWPL = "\"" + (pathConfig.removePathLeaf SrcPath) + "\\" + Dirname + ".opl" + "\""
		local MdlPath = "\"" + SrcPath + "\\wdr" + "\""
		local OutputDir = "\"" + DestPath  + "\""
		
		Dos_Command.run Program arg_array:#("-MapConvert", IdeFile, ObjFile, OPLPath, MainWPL,  MdlPath, OutputDir)
	),

	fn PropPlace IdePath OPLPath DestPath Name= 
	(
		scriptPath = (GetDir #userScripts )
		Program =  scriptPath + "\\BTLC\\Tools\\GTAConverter.exe"
		Dos_Command.run Program arg_array:#("-PropPlace",   IdePath,  OPLPath, DestPath, Name)
	)
)
btlcDataConverter = btlc_MapDataConverter();

--btlcDataConverter.PropPlace "F:\Modding\BTLC\02_GameData\proplacer\currentides" "F:\Modding\BTLC\02_GameData\proplacer\allopl\manhat"  "F:\Modding\BTLC\02_GameData\proplacer\out" "PrpsMh"
--btlcDataConverter.PropPlace "F:\Modding\BTLC\02_GameData\proplacer\currentides" "F:\Modding\BTLC\02_GameData\proplacer\allopl\brook"  "F:\Modding\BTLC\02_GameData\proplacer\out" "PrpsBrook"
--btlcDataConverter.PropPlace "F:\Modding\BTLC\02_GameData\proplacer\currentides" "F:\Modding\BTLC\02_GameData\proplacer\allopl\queens"  "F:\Modding\BTLC\02_GameData\proplacer\out" "PrpsQns"
/*
function ConvertIDE SrcPath DestPath StartID= 
(
	scriptPath = (GetDir #userScripts )

	Program =  scriptPath + "\\BTLC\\Functions\\GTAConverter.exe"
	--print SrcPath
	--print DestPath
	--print StartID
	Dos_Command.run Program arg_array:#("-IdeConvert",   SrcPath,  DestPath, StartID)
)

function CopyTextures SrcPath DestPath =
(
	scriptPath = (GetDir #userScripts )

	Program =  scriptPath + "\\BTLC\\Functions\\GTAConverter.exe"
	--print SrcPath
	--print DestPath
	Dos_Command.run Program arg_array:#("-textureconvert",   SrcPath,  DestPath)
)   
 
function Convert_MapConvert  =
(
	local Program =  scriptPath + "\\BTLC\\Functions\\GTAConverter.exe"
	local Dirname = (pathConfig.stripPathToLeaf MyConfig.CurrentCityPart)
	local IdeFile = "\"" + MyConfig.CurrentSACityPart + "\\" + Dirname + ".ide" + "\""
	local ObjFile = "\"" +  MyConfig.CurrentCityPart +  @"\Object.objs" + "\""
	local OPLPath =  "\"" + (MyConfig.CurrentCityPart) + "\\wpl" + "\""
	local MainWPL = "\"" + (pathConfig.removePathLeaf MyConfig.CurrentCityPart) + "\\" + Dirname + ".opl" + "\""
	local MdlPath = "\"" + MyConfig.CurrentCityPart + "\\wdr" + "\""
	local OutputDir = "\"" + MyConfig.CurrentSACityPart  + "\""
	
	Dos_Command.run Program arg_array:#("-MapConvert", IdeFile, ObjFile, OPLPath, MainWPL,  MdlPath, OutputDir)
)
*/