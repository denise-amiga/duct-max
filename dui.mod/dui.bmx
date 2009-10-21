
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
End Rem

SuperStrict

Rem
bbdoc: The duct GUI module
End Rem
Module duct.dui

ModuleInfo "Version: 0.45"
ModuleInfo "Copyright: Liam McGuigan (FryGUI creator)"
ModuleInfo "Copyright: Tim Howard (dui is a heavily modified FryGUI)"
ModuleInfo "License: MIT"

ModuleInfo "History: Version 0.45"
ModuleInfo "History: Renamed all 'dui_T*' types to 'dui_*'"
ModuleInfo "History: Added single-surface themes and theme rendering interface"
ModuleInfo "History: Ported to use Protog2D"
ModuleInfo "History: Massive cleanup (renamed all 'g*' fields to 'm_*' (lowercased) and all non-conflicting parameters from '_*' to '*')"
ModuleInfo "History: Version 0.44"
ModuleInfo "History: Changed some formatting here and there"
ModuleInfo "History: Fixed MouseZ scrolling flowing through to other gadgets"
ModuleInfo "History: Fixed dui_Table rendering"
ModuleInfo "History: Version 0.43"
ModuleInfo "History: Cleanup of headers (full cleanup may come later..)"
ModuleInfo "History: Version 0.4"
ModuleInfo "History: Changed event and mouse handling"
ModuleInfo "History: bbdoc'd everything"
ModuleInfo "History: Removed procedural interfaces"
ModuleInfo "History: Converted from FryGUI (permission given by Liam)"
ModuleInfo "History: Initial release"

ModuleInfo "TODO: Implement a better event system (thinking wxmax-style/connector functions) and change the way special-function gadgets work (scrollbox, datepanel, combobox, etc)"
ModuleInfo "TODO: Implement a registry system for extra gadget types (something like RegisterGadgetType(dui_MyGadgetType) - which will contain pointers for skin refreshing and whatnot)"
ModuleInfo "TODO: Find a good way to handle scripted ui <-> code and incapsulated event-handling"
ModuleInfo "ISSUE: The event EVENT_KEYCHAR is not repeated whilst a character key is held down under Linux [see temporary fix in TDUIMain.__keyinputhook(...)]"

' Used modules
Import brl.linkedlist

Import duct.etc
Import duct.objectmap
Import duct.scriptparser
Import duct.vector

Import duct.protog2d

Import duct.duimisc
Import duct.duidate
Import duct.duidraw

' Included source code
Include "inc/types/event.bmx"
Include "inc/types/theme.bmx"
Include "inc/types/renderers.bmx"
Include "inc/types/gadgets/gadgets.bmx"

Include "inc/other/extra.bmx"


' Selected item constant
Const dui_SELECTED_ITEM:Int = -2

Const dui_CURSOR_NORMAL:Int = 0
Const dui_CURSOR_MOUSEOVER:Int = 1
Const dui_CURSOR_MOUSEDOWN:Int = 2
Const dui_CURSOR_TEXTOVER:Int = 3

Const dui_ALIGN_VERTICAL:Int = 0
Const dui_ALIGN_HORIZONTAL:Int = 1
Const dui_ALIGN_LEFT:Int = 2
Const dui_ALIGN_RIGHT:Int = 3

Rem
	bbdoc: The dui controller/interface type.
End Rem
Type TDUIMain
	
	Global m_currentscreen:dui_Screen
	Global m_focusedpanel:dui_Panel, m_focusedgadget:dui_Gadget
	Global m_activegadget:dui_Gadget
	
	Global m_theme:dui_Theme
	
	Global m_screens:TListEx = New TListEx
	Global m_extras:TListEx = New TListEx
	
	Global m_width:Int = 1024, m_height:Int = 768
	
	Global m_cursorrenderer:dui_CursorRenderer = New dui_CursorRenderer
	Global m_currentcursor:Int, m_cursortype:Int
	
'#region Miscellaneous
	
	Rem
		bbdoc: Setup initial values for the ui.
		returns: Nothing.
	End Rem
	Function InitiateUI()
		'about: This needs to be called AFTER you open your graphics context.
		'dui_Font.SetupDefaultFont()
		
		AddHook(EmitEventHook, __keyinputhook, Null, 0)
	End Function
	
	Rem
		bbdoc: Set the current screen
		returns: Nothing.
	End Rem
	Function SetCurrentScreen(screen:dui_Screen, doevent:Int = False)
		If screen <> Null
			m_currentscreen = screen
			If doevent = True
				New dui_Event.Create(dui_EVENT_SETSCREEN, Null, 0, 0, 0, screen)
			End If
		End If
	End Function
	
	Rem
		bbdoc: Send a key to the active gadget (if there is an active gadget).
		returns: Nothing.
	End Rem
	Function SendKeyToActiveGadget(key:Int, _type:Int = 0)
		If m_activegadget <> Null
			m_activegadget.SendKey(key, _type)
		Else
			If m_focusedgadget <> Null
				If dui_TextField(m_focusedgadget) = Null
					'DebugLog("SKTAG; Focused")
					m_focusedgadget.SendKey(key, _type)
				End If
			End If
		End If
	End Function
	
'#end region (Miscellaneous)
	
'#region System dimensions
	
	Rem
		bbdoc: Set the ui dimensions.
		returns: Nothing.
	End Rem
	Function SetDimensions(width:Int, height:Int)
		m_width = width
		m_height = height
	End Function
	
	Rem
		bbdoc: Get the screen width of the ui system.
		returns: The ui area's width.
	End Rem
	Function GetScreenWidth:Int()
		Return m_width
	End Function
	
	Rem
		bbdoc: Get the screen height of the ui system.
		returns: The ui area's height.
	End Rem
	Function GetScreenHeight:Int()
		Return m_height
	End Function
	
'#end region (System dimensions)
	
'#region Update/Refresh & Render
	
	Rem
		bbdoc: Render the extra gadgets.
		returns: Nothing.
	End Rem
	Function RenderExtra()
		For Local extra:dui_Gadget = EachIn m_extras
			extra.Render(0.0, 0.0)
		Next
	End Function
	
	Rem
		bbdoc: Update the extra gadgets.
		returns: Nothing.
	End Rem
	Function UpdateExtra()
		Local extra:dui_Gadget
		For extra = EachIn New TListReversed.Create(m_extras)
			extra.Update(0.0, 0.0)
		Next
	End Function
	
	Rem
		bbdoc: Refresh the GUI.
		returns: Nothing.
		about: This will render, and update the current screen (and extras).
	End Rem
	Function Refresh()
		' Push the current graphics state on to the stack
		TProtogDrawState.Push()
		
		' Clear the focused gadget and panel
		m_focusedgadget = Null
		m_focusedpanel = Null
		
		' Reset the cursor
		m_currentcursor = dui_CURSOR_NORMAL
		m_currentscreen.Render()
		RenderExtra()
		
		UpdateExtra()
		m_currentscreen.Update()
		' Draw the cursor
		RenderCursor()
		
		' Re-instate the pushed graphics state
		TProtogDrawState.Pop()
		'TProtog2DDriver.UnbindTextureTarget(GL_TEXTURE_2D)
		'TProtog2DDriver.UnbindTextureTarget(GL_TEXTURE_RECTANGLE_EXT)
		
		' Temporary fix
		dui_Gadget.m_oz = MouseZ()
	End Function
	
'#end region (Update/Refresh & Render)
	
'#region Theme
	
	Rem
		bbdoc: Set the system's theme and update all gadget renderers.
		returns: Nothing.
	End Rem
	Function SetTheme(theme:dui_Theme)
		m_theme = theme
		dui_Panel.RefreshSkin(m_theme)
		dui_Button.RefreshSkin(m_theme)
		dui_ComboBox.RefreshSkin(m_theme)
		dui_Menu.RefreshSkin(m_theme)
		dui_ProgressBar.RefreshSkin(m_theme)
		dui_CheckBox.RefreshSkin(m_theme)
		dui_ScrollBar.RefreshSkin(m_theme)
		dui_TextField.RefreshSkin(m_theme)
		dui_Date.RefreshSkin(m_theme)
		dui_DatePanel.RefreshSkin(m_theme)
		dui_SearchBox.RefreshSkin(m_theme)
		dui_SearchPanel.RefreshSkin(m_theme)
		dui_Slider.RefreshSkin(m_theme)
		
		SetupCursorRenderer(m_theme)
	End Function
	
	Rem
		bbdoc: Setup the cursor renderer.
		returns: Nothing.
	End Rem
	Function SetupCursorRenderer(theme:dui_Theme)
		m_cursorrenderer.Create(theme, "cursor")
	End Function
	
'#end region (Theme)
	
'#region Collections
	
	Rem
		bbdoc: Add an extra gadget to the system.
		returns: Nothing.
	End Rem
	Function AddExtra(extra:dui_Gadget)
		If extra <> Null
			m_extras.AddLast(extra)
		End If
	End Function
	
	Rem
		bbdoc: Add a screen to the system.
		returns: Nothing.
	End Rem
	Function AddScreen(screen:dui_Screen)
		If screen <> Null
			m_screens.AddLast(screen)
		End If
	End Function
	
	Rem
		bbdoc: Get a screen the given name.
		returns: The screen with the given name, or Null if there is no screen with the name.
	End Rem
	Function GetScreenFromName:dui_Screen(name:String)
		Local screen:dui_Screen
		If name <> Null
			name = name.ToLower()
			For screen = EachIn m_screens
				If screen.GetName().ToLower() = name
					Return screen
				End If
			Next
		End If
		Return Null
	End Function
	
	Rem
		bbdoc: Get a panel from the given name.
		returns: The panel with the given name, or Null if there is no panel with the name.
		about: If @fromscreen is not Null it will be searched, if it is Null all screens will be searched.
	End Rem
	Function GetPanelFromName:dui_Panel(fromscreen:dui_Screen, name:String)
		Local screen:dui_Screen, panel:dui_Panel
		
		If name <> Null
			If fromscreen <> Null
				panel = screen.GetPanelByName(name)
			Else
				'_name = name.ToLower()
				For screen = EachIn m_screens
					panel = screen.GetPanelByName(name)
					If panel <> Null
						Return panel
					End If
				Next
			End If
		End If
		Return panel
	End Function
	
'#end region (Collections)
	
'#region Active and focus
	
	Rem
		bbdoc: Check if the active gadget is @gadget or if the active gadget is Null.
		returns: True if the active gadget is Null or @gadget, or False if it was neither (some other gadget).
	End Rem
	Function IsGadgetActive:Int(gadget:dui_Gadget)
		If m_activegadget = Null Or m_activegadget = gadget
			Return True
		End If
		Return False
	End Function
	
	Rem
		bbdoc: Clear the active gadget.
		returns: Nothing.
	End Rem
	Function ClearActiveGadget()
		m_activegadget = Null
	End Function
	
	Rem
		bbdoc: Get the active gadget.
		returns: The active gadget.
	End Rem
	Function GetActiveGadget:dui_Gadget()
		Return m_activegadget
	End Function
	
	Rem
		bbdoc: Set the active gadget.
		returns: Nothing.
	End Rem
	Function SetActiveGadget(gadget:dui_Gadget)
		m_activegadget = gadget
	End Function
	
	Rem
		bbdoc: Set the focused gadget.
		returns: Nothing.
		about: If a gadget already has focus this will do nothing. This creates an event (dui_EVENT_MOUSEOVER) with the given gadget.
	End Rem
	Function SetFocusedGadget(gadget:dui_Gadget, x:Int, y:Int)
		' Only make the change if no gadget has focus already (should be removed? - look at SetFocusedPanel \/)
		If m_focusedgadget = Null
			m_focusedgadget = gadget
			New dui_Event.Create(dui_EVENT_MOUSEOVER, gadget, 0, x, y, Null)
		End If
	End Function
	
	Rem
		bbdoc: Get the focused gadget.
		returns: The gadget with mouse focus.
	End Rem
	Function GetFocusedGadget:dui_Gadget()
		Return m_focusedgadget
	End Function
	
	Rem
		bbdoc: Set the focused panel.
		returns: Nothing.
	End Rem
	Function SetFocusedPanel(panel:dui_Panel)
		m_focusedpanel = panel
	End Function
	
	Rem
		bbdoc: Check if the focused panel is Null or @panel.
		returns: True if the focused panel is Null or if it is @panel, or False if it was neither (some other panel).
	End Rem
	Function IsPanelFocused:Int(panel:dui_Panel)
		If m_focusedpanel = Null Or m_focusedpanel = panel Or m_focusedpanel = panel.m_parent
			Return True
		Else
			Return False
		End If
	End Function
	
'#end region (Active and focus)
	
'#region Cursor
	
	Rem
		bbdoc: Set the current cursor.
		returns: Nothing.
	End Rem
	Function SetCursor(cursor:Int)
		m_currentcursor = cursor
	End Function
	Rem
		bbdoc: Get the current cursor.
		returns: The current cursor.
	End Rem
	Function GetCursor:Int()
		Return m_currentcursor
	End Function
	
	Rem
		bbdoc: Set the cursor type.
		returns: Nothing.
		about: @cursortype can be:<br/>
		0 - Normal cursor (the skin's cursors)<br/>
		1 - System cursor<br/>
	End Rem
	Function SetCursorType(cursortype:Int)
		m_cursortype = cursortype
	End Function
	Rem
		bbdoc: Get the cursor type.
		returns: The current cursor type.
	End Rem
	Function GetCursorType:Int()
		Return m_cursortype
	End Function
	
	Rem
		bbdoc: Render the cursor (if it is enabled).
		returns: Nothing.
	End Rem
	Function RenderCursor()
		If m_cursortype = 0
			TProtog2DDriver.SetBlend(BLEND_ALPHA)
			TProtog2DDriver.SetAlpha(1.0)
			TProtog2DDriver.BindColorParams(1.0, 1.0, 1.0)
			m_cursorrenderer.RenderCursor(m_currentcursor, Float(MouseX()), Float(MouseY()))
		Else If m_cursortype = 1
			'?win32
			'Select m_currentcursor
			'	Case dui_CURSOR_NORMAL
			'		pub.win32.SetCursor(1)
			'	Case dui_CURSOR_MOUSEOVER
			'		pub.win32.SetCursor(2)
			'	Case dui_CURSOR_MOUSEDOWN
			'		pub.win32.SetCursor(2)
			'End Select
			'?
		End If
	End Function
	
'#end region (Cursor)
	
'#region Default color & alpha
	
	Rem
		bbdoc: Set the default gadget color.
		returns: Nothing.
	End Rem
	Method SetDefaultColor(color:TProtogColor, alpha:Int = True, index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaultcolor.Length
			dui_Gadget.m_defaultcolor[index].SetFromColor(color, alpha)
		End If
	End Method
	
	Rem
		bbdoc: Set the defautl gadget color to the parameters given.
		returns: Nothing.
	End Rem
	Method SetDefaultColorParams(red:Float, green:Float, blue:Float, index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaultcolor.Length
			dui_Gadget.m_defaultcolor[index].SetColor(red, green, blue)
		End If
	End Method
	
	Rem
		bbdoc: Get the default gadget color.
		returns: The default gadget color at the given index, or Null if the given index was invalid.
	End Rem
	Method GetDefaultColor:TProtogColor(index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaultcolor.Length
			Return dui_Gadget.m_defaultcolor[index]
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Set the default gadget text color.
		returns: Nothing.
	End Rem
	Method SetDefaultTextColor(color:TProtogColor, alpha:Int = True, index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaulttextcolor.Length
			dui_Gadget.m_defaulttextcolor[index].SetFromColor(color, alpha)
		End If
	End Method
	
	Rem
		bbdoc: Set the default gadget text color by the parameters given.
		returns: Nothing.
	End Rem
	Method SetDefaultTextColorParams(red:Float, green:Float, blue:Float, index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaulttextcolor.Length
			dui_Gadget.m_defaulttextcolor[index].SetColor(red, green, blue)
		End If
	End Method
	
	Rem
		bbdoc: Get the default gadget text color.
		returns: The default gadget text color at the given index, or Null if the given index was invalid.
	End Rem
	Method GetDefaultTextColor:TProtogColor(index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaulttextcolor.Length
			Return dui_Gadget.m_defaulttextcolor[index]
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Set the default gadget alpha.
		returns: Nothing.
	End Rem
	Method SetDefaultAlpha(alpha:Float, index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaultcolor.Length
			dui_Gadget.m_defaultcolor[index].SetAlpha(alpha)
		End If
	End Method
	
	Rem
		bbdoc: Get the default gadget alpha.
		returns: The default gadget alpha at the given index, or 1.0 if the given index was invalid.
	End Rem
	Method GetDefaultAlpha:Float(index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaultcolor.Length
			Return dui_Gadget.m_defaultcolor[index].GetAlpha()
		End If
		Return 1.0
	End Method
	
	Rem
		bbdoc: Set the default gadget text alpha.
		returns: Nothing.
	End Rem
	Method SetDefaultTextAlpha(alpha:Float, index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaulttextcolor.Length
			dui_Gadget.m_defaulttextcolor[index].SetAlpha(alpha)
		End If
	End Method
	
	Rem
		bbdoc: Get the default gadget text alpha.
		returns: The default gadget text alpha at the given index, or 1.0 if the given index was invalid.
	End Rem
	Method GetDefaultTextAlpha:Float(index:Int = 0)
		If index > - 1 And index < dui_Gadget.m_defaulttextcolor.Length
			Return dui_Gadget.m_defaulttextcolor[index].GetAlpha()
		End If
		Return 1.0
	End Method
	
'#end region (Default color & alpha)
	
'#region Key hook
	
	' For some reason EVENT_KEYCHAR is only repeated in windows (not getting the event, over and over, when a key is held down on Ubuntu 8.04)
	Function __keyinputhook:Object(id:Int, data:Object, context:Object)
		Local event:TEvent
		
		event = TEvent(data)
		If event <> Null
			Select event.id
				Case EVENT_KEYDOWN
					'DebugLog("TDUIMain.__keyinputhook(); EVENT_KEYDOWN (ed: " + event.data + ") caught")
					SendKeyToActiveGadget(event.data, 0)
				Case EVENT_KEYREPEAT
					'DebugLog("TDUIMain.__keyinputhook(); EVENT_KEYREPEAT (ed: " + event.data + ") caught")
					
					' Temporary fix for EVENT_KEYCHAR not repeating (sadly the event's data is always upper-case, so this isn't completely viable)
					?Linux
						If event.data > 31
							SendKeyToActiveGadget(event.data, 1)
						Else
							SendKeyToActiveGadget(event.data, 0)
						End If
					?Not Linux
						SendKeyToActiveGadget(event.data, 0)
					?
				Case EVENT_KEYCHAR
					'DebugLog("TDUIMain.__keyinputhook(); EVENT_KEYCHAR (ed: " + event.data + ") caught")
					SendKeyToActiveGadget(event.data, 1)
			End Select
		End If
		Return data
	End Function
	
'#end region (Key hook & miscellaneous)
	
End Type

















