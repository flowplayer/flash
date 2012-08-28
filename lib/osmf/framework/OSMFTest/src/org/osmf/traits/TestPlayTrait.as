/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.traits
{
	import __AS3__.vec.Vector;

	import flash.events.Event;

	import org.flexunit.Assert;
	import org.osmf.events.PlayEvent;

	public class TestPlayTrait
	{
		[Before]
		public function setUp():void
		{
			playTrait = createInterfaceObject() as PlayTrait;
			events = [];
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
		
		/**
		 * Subclasses can override to specify their own trait class.
		 **/
		protected function createInterfaceObject(... args):Object
		{
			return new PlayTrait();
		}
		
		[Test]
		public function testCanPause():void
		{
			Assert.assertTrue(playTrait.canPause == true);
		}

		[Test]
		public function testPlayState():void
		{
			Assert.assertTrue(playTrait.playState == PlayState.STOPPED);
		}
		
		[Test]		
		public function testPlay():void
		{
			Assert.assertTrue(playTrait.playState == PlayState.STOPPED);
			
			playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, eventCatcher);
			
			playTrait.play();
			Assert.assertTrue(playTrait.playState == PlayState.PLAYING);
			
			// A change event should have been fired:
			Assert.assertTrue(events.length == 1);

			// Verify that the event holds the correct info:			
			var pce:PlayEvent = events[0] as PlayEvent;
			Assert.assertNotNull(pce);
			Assert.assertTrue(pce.type == PlayEvent.PLAY_STATE_CHANGE);
			Assert.assertTrue(pce.playState == PlayState.PLAYING);
			
			// Play again. This is not a change, so no event should be triggered:
			playTrait.play();
			Assert.assertTrue(playTrait.playState == PlayState.PLAYING);
			Assert.assertTrue(events.length == 1);
		}

		[Test]
		public function testPause():void
		{
			Assert.assertTrue(playTrait.playState == PlayState.STOPPED);
			
			playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, eventCatcher);
			
			playTrait.pause();
			Assert.assertTrue(playTrait.playState == PlayState.PAUSED);
			
			// A change event should have been fired:
			Assert.assertTrue(events.length == 1);

			// Verify that the event holds the correct info:			
			var pce:PlayEvent = events[0] as PlayEvent;
			Assert.assertNotNull(pce);
			Assert.assertTrue(pce.type == PlayEvent.PLAY_STATE_CHANGE);
			Assert.assertTrue(pce.playState == PlayState.PAUSED);
			
			// Pause again. This is not a change, so no event should be triggered:
			playTrait.pause();
			Assert.assertTrue(playTrait.playState == PlayState.PAUSED);
			Assert.assertTrue(events.length == 1);
		}

		[Test]
		public function testStop():void
		{
			Assert.assertTrue(playTrait.playState == PlayState.STOPPED);
			
			playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, eventCatcher);
			
			// Stopping when already stopped is not a change.
			playTrait.stop();
			Assert.assertTrue(playTrait.playState == PlayState.STOPPED);
			Assert.assertTrue(events.length == 0);
			
			playTrait.play();
			Assert.assertTrue(playTrait.playState == PlayState.PLAYING);
			Assert.assertTrue(events.length == 1);
			
			// Stopping when playing should trigger an event.
			playTrait.stop();
			Assert.assertTrue(playTrait.playState == PlayState.STOPPED);
			Assert.assertTrue(events.length == 2);
			
			// Verify that the event holds the correct info:			
			var pce:PlayEvent = events[1] as PlayEvent;
			Assert.assertNotNull(pce);
			Assert.assertTrue(pce.type == PlayEvent.PLAY_STATE_CHANGE);
			Assert.assertTrue(pce.playState == PlayState.STOPPED);
			
			playTrait.pause();
			Assert.assertTrue(playTrait.playState == PlayState.PAUSED);
			Assert.assertTrue(events.length == 3);
			
			// Stopping when paused should trigger an event.
			playTrait.stop();
			Assert.assertTrue(playTrait.playState == PlayState.STOPPED);
			Assert.assertTrue(events.length == 4);
			
			// Verify that the event holds the correct info:			
			pce = events[3] as PlayEvent;
			Assert.assertNotNull(pce);
			Assert.assertTrue(pce.type == PlayEvent.PLAY_STATE_CHANGE);
			Assert.assertTrue(pce.playState == PlayState.STOPPED);
		}
		
		protected var playTrait:PlayTrait;
		protected var events:Array;
		
		protected function eventCatcher(event:Event):void
		{
			events.push(event);
		}
	}
}