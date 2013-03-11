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

package org.osmf.qos
{
	import __AS3__.vec.Vector;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;

	public class VideoQoSPluginInfo extends PluginInfo
	{
		public function VideoQoSPluginInfo()
		{
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			items.push(mediaFactoryItem);
			
			super(items, mediaElementCreationNotificationFunction);
		}
		
		public static function get mediaFactoryItem():MediaFactoryItem
		{
			return _mediaFactoryItem;
		}
		
		private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean
		{
			return true;
		}
		
		private static function mediaElementCreationFunction():MediaElement
		{
			return new VideoQoSProxyElement();
		}
		
		private static var _mediaFactoryItem:MediaFactoryItem
			= new MediaFactoryItem
				( "org.osmf.qos.VideoQoSPluginInfo"
				, canHandleResourceFunction
				, mediaElementCreationFunction
				, MediaFactoryItemType.PROXY
				);
	}
}