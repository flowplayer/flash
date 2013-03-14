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
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.MetadataWatcher;
	
	public class MetadataLabel extends LabelWidget
	{
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			metadataNamespace = xml.@metadataNamespace;
			metadataKey = xml.@metadataKey;
			prefix = xml.@text;
			postfix = xml.@postfix;
			
			super.configure(xml, assetManager);	
		}
		
		override public function set media(value:MediaElement):void
		{
			if (media != value)
			{
				if (watcher)
				{
					// Clean up:
					watcher.unwatch();
					watcher = null;	
				}
				
				if (value)
				{
					// Watch the indicated metadata value for change:
					watcher = 
						new MetadataWatcher
							( value.metadata
							, metadataNamespace
							, metadataKey
							, onMetadataValueChange
							);
					watcher.watch();
				}
				else
				{
					text = "";
				}
			}
			
			super.media = value;
		}
		
		// Internals
		//
		
		private var watcher:MetadataWatcher;
		private var metadataNamespace:String;
		private var metadataKey:String;
		private var prefix:String = "";
		private var postfix:String = "";
		
		private function onMetadataValueChange(value:*):void
		{
			text = prefix + value + postfix;
		}	
	}
}