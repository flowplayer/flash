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

package org.osmf.examples.recommendations
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;

	[Event(name="click", type="flash.events.MouseEvent")]
	
	public class RecommendationsElement extends MediaElement
	{
		public function RecommendationsElement()
		{
			super();

            var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xFFFFFF;
            format.size = 14;
            format.align = TextFormatAlign.CENTER;
            
			var textField:TextField = new TextField();
			textField.defaultTextFormat = format;
			textField.text = "Click to jump to the 'Video with Timed Ad Insertion' example!";
            textField.y = 100;
            textField.width = 640;
            textField.selectable = false;
            
			displayObject = new Sprite();
			
			var g:Graphics = displayObject.graphics;
			g.beginFill(0xffffff, 0.2);
			g.drawRect(0,0,640, 360);
			g.endFill();
			
			displayObject.addChild(textField);
			displayObject.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			var displayObjectTrait:DisplayObjectTrait = new DisplayObjectTrait(displayObject, 640, 360);
			
			addTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			var data:Metadata = new Metadata();
			data.addValue("open", "Video with Timed Ad Insertion");
			
			addMetadata("recommendations", data); 
		}
		
		private var displayObject:Sprite;
	}
}