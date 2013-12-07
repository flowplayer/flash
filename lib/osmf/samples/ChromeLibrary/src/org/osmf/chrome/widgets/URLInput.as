/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.chrome.widgets
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.chrome.assets.FontAsset;
	import org.osmf.media.MediaElement;
	
	[Event(name="change", type="flash.events.Change")];
	
	public class URLInput extends Widget
	{
		public function URLInput()
		{
			label = new TextField();
			addChild(label);
			
			input = new TextField(); 
			input.type = TextFieldType.INPUT;
			input.selectable = true;
			input.background = true;
			
			input.addEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown);
			addChild(input);
			
			super();
		}
		
		public function set url(value:String):void
		{
			input.text = value;
			focus();
		}
		public function get url():String
		{
			return input.text;
		}
		
		public function focus():void
		{
			if (visible && stage)
			{
				stage.focus = input;
			}
			input.setSelection(0, input.text.length);
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
			
			label.defaultTextFormat = format;
			label.embedFonts = true;
			label.selectable = false;
			label.height = 20;
			label.alpha = 0.4;
			label.y = 6;
			label.text = String(parseAttribute(xml, "title", "MEDIA URL:"));
			
			input.defaultTextFormat = format;
			input.embedFonts = true;
			input.backgroundColor = 0x808080;
			input.height = 16;
			input.alpha = 0.8;
			input.x = 2;
			input.y = 21;
		}
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			label.width = availableWidth;
			input.width = availableWidth - input.x * 2;
		}
		
		override protected function processMediaElementChange(oldElement:MediaElement):void
		{
			visible = media == null;
			focus();
		}
		
		// Internals
		//
		
		private function onInputKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == 13 /*enter*/)
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private var label:TextField;
		private var input:TextField;	
	}
}