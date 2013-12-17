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
	import flash.events.MouseEvent;
	
	import org.osmf.chrome.metadata.ChromeMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataWatcher;
	
	public class PinUpButton extends ButtonWidget
	{
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
				visible = false;
			}
		}
		
		// Overrides
		//
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			if (media)
			{
				var metadata:Metadata = media.getMetadata(ChromeMetadata.CHROME_METADATA_KEY);
				if (metadata)
				{
					metadata.addValue(ChromeMetadata.AUTO_HIDE, !matchingAutoHideValue);
				}
				else
				{
					metadata = new Metadata();
					metadata.addValue(ChromeMetadata.AUTO_HIDE, !matchingAutoHideValue);
					media.addMetadata(ChromeMetadata.CHROME_METADATA_KEY, metadata);
				}
			}
		}
		
		// Internals
		//
		
		protected function get matchingAutoHideValue():Boolean
		{
			return false;
		}
		
		protected function autoHideChangeCallback(value:Boolean):void
		{
			visible = value == matchingAutoHideValue;
		}
		
		private var autoHideWatcher:MetadataWatcher;
	}
}