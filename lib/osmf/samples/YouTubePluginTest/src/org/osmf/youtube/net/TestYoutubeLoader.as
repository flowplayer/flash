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

package org.osmf.youtube.net
{
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.media.URLResource;
	import org.osmf.youtube.YouTubePlayerProxy;

	public class TestYoutubeLoader
	{
		[Before]
		public function setUp():void
		{
			youtubeLoader = new YouTubeLoader();
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
		public function testYoutubeLoader():void
		{
			assertNotNull(youtubeLoader);
		}

		[Test]
		public function testCanHandleResource():void
		{
			assertTrue(youtubeLoader.canHandleResource(GOOD_RESOURCE));
		}

		[Test]
		public function testCanHandleResourceInvalid():void
		{
			assertFalse(youtubeLoader.canHandleResource(BAD_RESOURCE));
		}

		[Test]
		public function testCanHandleResourceChromelessPlayer():void
		{
			assertTrue(youtubeLoader.canHandleResource(CHROMELESS_PLAYER_RESOURCE));
		}

		[Test]
		public function testCanHandleResourceNoYoutubeSWF():void
		{
			assertFalse(youtubeLoader.canHandleResource(INVALID_SWF_RESOURCE));
		}

		[Test]
		public function testCanHandleResourceFlv():void
		{
			assertFalse(youtubeLoader.canHandleResource(FLV_RESOURCE));
		}

		private var youtubeLoader:YouTubeLoader;


		/* static */

		private const GOOD_RESOURCE:URLResource = new URLResource("http://www.youtube.com/watch?v=jPg8zB3fpYo");


		private const BAD_RESOURCE:URLResource = new URLResource("http://www.noyoutube.com/watch?v=jPg8zB3fpYo");
		private const CHROMELESS_PLAYER_RESOURCE:URLResource = new URLResource(YouTubePlayerProxy.CHROMELESS_PLAYER);
		private const INVALID_SWF_RESOURCE:URLResource = new URLResource("http://www.unknown.com/sample.swf");
		private const FLV_RESOURCE:URLResource = new URLResource("http://www.somewhere.com/files/video.flv");
	}
}