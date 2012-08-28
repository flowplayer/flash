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

package
{
	import flash.display.Sprite;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.advertisementplugin.AdvertisementPluginInfo;
	
	/**
	 * Entry class for the Ad Plugin insertions.
	 */
	public class AdvertisementPlugin extends Sprite
	{
		public function AdvertisementPlugin()
		{
			super();
			_pluginInfo = new AdvertisementPluginInfo();
		}
		
		public function get pluginInfo():PluginInfo
		{	
			return _pluginInfo;
		}		
	
		private var _pluginInfo:PluginInfo = null;
	}
}