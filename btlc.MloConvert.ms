
struct MloItem 
(
    aName,
    Pos,
    Rot 
)

struct aMlo
(
aName = "NoName",
Items = #()

)

struct btlc_MLos
(
    TheMlo,
  function loadMloFile FilePath =
  (
    TheMlo = #()
    fs = openFile FilePath
		while not eof fs do
		(
			l = readline fs
			if l == "mlo" do 
			(
                mloID = 1
				while l != "end" do
				(
					l = readline fs
                    if l == "end" then exit
					fl = filterString l  ","
                    TheMlo[mloID] = aMlo()
                    TheMlo[mloID].aName = (trimLeft(trimRight fl[1]))
                    TheItem = 1
                    
                    while l != "mloend" do
				    (
						if l == "end" then exit
                        l = readline fs
						fl = filterString l  ","
                        if fl.count == 10 do 
                        (
                            TheMlo[mloID].Items[TheItem] = MloItem()
                            TheMlo[mloID].Items[TheItem].aName =  (trimLeft(trimRight fl[1]))
                            TheMlo[mloID].Items[TheItem].Pos =  [0,0,0] as point3 
                            TheMlo[mloID].Items[TheItem].Pos[1] =  toLower(trimLeft(trimRight fl[2])) as Float  
                            TheMlo[mloID].Items[TheItem].Pos[2] =  toLower(trimLeft(trimRight fl[3])) as Float  
                            TheMlo[mloID].Items[TheItem].Pos[3] =  toLower(trimLeft(trimRight fl[4])) as Float  
    
                            x =  toLower(trimLeft(trimRight fl[5])) as Float  
                            y =  toLower(trimLeft(trimRight fl[6])) as Float  
                            z =  toLower(trimLeft(trimRight fl[7])) as Float  
                            w =  toLower(trimLeft(trimRight fl[8])) as Float  
                            TheMlo[mloID].Items[TheItem].Rot = quat x y z w
                            TheItem =  TheItem + 1
                        )
                    )
                    mloID = mloID + 1
			
                )
            )
        )
        TheMlo   
  ),

  function PlaceMlos = 
  (
    posX = 20;
    posY = 0;
    posstep = 100;
    for aMlo in TheMlo do 
    (
        MyMloDum = getNodeByName aMlo.aName
        MyCollision = undefined;
        if MyMloDum != undefined and classof(MyMloDum) != Dummy do
        (
            MyCollision  = MyMloDum
        )
        if MyMloDum == undefined or  classof(MyMloDum) != Dummy do 
        (
            MyMloDum = Dummy()
            MyMloDum.Name = aMlo.aName
        )
        MyCollision.Parent = MyMloDum;
        MyCollision.Position = [0, 0, 0]
        MyMloDum.Position = [0, 0, 0]
    

        for aItem in aMlo.Items do 
        (
            TheObj = getNodeByName aItem.aName
            if TheObj != undefined do 
            (
                TheObj.Position = aItem.Pos;
                TheObj.Rotation = aItem.Rot;    
				TheObj.parent =   MyMloDum;
            )
           
        )

        MyMloDum.Position = [posX, posY, 0]
        posX = posX + posstep;
        if posX > (10*posstep) do 
        (
            posY = posY + posstep
            posX = 20;
        )
    )
  ),
  
  function HideLods = 
  (
    
  )
)
--BtlcMlo.loadMloFile
BtlcMlo = btlc_MLos();