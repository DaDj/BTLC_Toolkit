
fn createIStream c t = (
	fname = getopenfilename caption:c types:t
	if fname != undefined then return fopen fname "rb"
	return undefined
)

fn createMultitypeIStream c t = (
	fname = getopenfilename caption:c types:t
	if fname != undefined then( 
		f=fopen fname "rb"
		if f!= undefined then return #(f, (GetFilenameType fname))
	)
	return undefined
)

fn createOStream c t name:"" = (
	fname = getsavefilename caption:c types:t filename:name
	if fname != undefined then return (fopen fname "wb")
	return undefined
)


-- read fns

fn readVertex f = (
	[(readFloat f), (readFloat f), (readFloat f)]
)

fn readTexCord f = (
	[(readFloat f),(1 - (readFloat f)),0]
)

fn readColor f = (
	#((color (readbyte f #unsigned) (readbyte f #unsigned) (readbyte f #unsigned)), (readbyte f #unsigned))
)

fn readByteIndex f = (
	return ((readbyte f #unsigned)+1)
)

fn readShortIndex f = (
	((readShort f #unsigned)+1)
)

fn readLongIndex f = (
	((readLong f #unsigned)+1)
)

fn readShortFace f = (
	[(readShortIndex f), (readShortIndex f), (readShortIndex f)]
)

fn readLongFace f = (
	[(readLongIndex f), (readLongIndex f), (readLongIndex f)]
)

fn ignoreBytes f n = (
	fseek f n #seek_cur
)

fn readLimitedString f n = (
	str=readString f
	skip=n-(str.count)-1
	if skip<0 then throw "string out of limit"
	if skip>0 then ignoreBytes f skip
	str
)

fn readFixPoint f p = (
	((readShort f)/(p as float))
)

fn readFixPointVertex f p = (
	[(readFixPoint f p), (readFixPoint f p), (readFixPoint f p)]
)

-- write fns

fn writeVertex f v = (
	for i = 1 to 3 do writeFloat f v[i]
)

fn writeTexCord f t = (
	writeFloat f t.x
	writeFloat f (1-t.y)
)

fn writeColor f c a = (
	writeByte f (c.r as integer)
	writeByte f (c.g as integer)
	writeByte f (c.b as integer)
	writeByte f a
)

fn writeByteIndex f i = (
	writeByte f (i-1)
)

fn writeShortIndex f i = (
	writeShort f (i-1)
)

fn writeLongIndex f i = (
	writeLong f (i-1)
)

fn writeShortFace f fs= (
	for i = 1 to 3 do
		writeShortIndex f fs[i]
)

fn writeLongFace f fs= (
	for i = 1 to 3 do
		writeLongIndex f fs[i]
)

fn writePadding f bs = (
	for i = 1 to bs do writeByte f 0
)

fn writeLimitedString f str n = (
	limit=n-1
	pad=0
	if str.count>limit then str=substring str 1 limit
	else(
		if str.count<limit then pad=(limit-str.count)
	)
	writeString f str
	if pad>0 then writePadding f pad
)

fn writeFixPoint f p fp= (
	writeShort f (fp*p)
)

fn writeFixPointVertex f p v = (
	for i = 1 to 3 do writeFixPoint f p v[i]
)