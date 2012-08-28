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

package org.osmf.youtube.traits
{

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.youtube.MockYoutubePlayer;

	public class TestYoutubeSeekTrait
	{
		[Before]
		public function setUp():void
		{
			player = new MockYoutubePlayer();
			timeTrait = new YouTubeTimeTrait(DURATION, player);
			seekTrait = new YouTubeSeekTrait(timeTrait, player);
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
		public function testYoutubeSeekTrait():void
		{
			assertNotNull(seekTrait);
		}

		[Test]
		public function testCanSeekToAnywhere():void
		{
			assertTrue(seekTrait.canSeekTo(DURATION));
			assertTrue(seekTrait.canSeekTo(DURATION/2));			
		}

		[Test]
		public function testSeek():void
		{
			seekTrait.seek(DURATION/2.67);
			assertEquals(DURATION/2.67, timeTrait.currentTime);
		}

		[Test]
		public function testSeekWhileSeeking():void
		{
			player.slowSeek = true;
			seekTrait.seek(1);

			// the seek has not ended so the current time should not be updated
			assertFalse(timeTrait.currentTime == 1);

			// do a second seek that completes before the first
			player.slowSeek = false;
			seekTrait.seek(5);

			assertEquals(5, timeTrait.currentTime);
		}

		private var seekTrait:YouTubeSeekTrait;
		private var timeTrait:YouTubeTimeTrait;
		private var player:MockYoutubePlayer;

		/* static */
		private static const DURATION:int = 789;
		
	}
}