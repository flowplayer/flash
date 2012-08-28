/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.player.plugins
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	
	public class MockMediaFactory extends MediaFactory
	{
		public static const REMOTE_INVALID_PLUGIN_SWF_URL:String = "http://localhost/Invalid.swf";
		public static const REMOTE_VALID_PLUGIN_SWF_URL:String = "http://localhost/Valid.swf";		
		
		public function MockMediaFactory(asynchronous:Boolean = false, failCountUntilSuccess:int = 0)
		{
			this.asynchronous = asynchronous;
			this.failCountUntilSuccess = failCountUntilSuccess;
		}
		
		override public function loadPlugin(resource:MediaResourceBase):void
		{
			if (failCount < failCountUntilSuccess)
			{
				failCount++;
				dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.PLUGIN_LOAD_ERROR, false, false, resource));
				return;
			}			
			
			var urlResource:URLResource = resource as URLResource;
			if (REMOTE_INVALID_PLUGIN_SWF_URL == urlResource.url)
			{
				if (asynchronous)
				{
					var timer:Timer = new Timer(100, 1);
					timer.addEventListener(TimerEvent.TIMER, 
						function(event:Event):void 
						{
							dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.PLUGIN_LOAD_ERROR, false, false, resource));
						}
					);
				}
				else
				{
					dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.PLUGIN_LOAD_ERROR, false, false, resource));
				}
			}
			else
			{
				dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.PLUGIN_LOAD, false, false, resource));
			}		
		}
		
		private var failCount:int = 0;
		
		private var asynchronous:Boolean;
		private var failCountUntilSuccess:int;
	}
}