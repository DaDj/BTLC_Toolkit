
fn GetFaceMagnitude Obj FaceID =
(
	pivot =  meshop.getFaceCenter obj FaceID
	pivot =  sqrt(pivot.x^2 + pivot.y^2 + pivot.z^2)
	pivot
) 

function QuicksortFaces Obj low high =
(
	
	if low < high do 
	(
		pivot = GetFaceMagnitude Obj low

		i = low
		j = high
		while i <= j do 
		(
			while (GetFaceMagnitude Obj i) < pivot do 
			(
				i = i +1
			)

			while (GetFaceMagnitude Obj j) > pivot do 
			(
				j = j - 1
			)

			if (GetFaceMagnitude Obj i) <= (GetFaceMagnitude Obj j) do 
			(
				FaceAverts = copy getFace obj i
				FaceBverts = copy getFace obj j
			
			try 
			(
				setFace Obj i FaceBverts.x FaceBverts.y FaceBverts.z
				setFace Obj j FaceAverts.x FaceAverts.y FaceAverts.z


			) 
			catch()
			)
		)
		
	)
)


for tobj in selection  do 
(
	obj = copy tobj;
	TheObjFace = obj.Faces
	QuicksortFaces obj 1 TheObjFace.Count 
	update obj
)

/*public int[] SortArray(int[] array, int leftIndex, int rightIndex)
{
    var i = leftIndex;
    var j = rightIndex;
    var pivot = array[leftIndex];
    while (i <= j)
    {
        while (array[i] < pivot)
        {
            i++;
        }
        
        while (array[j] > pivot)
        {
            j--;
        }
        if (i <= j)
        {
            int temp = array[i];
            array[i] = array[j];
            array[j] = temp;
            i++;
            j--;
        }
    }
    
    if (leftIndex < j)
        SortArray(array, leftIndex, j);
    if (i < rightIndex)
        SortArray(array, i, rightIndex);
    return array;
} */