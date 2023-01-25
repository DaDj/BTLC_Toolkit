struct btlcIplTool
(
 fn ReadIde = 
 ( 
	-- LOAD IDE TO SELECTED OBJECTS
	obj = $selection as array
	
	if obj.count > 0 then
	(
	clearListener ()
	
	fname = getOpenFileName caption:"select IDE"  types:"GTA IDE file (*.ide)|*.ide|"
	if fname !=undefined do
	( 
	  ideid = #()
	  idelod = #()
	  idename = #()
	  
	  f = openFile fname
	  er_code = 0
	  
	  do         -- file pos to OBJS
	   if not eof f then (
	     s = readLine f
	     s = no_comments s
	     if (lowercase s == "objs") do exit
	   )
	    else ( er_code = 1 
		       exit )
	  while true
	  
	  --------------------
	  if er_code == 0 then 
	  (
	   n = 0
	
	   do
	    if not eof f then 
		(
		 s = readLine f
		 s = no_comments s
		 if s == "end" then exit
		 if s != "" do
		 (
		  fs = #()
		  fs = filterString s  ","
		  if fs.count >4 then
		   (
		    n += 1
		    ideid[n] = trimLeft(trimRight fs[1])
		    idename[n] = lowercase (trimLeft(trimRight fs[2]))
		    idelod[n] = "0"
		   )
		  else ( er_code = 2
		         exit )
		 )
		)
		else ( er_code = 1 
		       exit )
	   while true
	    
	  )
	  else format "objs not found \n"
	  
	  if er_code == 1  do format "not expected end of file\n"
	  if er_code == 2  do format "wrong data in :%\n" s
	  
	  nobj = 0
	  nlod = 0
	  if er_code == 0 do
	   for i = 1 to obj.count do
	   (
	    oname = lowercase obj[i].name
		if (substring oname 1 3)!= "lod" do
		(
		 k = findItem idename oname
		 if k>0 then 
		 (
		  nobj += 1
		  setuserpropbuffer obj[i] ""
		  setUserProp obj[i] "ID" ideid[k]
		  setUserProp obj[i] "LOD" "0"
		  
		  lodname = replace oname 1 3 "lod"
		  k = findItem idename lodname
		  if k>0 do (setUserProp obj[i] "LOD" ideid[k]
		             nlod +=1 )
		  
		 )
		 else format "%  -- not in thie IDE list\n" obj[i].name
		) -- if oname not LOD
	   ) -- i loop
	  
	  format "\nObj:%\nLod:%\n" nobj nlod
	  
	  close f
	) -- if fname !=undefined
	
	) -- if obj.count>0
	else format "no object selected\n"
 ),

 fn ExportIpl = 
 ( 
    obj = $selection as array
	L = lodstart.value as integer
	
	 if obj.count>0 then  (
	  clearlistener ()
	  for i = 1 to obj.count do 
	  if getuserprop obj[i] "ID" == undefined or getuserprop obj[i] "LOD" == undefined then (
	    L += 1 
	  )
	  else (
	      r = obj[i].rotation
	      format "%, %, %, %, %, %, %, %, %, %, "  \
		                     (getuserprop obj[i] "ID")  obj[i].name IntNum.value \
							 obj[i].position.x  obj[i].position.y  obj[i].position.z \
							 (-r.x as float) (-r.y as float) (-r.z as float) (r.w as float)
		   if (getuserprop obj[i] "LOD") != 0 then (
		       format "% \n" (L as integer)
			   L+=1
			   format "%, %, %, %, %, %, %, %, %, %, -1\n"  \
		                     (getuserprop obj[i] "LOD") (replace obj[i].name 1 3 "lod") IntNum.value \
							 obj[i].position.x  obj[i].position.y  obj[i].position.z \
							 (-r.x as float) (-r.y as float) (-r.z as float) (r.w as float)
		   )
		                                          else  format "-1\n"
	      L += 1                                               											  
	  )
	  format "\n# ---------------------------------------------------------------- LOD NUM = % \n" L
	 )
	else  format "empty selection\n"
 )
)