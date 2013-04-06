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
package org.osmf.test.mast.loader
{
	import flash.events.*;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.mast.loader.*;
	import org.osmf.mast.model.*;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.test.mast.MASTTestConstants;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.TestLoaderBase;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.MockHTTPLoader;
	import org.osmf.utils.NullResource;
	
	public class TestMASTLoader extends TestLoaderBase
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
		
		public function testLoadWithValidMASTDocument():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithValidMASTDocument);
			loader.load(createLoadTrait(loader, SUCCESSFUL_RESOURCE));
		}
		
		private function onTestLoadWithValidMASTDocument(event:LoaderEvent):void
		{
			if (event.newState == LoadState.READY)
			{
				// Just check that we got a valid MAST DOM back
				var document:MASTDocument = MASTLoadTrait(event.loadTrait).document;
				assertTrue(document != null);
				assertTrue(document.triggers.length == 1);
				
				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}
		
		//---------------------------------------------------------------------
		
		override protected function createInterfaceObject(... args):Object
		{
			return new MASTLoader(httpLoader);
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
						, MASTTestConstants.MAST_DOCUMENT_CONTENTS
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
			}
			return new MASTLoadTrait(loader, resource);
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
		
		private static const SUCCESSFUL_RESOURCE:URLResource = new URLResource(MASTTestConstants.MAST_DOCUMENT_URL);
		private static const FAILED_RESOURCE:URLResource = new URLResource(MASTTestConstants.MISSING_MAST_DOCUMENT_URL);
		private static const UNHANDLED_RESOURCE:URLResource = new URLResource("ftp://example.com");
		
	}
}
