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

	import flash.events.Event;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.youtube.MockYoutubePlayer;
	import org.osmf.youtube.events.YouTubeEvent;

	public class TestYoutubeDynamicStreamTrait
	{
		[Before]
		public function setUp():void
		{
			player = new MockYoutubePlayer();
			switchTrait = new YouTubeDynamicStreamTrait(player);
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
		public function testYoutubeDynamicStreamTrait():void
		{
			assertNotNull(switchTrait);
		}

		[Test]
		public function testMultipleQualityLevelsAvailableAtConstructTime():void
		{
			var streams:Array = ["low", "medium", "large"];
			player.qualityLevels = streams;

			var newSwitchTrait:YouTubeDynamicStreamTrait
					= new YouTubeDynamicStreamTrait(player);
			assertEquals(streams.length, newSwitchTrait.numDynamicStreams);
		}


		[Test]
		public function testUpdateStreamsOnPlay():void
		{

			player.qualityLevels = STREAMS;
			player.dispatchEvent(new YouTubeEvent("onStateChange", 1));
			
			assertEquals(STREAMS.length, switchTrait.numDynamicStreams);
		}

		[Test]
		public function testNoUpdateStreamsOnPlay():void
		{
			player.dispatchEvent(new YouTubeEvent("onStateChange", 1));

			assertEquals(1, switchTrait.numDynamicStreams);
		}

		[Test]
		public function testDisableAutoswitch():void
		{
			var initialQuality:String = player.getPlaybackQuality();

			switchTrait.autoSwitch = false;

			assertEquals(initialQuality, player.getPlaybackQuality());
		}



		private var switchTrait:YouTubeDynamicStreamTrait;
		private var player:MockYoutubePlayer;

		/* static */
		private static const STREAMS:Array = ["hd720", "large", "medium"];
	}
}