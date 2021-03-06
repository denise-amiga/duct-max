
Rem
Copyright (c) 2010 Coranna Howard <me@komiga.com>

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

Rem
	bbdoc: duct localization category (stores more categories and #dLocalizedText instances).
End Rem
Type dLocalizationCategory Extends dObjectMap
	
	Field m_name:String
	
	Rem
		bbdoc: Create a localization category.
		returns: Itself.
	End Rem
	Method Create:dLocalizationCategory(name:String)
		SetName(name)
		Return Self
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the category's name
		returns: Nothing.
	End Rem
	Method SetName(name:String)
		m_name = name
	End Method
	
	Rem
		bbdoc: Get the category's name.
		returns: The name of the category.
	End Rem
	Method GetName:String()
		Return m_name
	End Method
	
'#end region Field accessors
	
'#region Collections
	
	Rem
		bbdoc: Get a #dLocalizationCategory by the name given.
		returns: The #dLocalizationCategory with the name given, or Null if there is no category with the name given.
	End Rem
	Method Category:dLocalizationCategory(name:String)
		Return dLocalizationCategory(_ObjectWithKey(name.ToLower()))
	End Method
	
	Rem
		bbdoc: Get a #dLocalizedText with the name given.
		returns: The #dLocalizedText with the name given, or Null if there is no #dLocalizedText with the name given.
		about: See #TextAsString if you just want to get the value of the #dLocalizedText.
	End Rem
	Method TextL:dLocalizedText(name:String)
		Return dLocalizedText(_ObjectWithKey(name.ToLower()))
	End Method
	
	Rem
		bbdoc: Get the text of a #dLocalizedText with the name given.
		returns: The text for the #dLocalizedText with the name given, or Null if there is no #dLocalizedText with the name given.
	End Rem
	Method Text:String(name:String)
		Local ltext:dLocalizedText = TextL(name)
		If ltext
			Return ltext.GetValue()
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get a category from the given structure.
		returns: The category from the given structure, or Null if either no category was found at the end of the structure or the given separator is Null.
		about: @separator is the string inbetween a category (e.g. @{'mycategory.myothercategory'}, where @{'.'} is the separator).
	End Rem
	Method CategoryFromStructure:dLocalizationCategory(structure:String, separator:String = ".")
		If separator
			Local sloc:Int = structure.Find(separator)
			If sloc = -1
				Return Category(structure)
			Else
				Local cat:dLocalizationCategory = Category(structure[..sloc])
				If cat
					Return cat.CategoryFromStructure(structure[sloc + separator.Length..], separator)
				End If
			End If
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get the #dLocalizedText from the given structure.
		returns: The #dLocalizedText from the given structure, or Null if either no #dLocalizedText was found at the end of the structure or if the given separator is Null.
		about: @separator is the string inbetween a category/text (e.g. @{'mycategory.mytext'}, where @{'.'} is the separator).<br/>
		See #TextFromStructureAsString if you just want to get the value of the #dLocalizedText.
	End Rem
	Method TextFromStructureL:dLocalizedText(structure:String, separator:String = ".")
		If separator
			Local sloc:Int = structure.Find(separator)
			If sloc = -1
				Return TextL(structure)
			Else
				Local cat:dLocalizationCategory = Category(structure[..sloc])
				If cat
					Return cat.TextFromStructureL(structure[sloc + separator.Length..], separator)
				End If
			End If
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Get the value of the #dLocalizedText from the given structure.
		returns: The value of the #dLocalizedText from the given structure, or Null if either no #dLocalizedText was found at the end of the structure or the given separator is Null.
		about: @separator is the string inbetween a category/text (e.g. @{'mycategory.mytext'}, where @{'.'} is the separator).<br/>
	End Rem
	Method TextFromStructure:String(structure:String, separator:String = ".")
		Local ltext:dLocalizedText = TextFromStructureL(structure, separator)
		If ltext
			Return ltext.GetValue()
		End If
		Return Null
	End Method
	
	Rem
		bbdoc: Add a category to the category.
		returns: Nothing.
	End Rem
	Method AddCategory(category:dLocalizationCategory)
		Assert category, "(dLocalizationCategory.AddCategory()) @category is Null"
		If category
			_Insert(category.CollectionKey(), category)
		End If
	End Method
	
	Rem
		bbdoc: Add a LocalizedText to the category.
		returns: Nothing.
	End Rem
	Method AddText(text:dLocalizedText)
		Assert text, "(dLocalizationCategory.AddText()) @text is Null"
		If text
			_Insert(text.CollectionKey(), text)
		End If
	End Method
	
	Rem
		bbdoc: Remove a child by the given key.
		returns: True if the child was removed, or False if it was not (meaning the category does not contain a child with the key given).
		about: See #CollectionKey.
	End Rem
	Method RemoveChildByKey:Int(key:String)
		Return _Remove(key)
	End Method
	
	Rem
		bbdoc: Check if the category contains a text/category with the key given.
		returns: True if there is a text/category with the key given, or False if there is not.
	End Rem
	Method Contains:Int(key:String)
		Return _Contains(key.ToLower())
	End Method
	
	Rem
		bbdoc: Check if the category contains a category with the key given.
		returns: True if there is a category with the key given, or False if there is not.
	End Rem
	Method ContainsCategory:Int(key:String)
		Return Category(key.ToLower()) <> Null
	End Method
	
	Rem
		bbdoc: Check if the category contains a text with the key given.
		returns: True if there is a text with the key given, or False if there is not.
	End Rem
	Method ContainsText:Int(key:String)
		Return Text(key.ToLower()) <> Null
	End Method
	
	Rem
		bbdoc: Check if this category matches another.
		returns: True if the given category has all the categories and texts as this category, or False if the given category does not have all the categories and texts as this category.
		about: This will only check if the given category has the categories and texts that this category has.<br/>
		If the given category has extra categories or texts, they will not make the match false.<br/>
		If the given category is missing a category/text that this category has, the return value will be false.
	End Rem
	Method Matches:Int(category:dLocalizationCategory)
		Local cat:dLocalizationCategory, text:dLocalizedText
		Local catl:dLocalizationCategory
		For Local child:Object = EachIn ValueEnumerator()
			text = dLocalizedText(child)
			If text
				If Not category.ContainsText(text.CollectionKey())
					Return False
				End If
			Else
				cat = dLocalizationCategory(child)
				catl = category.Category(cat.CollectionKey())
				If catl
					If Not cat.Matches(catl)
						Return False
					End If
				Else
					Return False
				End If
			End If
		Next
		Return True
	End Method
	
	Rem
		bbdoc: Get the collection key for this category.
		returns: The collection key for this category (currently the name of the category).
	End Rem
	Method CollectionKey:String()
		Assert m_name, "(dLocalizationCategory.CollectionKey) m_name is Null"
		Return m_name.ToLower()
	End Method
	
'#end region Collections
	
	Rem
		bbdoc: Load the locale data from the given node.
		returns: The loaded locale (itself).
	End Rem
	Method FromNode:dLocalizationCategory(node:dNode)
		Local iden:dIdentifier, cnode:dNode
		SetName(node.GetName())
		For Local child:dVariable = EachIn node.GetChildren()
			iden = dIdentifier(child)
			If iden
				AddText(New dLocalizedText.FromIdentifier(iden, True))
			Else
				cnode = dNode(child)
				AddCategory(New dLocalizationCategory.FromNode(cnode))
			End If
		Next
		Return Self
	End Method
	
End Type

Rem
	bbdoc: duct localized text (contains a string localized to some language).
End Rem
Type dLocalizedText
	
	Rem
		bbdoc: The template for all dLocalizedText identifiers.
		about: Format: @{<i>text_name</i> "<i>text</i>"}
	End Rem
	Global m_template:dTemplate = New dTemplate.Create(Null, [[TV_STRING]])
	
	Field m_name:String
	Field m_text:String
	
	Rem
		bbdoc: Create a localized text.
		returns: Itself.
	End Rem
	Method Create:dLocalizedText(name:String)
		SetName(name)
		Return Self
	End Method
	
'#region Field accessors
	
	Rem
		bbdoc: Set the name for the localized text.
		returns: Nothing.
	End Rem
	Method SetName(name:String)
		m_name = name
	End Method
	
	Rem
		bbdoc: Get the text's name.
		returns: The name of the localized text.
	End Rem
	Method GetName:String()
		Return m_name
	End Method
	
	Rem
		bbdoc: Set the string value for the localized text.
		returns: Nothing.
		about: If @process is True (False by default), the given text will be post-processed (see #dLocaleManager #PostProcessText).
	End Rem
	Method SetValue(text:String, process:Int = False)
		If process
			text = dLocaleManager.PostProcessText(text)
		End If
		m_text = text
	End Method
	
	Rem
		bbdoc: Get the string value for the localized text.
		returns: The string value (text) for the localized text.
	End Rem
	Method GetValue:String()
		Return m_text
	End Method
	
'#end region Field accessors
	
'#region Collections
	
	Rem
		bbdoc: Get the collection key for the localized text.
		returns: The collection key for the localized text (currently the name of the localized text).
	End Rem
	Method CollectionKey:String()
		Assert m_name, "(dLocalizedText.CollectionKey) m_name is Null!"
		Return m_name.ToLower()
	End Method
	
'#end region Collections
	
	Rem
		bbdoc: Load a localized text from the given identifier.
		returns: The loaded localized text (itself), or Null if the given identifier is not of the correct template (see #m_template).
	End Rem
	Method FromIdentifier:dLocalizedText(iden:dIdentifier, process:Int = True)
		If m_template.ValidateIdentifier(iden)
			SetName(iden.GetName())
			SetValue(dStringVariable(iden.GetValueAtIndex(0)).Get(), process)
			Return Self
		Else
			Return Null
		End If
	End Method
	
End Type

