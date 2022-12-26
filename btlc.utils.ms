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
 )
)
btlcUtil = btlc_utils();
