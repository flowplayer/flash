/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.plugin
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.events.*;
	import org.osmf.media.*;
	import org.osmf.net.*;
	import org.osmf.traits.*;
	import org.osmf.utils.*;

	import com.akamai.osmf.AkamaiBasicStreamingPluginInfo;

	public class TestBasicStreamingPlugin extends TestCase
	{
		private static const forceReference:AkamaiBasicStreamingPluginInfo = null;
		
		public function TestBasicStreamingPlugin(methodName:String=null)
		{
			super(methodName);
		}
		
		override public function setUp():void
		{
			super.setUp();
			
			mediaFactory = new MediaFactory();
			eventDispatcher = new EventDispatcher();
		}

		override public function tearDown():void
		{
			super.tearDown();

			mediaFactory = null;
			eventDispatcher = null;
		}
		
		public function testPlayVODStreamWithAuth():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, TEST_TIME));
			
			callAfterLoad(doTestPlayVODStreamWithAuth);
		}

		public function testPlayVODStream():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, TEST_TIME));
			
			callAfterLoad(doTestPlayVODStream);
		}

		public function testPlayBadLiveStream():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, TEST_TIME));
			
			callAfterLoad(doTestPlayBadLiveStream);
		}

		public function testPlayProgressive():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, TEST_TIME));
			
			callAfterLoad(doTestPlayProgressive);
		}
		
		// Internals
		//

		private function doTestPlayVODStreamWithAuth():void
		{
			// on-demand stream with an auth token
			doTestMediaElementLoadAndPlay(REMOTE_STREAM_WITH_AUTH);
		}

		private function doTestPlayVODStream():void
		{
			// on-demand stream with no auth
			doTestMediaElementLoadAndPlay(REMOTE_STREAM);
		}

		private function doTestPlayBadLiveStream():void
		{
			// a bad live stream, cause it to test the retry timer
			doTestMediaElementLoadAndPlay(REMOTE_LIVE_BAD);
		}

		private function doTestPlayProgressive():void
		{
			// a progressive file
			doTestMediaElementLoadAndPlay(PROGRESSIVE_FLV);
		}

		private function callAfterLoad(callback:Function):void
		{
			assertTrue(mediaFactory.getItemById(AKAMAI_VIDEO_MEDIA_INFO_ID) == null);
			assertTrue(mediaFactory.getItemById(AKAMAI_AUDIO_MEDIA_INFO_ID) == null);
			
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
			
			var pluginInfoRef:Class = flash.utils.getDefinitionByName(AKAMAI_BASIC_STREAMING_PLUGIN_INFO) as Class;
			var pluginResource:MediaResourceBase = new PluginInfoResource(new pluginInfoRef);
			mediaFactory.loadPlugin(pluginResource);
			
			function onPluginLoaded(event:MediaFactoryEvent):void
			{
				assertTrue(mediaFactory.getItemById(AKAMAI_VIDEO_MEDIA_INFO_ID) != null);
				assertTrue(mediaFactory.getItemById(AKAMAI_AUDIO_MEDIA_INFO_ID) != null);
				
				callback.apply(this);
			}
		}
		
		private function doTestMediaElementLoadAndPlay(url:String):void
		{			
			var urlResource:URLResource = new URLResource(url);
			var mediaElement:MediaElement = mediaFactory.createMediaElement(urlResource);
			assertTrue(mediaElement != null);
			
			var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onElementLoadStateChange);
			loadTrait.load();
						
			function onElementLoadStateChange(event:LoadEvent):void
			{
				if (event.loadState == LoadState.READY)
				{
					var playTrait:PlayTrait = mediaElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
					mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError, false, 0, true);
					assertTrue(playTrait != null);
					playTrait.play();
					
					eventDispatcher.dispatchEvent(new Event("testComplete"));			
				}
				else if (event.loadState == LoadState.LOAD_ERROR)
				{
					elementLoadFailed(null);
				}
			}
		}
						
		private function loadFailed(event:Event):void
		{
			fail("Loading the plugin failed - make sure you are loading both this app and the plugin swf from localhost or a web server.");			
		}
		
		private function elementLoadFailed(event:Event):void
		{
			fail("Loading a media element failed - check the address and make sure the resource exists at that URL/URI.");
		}

		private function onMediaError(event:MediaErrorEvent):void
		{
			fail("Media Error: "+ event.error.errorID + " - " + event.error.message);	
		}
		
		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is received.
		}
			
		private var mediaFactory:MediaFactory;
		private var eventDispatcher:EventDispatcher;
		
		private static const AKAMAI_BASIC_STREAMING_PLUGIN_INFO:String = "com.akamai.osmf.AkamaiBasicStreamingPluginInfo";
		private static const AKAMAI_VIDEO_MEDIA_INFO_ID:String = "com.akamai.osmf.BasicStreamingVideoElement";
		private static const AKAMAI_AUDIO_MEDIA_INFO_ID:String = "com.akamai.osmf.BasicStreamingAudioElement";
		
		private static const TEST_TIME:int = 4000;

		private static const PROGRESSIVE_FLV:String 		= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
		private static const REMOTE_STREAM_WITH_AUTH:String	= "rtmp://cp78634.edgefcs.net/ondemand/mp4:mediapmsec/osmf/content/test/SpaceAloneHD_sounas_640_700.mp4?auth=daEcScnchcpd8dkcBa3b1azdScKcyaSd0aM-bmqrYo-b4toa-zpptqAAEno&aifp=v0001";
		private static const REMOTE_STREAM:String 			= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
		private static const REMOTE_LIVE_BAD:String			= "rtmp://cp34973.live.edgefcs.net/live/Flash_Live_Benchmarkxxx@632";
	}
}
