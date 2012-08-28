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
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	
	public class TestPlayButtonOverlay
	{		
		[Before]
		public function setUp():void
		{
			playableMedia = new MockMediaElement();
			playableMedia.addSomeTrait(new PlayTrait());
			
			unplayableMedia = new MockMediaElement();
			
			overlay = new PlayButtonOverlay();
			overlay.configure(<default/>, new AssetsManager());
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
		public function testIsVisible():void
		{
			overlay.media = playableMedia;			
			assertTrue(overlay.visible);
		}
		
		[Test]
		public function testIsNotVisible():void
		{
			overlay.media = unplayableMedia;			
			assertFalse(overlay.visible);
		}
		
		[Test]
		public function testNoMedia():void
		{
			assertFalse(overlay.visible);
		}
		
		[Test]
		public function testIsPlaying():void
		{
			overlay.media = playableMedia;
			(playableMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).play();
			
			assertFalse(overlay.visible);
		}
		
		
		[Test]
		public function testPlayMouseClick():void
		{
			overlay.media = playableMedia;
			overlay.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			assertEquals(PlayState.PLAYING, (playableMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).playState);						
			assertFalse(overlay.visible);
		}
		
		private var overlay:PlayButtonOverlay;
		private var playableMedia:MockMediaElement;
		private var unplayableMedia:MockMediaElement;	
	}
}