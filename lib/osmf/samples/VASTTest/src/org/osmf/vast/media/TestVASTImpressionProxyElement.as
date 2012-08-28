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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.TestProxyElement;
	import org.osmf.events.LoaderEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.utils.DynamicBufferTrait;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.MockHTTPLoader;
	import org.osmf.utils.SimpleLoader;
	import org.osmf.vast.VASTTestConstants;
	import org.osmf.vast.model.VASTUrl;
	
	public class TestVASTImpressionProxyElement extends TestProxyElement
	{
		public function testPlay():void
		{
			doTestPlay(createProxyElementWithWrappedElement(false), false);
		}

		public function testPlayWithSetProperty():void
		{
			doTestPlay(createProxyElementWithWrappedElement(true), false);
		}

		public function testPlayWithReload():void
		{
			doTestPlay(createProxyElementWithWrappedElement(false), true);
		}

		public function testPlayWithReloadWithSetProperty():void
		{
			doTestPlay(createProxyElementWithWrappedElement(true), true);
		}
		
		private function doTestPlay(proxyElement:ProxyElement, reload:Boolean):void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, 4000));
			
			var impressionCount:int = 0;
			var done:Boolean = false;
			
			// Listen for the pings.
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onLoaderStateChange);

			// Playback should cause the impression to fire.
			var playTrait:PlayTrait = proxyElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			assertTrue(playTrait != null);
			playTrait.play();

			function onLoaderStateChange(event:LoaderEvent):void
			{
				if (event.loadTrait.loadState == LoadState.READY)
				{
					impressionCount++;
					
					assertTrue(playTrait.playState == PlayState.PLAYING);
					
					if (impressionCount == 2)
					{
						if (reload)
						{
							// Playing again should not trigger another impression.
							playTrait.stop()
							playTrait.play();
							
							assertTrue(!done);
							
							// But if we reload first, then play, it should.
							var loadTrait:LoadTrait = proxyElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
							assertTrue(loadTrait != null);
							loadTrait.load();
							playTrait.stop()
							playTrait.play();
						}
						else
						{
							eventDispatcher.dispatchEvent(new Event("testComplete"));
						}
					}
					else if (impressionCount == 4 && reload)
					{
						done = true;
						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
				}
			}
		}
		
		public function testPlayWhileBuffering():void
		{
			doTestPlayWhileBuffering(false);
		}

		public function testPlayWhileBufferingThenExitingBuffering():void
		{
			doTestPlayWhileBuffering(true);
		}
		
		private function doTestPlayWhileBuffering(exitBuffering:Boolean):void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, 4000));
			
			var impressionCount:int = 0;
			
			// We'll fail if we receive any pings.
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, dontCall);

			var proxyElement:ProxyElement = createProxyElementWithWrappedElement(true);
			
			// Enter the buffering state.
			var bufferTrait:DynamicBufferTrait = proxyElement.getTrait(MediaTraitType.BUFFER) as DynamicBufferTrait;
			assertTrue(bufferTrait != null);
			bufferTrait.buffering = true;
			
			// Playback should not cause the impression to fire because
			// we're buffering.
			var playTrait:PlayTrait = proxyElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			assertTrue(playTrait != null);
			playTrait.play();
			
			// Wait a second to verify that no pings are received.
			var timer:Timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			function onTimer(event:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				
				if (exitBuffering)
				{
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, dontCall);
					httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onImpressionLoaded);
					
					var impressionCount:int = 0;
					
					bufferTrait.buffering = false;
					
					function onImpressionLoaded(event:LoaderEvent):void
					{
						if (event.loadTrait.loadState == LoadState.READY)
						{
							impressionCount++;
							
							assertTrue(playTrait.playState == PlayState.PLAYING);
							
							if (impressionCount == 2)
							{
								eventDispatcher.dispatchEvent(new Event("testComplete"));
							}
						}
					}
				}
				else
				{
					eventDispatcher.dispatchEvent(new Event("testComplete"));
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
			return new VASTImpressionProxyElement(new Vector.<VASTUrl>());
		}
		
		override protected function createMediaElement():MediaElement
		{
			return new VASTImpressionProxyElement(new Vector.<VASTUrl>(), null, new MediaElement());
		}

		// Internals
		//
		
		private function createHTTPLoader():HTTPLoader
		{
			// Change to false to run against the network.
			var useMockLoader:Boolean = true;
			
			if (useMockLoader == false)
			{
				return new HTTPLoader();
			}
			else
			{
				var loader:MockHTTPLoader = new MockHTTPLoader();
				loader.setExpectationForURL(VASTTestConstants.IMPRESSION_URL1, true, null);
				loader.setExpectationForURL(VASTTestConstants.IMPRESSION_URL2, true, null);
				return loader;
			}
		}

		private function createProxyElementWithWrappedElement(setProperty:Boolean):ProxyElement
		{
			var vastURLs:Vector.<VASTUrl> = new Vector.<VASTUrl>();
			vastURLs.push(VAST_URL1);
			vastURLs.push(VAST_URL2);
			
			var proxiedElement:MediaElement =
				new DynamicMediaElement
					( [	  MediaTraitType.BUFFER
				  		, MediaTraitType.PLAY
				  		, MediaTraitType.LOAD
					  ]
					  , new SimpleLoader()
					  , null
					  , true
					);
					
			var proxyElement:ProxyElement = new VASTImpressionProxyElement
				( vastURLs
				, httpLoader
				, setProperty == false
					? proxiedElement
					: null
				);
			if (setProperty)
			{
				proxyElement.proxiedElement = proxiedElement;
			}
			return proxyElement;
		}
		
		private function dontCall(event:Event):void
		{
			fail();
		}
		
		private var httpLoader:HTTPLoader;
				
		private static const VAST_URL1:VASTUrl = new VASTUrl(VASTTestConstants.IMPRESSION_URL1, "id1");
		private static const VAST_URL2:VASTUrl = new VASTUrl(VASTTestConstants.IMPRESSION_URL2, "id2");
	}
}