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
 **********************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.MockMediaElement;
	import org.osmf.MockPlayTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	public class TestPauseButton
	{		
		[Before]
		public function setUp():void
		{
			playableMedia = new MockMediaElement();
			playableMedia.addSomeTrait(new PlayTrait());
			
			var unpausablePlayable:MockPlayTrait = new MockPlayTrait();
			unpausablePlayable.canPause = false;
			
			unpausableMedia = new MockMediaElement();
			unpausableMedia.addSomeTrait(unpausablePlayable);
			
			pauseButton = new PauseButton();
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
		public function testPauseButton():void
		{
			assertNotNull(pauseButton);
		}
		
		
		[Test]
		public function testIsNotVisible():void
		{
			pauseButton.media = unpausableMedia;			
			assertFalse(pauseButton.visible);
		}
		
		[Test]
		public function testStopInsteadOfPause():void
		{
			pauseButton.media = unpausableMedia;
			(unpausableMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).play();
			
			//try to pause
			pauseButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));

			assertEquals(PlayState.STOPPED, (unpausableMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).playState);						
			assertFalse(pauseButton.visible);
		}
		
		[Test]
		public function testIsPlaying():void
		{
			pauseButton.media = playableMedia;
			(playableMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).play();
			
			assertTrue(pauseButton.visible);
		}

		[Test]
		public function testIsPaused():void
		{
			pauseButton.media = playableMedia;
			(playableMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).pause();
			
			assertFalse(pauseButton.visible);
		}
		
		
		[Test]
		public function testPauseOnMouseClick():void
		{
			pauseButton.media = playableMedia;
			pauseButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			assertEquals(PlayState.PAUSED, (playableMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).playState);						
			assertFalse(pauseButton.visible);
		}
		
		private var pauseButton:PauseButton;
		
		private var playableMedia:MockMediaElement;
		private var unpausableMedia:MockMediaElement;
	}
}