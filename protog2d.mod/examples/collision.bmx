
Rem
	example01.bmx
	Tests xroads.p2d collision.
End Rem

SuperStrict

Framework brl.blitz
Import brl.standardio
Import brl.system
Import brl.textstream

Import brl.bmploader
Import brl.jpgloader
Import brl.pngloader

Import duct.protog2d
'Import ductdev.p2d

Global mainapp:MyGraphicsApp = New MyGraphicsApp.Create()
mainapp.Run()
End

Type MyGraphicsApp Extends dProtogGraphicsApp
	
	Field m_gdriver:dProtog2DDriver
	
	Field m_font:dProtogFont
	Field m_bmaxlogo:dProtogTexture
	Field m_color_white:dProtogColor, m_color_grey:dProtogColor, m_color_highlight:dProtogColor
	
	Field m_infotext:dProtogTextEntity, m_bmaxsprite:dProtogSpriteEntity
	
	Method New()
	End Method
	
	Method Create:MyGraphicsApp()
		Super.Create()
		Return Self
	End Method
	
	Method OnInit()
		m_graphics = New dProtogGraphics.Create(800, 600, 0, 60,, 0, False)
		If m_graphics.StartGraphics() = False
			Print("Failed to open graphics mode!")
			End
		End If
		m_gdriver = m_graphics.GetDriverContext()
		
		m_gdriver.SetRenderBufferOnFlip(False)
		m_gdriver.UnbindRenderBuffer()
		
		InitResources()
		InitEntities()
	End Method
	
	Method InitResources()
		m_color_white = New dProtogColor.Create(1.0, 1.0, 1.0)
		dProtogEntity.SetDefaultColor(m_color_white)
		m_color_grey = New dProtogColor.Create(0.6, 0.6, 0.6)
		m_color_highlight = New dProtogColor.Create(1.0, 0.0, 0.0)
		
		m_font = New dProtogFont.FromNode(New TSNode.LoadScriptFromObject("fonts/arial.font"), True)
		dProtogTextEntity.SetDefaultFont(m_font)
		
		m_bmaxlogo = New dProtogTexture.Create(LoadPixmap("textures/max.png"), TEXTURE_RECTANGULAR, True)
	End Method
	
	Method InitEntities()
		m_infotext = New dProtogTextEntity.Create("fps: {fps} - vsync: {vsync}~n" + ..
			"~tControls: F1 - vsync on/off",  ..
			, New dVec2.Create(2.0, 2.0), m_color_grey)
		
		m_infotext.SetupReplacer()
		m_infotext.SetReplacementByName("vsync", m_graphics.GetVSyncState())
		m_bmaxsprite = New dProtogSpriteEntity.Create(m_bmaxlogo, New dVec2.Create(44.0, 44.0))
	End Method
	
	Method Run()
		m_gdriver.SetBlend(BLEND_ALPHA)
		While KeyDown(KEY_ESCAPE) = False And AppTerminate() = False
			m_graphics.Cls()
			dProtog2DCollision.ResetCollisions(ECollisionLayers.LAYER_1)
			Update()
			Render()
			m_graphics.Flip()
			Delay(2)
		Wend
		Shutdown()
	End Method
	
	Method Render()
		m_bmaxsprite.Render()
		m_infotext.Render()
	End Method
	
	Method Update()
		' Entities
		'm_bmaxsprite.SetPositionParams(MouseX() - (m_bmaxlogo.GetWidth() / 2), MouseY () - (m_bmaxlogo.GetHeight() / 2))
		If KeyHit(KEY_F2) = True
			DebugStop
		End If
		
		Local pos:dVec2 = m_bmaxsprite.m_pos, size:dVec2 = m_bmaxsprite.m_size
		dProtog2DCollision.CollideTexture(m_bmaxsprite.m_texture, pos.m_x, pos.m_y, 0, ECollisionLayers.LAYER_1, m_bmaxsprite)
		
		Local objs:Object[]
		objs = dProtog2DCollision.CollideRect(MouseX(), MouseY(), 1.0, 1.0, ECollisionLayers.LAYER_1, 0, Null)
		If objs <> Null
			If objs[0] = m_bmaxsprite
				DebugLog("Collided with sprite!!")
				m_bmaxsprite.SetColor(m_color_highlight)
			End If
		Else
			m_bmaxsprite.SetColor(m_color_white)
			DebugLog("Not colliding")
		End If
		
		TFPSCounter.Update()
		m_infotext.SetReplacementByName("fps", TFPSCounter.GetFPS())
		
		If KeyHit(KEY_F1) = True
			m_graphics.SetVSyncState(m_graphics.GetVSyncState() ~1)
			m_infotext.SetReplacementByName("vsync", m_graphics.GetVSyncState())
		End If
	End Method
	
	Method OnExit()
		' The super OnExit method will destroy the graphical context
		Super.OnExit()
	End Method
	
End Type

