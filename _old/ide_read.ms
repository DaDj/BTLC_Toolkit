 
  theFile = openfile @"F:\Modding\BTLC\02_GameData\SA\data\maps\jersey\nj_liberty\nj_liberty.ide"
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
			print (amax myIds)
		)