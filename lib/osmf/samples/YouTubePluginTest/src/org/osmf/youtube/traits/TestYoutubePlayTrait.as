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
	import flexunit.framework.Assert;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.async.Async;
	import org.osmf.events.PlayEvent;
	import org.osmf.traits.PlayState;
	import org.osmf.youtube.MockYoutubePlayer;

	public class TestYoutubePlayTrait
	{
		[Before]
		public function setUp():void
		{
			player = new MockYoutubePlayer();
			playTrait = new YouTubePlayTrait(player);
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

		[Test] [Ignore]
		public function testYoutubePlayTrait():void
		{
			assertNotNull(playTrait);
			assertEquals(PlayState.STOPPED, playTrait.playState);
		}

		[Test]
		public function testPlay():void
		{
			playTrait.play();

			assertEquals(PlayState.PLAYING, playTrait.playState);
		}

		[Test]
		public function testPause():void
		{
			playTrait.play();
			playTrait.pause();

			assertEquals(PlayState.PAUSED, playTrait.playState);
		}

		[Test][Ignore]
		public function testStop():void
		{
			playTrait.play();
			playTrait.stop();

			assertEquals(PlayState.STOPPED, playTrait.playState);
		}


		private var player:MockYoutubePlayer;
		private var playTrait:YouTubePlayTrait;

	}
}