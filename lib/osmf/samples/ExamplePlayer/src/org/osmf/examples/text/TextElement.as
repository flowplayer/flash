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
package org.osmf.examples.text
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.DisplayObjectTrait;
	
	public class TextElement extends MediaElement
	{
		public function TextElement(text:String=null)
		{
			super();
			
			this.text = text;
		}
		
		public function set text(value:String):void
		{
			if (value != text)
			{
				_text = value;
			
				updateText();
			}
		}
		
		public function get text():String
		{
			return _text;
		}

		// Internals
		//
		
		private function updateText():void
		{
			var textField:TextField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;

            var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xFFFFFF;
            format.size = 30;

            textField.defaultTextFormat = format;
            
            if (text != null)
            {
            	textField.text = text;

				if (displayObjectTrait == null)
				{
  					displayObjectTrait = new TextDisplayObjectTrait(textField);
			
					addTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);
				}
				
				displayObjectTrait.setSize(textField.width, textField.height);
            }
		}
		
		private var displayObjectTrait:TextDisplayObjectTrait;
		private var _text:String;
	}
}