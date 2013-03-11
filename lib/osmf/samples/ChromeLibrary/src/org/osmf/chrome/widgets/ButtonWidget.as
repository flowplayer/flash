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
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import org.osmf.chrome.assets.Asset;
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.chrome.assets.DisplayObjectAsset;
	
	public class ButtonWidget extends Widget
	{
		public function ButtonWidget()
		{
			mouseEnabled = true;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onMouseClick_internal);
		}
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			up = assetManager.getDisplayObject(xml.@upFace);
			down = assetManager.getDisplayObject(xml.@downFace);
			disabled = assetManager.getDisplayObject(xml.@disabledFace);
			
			super.configure(xml, assetManager);
		}
		
		// Internals
		//
		
		private function onMouseOver(event:MouseEvent):void
		{
			mouseOver = true;
			setFace(enabled ? down : disabled);
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			mouseOver = false;
			setFace(enabled ? up : disabled);
		}
		
		private function setFace(face:DisplayObject):void
		{
			if (currentFace != face)
			{
				if (currentFace != null)
				{
					removeChild(currentFace);
				}
				
				currentFace = face;
				
				if (currentFace != null)
				{
					addChildAt(currentFace, 0);
					
					width = currentFace.width;
					height = currentFace.height;
				}
			}
		}
		
		private function onMouseClick_internal(event:MouseEvent):void
		{
			if (enabled == false)
			{
				event.stopImmediatePropagation();
			}
			else
			{
				onMouseClick(event);
			}
		}
		
		// Overrides
		//
		
		override protected function processEnabledChange():void
		{
			setFace(enabled ? mouseOver ? down : up : disabled);
			
			super.processEnabledChange();
		}
		
		// Stubs
		//
		
		protected function onMouseClick(event:MouseEvent):void
		{
		}
		
		protected var currentFace:DisplayObject;
		protected var mouseOver:Boolean;
		
		protected var up:DisplayObject;
		protected var down:DisplayObject;
		protected var disabled:DisplayObject;
		
	}
}