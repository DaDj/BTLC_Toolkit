-- This file is a part of OPEN FORMATS I/O project, (C) Alexander Blade, MIXAZZZ
-- alexander.sannybuilder.com, openiv.com

-- Description: simply functions for common usage
-- Last changed: Jun 2013

global ofutils

fileIn "ofio.iv.drawable.mtl.ms"

struct ofutils (

	fn lowerCase instring = ( 
		if instring == undefined then return ""
		local upper, lower, outstring 
		upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		lower = "abcdefghijklmnopqrstuvwxyz"
		outstring = copy instring
		for i = 1 to outstring.count do
		( 
			j = findString upper outstring[i]
			if (j != undefined) do outstring[i] = lower[j]
		)
		return outstring 
	),
	
	fn extractFileName path = (
		if path.count == 0 then return ""
		local i = path.count, r = ""
		while (i > 0) and (path[i] != "\\") and (path[i] != "/") do
		(
			r = path[i] + r
			i -= 1
		)
		return r
	),
	
	fn extractFilePath path = (
		if path.count == 0 then return ""
		local i = path.count
		while (i > 0) and (path[i] != "\\") and (path[i] != "/") do
		(
			i -= 1
		)
		local r = substring path 1 i
		return r
	),	
	
	fn removeExt name = (
		if name.count == 0 then return ""
		local i = name.count, dotpos = 0
		while i > 0 do
		(
			if name[i] == "." then
			(
				dotpos = i
				exit
			)
			i -= 1	
		)
		local r = name
		if dotpos > 0 then
		(
			r = ""
			for i = 1 to dotpos - 1 do r += name[i]	
		) 	
		return r
	),	
	
	fn round val dp = (
		local a = val * (10 ^ dp)
	 	local b = a as Integer
	 	a = (b as float) / (10 ^ dp)
	 	return a
	),
	
	fn showException = (
		local e = getcurrentexception()
		if e != undefined then
		(
			local str_to_replace = "-- Runtime error: "
			local pos = findString e str_to_replace
			while (pos != undefined) do
			(
				e = replace e pos str_to_replace.count ""
				pos = findString e str_to_replace
			)
			local s = "EXCEPTION: " + e
			try ( ofioLog.print s ) catch ( )			
			messagebox s title:"OPEN FORMATS I/O EXCEPTION"
			try ( gc() ) catch ()
		)		
	),
	
	fn showListener = (
		actionMan.executeAction 0 "40472"
	),
	
	fn openUtilities = (
		local dummyrollout
		rollout dummyrollout "" ( )
		addRollout dummyrollout
		removeRollout dummyrollout
	),	
	
	fn promtReset text:"" time:0 = (
		removeTempPrompt()
		if text != "" and time > 0 then displayTempPrompt text time
	),
	
	fn promtUpdate text percents:-1 = (
		local t = text 
		if percents >= 0 then t += " ( " + ((percents as Integer) as String) + "% )"
		displayTempPrompt t (60 * 1000)
	),
	
	fn try_cut_big_faces_to_traingles obj first:true = (
		if (classof obj != Editable_Poly) and (classof obj != Editable_Mesh) 
			then throw "incorrect object type, only mesh or poly can be tesselated"
		local convert_to_mesh = false
		if classof obj == Editable_Mesh then 
		(
			convertToPoly obj
			convert_to_mesh = True
		)
		-- find big polys
		local i, big_polys = #()	
		for i = 1 to obj.faces.count do
		(
			local verts = polyop.getFaceVerts obj i
			if verts.count > 4 then	append big_polys i
		)	
		if big_polys.count == 0 then 
		(
			if convert_to_mesh then convertToMesh obj
			return True		
		)
		-- tesselate by face
		obj.tesselateBy = 1
		obj.tessTension = 0
		polyOp.tessellateByFace obj big_polys
/*		
		-- find not tesselated polys
		big_polys = #()
		for i = 1 to obj.faces.count do
		(
			local verts = polyop.getFaceVerts obj i
			if verts.count > 4 then	append big_polys i
		)	
		if big_polys.count == 0 then 
		(
			if convert_to_mesh then convertToMesh obj
			return True		
		)
		-- tesselate by edge
		obj.tesselateBy = 0
		obj.tessTension = 0
		polyOp.tessellateByFace obj big_polys
*/		
		-- check tesselation result
		big_polys = #()
		for i = 1 to obj.faces.count do
		(
			local verts = polyop.getFaceVerts obj i
			if verts.count > 4 then	append big_polys i
		)	
		if big_polys.count == 0 then 
		(
			if convert_to_mesh then convertToMesh obj
			return True		
		)		
		
		-- find verts of not tesselated polys
		local verts_of_big_polys = #()
		for i = 1 to obj.faces.count do
		(
			local verts = polyop.getFaceVerts obj i
			if verts.count > 4 then
			( 
				local vert
				for vert in verts do
					if (findItem verts_of_big_polys vert) == 0 then
							append verts_of_big_polys vert
			)
		)
		-- if such polys exist then get edges from mesh mode and create them in poly mode
		if verts_of_big_polys.count > 0 then
		(
			local polymode_verts = obj.verts.count		
			convertToMesh obj
			if obj.verts.count != polymode_verts then
			(
				if not convert_to_mesh then convertToPoly obj
				throw "object can't be tesselated because mesh and poly modes have different vert count"
			)
			local edges_using_verts = (meshop.getEdgesUsingVert obj verts_of_big_polys) as Array
			for i = 1 to edges_using_verts.count do
			(
				edges_using_verts[i] = (meshop.getVertsUsingEdge obj edges_using_verts[i]) as Array
				if edges_using_verts[i].count != 2 then edges_using_verts[i] = undefined
			)
			convertToPoly obj
			print obj.faces.count
			for i = 1 to edges_using_verts.count do
				if edges_using_verts[i] != undefined then
					polyop.createEdge obj edges_using_verts[i][1] edges_using_verts[i][2]
			print obj.faces.count
				
			-- one more pass
			if first then ofutils.try_cut_big_faces_to_traingles obj first:false			
		)
		-- result
		for i = 1 to obj.faces.count do
		(
			local verts = polyop.getFaceVerts obj i
			if verts.count > 4 then 
			(
				if convert_to_mesh then convertToMesh obj
				return false
			)
		)
		if convert_to_mesh then convertToMesh obj
		return true	
	),	
	
	fn select_bound_bad_polys obj = (
		if classof obj != Editable_Poly then
			convertTo obj Editable_Poly
		local faceSel = #()
		local i
		if classof obj.Material == Multimaterial then	
		(
			for i = 1 to obj.numfaces do
			(
				local mtl_id = polyop.getFaceMatID obj i
				local sub_mtl = obj.Material[mtl_id]
				if sub_mtl == undefined or classof sub_mtl != iv_col_material then
					append faceSel i
			)
		)
		if faceSel.count > 0 then
		(
			max modify mode
			select obj
			subObjectLevel = 4
			setFaceSelection obj faceSel
			messagebox (faceSel.count as String + " polygons selected in " + obj.name)
		)
	),
	
	fn std_mats_to_drawable obj = (
		local mtl = obj.material
		if mtl != undefined then 
		(
			if classof mtl == Multimaterial then
			(
				local matid_list = mtl.materialIDList
				local i
				for i in matid_list do
				(
					if classof mtl[i] == Standard then
					(
						if mtl[i].diffuseMap == undefined then 
						(
							mtl[i] = iv_drawable_material()
							mtl[i].setInfo #("gta_default.sps", "NULL") ""
							continue
						)
						local newMtl = iv_drawable_material()
						newMtl.setInfo #("gta_default.sps", mtl[i].diffuseMap.fileName) ""
						newMtl.delegate.diffuseMap = mtl[i].diffuseMap
						mtl[i] = newMtl								
					)
				)
			) else
			if classof mtl == Standard then
			(		
				if mtl.diffuseMap == undefined then
				(
					local newMtl = iv_drawable_material()
					newMtl.setInfo #("gta_default.sps", "NULL") ""
					obj.material = newMtl
				) else
				(
					local newMtl = iv_drawable_material()
					newMtl.setInfo #("gta_default.sps", mtl.diffuseMap.fileName) ""
					newMtl.delegate.diffuseMap = mtl.diffuseMap
					obj.material = newMtl					
				)
			)
		) 
	) 
	
)





