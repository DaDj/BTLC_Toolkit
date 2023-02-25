struct btlc_utils 
(
	function  GetMaxIDFromIDE IDEFile = 
	(
		theFile = openfile IDEFile
		myIds = #()
		if theFile != undefined then
		(
			while not eof theFile do
			(
				mystring = readline theFile
				mystring = filterString  mystring ", "
				
				if mystring[1] != undefined and mystring[1] != "objs" and mystring[1] != "tobj" and  mystring[1] != "end" and  mystring[1] != "txdp" do 
				(
					if mystring.count == 5 or mystring.count == 7 do append myIds (mystring[1] as integer)
					
				)
				
			)
			close theFile
			gc()
			free theFile
			TheID =  (amax myIds)
		)
		TheID
	),

	fn CutNameAdv TheName = 
	( -- Cut Names in a more advanced way.
		/* Testfucntion:
        thename =  "ABCDEFGHIJKLMNOPQRSTU";
        thename.count
        thename =  btlcUtil.CutNameAdv thename;
        thename.count
        */
		
		-- 1. delete underscores in name to reduce character count
		if TheName.count >  19 then 
		(
			TheName = substituteString TheName  "_" ""
		) 
		-- 2. if its still too long try to delete every second character till it fits
		if TheName.count >  19 then 
		(
			iOverMax = TheName.count - 19

			for idx = 1 to iOverMax do 
			(
				TheName =  replace TheName (idx + 1) 1 ""
			)
		)
		-- 3. if that doesnt help..cut the end characters..should never happen. lol
		if TheName.count >  19 then 
		(
			TheName = substring TheName 1 19
		)
		TheName
	)
)
btlcUtil = btlc_utils();


fn get_all_nodes nodes =
(
	allnodes = #()
	
	for n in nodes do
	(
		append allnodes n
		join allnodes (get_all_nodes (n.children))
	)
	
	allnodes
)