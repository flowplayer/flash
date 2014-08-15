package org.osmf.syndication.loader
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.syndication.SyndicationTestConstants;
	import org.osmf.syndication.model.Feed;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.TestLoaderBase;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.MockHTTPLoader;
	import org.osmf.utils.NullResource;
	

	public class TestFeedLoader extends TestLoaderBase
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
		
		public function testLoadWithValidSyndicationDocument():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithValidSyndicationDocument);
			loader.load(createLoadTrait(loader, SUCCESSFUL_RESOURCE));
		}
		
		private function onTestLoadWithValidSyndicationDocument(event:LoaderEvent):void
		{
			if (event.newState == LoadState.READY)
			{
				var loadTrait:FeedLoadTrait = event.loadTrait as FeedLoadTrait;
				assertTrue(loadTrait != null);
				
				// Just check that we got a Feed object back
				var feed:Feed = loadTrait.feed;
				assertTrue(feed != null);
				assertTrue(feed.entries.length == 4);
				
				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}		
		
		//---------------------------------------------------------------------
		
		override protected function createInterfaceObject(... args):Object
		{
			return new FeedLoader(args != null && args.length == 1 ? args[0] as HTTPLoader : httpLoader);
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
						, SyndicationTestConstants.RSS_DOCUMENT_CONTENTS
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
						, SyndicationTestConstants.INVALID_XML_SYNDICATION_DOCUMENT_CONTENTS
						);
				}
				else if (resource == INVALID_RESOURCE)
				{
					mockLoader.setExpectationForURL
						( URLResource(resource).url
						, true
						, SyndicationTestConstants.INVALID_SYNDICATION_DOCUMENT_CONTENTS
						);
				}
			}
			return new FeedLoadTrait(loader, resource);
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
		
		override protected function verifyMediaErrorOnLoadFailure(error:MediaError):void
		{
			assertTrue(		error.errorID == MediaErrorCodes.IO_ERROR
						||	error.errorID == MediaErrorCodes.SECURITY_ERROR
					  );
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

		private static const SUCCESSFUL_RESOURCE:URLResource = new URLResource(SyndicationTestConstants.RSS_DOCUMENT_URL);
		private static const FAILED_RESOURCE:URLResource = new URLResource(SyndicationTestConstants.MISSING_SYNDICATION_DOCUMENT_URL);
		private static const UNHANDLED_RESOURCE:URLResource = new URLResource("ftp://example.com");
		
		private static const INVALID_XML_RESOURCE:URLResource = new URLResource(SyndicationTestConstants.INVALID_XML_SYNDICATION_DOCUMENT_URL);
		private static const INVALID_RESOURCE:URLResource = new URLResource(SyndicationTestConstants.INVALID_SYNDICATION_DOCUMENT_URL);
	}
}
