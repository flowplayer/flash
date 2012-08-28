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
	import __AS3__.vec.Vector;
	
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetLoaderForTest;
	
	public class SimpleVideoImagePluginInfo extends PluginInfo
	{
		public static const VIDEO_MEDIA_FACTORY_ITEM_ID:String = "org.osmf.elements.video.simplevideo";
		public static const IMAGE_MEDIA_FACTORY_ITEM_ID:String = "org.osmf.elements.image.simplemage";

		public function SimpleVideoImagePluginInfo()
		{
			var netLoader:NetLoader = new NetLoaderForTest(null, false);
			var imageLoader:ImageLoader = new ImageLoader();

			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			items.push(new MediaFactoryItem(VIDEO_MEDIA_FACTORY_ITEM_ID, netLoader.canHandleResource, createVideoElement));
			items.push(new MediaFactoryItem(IMAGE_MEDIA_FACTORY_ITEM_ID, imageLoader.canHandleResource, createImageElement));
			
			super(items);
		}
		
		private function createVideoElement():MediaElement
		{
			return new VideoElement();
		}

		private function createImageElement():MediaElement
		{
			return new ImageElement();
		}
	}
}