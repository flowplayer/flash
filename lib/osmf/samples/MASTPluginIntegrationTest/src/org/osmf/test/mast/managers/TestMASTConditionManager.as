package org.osmf.test.mast.managers
{
	import flash.errors.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.mast.MASTPluginInfo;
	import org.osmf.mast.model.*;
	import org.osmf.media.*;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.*;
	import org.osmf.utils.*;

	public class TestMASTConditionManager extends TestCase
	{
		override public function setUp():void
		{
			super.setUp();
			
			_eventDispatcher = new EventDispatcher();
		}
		
		override public function tearDown():void
		{
			_eventDispatcher = null;
			_timer = null;
		}

		public function testConditionManager():void
		{
			mediaFactory = new MediaFactory();
			mediaPlayer = new MediaPlayer();

 			loadPlugin(MAST_PLUGIN_INFOCLASS);
		}
		
		private function loadPlugin(source:String):void
		{
			var pluginResource:MediaResourceBase;
			if (source.substr(0, 4) == "http" || source.substr(0, 4) == "file")
			{
				// This is a URL, create a URLResource
				pluginResource = new URLResource(source);
			}
			else
			{
				// Assume this is a class
				var pluginInfoRef:Class = getDefinitionByName(source) as Class;
				pluginResource = new PluginInfoResource(new pluginInfoRef);
			}
			
			loadPluginFromResource(pluginResource);			
		}
		
		private function loadPluginFromResource(pluginResource:MediaResourceBase):void
		{
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);
			mediaFactory.loadPlugin(pluginResource);
		}
		
		private function onPluginLoaded(event:MediaFactoryEvent):void
		{
			trace(">>> Plugin successfully loaded.");
			loadMainVideo(REMOTE_STREAM);
		}
		
		private function onPluginLoadFailed(event:MediaFactoryEvent):void
		{
			trace(">>> Plugin failed to load.");
		}
					
		private function loadMainVideo(url:String):void
		{	
			var resource:URLResource = new URLResource(url);
			// Assign to the resource the metadata that indicates that it should have a MAST
			// document applied (and include the URL of that MAST document).
			var metadata:Metadata = new Metadata();
			metadata.addValue(MASTPluginInfo.MAST_METADATA_KEY_URI, MAST_URL_TEST);
			resource.addMetadataValue(MASTPluginInfo.MAST_METADATA_NAMESPACE, metadata);
			
			var mediaElement:MediaElement = mediaFactory.createMediaElement(resource);
			
			if (mediaElement == null)
			{
				var netLoader:NetLoader = new NetLoader();
				
				// Add a default VideoElement
				mediaFactory.addItem(new MediaFactoryItem("org.osmf.elements.video", netLoader.canHandleResource, createVideoElement));
				mediaElement = mediaFactory.createMediaElement(resource);
			}
			
			mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError, false, 0, true);
			
			_eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, ASYNC_DELAY));
			_timer = new Timer(30000, 1);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
			
			mediaPlayer.media = mediaElement;
		}
		
		private function createVideoElement():MediaElement
		{
			return new VideoElement();
		}

		private function onTimer(event:TimerEvent):void
		{
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_eventDispatcher.dispatchEvent(new Event("testComplete"));				
		}
		
		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is received.
		}
		
   		private function onMediaError(event:MediaErrorEvent):void
   		{
   			var errMsg:String = "Media error : ID="+event.error.errorID+" message="+event.error.message;
   			
   			trace(errMsg);
   		}
		
		private var mediaPlayer:MediaPlayer;
		private var mediaFactory:MediaFactory;
		private var _eventDispatcher:EventDispatcher;
		private var _timer:Timer;
		
		private static const ASYNC_DELAY:Number = 90000;

		private static const MAST_PLUGIN_INFOCLASS:String = "org.osmf.mast.MASTPluginInfo";		
		private static const loadTestRef:MASTPluginInfo = null;
		
		private static const MAST_URL_TEST:String = "http://mediapm.edgesuite.net/osmf/content/mast/mast_sample_integration_test.xml";
		
		private static const REMOTE_STREAM:String
			= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
		
	}
}