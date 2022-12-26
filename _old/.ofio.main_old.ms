-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- dev-c.com, openiv.com

-- Description: script that starts every other OF I/O component
-- Last changed: March 2014

try (
	if (maxVersion())[1] < 8000 then throw "In order to use OF I/O you need 3DSMax8 or higher"
	if HeapSize < 256000000 then 
		messagebox "MAXScript memory heap size is less than 256MB\nRead OFIO.chm for details !" title:"Warning !"
	fileIn "ofio.utils.ms"
	fileIn "ofio.log.ms"
	fileIn "ofio.iv.drawable.mtl.ms"
	fileIn "ofio.iv.navmesh.ms"
	fileIn "ofio.iv.bounds.ms"	
	fileIn "ofio.iv.drawable.ms"
	fileIn "ofio.iv.fragments.ms"
	fileIn "ofio.iv.anim.ms"
	fileIn "ofio.gui.ms"
) catch
(
	messagebox (getcurrentexception() as String) title:"OPEN FORMATS I/O EXCEPTION WHILE INITIALIZATION"
)

