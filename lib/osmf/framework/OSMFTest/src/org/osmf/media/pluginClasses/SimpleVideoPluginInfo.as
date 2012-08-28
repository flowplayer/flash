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
package org.osmf.media.pluginClasses
{
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetLoaderForTest;
	
	public class SimpleVideoPluginInfo extends PluginInfo
	{
		public static const MEDIA_FACTORY_ITEM_ID:String = "org.osmf.elements.video.simplevideo2";

		public function SimpleVideoPluginInfo()
		{
		}
		
		override public function initializePlugin(resource:MediaResourceBase):void
		{
			var netLoader:NetLoader = new NetLoaderForTest(null, false);
			var imageLoader:ImageLoader = new ImageLoader();

			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			items.push(new MediaFactoryItem(MEDIA_FACTORY_ITEM_ID, netLoader.canHandleResource, createVideoElement));
			
			mediaFactoryItems = items;
		}

		private function createVideoElement():MediaElement
		{
			return new VideoElement();
		}
	}
}