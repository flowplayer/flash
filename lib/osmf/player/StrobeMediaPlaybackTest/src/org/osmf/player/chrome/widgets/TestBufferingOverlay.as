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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.osmf.MockMediaElement;
	import org.osmf.MockPlayTrait;
	import org.osmf.MockTimeTrait;
	import org.osmf.events.TimeEvent;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.traits.BufferTrait;

	public class TestBufferingOverlay
	{		
		[Before]
		public function setUp():void
		{
			overlay = new BufferingOverlay();
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
		public function testInitallyVisible():void
		{
			assertTrue(overlay.visible);
		}
		
		[Test]
		public function testNonBufferingMedia():void
		{
			var element:MockMediaElement = new MockMediaElement();
			overlay.media = element;
			
			assertFalse(overlay.visible);
		}
		
		[Test]
		public function testPlayableBufferingMedia():void
		{
			var element:MockMediaElement = new MockMediaElement();
			var bufferTrait:MutableBufferTrait = new MutableBufferTrait();
			element.addSomeTrait(bufferTrait);
			var playTrait:MockPlayTrait = new MockPlayTrait();
			element.addSomeTrait(playTrait);
			var timeTrait:MockTimeTrait = new MockTimeTrait();
			element.addSomeTrait(timeTrait);
			
			overlay.media = element;
			
			assertFalse(overlay.visible);
			
			bufferTrait.switchBuffering(true);
			assertFalse(overlay.visible);
			
			bufferTrait.switchBuffering(false);
			playTrait.play();
			
			assertFalse(overlay.visible);
			
			bufferTrait.switchBuffering(true);
			assertTrue(overlay.visible);
			
			playTrait.stop();
			assertFalse(overlay.visible);
		}
		
		private var overlay:BufferingOverlay;
	}
}

import org.osmf.traits.BufferTrait;

class MutableBufferTrait extends BufferTrait
{
	public function switchBuffering(value:Boolean):void
	{
		setBuffering(value);
	}
}