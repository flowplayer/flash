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
	import flash.display.*;
	import flash.events.*;
	
	import org.osmf.chrome.application.*;
	import org.osmf.chrome.configuration.*;
	import org.osmf.chrome.debug.*;
	import org.osmf.chrome.metadata.ChromeMetadata;
	import org.osmf.chrome.widgets.*;
	import org.osmf.containers.*;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.*;
	import org.osmf.layout.*;
	import org.osmf.media.*;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.*;
	import org.osmf.net.httpstreaming.HTTPStreamingNetLoaderWithBufferControl;
	import org.osmf.player.configuration.*;
	import org.osmf.player.debug.*;
	import org.osmf.player.preloader.*;
	import org.osmf.traits.*;
	import org.osmf.utils.OSMFSettings;
	
	CONFIG::DEBUG 
	{
	import org.osmf.logging.Log;
	}
	
	[Frame(factoryClass="org.osmf.player.preloader.Preloader")]
	[SWF(backgroundColor="0x000000", frameRate="25", width="640", height="380")]
	public class OSMFPlayer extends ChromeApplication
	{
		public function OSMFPlayer(preloader:Preloader)
		{
			OSMFSettings.enableStageVideo = false;
			OSMFSettings.hdsDVRLiveOffset = 4;
			
			// Get a reference to the stage from the preloader (ours isn't set yet).
			_stage = preloader.stage;
			
			// Store pre-loader references:
			CONFIG::DEBUG
			{
				debugger = preloader.debugger;
				Log.loggerFactory = new DebuggerLoggerFactory(preloader.debugger);
			}

			super();
			
			
			// Set the SWF scale mode, and listen to the stage change
			// dimensions:
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.addEventListener(Event.RESIZE, onStageResize);
			
			// Parse configuration from the parameters passed on embedding
			// OSMFPlayer.swf:
			configuration = new PlayerConfiguration(preloader.loaderInfo.parameters);
			
			// Setup the ChromeApplication (base class):		
			setup(preloader.configuration);
		}
		
		// Internals
		//
		
		override protected function constructWidgetsParser():WidgetsParser
		{
			var widgets:WidgetsParser = super.constructWidgetsParser();
			
			// Add a number of (debug) type widgets:
			widgets.addType("memoryMeter", MemoryMeter);
			widgets.addType("fpsMeter", FPSMeter);
			
			return widgets;
		}
		
		override protected function processSetupComplete():void
		{
			player.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			player.addEventListener(MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, onIsDynamicStreamChange);
			
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			
			player.autoPlay = true;
			
			container.clipChildren = true;
			container.backgroundColor = configuration.backgroundColor;
			container.backgroundAlpha = isNaN(configuration.backgroundColor) ? 0 : 1;
			
			var urlInput:URLInput = widgets.getWidget("urlInput") as URLInput;
			if (urlInput)
			{
				urlInput.addEventListener(Event.CHANGE, onInputURLChange);
				urlInput.url = configuration.url;
			}
			
			var button:EjectButton = widgets.getWidget("ejectButton") as EjectButton;
			if (button)
			{
				button.addEventListener(MouseEvent.CLICK, onEjectButtonClick);
			}
			
			alert = widgets.getWidget("alert") as AlertDialog;
			
			// Simulate the stage resizing, to update the dimensions of the
			// container:
			onStageResize();
			
			// Try to load the URL set on the configuration:
			url = configuration.url;
		}
		
		override protected function processNewMedia(value:MediaElement):MediaElement
		{
			var result:MediaElement = value;
			
			if (result != null)
			{
				// Forward the configuration's auto-hide setting:
				var metadata:Metadata = new Metadata();
				metadata.addValue(ChromeMetadata.AUTO_HIDE, configuration.autoHideControlBar);
				result.addMetadata(ChromeMetadata.CHROME_METADATA_KEY, metadata);
				
				// If not auto-playing, watch the player become seekable, once:
				if (configuration.autoPlay == false)
				{
					player.addEventListener
						( MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE
						, onCanSeekChange
						);
					
					function onCanSeekChange(event:MediaPlayerCapabilityChangeEvent):void
					{
						player.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onCanSeekChange);
						if (player.canPause)
						{
							player.pause();
							if (player.canSeek && player.canSeekTo(0.001))
							{
								player.seek(0.001);
							}
						}
					}
				}
				 
				// When in debugging mode, wrap the element in a debugger proxy:
				CONFIG::DEBUG
				{
					result = new DebuggerElementProxy(value, debugger);
					debugger.send("TRACE", "media change", value);
				}
			}
			
			return result;
		}
		
		override protected function constructMediaFactory():MediaFactory
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			var item:MediaFactoryItem;
			
			CONFIG::FLASH_10_1
			{		
				/**
				 * Here, we want to replace the standard http streaming media factory item
				 * with our "home made" media factory item which used HTTPStreamingNetLoaderWithBufferControl
				 * instead of the HTTPStreamNetLoader that comes with OSMF.
				 * 
				 * Meanwhile, we want to make sure that our "home made" media factory item
				 * gets picked up to handle a media before any other media factory item. Therefore
				 * we want to rename the id of the item to be something other than org.osmf...
				 * This way the media factory will put this item in front of any osmf item. 
				 */
				item = factory.getItemById(HTTPSTREAM_ITEM_ID);
				if (item != null)
				{
					factory.removeItem(item);
				}
				
				httpStreamingLoader = new HTTPStreamingNetLoaderWithBufferControl();
				item 
					= new MediaFactoryItem
						( HTTPSTREAM_WITH_BUFFER_CONTROL_ITEM_ID
						, httpStreamingLoader.canHandleResource
						, function():MediaElement
							{
								return new VideoElement(null, httpStreamingLoader);
							}
						);
						
				factory.addItem(item);
			}
			
			return factory;
		}

		// Handlers
		//
		
		private function onCurrentTimeChange(event:TimeEvent):void
		{
			if  (	player.state == MediaPlayerState.BUFFERING
				|| player.state == MediaPlayerState.PLAYING
				|| player.state == MediaPlayerState.PAUSED
			) // If the player is in a relevant state
			{
				var dvrTrait:DVRTrait = player.media.getTrait(MediaTraitType.DVR) as DVRTrait;
				if ((dvrTrait != null) && (dvrTrait.windowDuration != -1)) // If rolling window is present
				{
					if (event.time < DEFAULT_FRAGMENT_SIZE) // If we're too close to the left-most side of the rolling window
					{
						// Seek to a safe area
						player.seek(DEFAULT_SEGMENT_SIZE);
					}
				}
			}
		}

		private function onStageResize(event:Event = null):void
		{
			// Propagate dimensions to the main container:
			width = _stage.stageWidth;
			height = _stage.stageHeight;
		}
		
		private function onEjectButtonClick(event:MouseEvent):void
		{
			// Escape full-screen mode (if applicable):
			_stage.displayState = StageDisplayState.NORMAL;
			
			// Reset the current media:
			media = null;
		}
		
		private function onInputURLChange(event:Event):void
		{
			var urlInput:URLInput = event.target as URLInput;
			if (urlInput)
			{
				if (alert)
				{
					alert.close();
				}
				url = urlInput.url;
			}
		}
		
		private function onMediaError(event:MediaErrorEvent):void
		{
			// Compose error message:
			var message:String;
			if (event.error.detail && event.error.detail.indexOf(URL_LOADER_NOT_FOUND) == 0)
			{
				// If the error is a URLLoader #2032 error, replace the message with
				// a custom one (FM-487):
				message
					= "The media located at "
					+ event.error.detail.substr(URL_LOADER_NOT_FOUND.length)
					+ " was not found";
			}
			else
			{
				message
					= event.error.message
					+ (event.error.detail ? "\n" + event.error.detail : "");
			}
			
			// If an alert widget is available, use it. Otherwise, trace the message:
			if (alert)
			{
				alert.alert("Error", message);
			}
			else
			{
				trace("Error:",event.error.message + "\n" + event.error.detail); 
			}
		}
		
		private function onIsDynamicStreamChange(event:MediaPlayerCapabilityChangeEvent):void
		{
			// Apply the configuration's autoSwitchQuality setting:
			if (player.isDynamicStream)
			{
				player.autoDynamicStreamSwitch = configuration.autoSwitchQuality;
			}
		}
		
		private var _stage:Stage;
		CONFIG::DEBUG {	private var debugger:Debugger; }
		
		private var configuration:PlayerConfiguration;
		private var alert:AlertDialog;
		
		CONFIG::FLASH_10_1
		{
			private const HTTPSTREAM_ITEM_ID:String = "org.osmf.elements.video.httpstreaming";
			private const HTTPSTREAM_WITH_BUFFER_CONTROL_ITEM_ID:String = "com.adobe.osmfplayer.elements.video.httpstreaming";
		}
		
		private var httpStreamingLoader:HTTPStreamingNetLoaderWithBufferControl;
		
		/* static */
		private static const URL_LOADER_NOT_FOUND:String = "Error #2032: Stream Error. URL: ";
		
		private static const DEFAULT_FRAGMENT_SIZE:Number = 4;
		private static const DEFAULT_SEGMENT_SIZE:Number = 16;
	}
}            