
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
	
	collision.bmx (Contains: ECollisionLayers, TProtog2DCollision, )
	
	TODO:
		
	
End Rem

Rem
	bbdoc: Collision layers enumerator.
End Rem
Type ECollisionLayers
	Const LAYER_ALL:Int = 0
	Const LAYER_1:Int = $0001
	Const LAYER_2:Int = $0002
	Const LAYER_3:Int = $0004
	Const LAYER_4:Int = $0008
	Const LAYER_5:Int = $0010
	Const LAYER_6:Int = $0020
	Const LAYER_7:Int = $0040
	Const LAYER_8:Int = $0080
	Const LAYER_9:Int = $0100
	Const LAYER_10:Int = $0200
	Const LAYER_11:Int = $0400
	Const LAYER_12:Int = $0800
	Const LAYER_13:Int = $1000
	Const LAYER_14:Int = $2000
	Const LAYER_15:Int = $4000
	Const LAYER_16:Int = $8000
	Const LAYER_17:Int = $00010000
	Const LAYER_18:Int = $00020000
	Const LAYER_19:Int = $00040000
	Const LAYER_20:Int = $00080000
	Const LAYER_21:Int = $00100000
	Const LAYER_22:Int = $00200000
	Const LAYER_23:Int = $00400000
	Const LAYER_24:Int = $00800000
	Const LAYER_25:Int = $01000000
	Const LAYER_26:Int = $02000000
	Const LAYER_27:Int = $04000000
	Const LAYER_28:Int = $08000000
	Const LAYER_29:Int = $10000000
	Const LAYER_30:Int = $20000000
	Const LAYER_31:Int = $40000000
	Const LAYER_32:Int = $80000000
End Type

Rem
	bbdoc: Protog2D collision manager.
End Rem
Type TProtog2DCollision
	
	Rem
		bbdoc: Clears collision layers specified by the value of @mask, mask=0 for all layers. 
		about: The BlitzMax 2D collision system manages 32 layers, the @mask parameter can
		be a combination of the following values or the special value COLLISION_LAYER_ALL in order 
		to perform collision operations on multiple layers.<br/>
		Note: COLLISION_LAYER_32 is used by the #ImagesCollide and #ImagesCollide2 commands.<br/>
		
		[ @Layer | @{Mask value}
		* COLLISION_LAYER_ALL | 0
		* COLLISION_LAYER_1 | $0001
		* COLLISION_LAYER_2 | $0002
		* COLLISION_LAYER_3 | $0004
		* COLLISION_LAYER_4 | $0008
		* COLLISION_LAYER_5 | $0010
		* COLLISION_LAYER_6 | $0020
		* COLLISION_LAYER_7 | $0040
		* COLLISION_LAYER_8 | $0080
		* COLLISION_LAYER_9 | $0100
		* COLLISION_LAYER_10 | $0200
		* COLLISION_LAYER_11 | $0400
		* COLLISION_LAYER_12 | $0800
		* COLLISION_LAYER_13 | $1000
		* COLLISION_LAYER_14 | $2000
		* COLLISION_LAYER_15 | $4000
		* COLLISION_LAYER_16 | $8000
		]
	End Rem
	Function ResetCollisions(mask:Int = 0)
		Local i:Int, q:TQuad
		
		For i = 0 To 31
			If mask = 0 Or mask & (1 Shl i)
				q = g_quadlayer[i]
				If q
					q.m_mask = Null
					q.m_id = Null
					While q.m_link
						q = q.m_link
						q.m_mask = Null
						q.m_id = Null
					Wend
					q.m_link = g_freequads
					q = g_quadlayer[i]
					g_freequads = q
					g_quadlayer[i] = Null
				End If
			End If
		Next
	End Function
	
	Rem 
		bbdoc: Pixel accurate collision testing between transformed Images. 
		about: The @collidemask specifies any layers to test for collision with.<br/>
		The @writemask specifies which if any collision layers the @image is added to in it's currently transformed state.<br/>
		The id specifies an object to be returned to future #CollideImage calls when collisions occur.
	End Rem
	Function CollideTexture:Object[] (texture:TProtogTexture, x:Float, y:Float, collidemask:Int, writemask:Int, id:Object = Null)
		Local q:TQuad
		q = TQuad.CreateQuad(texture, x, y, texture.m_width, texture.m_height, id)
		Return CollideQuad(q, collidemask, writemask)
	End Function
	
	Rem
		bbdoc: Pixel accurate collision testing between image layers.
		about: The @collidemask specifies any layers to test for collision with.<br/>
		The @writemask specifies which if any collision layers the @image is added to in it's currently transformed state.<br/>
		The @id specifies an object to be returned to future #CollideImage calls when collisions occur.<br/>
	End Rem
	Function CollideRect:Object[] (x:Float, y:Float, w:Float, h:Float, collidemask:Int, writemask:Int, id:Object = Null)
		Local q:TQuad
		q = TQuad.CreateQuad(Null, x, y, w, h, id)
		Return CollideQuad(q, collidemask, writemask)
	End Function
	
	Rem
		bbdoc: Check collisions with the given image and layer.
		about: The image can be Null (if it is the area of the quad will be checked).
	End Rem
	Function CollideTextureQuad:Object[] (texture:TProtogTexture, tx0:Float, ty0:Float, tx1:Float, ty1:Float, tx2:Float, ty2:Float, tx3:Float, ty3:Float, collidemask:Int, writemask:Int, id:Object = Null)
		Local q:TQuad, pix:TPixmap
		
		If g_freequads
			q = g_freequads
			g_freequads = q.m_link
			q.m_link = Null
		Else
			q = New TQuad
		End If
		
		q.m_id = id
		If texture
			pix = texture.m_pixmap
			If pix <> Null
				If AlphaBitsPerPixel[pix.format] > 0
					q.m_mask = pix
				End If
			End If
		End If
		
		q.SetCoords(tx0, ty0, tx1, ty1, tx2, ty2, tx3, ty3)
		
		Return CollideQuad(q, collidemask, writemask)
	End Function
	
End Type


'			PRIVATE
Private

Global g_texturemaps:TPixmap[]
Global g_linebuffer:Int[]
Global g_quadlayer:TQuad[32]
Global g_freequads:TQuad

Const POLYX:Int = 0
Const POLYY:Int = 1
Const POLYU:Int = 2
Const POLYV:Int = 3

Type rpoly
	Field m_texture:TPixmap
	Field m_data:Float[]
	Field m_channels:Int, m_count:Int, m_size:Int
	Field m_ldat:Float[], m_ladd:Float[]
	Field m_rdat:Float[], m_radd:Float[]
	Field m_left:Int, m_right:Int, m_top:Int
	Field m_state:Int
End Type

Type TQuad
	Field m_link:TQuad
	Field m_id:Object
	Field m_mask:TPixmap
	Field m_minx:Float, m_miny:Float, m_maxx:Float, m_maxy:Float
	Field m_xyuv:Float[16]
	
	Function CreateQuad:TQuad(texture:TProtogTexture, x:Float, y:Float, w:Float, h:Float, id:Object)
		Local tx0:Float, ty0:Float, tx1:Float, ty1:Float, tx2:Float, ty2:Float, tx3:Float, ty3:Float
		Local q:TQuad, pix:TPixmap
		
		tx0 = x
		ty0 = y
		tx1 = x + w
		ty1 = y
		tx2 = x + w
		ty2 = y + h
		tx3 = x
		ty3 = y + h
		
		'DebugLog("(p2d.CreateQuad) tx0=" + tx0 + ", ty0=" + ty0 + "; tx1=" + tx1 + ", ty1=" + ty1)
		'DebugLog("(p2d.CreateQuad) tx2=" + tx2 + ", ty2=" + ty2 + "; tx3=" + tx3 + ", ty3=" + ty3)
		
		If g_freequads <> Null
			q = g_freequads
			g_freequads = q.m_link
			q.m_link = Null
		Else
			q = New TQuad
		End If
		
		q.m_id = id
		If texture <> Null
			pix = texture.m_pixmap
			If pix <> Null
				If AlphaBitsPerPixel[pix.format]
				q.m_mask = pix
				End If
			End If
		End If
		
		q.SetCoords(tx0, ty0, tx1, ty1, tx2, ty2, tx3, ty3)
		Return q
	End Function
	
	Method SetCoords(tx0:Float, ty0:Float, tx1:Float, ty1:Float, tx2:Float, ty2:Float, tx3:Float, ty3:Float)
		m_xyuv[0] = tx0
		m_xyuv[1] = ty0
		m_xyuv[2] = 0.0
		m_xyuv[3] = 0.0
		m_xyuv[4] = tx1
		m_xyuv[5] = ty1
		m_xyuv[6] = 1.0
		m_xyuv[7] = 0.0
		m_xyuv[8] = tx2
		m_xyuv[9] = ty2
		m_xyuv[10] = 1.0
		m_xyuv[11] = 1.0
		m_xyuv[12] = tx3
		m_xyuv[13] = ty3
		m_xyuv[14] = 0.0
		m_xyuv[15] = 1.0
		m_minx = Min(Min(Min(tx0, tx1), tx2), tx3)
		m_miny = Min(Min(Min(ty0, ty1), ty2), ty3)
		m_maxx = Max(Max(Max(tx0, tx1), tx2), tx3)
		m_maxy = Max(Max(Max(ty0, ty1), ty2), ty3)
	End Method
	
End Type


Function DotProduct:Float(x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float)
	Return (((x2 - x1) * (y1 - y0)) - ((x1 - x0) * (y2 - y1)))
End Function

Function ClockwisePoly(data:Float[], channels:Int)	'flips order if anticlockwise
	Local count:Int, clk:Int, i:Int, j:Int
	Local r0:Int, r1:Int, r2:Int
	Local t:Float
	
	count = data.length / channels
	' clock wise test
	r0 = 0
	r1 = channels
	clk = 2
	For i = 2 To count - 1
		r2 = r1 + channels
		If DotProduct(data[r0 + POLYX], data[r0 + POLYY], data[r1 + POLYX], data[r1 + POLYY], data[r2 + POLYX], data[r2 + POLYY]) >= 0 Then clk:+1
		r1 = r2
	Next
	If clk < count Then Return
	
	' flip order for anticockwise
	r0 = 0
	r1 = (count - 1) * channels
	While r0 < r1
		For j = 0 To channels - 1
			t = data[r0 + j]
			data[r0 + j] = data[r1 + j]
			data[r1 + j] = t
		Next
		r0:+channels
		r1:-channels
	Wend
End Function

Function RenderPolys:Int(vdata:Float[][], channels:Int[], textures:TPixmap[], renderspans(polys:TListEx, count:Int, ypos:Int))
	Local polys:rpoly[], p:rpoly, pcount:Int
	Local active:TListEx
	Local top:Int, bot:Int
	Local n:Int, y:Int, h:Int, i:Int, j:Int, res:Int
	Local data:Float[]
	
	bot = $80000000
	top = $7fffffff
	n = vdata.Length
	' create polys an array of poly renderers	
	polys = New rpoly[n]
	
	For i = 0 Until n
		p = New rpoly
		polys[i] = p
		p.m_texture = textures[i]
		p.m_data = vdata[i]
		p.m_channels = channels[i]
		p.m_count = p.m_data.length / p.m_channels
		p.m_size = p.m_count * p.m_channels
		ClockwisePoly(p.m_data, p.m_channels)	' flips order if anticlockwise
		
		' find top verticies
		p.m_left = 0
		j = 0
		p.m_top = $7fffffff
		While j < p.m_size
			y = p.m_data[j + POLYY]		' float to int conversion
			If y < p.m_top Then p.m_top = y; p.m_left = j
			If y < top Then top = y
			If y > bot Then bot = y
			j:+p.m_channels
		Wend
		p.m_right = p.m_left
	Next
	
	active = New TListEx
	pcount = 0
	' draw top to bottom
	For y = top To bot - 1
		
		' get left gradient
		For p = EachIn polys
			If p.m_state = 2 Then Continue
			If p.m_state = 0 And y < p.m_top Then Continue
			
			data = p.m_data
			If y >= Int(data[p.m_left + POLYY])
				j = p.m_left
				i = (p.m_left - p.m_channels)
				If i < 0 Then i:+p.m_size
				While i <> p.m_left
					If Int(data[i + POLYY]) > y Then Exit
					j = i
					i = (i - p.m_channels)
					If i < 0 Then i:+p.m_size
				Wend
				
				h = Int(data[i + POLYY]) - Int(data[j + POLYY])
				If i = p.m_left Or h <= 0
					active.Remove(p)
					pcount:-1
					p.m_state = 2
					Continue
				End If
				
				p.m_ldat = data[j..j + p.m_channels]
				p.m_ladd = data[i..i + p.m_channels]
				For j = 0 To p.m_channels - 1
					p.m_ladd[j] = (p.m_ladd[j] - p.m_ldat[j]) / h
					p.m_ldat[j]:+p.m_ladd[j] * 0.5
				Next
				p.m_left = i
				If p.m_state = 0
					p.m_state = 1
					active.AddLast(p)
					pcount:+1
				End If
			End If
			
			' get right gradient
			If y >= Int(data[p.m_right + POLYY])
				i = (p.m_right + p.m_channels) Mod p.m_size
				j = p.m_right
				While i <> p.m_right
					If Int(data[i + POLYY]) > y Then Exit
					j = i
					i = (i + p.m_channels) Mod p.m_size
				Wend
				
				h = Int(data[i + POLYY]) - Int(data[j + POLYY])
				If i = p.m_right Or h <= 0
					active.Remove(p)
					pcount:-1
					p.m_state = 2
					Continue
				End If
				
				p.m_rdat = data[j..j + p.m_channels]
				p.m_radd = data[i..i + p.m_channels]
				For j = 0 To p.m_channels - 1
					p.m_radd[j] = (p.m_radd[j] - p.m_rdat[j]) / h
					p.m_rdat[j]:+p.m_radd[j] * 0.5
				Next
				
				p.m_right = i
				If p.m_state = 0
					p.m_state = 1
					active.AddLast(p)
					pcount:+1
				End If
			End If
		Next
		
		' call renderer
		If pcount > 0
			res = renderspans(active, pcount, y)
			If res < 0
				Return res
			End If
		End If
		
		' increment spans
		For p = EachIn active
			For j = 0 To p.m_channels - 1
				p.m_ldat[j]:+p.m_ladd[j]
				p.m_rdat[j]:+p.m_radd[j]
			Next
		Next
	Next
	
	Return res
End Function

Function CollideSpans:Int(polys:TListEx, count:Int, y:Int)
	Local p:rpoly
	Local startx:Int, endx:Int
	Local x0:Int, x1:Int, w:Int, x:Int
	Local u:Float, v:Float, ui:Float, vi:Float
	Local pix:Int Ptr
	Local src:TPixmap
	Local tw:Int, th:Int, tp:Int, argb:Int
	Local width:Int, skip:Float
	
	startx = $7fffffff
	endx = $80000000
	
	If count < 2 Then Return 0
	p = rpoly(polys.ValueAtIndex(0))
	startx = p.m_ldat[POLYX]
	endx = p.m_rdat[POLYX]
	
	p = rpoly(polys.ValueAtIndex(1))
	x0 = p.m_ldat[POLYX]
	x1 = p.m_rdat[POLYX]
	
	If x0 >= endx Then Return 0
	If x1 <= startx Then Return 0
	If x0 > startx Then startx = x0
	If x1 < endx Then endx = x1
	
	width = endx - startx
	If width <= 0 Then Return 0
	If width > g_linebuffer.Length Then g_linebuffer = New Int[width]
	MemClear(g_linebuffer, width * 4)
	
	For p = EachIn polys
		src = p.m_texture
		If src <> Null
			x0 = p.m_ldat[POLYX]
			x1 = p.m_rdat[POLYX]
			w = x1 - x0
			If w <= 0 Then Continue
			u = p.m_ldat[POLYU]
			v = p.m_ldat[POLYV]
			ui = (p.m_rdat[POLYU] - u) / w
			vi = (p.m_rdat[POLYV] - v) / w
			skip = (startx - x0) + 0.5
			u = u + ui * skip
			v = v + vi * skip
			
			pix = Int Ptr(src.pixels)
			tw = src.width
			th = src.height
			tp = src.pitch / 4
			For x = 0 Until width
				If u < 0.0 Then u = 0.0
				If v < 0.0 Then v = 0.0
				If u > 1.0 Then u = 1.0
				If v > 1.0 Then v = 1.0
				?BigEndian
				argb = $00000080 & pix[(Int(v * th)) * tp + (Int(u * tw))]
				?LittleEndian
				argb = $80000000 & pix[(Int(v * th)) * tp + (Int(u * tw))]
				?
				If argb <> 0
					If g_linebuffer[x]
						Return - 1
					End If
					g_linebuffer[x] = argb
				End If
				u:+ui
				v:+vi
			Next
			
		Else
			For x = 0 Until width
				If g_linebuffer[x]
					Return - 1
				End If
				g_linebuffer[x] = - 1
			Next
		End If
	Next
	
	Return 0
End Function

Function QuadsCollide:Int(p:TQuad, q:TQuad)
	If p.m_maxx < q.m_minx Or p.m_maxy < q.m_miny Or p.m_minx > q.m_maxx Or p.m_miny > q.m_maxy Then Return False
	Local vertlist:Float[][2]
	Local textures:TPixmap[2]
	Local channels:Int[2]
	vertlist[0] = p.m_xyuv
	vertlist[1] = q.m_xyuv
	textures[0] = p.m_mask
	textures[1] = q.m_mask
	channels[0] = 4
	channels[1] = 4
	Return RenderPolys(vertlist, channels, textures, CollideSpans)
End Function

Function CollideQuad:Object[] (pquad:TQuad, collidemask:Int, writemask:Int)
	Local result:Object[]
	Local p:TQuad, q:TQuad
	Local i:Int, j:Int, count:Int
	
	p = pquad
	' check for collisions
	If collidemask <> 0
		For i = 0 To 31
			If collidemask & (1 Shl i)
				q = g_quadlayer[i]
				While q
					If QuadsCollide(p, q) <> 0
						If count = result.Length Then result = result[..((count + 4) * 1.2)]
						result[count] = q.m_id
						count:+1
					End If
					q = q.m_link
				Wend
			End If
		Next
	End If
	
	' write to layers
	If writemask <> 0
		For i = 0 To 31
			If writemask & (1 Shl i)
				If g_freequads <> Null
					q = g_freequads
					g_freequads = q.m_link
				Else
					q = New TQuad
				End If
				q.m_id = p.m_id		' TODO:optimize with memcpy?
				q.m_mask = p.m_mask
				'q.m_frame = p.m_frame
				MemCopy(q.m_xyuv, p.m_xyuv, 64)
				q.m_minx = p.m_minx; q.m_miny = p.m_miny; q.m_maxx = p.m_maxx; q.m_maxy = p.m_maxy
				q.m_link = g_quadlayer[i]
				g_quadlayer[i] = q
			End If
		Next
	End If
	
	' return result
	If count <> 0
		Return result[..count]
	Else
		Return Null
	End If
End Function


Public



