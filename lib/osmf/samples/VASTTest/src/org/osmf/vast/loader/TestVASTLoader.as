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
package org.osmf.vast.loader
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.TestLoaderBase;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.MockHTTPLoader;
	import org.osmf.utils.NullResource;
	import org.osmf.vast.VASTTestConstants;
	import org.osmf.vast.model.VASTAd;
	import org.osmf.vast.model.VASTDocument;
	import org.osmf.vast.model.VASTTrackingEvent;
	import org.osmf.vast.model.VASTTrackingEventType;
	import org.osmf.vast.model.VASTUrl;
		
	public class TestVASTLoader extends TestLoaderBase
	{
		override public function setUp():void
		{
			eventDispatcher = new EventDispatcher();
			
			// Change to HTTPLoader to run against the network.
			httpLoader = new MockHTTPLoader();
			
			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			eventDispatcher = null;
			httpLoader = null;
		}
		
		//---------------------------------------------------------------------
		
		// Success cases
		//

		public function testLoadWithValidVASTDocument():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithValidVASTDocument);
			loader.load(createLoadTrait(loader, SUCCESSFUL_RESOURCE));
		}
		
		private function onTestLoadWithValidVASTDocument(event:LoaderEvent):void
		{
			if (event.newState == LoadState.READY)
			{
				var vastLoadTrait:VASTLoadTrait = event.loadTrait as VASTLoadTrait;
				assertTrue(vastLoadTrait != null);
				
				// Just check that we got an inline ad back.
				var document:VASTDocument = vastLoadTrait.vastDocument as VASTDocument;
				assertTrue(document != null);
				assertTrue(document.ads.length == 1);
				var ad:VASTAd = document.ads[0] as VASTAd;
				assertTrue(ad.inlineAd != null);
				assertTrue(ad.wrapperAd == null);
				
				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}
		
		public function testLoadWithDefaultMaxNumWrapperRedirects():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithDefaultMaxNumWrapperRedirects);
			loader.load(createLoadTrait(loader, OUTER_WRAPPER_RESOURCE));
		}
		
		private function onTestLoadWithDefaultMaxNumWrapperRedirects(event:LoaderEvent):void
		{
			if (event.newState == LoadState.READY)
			{
				var vastLoadTrait:VASTLoadTrait = event.loadTrait as VASTLoadTrait;
				assertTrue(vastLoadTrait != null);
				
				// Verify that the result has an inline ad (which would have
				// come from the nested VAST document) and that the wrapper ad
				// (which would have come from the original VAST document) has
				// been merged and removed.
				var document:VASTDocument = vastLoadTrait.vastDocument as VASTDocument;
				assertTrue(document != null);
				assertTrue(document.ads.length == 1);
				var ad:VASTAd = document.ads[0] as VASTAd;
				assertTrue(ad.inlineAd != null);
				assertTrue(ad.wrapperAd == null);
				
				// Verify the impressions were merged over.
				var impressions:Vector.<VASTUrl> = ad.inlineAd.impressions;
				assertTrue(impressions != null);
				assertTrue(impressions.length == 4);
				var impression:VASTUrl = impressions[0];
				assertTrue(impression.id == "myadsever");
				assertTrue(impression.url == "http://www.primarysite.com/tracker?imp");
				impression = impressions[1];
				assertTrue(impression.id == "anotheradsever");
				assertTrue(impression.url == "http://www.thirdparty.com/tracker?imp");
				impression = impressions[2];
				assertTrue(impression.id == "myadsever");
				assertTrue(impression.url == "http://www.secondarysite.com/tracker?imp");
				impression = impressions[3];
				assertTrue(impression.id == "myadsever");
				assertTrue(impression.url == "http://www.wrapper.com/tracker?imp");
				
				// Verify the tracking events were merged over.
				var trackingEvents:Vector.<VASTTrackingEvent> = ad.inlineAd.trackingEvents;
				assertTrue(trackingEvents.length == 10);
				
				var trackingEvent:VASTTrackingEvent = trackingEvents[0];
				assertTrue(trackingEvent.type == VASTTrackingEventType.START);
				assertTrue(trackingEvent.urls.length == 1);
				var trackingURL:VASTUrl = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?start");
				
				trackingEvent = trackingEvents[1];
				assertTrue(trackingEvent.type == VASTTrackingEventType.MIDPOINT);
				assertTrue(trackingEvent.urls.length == 4);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mid");
				trackingURL = trackingEvent.urls[1];
				assertTrue(trackingURL.id == "anotheradsever");
				assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?mid");
				trackingURL = trackingEvent.urls[2];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.secondarysite.com/tracker?mid");
				trackingURL = trackingEvent.urls[3];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.wrapper.com/tracker?mid");

				trackingEvent = trackingEvents[2];
				assertTrue(trackingEvent.type == VASTTrackingEventType.FIRST_QUARTILE);
				assertTrue(trackingEvent.urls.length == 4);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?fqtl");
				trackingURL = trackingEvent.urls[1];
				assertTrue(trackingURL.id == "anotheradsever");
				assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?fqtl");
				trackingURL = trackingEvent.urls[2];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.secondarysite.com/tracker?fqtl");
				trackingURL = trackingEvent.urls[3];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.wrapper.com/tracker?fqtl");
	
				trackingEvent = trackingEvents[3];
				assertTrue(trackingEvent.type == VASTTrackingEventType.THIRD_QUARTILE);
				assertTrue(trackingEvent.urls.length == 4);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?tqtl");
				trackingURL = trackingEvent.urls[1];
				assertTrue(trackingURL.id == "anotheradsever");
				assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?tqtl");
				trackingURL = trackingEvent.urls[2];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.secondarysite.com/tracker?tqtl");
				trackingURL = trackingEvent.urls[3];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.wrapper.com/tracker?tqtl");
	
				trackingEvent = trackingEvents[4];
				assertTrue(trackingEvent.type == VASTTrackingEventType.COMPLETE);
				assertTrue(trackingEvent.urls.length == 4);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?comp");
				trackingURL = trackingEvent.urls[1];
				assertTrue(trackingURL.id == "anotheradsever");
				assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?comp");
				trackingURL = trackingEvent.urls[2];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.secondarysite.com/tracker?comp");
				trackingURL = trackingEvent.urls[3];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.wrapper.com/tracker?comp");
		
				trackingEvent = trackingEvents[5];
				assertTrue(trackingEvent.type == VASTTrackingEventType.PAUSE);
				assertTrue(trackingEvent.urls.length == 3);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?pause");
				trackingURL = trackingEvent.urls[1];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.secondarysite.com/tracker?pause");
				trackingURL = trackingEvent.urls[2];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.wrapper.com/tracker?pause");
	
				trackingEvent = trackingEvents[6];
				assertTrue(trackingEvent.type == VASTTrackingEventType.REPLAY);
				assertTrue(trackingEvent.urls.length == 3);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?replay");
				trackingURL = trackingEvent.urls[1];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.secondarysite.com/tracker?replay");
				trackingURL = trackingEvent.urls[2];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.wrapper.com/tracker?replay");
	
				trackingEvent = trackingEvents[7];
				assertTrue(trackingEvent.type == VASTTrackingEventType.FULLSCREEN);
				assertTrue(trackingEvent.urls.length == 3);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?full");
				trackingURL = trackingEvent.urls[1];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.secondarysite.com/tracker?full");
				trackingURL = trackingEvent.urls[2];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.wrapper.com/tracker?full");
	
				trackingEvent = trackingEvents[8];
				assertTrue(trackingEvent.type == VASTTrackingEventType.STOP);
				assertTrue(trackingEvent.urls.length == 1);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?stop");
				
				trackingEvent = trackingEvents[9];
				assertTrue(trackingEvent.type == VASTTrackingEventType.MUTE);
				assertTrue(trackingEvent.urls.length == 2);
				trackingURL = trackingEvent.urls[0];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.secondarysite.com/tracker?mute");
				trackingURL = trackingEvent.urls[1];
				assertTrue(trackingURL.id == "myadsever");
				assertTrue(trackingURL.url == "http://www.wrapper.com/tracker?mute");

				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}

		public function testLoadWithZeroMaxNumWrapperRedirects():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
			
			setOverriddenLoader(createInterfaceObject(0) as LoaderBase);
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithZeroMaxNumWrapperRedirects);
			loader.load(createLoadTrait(loader, OUTER_WRAPPER_RESOURCE));
		}
		
		private function onTestLoadWithZeroMaxNumWrapperRedirects(event:LoaderEvent):void
		{
			if (event.newState == LoadState.READY)
			{
				var vastLoadTrait:VASTLoadTrait = event.loadTrait as VASTLoadTrait;
				assertTrue(vastLoadTrait != null);
				
				// Verify that the result has a wrapper ad (indicating that
				// a reference to a nested VAST document exists) but no inline
				// ad (which would show that the nested VAST document was not
				// retrieved).
				var document:VASTDocument = vastLoadTrait.vastDocument as VASTDocument;
				assertTrue(document != null);
				assertTrue(document.ads.length == 1);
				var ad:VASTAd = document.ads[0] as VASTAd;
				assertTrue(ad.inlineAd == null);
				assertTrue(ad.wrapperAd != null);
				
				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}
		
		// Failure cases
		//
		
		public function testLoadWithInvalidXMLVASTDocument():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithInvalidXMLVASTDocument);
			loader.load(createLoadTrait(loader, INVALID_XML_RESOURCE));
		}
		
		private function onTestLoadWithInvalidXMLVASTDocument(event:LoaderEvent):void
		{
			if (event.newState == LoadState.LOAD_ERROR)
			{
				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}
		
		public function testLoadWithInvalidVASTDocument():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithInvalidVASTDocument);
			loader.load(createLoadTrait(loader, INVALID_RESOURCE));
		}
		
		private function onTestLoadWithInvalidVASTDocument(event:LoaderEvent):void
		{
			if (event.newState == LoadState.LOAD_ERROR)
			{
				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}
		
		public function testLoadWithInvalidWrapperRedirect():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithInvalidWrapperRedirect);
			loader.load(createLoadTrait(loader, WRAPPER_WITH_INVALID_WRAPPED_RESOURCE));
		}
		
		private function onTestLoadWithInvalidWrapperRedirect(event:LoaderEvent):void
		{
			if (event.newState == LoadState.LOAD_ERROR)
			{
				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}
		
		//---------------------------------------------------------------------
		
		override protected function createInterfaceObject(... args):Object
		{
			return new VASTLoader
				( args != null && args.length == 1 ? args[0] as int : -1
				, httpLoader
				);
		}

		override protected function createLoadTrait(loader:LoaderBase, resource:MediaResourceBase):LoadTrait
		{
			var mockLoader:MockHTTPLoader = httpLoader as MockHTTPLoader;
			if (mockLoader)
			{
				if (resource == successfulResource)
				{
					mockLoader.setExpectationForURL
						( URLResource(resource).url
						, true
						, VASTTestConstants.VAST_DOCUMENT_CONTENTS
						);
				}
				else if (resource == failedResource)
				{
					mockLoader.setExpectationForURL
						( URLResource(resource).url
						, false
						, null
						);
				}
				else if (resource == unhandledResource)
				{
					mockLoader.setExpectationForURL
						( URLResource(resource).url
						, false
						, null
						);
				}
				else if (resource == INVALID_XML_RESOURCE)
				{
					mockLoader.setExpectationForURL
						( URLResource(resource).url
						, true
						, VASTTestConstants.INVALID_XML_VAST_DOCUMENT_CONTENTS
						);
				}
				else if (resource == INVALID_RESOURCE)
				{
					mockLoader.setExpectationForURL
						( URLResource(resource).url
						, true
						, VASTTestConstants.INVALID_VAST_DOCUMENT_CONTENTS
						);
				}
				else if (resource == OUTER_WRAPPER_RESOURCE)
				{
					mockLoader.setExpectationForURL
						( URLResource(resource).url
						, true
						, VASTTestConstants.OUTER_WRAPPER_VAST_DOCUMENT_CONTENTS
						);

					mockLoader.setExpectationForURL
						( INNER_WRAPPER_RESOURCE.url
						, true
						, VASTTestConstants.INNER_WRAPPER_VAST_DOCUMENT_CONTENTS
						);

					mockLoader.setExpectationForURL
						( SUCCESSFUL_RESOURCE.url
						, true
						, VASTTestConstants.VAST_DOCUMENT_CONTENTS
						);
				}
				else if (resource == WRAPPER_WITH_INVALID_WRAPPED_RESOURCE)
				{
					mockLoader.setExpectationForURL
						( URLResource(resource).url
						, true
						, VASTTestConstants.WRAPPER_WITH_INVALID_WRAPPED_VAST_DOCUMENT_CONTENTS
						);

					mockLoader.setExpectationForURL
						( FAILED_RESOURCE.url
						, false
						, null
						);
				}
			}
			return new VASTLoadTrait(loader, resource);
		}
		
		override protected function get successfulResource():MediaResourceBase
		{
			return SUCCESSFUL_RESOURCE;
		}

		override protected function get failedResource():MediaResourceBase
		{
			return FAILED_RESOURCE;
		}

		override protected function get unhandledResource():MediaResourceBase
		{
			return UNHANDLED_RESOURCE;
		}
		
		override public function testCanHandleResource():void
		{
			super.testCanHandleResource();
			
			// Verify some valid resources.
			assertTrue(loader.canHandleResource(new URLResource("http://example.com")));
			assertTrue(loader.canHandleResource(new URLResource("http://example.com/video.flv")));
			assertTrue(loader.canHandleResource(new URLResource("http://example.com/script.php?param=value")));
			assertTrue(loader.canHandleResource(new URLResource("https://example.com")));
			assertTrue(loader.canHandleResource(new URLResource("https://example.com/video.flv")));
			assertTrue(loader.canHandleResource(new URLResource("https://example.com/script.php?param=value")));
			assertTrue(loader.canHandleResource(new URLResource("assets/audio.mp3")));
			assertTrue(loader.canHandleResource(new URLResource("audio.mp3")));
			assertTrue(loader.canHandleResource(new URLResource("foo")));
			
			// And some invalid ones.
			assertFalse(loader.canHandleResource(new URLResource("file:///audio.mp3")));
			assertFalse(loader.canHandleResource(new URLResource("httpt://example.com")));
			assertFalse(loader.canHandleResource(new URLResource("")));
			assertFalse(loader.canHandleResource(new URLResource(null)));
			assertFalse(loader.canHandleResource(new NullResource()));
			assertFalse(loader.canHandleResource(null));
		}
		
		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder
		}
		
		private static const TEST_TIME:int = 8000;
		
		private var httpLoader:HTTPLoader;
		private var eventDispatcher:EventDispatcher;
		
		private static const SUCCESSFUL_RESOURCE:URLResource = new URLResource(VASTTestConstants.VAST_DOCUMENT_URL);
		private static const FAILED_RESOURCE:URLResource = new URLResource(VASTTestConstants.MISSING_VAST_DOCUMENT_URL);
		private static const UNHANDLED_RESOURCE:URLResource = new URLResource("ftp://example.com");
		
		private static const INVALID_XML_RESOURCE:URLResource = new URLResource(VASTTestConstants.INVALID_XML_VAST_DOCUMENT_URL);
		private static const INVALID_RESOURCE:URLResource = new URLResource(VASTTestConstants.INVALID_VAST_DOCUMENT_URL);
		private static const OUTER_WRAPPER_RESOURCE:URLResource = new URLResource(VASTTestConstants.OUTER_WRAPPER_VAST_DOCUMENT_URL);
		private static const INNER_WRAPPER_RESOURCE:URLResource = new URLResource(VASTTestConstants.INNER_WRAPPER_VAST_DOCUMENT_URL);
		private static const WRAPPER_WITH_INVALID_WRAPPED_RESOURCE:URLResource = new URLResource(VASTTestConstants.WRAPPER_WITH_INVALID_WRAPPED_VAST_DOCUMENT_URL); 
	}
}