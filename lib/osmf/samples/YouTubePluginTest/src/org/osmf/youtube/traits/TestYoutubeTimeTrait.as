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
	import org.osmf.youtube.MockYoutubePlayer;

	public class TestYoutubeTimeTrait
	{
		[Before]
		public function setUp():void
		{
			player = new MockYoutubePlayer();
			timeTrait = new YouTubeTimeTrait(DURATION, player);
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
		public function testYoutubeTimeTrait():void
		{
			assertEquals(DURATION, timeTrait.duration);
		}

		[Test]
		public function testCurrentTime():void
		{
			player.currentTime = 576;
			assertEquals(576, timeTrait.currentTime);
		}


		private var timeTrait:YouTubeTimeTrait;
		private var player:MockYoutubePlayer;
		
		/* static */

		private static const DURATION:int = 145;
	}
}