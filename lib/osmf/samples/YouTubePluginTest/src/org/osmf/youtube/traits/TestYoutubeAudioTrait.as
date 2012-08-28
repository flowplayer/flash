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
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.youtube.MockYoutubePlayer;

	public class TestYoutubeAudioTrait
	{
		[Before]
		public function setUp():void
		{
			player = new MockYoutubePlayer();
			audioTrait = new YouTubeAudioTrait(player);
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
		public function testYoutubeAudioTrait():void
		{
			assertNotNull(audioTrait);
		}


		[Test]
		public function testMute():void
		{
			audioTrait.muted = true;

			assertTrue(player.isMuted());
		}

		[Test]
		public function testIsMuted():void
		{
			player.mute();

			assertTrue(audioTrait.muted);
		}

		[Test]
		public function testUnmute():void
		{
			player.mute();

			audioTrait.muted = false;

			assertTrue(player.isMuted());
		}

		[Test]
		public function testIsUnmuted():void
		{
			audioTrait.muted = true;
			
			player.unMute();
			
			assertFalse(audioTrait.muted);
		}

		[Test]
		public function testSetVolume():void
		{
			audioTrait.volume= 0.5;

			assertEquals(50, player.getVolume());
		}


		[Test]
		public function testGetVolume():void
		{
			player.setVolume(25);

			assertEquals(0.25, audioTrait.volume);
		}

		private var audioTrait:YouTubeAudioTrait;
		private var player:MockYoutubePlayer;
	}
}