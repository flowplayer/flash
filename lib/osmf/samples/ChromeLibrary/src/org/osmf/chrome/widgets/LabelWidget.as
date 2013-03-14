/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.chrome.widgets
{
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.chrome.assets.FontAsset;
	
	public class LabelWidget extends Widget
	{
		public function LabelWidget()
		{
			textField = new TextField();
			addChild(textField);
			
			super();
		}
		
		public function get text():String
		{
			return textField.text;
		}
		
		public function set text(value:String):void
		{
			textField.text = value;
		}
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			var fontId:String = xml.@font || "defaultFont";
			var fontAsset:FontAsset = assetManager.getAsset(fontId) as FontAsset;
			var format:TextFormat = fontAsset.format;
			format.color = parseInt(xml.@textColor || format.color.toString());
			
			textField.defaultTextFormat = format;
			textField.embedFonts = true;
			textField.type = String(parseAttribute(xml, "input", "false")).toLocaleLowerCase()=="true" ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			textField.selectable = textField.type == TextFieldType.INPUT || String(parseAttribute(xml, "selectable", "false")).toLocaleLowerCase()=="true";
			textField.background = String(parseAttribute(xml, "background", "false")).toLocaleLowerCase()=="true";
			textField.displayAsPassword = String(parseAttribute(xml, "password", "false")).toLocaleLowerCase()=="true";
			textField.backgroundColor = Number(xml.@backgroundColor || NaN);
			textField.alpha = Number(xml.@textAlpha) || 1;
			textField.text = xml.@text;
			textField.multiline = String(parseAttribute(xml, "multiline", "false")).toLocaleLowerCase()=="true";
			textField.wordWrap = textField.multiline;
		}
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			textField.width = availableWidth;
			textField.height = availableHeight;
		}
		
		// Internals
		//
		
		private var textField:TextField;
	}
}