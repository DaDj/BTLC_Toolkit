global MyBtlcRoot = pathConfig.removePathLeaf ( getSourceFileName()) ;

fn btlcStartupLoadALL MyRoot = 
(
    local files = #()
    files =  getfiles (MyBtlcRoot + "\\*.ms")
    files = deleteItem files  (finditem files (getSourceFileName())) -- dont laod startup ms again

	local dirs = getDirectories ( ( trimright MyRoot "\\" ) + "\\*" )
	for d in dirs do join dirs ( getDirectories ( ( trimright d "\\" ) + "\\*" ) )

	for d in dirs where not ( matchpattern d pattern:"*_old*" ) do join files ( getFiles ( ( trimright d "\\" ) + "\\*.ms" ) )

	for f in files do 
    (	
	 try 
	 (
		fileIn f
		format "loaded script '%'\n" f
	 )	
	 catch
	 (
		format "failed loading script '%'\n" f
	 )
	)
)

btlcStartupLoadALL MyBtlcRoot
btlcStartupLoadALL MyBtlcRoot