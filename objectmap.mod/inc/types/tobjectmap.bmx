
Rem
	Copyright (c) 2009 Tim Howard
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
	-----------------------------------------------------------------------------
	
	tobjectmap.bmx (Contains: TObjectMap, )
	
End Rem

Rem
	bbdoc: The ObjectMap type.
	about: This type is intended to be used abstractly, but still usable otherwise.
End Rem
Type TObjectMap
	
	Field m_count:Int
	Field m_map:TMap
	
		Method New()
			
			m_map = New TMap
			
		End Method
		
		Rem
		Method Create:TObjectMap()
			
			Return Self
			
		End Method
		End Rem
		
		Rem
			bbdoc: Insert an object into the map.
			returns: Nothing.
			about: This method does not provide Null checking.
		End Rem
		Method _Insert(key:Object, value:Object)
			
			m_map.Insert(key, value)
			m_count:+1
			
		End Method
		
		Rem
			bbdoc: Remove a key from the map.
			returns: True if the key was removed from the map, or False if it was not.
			about: Count is lowered by 1 if the key was removed.
		End Rem
		Method _Remove:Int(key:Object)
			
			If m_map.Remove(key) = True
				
				m_count:-1
				Return True
				
			End If
			
			Return False
			
		End Method
		
		Rem
			bbdoc: Get a value by its key.
			returns: An object or Null (not found).
		End Rem
		Method _ValueByKey:Object(key:Object)
			
			If key = Null Then Return Null
			Return m_map.ValueForKey(key)
			
		End Method
		
		Rem
			bbdoc: Check if a key is in the map.
			returns: True if the key is in the map, or False if it is not.
		End Rem
		Method _Contains:Int(key:Object)
			
			Return m_map.Contains(key)
			
		End Method
		
		Rem
			bbdoc: Clear the map.
			returns: Nothing.
			about: Count is zeroed.
		End Rem
		Method Clear()
			
			m_map.Clear()
			m_count = 0
			
		End Method
		
		Rem
			bbdoc: Get the number of entries in the map.
			returns: Nothing.
		End Rem
		Method Count:Int()
			
			Return m_count
			
		End Method
		
		Rem
			bbdoc: Get the value enumerator for the map.
			returns: Nothing.
		End Rem
		Method ValueEnumerator:TMapEnumerator()
			
			Return m_map.Values()
			
		End Method
		
		Rem
			bbdoc: Get the key enumerator for the map.
			returns: Nothing.
		End Rem
		Method KeyEnumerator:TMapEnumerator()
			
			Return m_map.Keys()
			
		End Method
		
End Type

























