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
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.MockMediaElement;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.events.ScrubberEvent;
	import org.osmf.events.AudioEvent;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;

	public class TestVolumeWidget
	{		
		[Before]
		public function setUp():void
		{
			//dummy media element
			var media:MockMediaElement = new MockMediaElement(); 
			media.addSomeTrait(new AudioTrait());
			
			volumeWidget = new VolumeWidget();
			volumeWidget.configure(<default/>, new AssetsManager());
			volumeWidget.media = media;
			
			FlexGlobals.topLevelApplication.stage.addChild(volumeWidget);
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
		public function testVolumeWidgetConstructor():void
		{
			assertNotNull(volumeWidget);
		}
		
		[Test]
		public function testVolumeSlider():void
		{
			assertNotNull(volumeWidget.slider);
		}
				
		[Test]
		public function testUpdateVolume():void
		{
			volumeWidget.sliderStart = 0;
			volumeWidget.sliderEnd = 100;
			volumeWidget.slider.y = 50;
			volumeWidget.slider.dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_UPDATE));
			
			assertEquals(0.5, (volumeWidget.media.getTrait(MediaTraitType.AUDIO) as AudioTrait).volume);
		}

		[Test]
		public function testSetVolume():void
		{
			volumeWidget.sliderStart = 50;
			volumeWidget.sliderEnd = 100;
			volumeWidget.slider.y = 87.5;
			volumeWidget.slider.dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_END));
			
			assertEquals(0.25, (volumeWidget.media.getTrait(MediaTraitType.AUDIO) as AudioTrait).volume);
		}

		
		[Test]
		public function testMinVolume():void
		{
			volumeWidget.slider.y = volumeWidget.sliderEnd;
			volumeWidget.slider.dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_END));
			
			assertEquals(0, (volumeWidget.media.getTrait(MediaTraitType.AUDIO) as AudioTrait).volume);
			
		}

		[Test]
		public function testMuteOnMinVolume():void
		{
			volumeWidget.slider.y = volumeWidget.sliderEnd;
			volumeWidget.slider.dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_END));
			
			assertTrue((volumeWidget.media.getTrait(MediaTraitType.AUDIO) as AudioTrait).muted);
			
		}

		[Test]
		public function testUnmuteOnVolumeChange():void
		{
			(volumeWidget.media.getTrait(MediaTraitType.AUDIO) as AudioTrait).muted = true;
			volumeWidget.slider.y = 50;
			volumeWidget.slider.dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_END));
			
			assertFalse((volumeWidget.media.getTrait(MediaTraitType.AUDIO) as AudioTrait).muted);
			
		}

		
		[Test]
		public function testMaxVolume():void
		{
			volumeWidget.slider.y = volumeWidget.sliderStart;
			volumeWidget.slider.dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_UPDATE));
			
			assertEquals(1, (volumeWidget.media.getTrait(MediaTraitType.AUDIO) as AudioTrait).volume);
			
		}
		
		[Test]
		public function testOnMutedChange_muted():void
		{
			volumeWidget.dispatchEvent(new AudioEvent(AudioEvent.MUTED_CHANGE, false, false, true));
			
			assertEquals(volumeWidget.sliderStart, volumeWidget.slider.y);
		}
		
		[Test]
		public function testOnMutedChange_unmuted():void
		{
			volumeWidget.dispatchEvent(new AudioEvent(AudioEvent.MUTED_CHANGE, false, false, false, 1));
			
			assertEquals(volumeWidget.sliderStart, volumeWidget.slider.y);
		}

		[Ignore][Test]
		public function testOnMouseDown():void
		{
			//HACK: this hacks the slider start position to be negative
			//since we cannot tinker with the mouseY property which is set to 0
			//and we need the event to take place inside the volume track
			volumeWidget.sliderStart = -1;
			volumeWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, false, false, 0, volumeWidget.sliderStart+1));
			
			assertTrue(volumeWidget.slider.sliding);
		}

		[Test] [Ignore]
		public function testOnMouseDownOutsideSliderTrack():void
		{
			volumeWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, false, false, 0, 0));
			
			assertFalse(volumeWidget.slider.sliding);
		}

		[Test]
		public function testOnMouseClick():void
		{
			//HACK: this hacks the slider start position to be negative
			//since we cannot tinker with the mouseY property which is set to 0
			//and we need the event to take place inside the volume track
			volumeWidget.sliderStart = -1;

			volumeWidget.dispatchEvent(new MouseEvent(MouseEvent.CLICK, false, false, 0, 0));
			
			assertFalse(volumeWidget.slider.sliding);
		}
		
		[Ignore][Test]
		public function testOnMouseMoveWithButtonDown():void
		{
			//HACK: this hacks the slider start position to be negative
			//since we cannot tinker with the mouseY property which is set to 0
			//and we need the event to take place inside the volume track
			volumeWidget.sliderStart = -1;
			
			volumeWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, false, false, 0, 0, null, false, false, false, true));
			
			assertTrue(volumeWidget.slider.sliding);
		}
		
		[Test] [Ignore]
		public function testOnMouseMoveWithButtonDownOutsideSliderTrack():void
		{
			
			volumeWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, false, false, 0, 0, null, false, false, false, true));
			
			assertFalse(volumeWidget.slider.sliding);
		}

		[Test]
		public function testOnMouseMove():void
		{
			//HACK: this hacks the slider start position to be negative
			//since we cannot tinker with the mouseY property which is set to 0
			//and we need the event to take place inside the volume track
			volumeWidget.sliderStart = -1;
			
			volumeWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, false, false, 0, 0));
			
			assertFalse(volumeWidget.slider.sliding);
		}
		
		[Test]
		public function testOnMouseMoveOutsideSliderTrack():void
		{
			volumeWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, false, false, 0, 0));	
			assertFalse(volumeWidget.slider.sliding);
		}
		
		private var volumeWidget:VolumeWidget;
	}
}