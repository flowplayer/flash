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

package org.osmf.youtube.media
{
	import flash.events.Event;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.youtube.elements.*;
	import org.osmf.youtube.events.YouTubeEvent;
	import org.osmf.youtube.net.YouTubeLoader;
	import org.osmf.youtube.*;
	
	public class TestYoutubeElement
	{
		[Before]
		public function setUp():void
		{
			emptyYoutubeElement = new YouTubeElement();

			badYoutubeElement =  new YouTubeElement(BAD_RESOURCE, new YouTubeLoader());
			goodYoutubeElement = new YouTubeElement(GOOD_RESOURCE, new YouTubeLoader());

		}

		[After]
		public function tearDown():void
		{
		}

		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}

		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}

		[Test]
		public function testYoutubeElement():void
		{
			assertNotNull(emptyYoutubeElement);
		}

		[Test]
		public function testYoutubeElementNoResource():void
		{
			assertStrictlyEquals(null, emptyYoutubeElement.resource);
		}


		[Test]
		public function testYoutubeElementWithResourceAndLoader():void
		{
			assertStrictlyEquals(GOOD_RESOURCE, goodYoutubeElement.resource);
		}

		[Test][Ignore]
		public function testYoutubeElementSetResource():void
		{
			emptyYoutubeElement.resource = BAD_RESOURCE;
			assertStrictlyEquals(BAD_RESOURCE, emptyYoutubeElement.resource);
			assertTrue(emptyYoutubeElement.hasTrait(MediaTraitType.LOAD));
		}

		[Test][Ignore]
		public function testYoutubeElementLoadTrait():void
		{
			var loadable:LoadTrait = goodYoutubeElement.getTrait(MediaTraitType.LOAD) as LoadTrait;

			assertEquals(CHROMELESS_PLAYER_RESOURCE.url, URLResource(loadable.resource).url);
		}

		[Test(async)] [Ignore]
		public function testYoutubeElementUnload():void
		{
			var loadable:LoadTrait = goodYoutubeElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadable.load();
			loadable.unload();

			// Wait for unload to occur.
			Async.handleEvent(this, goodYoutubeElement, "inexistent", null, 1000, null, loadStateChange);

			function loadStateChange(event:LoadEvent):void
			{
				assertFalse(goodYoutubeElement.hasTrait(MediaTraitType.DISPLAY_OBJECT));
			}
		}


		[Test(async)][Ignore]
		public function testYoutubeElementLoad():void
		{
			var loadable:LoadTrait = goodYoutubeElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadable.load();
			Async.handleEvent(this, loadable, LoadEvent.LOAD_STATE_CHANGE, loadStateChange);

			function loadStateChange(event:LoadEvent, param2:*):void
			{
				if (event.loadState == LoadState.READY)
				{
					assertNotNull(goodYoutubeElement.youTubePlayer);
				}
				else
				{
					fail("Cannot load the Youtube chromeless player");
				}
			}
		}

		[Test(async,timeout="10000")][Ignore]
		public function testHasRequiredTraitsAfterLoad():void
		{
			var loadable:LoadTrait = goodYoutubeElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadable.load();

			// Check the traits on the timeout handler, to give the YoutubeElement a chance to add them all
			Async.handleEvent(this, goodYoutubeElement, "inexistent", null, 1000, null, checkTraits);

			function checkTraits(event:LoadEvent):void
			{
				assertTrue(goodYoutubeElement.hasTrait(MediaTraitType.DYNAMIC_STREAM));
				assertTrue(goodYoutubeElement.hasTrait(MediaTraitType.DISPLAY_OBJECT));
				assertTrue(goodYoutubeElement.hasTrait(MediaTraitType.PLAY));
				assertTrue(goodYoutubeElement.hasTrait(MediaTraitType.AUDIO));
			}
		}

		[Test(async)] [Ignore]
		public function testDoesNotHaveTraitsAfterLoadOfBadMovie():void
		{
			var loadable:LoadTrait = badYoutubeElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadable.load();
			Async.handleEvent(this, loadable, LoadEvent.LOAD_STATE_CHANGE, loadStateChange);

			function loadStateChange(event:LoadEvent, param2:*):void
			{
				if (event.loadState == LoadState.READY)
				{
					assertFalse(badYoutubeElement.hasTrait(MediaTraitType.DYNAMIC_STREAM));
					assertFalse(badYoutubeElement.hasTrait(MediaTraitType.DISPLAY_OBJECT));
					assertFalse(badYoutubeElement.hasTrait(MediaTraitType.PLAY));
					assertFalse(badYoutubeElement.hasTrait(MediaTraitType.AUDIO));
				}
				else
				{
					fail("Cannot load the Youtube chromeless player");
				}
			}
		}

		[Test(async,timeout="10000")] [Ignore]
		public function testHasRequiredTraitsAfterPlay():void
		{
			var loadable:LoadTrait = goodYoutubeElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadable.load();
			Async.handleEvent(this, loadable, LoadEvent.LOAD_STATE_CHANGE, loadStateChange, 2000);

			// Wait to be sure the traits were added
			//Async.handleEvent(this, goodYoutubeElement, "inexistent", null, 2000, null, traitAdd);

			function loadStateChange(event:LoadEvent, param2:*):void
			{
				if (event.loadState == LoadState.READY)
				{
					var ytEvent:Event = new YouTubeEvent("onStateChange", YouTubePlayerProxy.YOUTUBE_STATE_PLAYING);

					goodYoutubeElement.youTubePlayer.dispatchEvent(ytEvent as Event);
				}
				else
				{
					fail("Cannot load youtube chromeless player");
				}
			}

			function traitAdd(event:MediaElementEvent):void
			{
				assertTrue(goodYoutubeElement.hasTrait(MediaTraitType.TIME));
				assertTrue(goodYoutubeElement.hasTrait(MediaTraitType.SEEK));
			}
			
		}

		[Test(async)][Ignore]
		public function testYoutubeError():void
		{
			var loadable:LoadTrait = badYoutubeElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadable.load();
			Async.handleEvent(this, loadable, LoadEvent.LOAD_STATE_CHANGE, loadStateChange);
			Async.handleEvent(this, badYoutubeElement, MediaErrorEvent.MEDIA_ERROR, mediaError);

			function loadStateChange(event:LoadEvent, param2:*):void
			{
				if (event.loadState == LoadState.READY)
				{
					badYoutubeElement.youTubePlayer.dispatchEvent(new Event("onError"));
				}
				else
				{
					fail("Cannot load the Youtube chromeless player");
				}
			}

			function mediaError(event:MediaErrorEvent, param2:*):void
			{
				assertEquals(MediaErrorCodes.MEDIA_LOAD_FAILED, event.error.errorID);
				assertEquals("Youtube Error", event.error.detail);
			}

		}

		private var emptyYoutubeElement:YouTubeElement;
		private var badYoutubeElement:YouTubeElement;
		private var goodYoutubeElement:YouTubeElement;

		/* static */
		private static const BAD_RESOURCE:URLResource
				= new URLResource("http://youtube.com/watch?v=inexistent_");

		private static const GOOD_RESOURCE:URLResource
				= new URLResource("http://www.youtube.com/watch?v=0uYOKMeHVaQ");

		private static const CHROMELESS_PLAYER_RESOURCE:URLResource
				= new URLResource(YouTubePlayerProxy.CHROMELESS_PLAYER);


	}
}