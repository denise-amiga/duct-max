
Rem
	textfield.bmx (Contains: duiTextField, )
End Rem

Rem
	bbdoc: duct ui text field gadget.
End Rem
Type duiTextField Extends duiGadget
	
	Const IDLE_MODE:Int = 0		' Gadget is not accepting text input
	Const INPUT_MODE:Int = 1	' Gadget will accept text input		
	
	Global m_renderer:duiGenericRenderer = New duiGenericRenderer
	Global m_searchglasswidth:Float, m_searchglassheight:Float
	
	Global m_blinktimer:TMSTimer = New TMSTimer.Create(500), m_cursoron:Int
	
	Field m_text:String			' Text content
	Field m_mode:Int			' In input mode (gadget remians active regardless of mouse presses)
	Field m_cursorpos:Int		' Cursor position
	Field m_cursorx:Int			' Cursor's x location, where 0 is the start of the text
	Field m_textx:Int			' Text's x location, where 0 is the start of the visible area
	
	Field m_issearch:Int		' Set text field to search field
	
	Rem
		bbdoc: Create a textfield gadget.
		returns: Itself.
	End Rem
	Method Create:duiTextField(name:String, text:String, x:Float, y:Float, width:Float, height:Float, issearch:Int = False, parent:duiGadget)
		_Init(name, x, y, width, height, parent, False)
		SetText(text)
		m_issearch = issearch
		'SetTextColor(0, 0, 0)
		Return Self
	End Method
	
'#region Render & update methods
	
	Rem
		bbdoc: Render the textfield.
		returns: Nothing.
	End Rem
	Method Render(x:Float, y:Float)
		Local relx:Float, rely:Float
		
		If IsVisible() = True
			relx = m_x + x
			rely = m_y + y
			
			BindDrawingState()
			m_renderer.RenderCells(relx, rely, Self)
			dProtogDrawState.Push(False, False, False, True, True, False)
			
			If m_issearch = True
				'DrawImage(m_searchimage, relx + (m_width - 16), rely + ((m_height - 2) / 2) - 4)
				m_renderer.RenderSectionToSectionSize("glass", relx + (m_width - 16), rely + ((m_height - 2) / 2) - 4)
				dui_SetViewport(relx + 2, rely + 2, m_width - 20, m_height - 4)
			Else
				dui_SetViewport(relx + 2, rely + 2, m_width - 4, m_height - 4)
			End If
			
			BindTextDrawingState()
			duiFontManager.RenderString(m_text, m_font, relx + m_textx + 2, rely + 3)
			
			If m_mode = INPUT_MODE
				If m_blinktimer.Update() = True
					m_cursoron:~ 1
				End If
				If m_cursoron = True
					dProtog2DDriver.SetLineWidth(1.5)
					dProtogPrimitives.DrawLine(m_cursorx + relx + m_textx + 2, rely + 2, m_cursorx + relx + m_textx + 2, rely + (m_height - 4))
				End If
			End If
			
			dProtogDrawState.Pop(False, False, False, True, True, False)
			Super.Render(x, y)
		End If
	End Method
	
	Rem
		bbdoc: Update the textfield.
		returns: Nothing.
	End Rem
	Method Update(x:Int, y:Int)
		Super.Update(x, y)
		If m_mode = INPUT_MODE And MouseDown(1) = True
			UpdateMouseDown(x, y)
		End If
	End Method
	
	Rem
		bbdoc: Update the MouseOver state.
		returns: Nothing.
	End Rem
	Method UpdateMouseOver(x:Int, y:Int)
		If m_issearch = True And dui_MouseIn(m_x + x + (m_width - m_searchglasswidth - 7), m_y + y, m_searchglasswidth + 7, m_searchglassheight + 7) = False Or m_issearch = False And dui_MouseIn(m_x + x, m_y + y, m_width, m_height) = True
			duiMain.SetCursor(dui_CURSOR_TEXTOVER)
		End If
		Super.UpdateMouseOver(x, y)
	End Method
	
	Rem
		bbdoc: Update the MouseDown state.
		returns: Nothing.
	End Rem
	Method UpdateMouseDown(x:Int, y:Int)
		
		'duiMain.SetCursor(dui_CURSOR_TEXTOVER)
		Super.UpdateMouseDown(x, y)
		
		If m_mode = IDLE_MODE Then FlushKeys()
		
		' Set the text input mode
		m_mode = INPUT_MODE
		' Test the mouse location to see what was clicked
		If dui_MouseIn(m_x + x, m_y + y, m_width, m_height) = True
			' First, test that it's part of the text
			If m_issearch = False Or dui_MouseIn(m_x + x, m_y + y, m_width - 20, m_height)
				duiMain.SetCursor(dui_CURSOR_TEXTOVER)
				SetCursorPositionByX(MouseX() - x)
			Else If m_issearch = True And dui_MouseIn(m_x + x + (m_width - 17), m_y + y, 12, 17)
				duiMain.SetCursor(dui_CURSOR_MOUSEDOWN)
			End If
		Else
			m_state = STATE_IDLE
			m_mode = IDLE_MODE
			duiMain.ClearActiveGadget()
		End If
	End Method
	
	Rem
		bbdoc: Update the MouseRelease state.
		returns: Nothing.
	End Rem
	Method UpdateMouseRelease(x:Int, y:Int)
		Super.UpdateMouseRelease(x, y)
		If dui_MouseIn(m_x + x, m_y + y, m_width, m_height) = False
			m_state = STATE_IDLE
			m_mode = IDLE_MODE
			duiMain.ClearActiveGadget()
			'Deactivate()
		End If
		
		If m_mode = INPUT_MODE
			duiMain.SetActiveGadget(Self)
			m_blinktimer.Reset(- m_blinktimer.GetMS())
			m_cursoron = False
		End If
		
		If duiMain.IsGadgetActive(Self) = True
			If m_issearch = True
				If dui_MouseIn(m_x + x + (m_width - m_searchglasswidth - 7), m_y + y, m_searchglasswidth + 7, m_searchglassheight + 7) = True
					Deactivate()
				Else
					If m_state <> STATE_IDLE Then duiMain.SetCursor(dui_CURSOR_TEXTOVER)
				End If
			Else
				If m_state <> STATE_IDLE Then duiMain.SetCursor(dui_CURSOR_TEXTOVER)
			End If
		End If
	End Method
	
	Rem
		bbdoc: Refresh the textfield.
		returns: Nothing.
	End Rem
	Method Refresh()
		Local pos:Int
		
		' Set the cursor's position relative to the text
		m_cursorx = duiFontManager.StringWidth(m_text[0..m_cursorpos], m_font)
		If m_cursorpos = 0 Then m_cursorx:+1
		'DebugLog("(duiTextField.Refresh) m_cursorpos = " + m_cursorpos + ", m_cursorx = " + m_cursorx)
		
		' Also update the starting location of the text so that m_cursorx is in view
		pos = m_cursorx + m_textx
		If m_issearch = True
			If pos + m_searchglasswidth > (m_width - m_searchglasswidth - 5)
				m_textx = (m_width - m_searchglasswidth - 5) - m_cursorx
				m_textx:-10 ' EXPERIMENTAL!!
				'm_textx:-m_searchglasswidth - 4
			End If
		Else
			If pos > (m_width - 10)
				m_textx = (m_width - 10) - m_cursorx
				m_textx:-10 ' EXPERIMENTAL!!
			End If
		End If
		
		If pos < 10
			If m_cursorpos = 0
				m_textx = 0
			Else
				m_textx = -m_cursorx
				m_textx:+9 ' EXPERIMENTAL!!
			End If
		End If
		
		If m_mode = INPUT_MODE
			m_cursoron = True
			m_blinktimer.Reset(300)
		End If
		'DebugLog("(duiTextField.Refresh) m_cursorpos = " + m_cursorpos + ", m_cursorx = " + m_cursorx)
	End Method
'#end region (Render & update methods)
	
'#region Field accessors
	
	Rem
		bbdoc: Set the textfield's text.
		returns: Nothing.
	End Rem
	Method SetText(text:String, cursorend:Int = True)
		m_text = text
		If cursorend = True
			MoveCursorToEnd()
		End If
	End Method
	Rem
		bbdoc: Get the text in the textfield.
		returns: The text in the textfield.
	End Rem
	Method GetText:String()
		Return m_text
	End Method
	Rem
		bbdoc: Clear the textfield.
		returns: Nothing.
	End Rem
	Method Clear()
		SetText("", True)
	End Method
	
	Rem
		bbdoc: Get the cursor position.
		returns: The position of the textfield cursor.
	End Rem
	Method GetCursorPosition:Int()
		Return m_cursorpos
	End Method
	
	Rem
		bbdoc: Get the number of characters in the textfield.
		returns: The number of characters in the textfield.
	End Rem
	Method GetCharCount:Int()
		Return m_text.Length
	End Method
	
	Rem
		bbdoc: Set the milliseconds before a blink of the text cursor occurs.
		returns: Nothing.
	End Rem
	Function SetBlinkTime(blinktime:Int = 500)
		m_blinktimer.SetLength(blinktime)
	End Function
	Rem
		bbdoc: Get the milliseconds before a blink of the text cursor occurs.
		returns: The milliseconds between cursor blinks.
	End Rem
	Function GetBlinkTime:Int()
		Return m_blinktimer.GetLength()
	End Function
	
'#end region (Field accessors)
	
'#region Function
	
	Rem
		bbdoc: Insert text into the textfield at an index (not zero-based).
		returns: Nothing.
	End Rem
	Method InsertTextAtIndex(text:String, index:Int, setpos:Int = True)
		SetText(m_text[0..index] + text + m_text[index..GetCharCount()], False)
		If setpos = True
			SetCursorPosition(index + text.Length)
		End If
	End Method
	
	Rem
		bbdoc: Make a text-editing action: Backspace.
		returns: Nothing.
	End Rem
	Method TextBackspace()
		If m_cursorpos > 0
			RemoveText(m_cursorpos - 1, m_cursorpos)
		End If
	End Method
	
	Rem
		bbdoc: Make a text-editing action: Delete a character.
		returns: Nothing.
	End Rem
	Method TextDelete()
		If m_cursorpos < GetCharCount()
			RemoveText(m_cursorpos, m_cursorpos + 1)
		End If
	End Method
	
	Rem
		bbdoc: Make a text-editing action: Remove a section of text.
		returns: Nothing.
	End Rem
	Method RemoveText(start:Int, _end:Int)
		Local txleft:String, txright:String
		
		start = ClampPosition(start, False)
		_end = ClampPosition(_end, False)
		
		' Get left and right portions of remaining text
		txleft = m_text[0..start]
		txright = m_text[_end..GetCharCount()]
		
		' Piece them together
		m_text = txleft + txright
		
		' Update the cursor position
		SetCursorPosition(start)
	End Method
	
	Rem
		bbdoc: Move the cursor to the end (last position) of the textfield.
		returns: Nothing.
	End Rem
	Method MoveCursorToEnd()
		SetCursorPosition(GetCharCount())
	End Method
	
	Rem
		bbdoc: Move the cursor to the start (first position) of the textfield.
		returns: Nothing.
	End Rem
	Method MoveCursorToStart()
		SetCursorPosition(0)
	End Method
	
	Rem
		bbdoc: Move the text cursor relative to it's position.
		returns: Nothing.
		about: Positions are clamped.<br/>
		e.g. textfield.MoveCursor(-1); Will move the cursor back one.
	End Rem
	Method MoveCursor(amount:Int)
		SetCursorPosition(m_cursorpos + amount)
	End Method
	
	Rem
		bbdoc: Set the text cursor position.
		returns: Nothing.
		about: @_cursor will be clamped to the size of the text in the textfield if it is invalid.
	End Rem
	Method SetCursorPosition(pos:Int)
		m_cursorpos = pos
		m_cursorpos = ClampPosition(m_cursorpos, False)
		'DebugLog("(duiTextField.SetCursorPosition) pos = " + pos + ", m_cursorpos = " + m_cursorpos)
		Refresh()
	End Method
	
	Rem
		bbdoc: Set the cursor position by an x screen position.
		returns: Nothing.
	End Rem
	Method SetCursorPositionByX(x:Int)
		Local xmouse:Int, cutout:String, scursor:Int
		Local leftdist:Int, rightdist:Int
		
		' Set up relative mouse position
		xmouse = x - (m_x + 3)
		' Check to see if the mouse is positioned somewhere in the text
		If xmouse < duiFontManager.StringWidth(m_text, m_font)
			' Step through string until the mouse is on the left of the string width
			scursor = -1
			Repeat
				scursor:+1
				cutout = m_text[0..scursor]
			Until xmouse < duiFontManager.StringWidth(cutout, m_font)
			
			m_cursorpos = scursor
			' At this point, you can narrow it down based on distance.
			If m_cursorpos > 0
				' Get distance from mouse to the text
				leftdist = duiFontManager.StringWidth(cutout, m_font) - xmouse
				rightdist = xmouse - duiFontManager.StringWidth(m_text[0..(scursor - 1)], m_font)
				
				If leftdist <= rightdist
					m_cursorpos = scursor
				Else ' Backwards
					m_cursorpos = scursor - 1
				End If
			End If
			
		Else
			m_cursorpos = GetCharCount()
		End If
		
		' Just to make sure we aren't at an invalid position
		SetCursorPosition(m_cursorpos)
		Refresh()
	End Method
	
	Rem
		bbdoc: Deactivate the textfield.
		returns: Nothing.
	End Rem
	Method Deactivate()
		duiMain.ClearActiveGadget()
		m_state = STATE_IDLE
		m_mode = IDLE_MODE
		
		' Check to see if text field forms part of search box
		Local search:duiSearchPanel = duiSearchPanel(m_parent)
		If search <> Null
			'New duiEvent.Create(dui_EVENT_GADGETACTION, search.m_issearchBox, 0, 0, 0, GetText())
			search.m_searchbox.Search(m_text)
		Else
			New duiEvent.Create(dui_EVENT_GADGETACTION, Self, 0, 0, 0, GetText())
		End If
	End Method
	
'#end region (Function)
	
'#region Miscellaneous
	
	Rem
		bbdoc: Clamp a cursor position to the size of the text in the textfield.
		returns: The clamped value.
	End Rem
	Method ClampPosition:Int(value:Int, zerobased:Int = False)
		Local size:Int
		size = GetCharCount()
		If zerobased = True
			size:-1
		End If
		Return IntMax(IntMin(value, 0), size)
	End Method
	
	Rem
		bbdoc: Send a key to the textfield for input.
		returns: Nothing.
		about: @_type can be either<br/>
		0 - An action key (KEY_ constants, things like cursor left, right; backspace and delete, enter and escape)<br/>
		1 - An ascii character key (e.g. a value from GetChar - this does not convert from KEY_ constants to actual input)
	End Rem
	Method SendKey(key:Int, _type:Int = 0)
		'If m_mode = INPUT_MODE
			If _type = 0
				Select key
					Case KEY_LEFT SetCursorPosition(m_cursorpos - 1)
					Case KEY_RIGHT SetCursorPosition(m_cursorpos + 1)
					Case KEY_END MoveCursorToEnd()
					Case KEY_HOME MoveCursorToStart()
					
					'Case KEY_TAB InsertTextAtIndex("~t", GetCursorPosition(), True)
					
					Case KEY_BACKSPACE TextBackspace()
					Case KEY_DELETE TextDelete()
					Case KEY_RETURN, KEY_ESCAPE
						If m_mode = INPUT_MODE
							DeActivate()
						End If
				End Select
			Else If _type = 1
				If key > 31
					InsertTextAtIndex(Chr(key), m_cursorpos, True)
				End If
			End If
		'End If
	End Method
	
'#end region (Miscellaneous)
	
	Rem
		bbdoc: Refresh the skin for the textfield.
		returns: Nothing.
	End Rem
	Function RefreshSkin(theme:duiTheme)
		Local section:duiThemeSection
		
		m_renderer.Create(theme, "textfield")
		section = m_renderer.AddSectionFromStructure("glass", True)
		If section = Null
			Throw("(duiTextField.RefreshSkin) Failed to get section 'glass'")
		End If
		m_searchglasswidth = section.m_width
		m_searchglassheight = section.m_height
	End Function
	
End Type
