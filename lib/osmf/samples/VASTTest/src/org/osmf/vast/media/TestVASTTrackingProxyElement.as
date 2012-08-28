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
package org.osmf.vast.media
{
	import flash.events.Event;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.TestProxyElement;
	import org.osmf.events.LoaderEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.MockHTTPLoader;
	import org.osmf.utils.SimpleLoader;
	import org.osmf.utils.TimerTimeTrait;
	import org.osmf.vast.model.VASTTrackingEvent;
	import org.osmf.vast.model.VASTTrackingEventType;
	import org.osmf.vast.model.VASTUrl;
	
	public class TestVASTTrackingProxyElement extends TestProxyElement
	{
		public function testPlay():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, 6000));

			var proxyElement:ProxyElement = createProxyElementWithWrappedElement(false);
			
			var timeTrait:TimeTrait = proxyElement.getTrait(MediaTraitType.TIME) as TimeTrait;
			assertTrue(timeTrait != null);
			
			// Listen for the events being fired.
			var eventCount:int = 0;
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onLoaderStateChange);

			// Playback should cause the events to begin firing.
			var playTrait:PlayTrait = proxyElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			assertTrue(playTrait != null);
			playTrait.play();

			function onLoaderStateChange(event:LoaderEvent):void
			{				
				if (event.loadTrait.loadState == LoadState.READY)
				{
					eventCount++;
					
					if (eventCount == 1)
					{
						// START Event #1
						assertTrue(URLResource(event.loadTrait.resource).url == START_EVENT_URL1);
						assertTrue(timeTrait.currentTime == 0);
					}
					else if (eventCount == 2)
					{
						// START Event #2
						assertTrue(URLResource(event.loadTrait.resource).url == START_EVENT_URL2);
						assertTrue(timeTrait.currentTime == 0);
					}
					else if (eventCount == 3)
					{
						// FIRST_QUARTILE Event
						assertTrue(URLResource(event.loadTrait.resource).url == FIRST_QUARTILE_EVENT_URL);
						assertTrue(timeTrait.currentTime == DURATION * 0.25);
					}
					else if (eventCount == 4)
					{
						// MIDPOINT Event
						assertTrue(URLResource(event.loadTrait.resource).url == MIDPOINT_EVENT_URL);
						assertTrue(timeTrait.currentTime == DURATION * 0.5);
					}
					else if (eventCount == 5)
					{
						// THIRD_QUARTILE Event
						assertTrue(URLResource(event.loadTrait.resource).url == THIRD_QUARTILE_EVENT_URL);
						assertTrue(timeTrait.currentTime == DURATION * 0.75);
					}
					else if (eventCount == 6)
					{
						// COMPLETE Event
						assertTrue(URLResource(event.loadTrait.resource).url == COMPLETE_EVENT_URL);
						assertTrue(timeTrait.currentTime == DURATION);
						
						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
					else 
					{
						fail();
					}
				}
			}
		}
		
		public function testPlayWithPause():void
		{
			doTestPlayWithPause(createProxyElementWithWrappedElement(true));
		}

		private function doTestPlayWithPause(proxyElement:ProxyElement):void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, 2000));
			
			var timeTrait:TimeTrait = proxyElement.getTrait(MediaTraitType.TIME) as TimeTrait;
			assertTrue(timeTrait != null);
			
			// Listen for the events being fired.
			var eventCount:int = 0;
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onLoaderStateChange);

			// Playback should cause the events to begin firing.
			var playTrait:PlayTrait = proxyElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			assertTrue(playTrait != null);
			playTrait.play();

			function onLoaderStateChange(event:LoaderEvent):void
			{
				if (event.loadTrait.loadState == LoadState.READY)
				{
					eventCount++;
					
					if (eventCount == 1)
					{
						// START Event #1
						assertTrue(URLResource(event.loadTrait.resource).url == START_EVENT_URL1);
						assertTrue(timeTrait.currentTime == 0);
					}
					else if (eventCount == 2)
					{
						// START Event #2
						assertTrue(URLResource(event.loadTrait.resource).url == START_EVENT_URL2);
						assertTrue(timeTrait.currentTime == 0);
						
						// Pausing should fire the PAUSE event, and no other event.
						playTrait.pause();
					}
					else if (eventCount == 3)
					{
						// PAUSE Event
						assertTrue(URLResource(event.loadTrait.resource).url == PAUSE_EVENT_URL);
						assertTrue(timeTrait.currentTime < DURATION * 0.25);
						
						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
					else fail();
				}
			}
		}
		
		public function testMute():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, 1000));

			var proxyElement:ProxyElement = createProxyElementWithWrappedElement(false);
						
			var timeTrait:TimeTrait = proxyElement.getTrait(MediaTraitType.TIME) as TimeTrait;
			assertTrue(timeTrait != null);
			
			// Listen for the events being fired.
			var eventCount:int = 0;
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onLoaderStateChange);

			// Muting should cause an event to fire.
			var audioTrait:AudioTrait = proxyElement.getTrait(MediaTraitType.AUDIO) as AudioTrait;
			assertTrue(audioTrait!= null);
			audioTrait.muted  = true;

			function onLoaderStateChange(event:LoaderEvent):void
			{
				if (event.loadTrait.loadState == LoadState.READY)
				{
					eventCount++;
					
					if (eventCount == 1)
					{
						// MUTE Event
						assertTrue(URLResource(event.loadTrait.resource).url == MUTE_EVENT_URL);

						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
					else fail();
				}
			}
		}
		
		// Overrides
		//
		
		override public function setUp():void
		{
			httpLoader = createHTTPLoader();
			
			super.setUp();
		}

		override public function tearDown():void
		{
			super.setUp();

			httpLoader = null;
		}
		
		override protected function createProxyElement():ProxyElement
		{
			return new VASTTrackingProxyElement(new Vector.<VASTTrackingEvent>());
		}
		
		override  protected function createMediaElement():MediaElement
		{
			return new VASTTrackingProxyElement(new Vector.<VASTTrackingEvent>(), null, new MediaElement());
		}

		// Internals
		//
		
		private function createHTTPLoader():HTTPLoader
		{
			// Change to true to run against the network.
			var useMockLoader:Boolean = true;
			
			if (useMockLoader == false)
			{
				return new HTTPLoader();
			}
			else
			{
				var loader:MockHTTPLoader = new MockHTTPLoader();
				loader.setExpectationForURL(START_EVENT_URL1, true, null);
				loader.setExpectationForURL(START_EVENT_URL2, true, null);
				loader.setExpectationForURL(FIRST_QUARTILE_EVENT_URL, true, null);
				loader.setExpectationForURL(MIDPOINT_EVENT_URL, true, null);
				loader.setExpectationForURL(THIRD_QUARTILE_EVENT_URL, true, null);
				loader.setExpectationForURL(COMPLETE_EVENT_URL, true, null);
				loader.setExpectationForURL(PAUSE_EVENT_URL, true, null);
				loader.setExpectationForURL(MUTE_EVENT_URL, true, null);
				return loader;
			}
		}

		private function createProxyElementWithWrappedElement(setProperty:Boolean):ProxyElement
		{
			var mediaElement:DynamicMediaElement = new DynamicMediaElement
				( [	MediaTraitType.PLAY
				  , MediaTraitType.AUDIO
				  ]
				, new SimpleLoader()
				);
			var timerTrait:TimerTimeTrait = new TimerTimeTrait(DURATION, mediaElement.getTrait(MediaTraitType.PLAY) as PlayTrait);
			mediaElement.doAddTrait(MediaTraitType.TIME, timerTrait);
			var proxyElement:ProxyElement = new VASTTrackingProxyElement
				( createTrackingEvents()
				, httpLoader
				, setProperty ? null : mediaElement
				);
			if (setProperty)
			{
				proxyElement.proxiedElement = mediaElement;
			}
			return proxyElement;
		}
		
		private function createTrackingEvents():Vector.<VASTTrackingEvent>
		{
			var trackingEvents:Vector.<VASTTrackingEvent> = new Vector.<VASTTrackingEvent>();

			var trackingEvent:VASTTrackingEvent;
			var eventURLs:Vector.<VASTUrl>;
			
			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.START);
			eventURLs = new Vector.<VASTUrl>();
			eventURLs.push(START_EVENT_VAST_URL1);
			eventURLs.push(START_EVENT_VAST_URL2);
			trackingEvent.urls = eventURLs;
			trackingEvents.push(trackingEvent);
			
			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.FIRST_QUARTILE);
			eventURLs = new Vector.<VASTUrl>();
			eventURLs.push(FIRST_QUARTILE_EVENT_VAST_URL);
			trackingEvent.urls = eventURLs;
			trackingEvents.push(trackingEvent);

			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.MIDPOINT);
			eventURLs = new Vector.<VASTUrl>();
			eventURLs.push(MIDPOINT_EVENT_VAST_URL);
			trackingEvent.urls = eventURLs;
			trackingEvents.push(trackingEvent);

			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.THIRD_QUARTILE);
			eventURLs = new Vector.<VASTUrl>();
			eventURLs.push(THIRD_QUARTILE_EVENT_VAST_URL);
			trackingEvent.urls = eventURLs;
			trackingEvents.push(trackingEvent);

			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.COMPLETE);
			eventURLs = new Vector.<VASTUrl>();
			eventURLs.push(COMPLETE_EVENT_VAST_URL);
			trackingEvent.urls = eventURLs;
			trackingEvents.push(trackingEvent);

			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.PAUSE);
			eventURLs = new Vector.<VASTUrl>();
			eventURLs.push(PAUSE_EVENT_VAST_URL);
			trackingEvent.urls = eventURLs;
			trackingEvents.push(trackingEvent);

			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.MUTE);
			eventURLs = new Vector.<VASTUrl>();
			eventURLs.push(MUTE_EVENT_VAST_URL);
			trackingEvent.urls = eventURLs;
			trackingEvents.push(trackingEvent);
			
			return trackingEvents;
		}
		
		private function dontCall(event:Event):void
		{
			fail();
		}
		
		private var httpLoader:HTTPLoader;
		
		private static const DURATION:Number = 4;
		
		private static const START_EVENT_VAST_URL1:VASTUrl = new VASTUrl(START_EVENT_URL1, "start1");
		private static const START_EVENT_VAST_URL2:VASTUrl = new VASTUrl(START_EVENT_URL2, "start2");
		private static const COMPLETE_EVENT_VAST_URL:VASTUrl = new VASTUrl(COMPLETE_EVENT_URL, "complete");
		private static const FIRST_QUARTILE_EVENT_VAST_URL:VASTUrl = new VASTUrl(FIRST_QUARTILE_EVENT_URL, "1q");
		private static const MIDPOINT_EVENT_VAST_URL:VASTUrl = new VASTUrl(MIDPOINT_EVENT_URL, "mid");
		private static const THIRD_QUARTILE_EVENT_VAST_URL:VASTUrl = new VASTUrl(THIRD_QUARTILE_EVENT_URL, "3q");
		private static const PAUSE_EVENT_VAST_URL:VASTUrl = new VASTUrl(PAUSE_EVENT_URL, "pause");
		private static const MUTE_EVENT_VAST_URL:VASTUrl = new VASTUrl(MUTE_EVENT_URL, "mute");
		
		private static const START_EVENT_URL1:String = "http://example.com/start1";
		private static const START_EVENT_URL2:String = "http://example.com/start2";
		private static const COMPLETE_EVENT_URL:String = "http://example.com/complete";
		private static const FIRST_QUARTILE_EVENT_URL:String = "http://example.com/1q";
		private static const MIDPOINT_EVENT_URL:String = "http://example.com/midpoint";
		private static const THIRD_QUARTILE_EVENT_URL:String = "http://example.com/3q";
		private static const PAUSE_EVENT_URL:String = "http://example.com/pause";
		private static const MUTE_EVENT_URL:String = "http://example.com/mute";
	}
}
