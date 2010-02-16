
SuperStrict

Framework brl.blitz
Import brl.standardio

Import duct.intmap

Local intmap:TIntMap = New TIntMap

intmap.Insert(1, "ioudfg")
Print(String(intmap.ForKey(1)))

Local array:Float[] = [2.0, 1.0]
intmap.Insert(2, array)

Local garray:Float[]
garray = Float[] (intmap.ForKey(2))

If array = garray
	Print("Works!")
End If

Print(intmap.Count())

Local fl:Float
For fl = EachIn array
	Print(fl)
Next
For fl = EachIn garray
	Print(fl)
Next

intmap.Clear()
Print(intmap.Count())
Print(intmap.Contains(1))

intmap.Insert(1, "adfgj")
intmap.Insert(2, "689fy")
intmap.Insert(3, "sydtu")
intmap.Insert(4, "if86r")
intmap.Insert(5, "wi56s")

For Local str:String = EachIn intmap
	Local str2:String = str + str
Next

Print("End!")

