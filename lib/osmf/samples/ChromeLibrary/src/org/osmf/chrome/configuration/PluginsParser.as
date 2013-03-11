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

package org.osmf.chrome.configuration
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;
	
	[Event(name="complete", type="flash.events.Event")]
	
	public class PluginsParser extends EventDispatcher
	{
		public function parse(pluginsList:XMLList, mediaFactory:MediaFactory):void
		{
			var pluginsToLoad:int = 0;
			
			if (mediaFactory == null)
			{
				onPluginResult();
				return;
			}
			else
			{
				mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginResult);
				mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginResult);
			}
			
			function onPluginResult(event:MediaFactoryEvent = null):void
			{
				pluginsToLoad--;
				if (pluginsToLoad <= 0)
				{
					mediaFactory.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginResult);
					mediaFactory.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginResult);
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
			
			for each (var plugin:XML in pluginsList)
			{
				mediaFactory.loadPlugin(new URLResource(plugin.@url));
			}
			
			onPluginResult();
		}
	}
}