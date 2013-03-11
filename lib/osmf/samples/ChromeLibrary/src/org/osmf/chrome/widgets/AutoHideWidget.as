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
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.chrome.metadata.ChromeMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.MetadataWatcher;
	
	public class AutoHideWidget extends Widget
	{
		public function AutoHideWidget()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onFirstAddedToStage);
		}
		
		// Overrides
		//
		
		override protected function processMediaElementChange(oldElement:MediaElement):void
		{
			if (autoHideWatcher)
			{
				autoHideWatcher.unwatch();
				autoHideWatcher = null;
			}
			
			if (media != null)
			{
				autoHideWatcher
					= new MetadataWatcher
						( media.metadata
						, ChromeMetadata.CHROME_METADATA_KEY
						, ChromeMetadata.AUTO_HIDE
						, autoHideChangeCallback
						);
				autoHideWatcher.watch();
			}
			else
			{
				visible = true;
			}
		}
		
		private function onFirstAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onFirstAddedToStage);
			 
			stage.addEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver);
			stage.addEventListener(MouseEvent.MOUSE_OUT, onStageMouseOut);
		}
		
		private function onStageMouseOver(event:MouseEvent):void
		{
			mouseOver = true;
			visible = _autoHide ? mouseOver : true;
		}
		
		private function onStageMouseOut(event:MouseEvent):void
		{
			mouseOver = false;
			visible = _autoHide ? mouseOver : true;
		}
		
		private function autoHideChangeCallback(value:Boolean):void
		{
			_autoHide = value;
			visible = _autoHide ? mouseOver : true;
		}
		
		private var autoHideWatcher:MetadataWatcher;
		private var _autoHide:Boolean;
		private var mouseOver:Boolean;
	}
}