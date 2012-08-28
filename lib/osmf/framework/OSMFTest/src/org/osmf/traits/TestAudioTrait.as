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
	import flexunit.framework.Assert;
	
	import __AS3__.vec.Vector;
	
	import flash.events.Event;

	import org.osmf.events.AudioEvent;

	public class TestAudioTrait
	{		
		[Before]
		public function setUp():void
		{
			audioTrait = createInterfaceObject() as AudioTrait;
			events = new Vector.<Event>;
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
		
		protected function createInterfaceObject(... args):Object
		{
			return new AudioTrait();
		}
		
		[Test]
		public function testVolume():void
		{
			audioTrait.addEventListener(AudioEvent.VOLUME_CHANGE, eventCatcher);
			
			Assert.assertTrue(audioTrait.volume == 1);
			
			audioTrait.volume = 0;
			Assert.assertTrue(audioTrait.volume == 0);
			
			audioTrait.volume = 0.5;
			Assert.assertTrue(audioTrait.volume == 0.5);
			
			audioTrait.volume = 100;
			Assert.assertTrue(audioTrait.volume == 1);
			
			// Should not trigger change:
			audioTrait.volume = 8054562546;
			
			var vce:AudioEvent;
			
			Assert.assertTrue(events.length == 3);
			vce = events[0] as AudioEvent;
			Assert.assertNotNull(vce);
			Assert.assertTrue(vce.type == AudioEvent.VOLUME_CHANGE);
			Assert.assertTrue(vce.volume == 0);
			
			vce = events[1] as AudioEvent;
			Assert.assertNotNull(vce);
			Assert.assertTrue(vce.type == AudioEvent.VOLUME_CHANGE);
			Assert.assertTrue(vce.volume == 0.5);
			
			vce = events[2] as AudioEvent;
			Assert.assertNotNull(vce);
			Assert.assertTrue(vce.type == AudioEvent.VOLUME_CHANGE);
			Assert.assertTrue(vce.volume == 1);
		}
		
		[Test]
		public function testMuted():void
		{
			audioTrait.addEventListener(AudioEvent.MUTED_CHANGE, eventCatcher);
			
			Assert.assertFalse(audioTrait.muted);
			Assert.assertTrue(audioTrait.volume == 1);
			
			audioTrait.muted = true;
			Assert.assertTrue(audioTrait.muted);
			Assert.assertTrue(audioTrait.volume == 1);
			
			audioTrait.muted = false; 
			Assert.assertFalse(audioTrait.muted);
			Assert.assertTrue(audioTrait.volume == 1);
			
			// Should not trigger change:
			audioTrait.muted = false; 
			Assert.assertFalse(audioTrait.muted);
			Assert.assertTrue(audioTrait.volume == 1);
			
			var mce:AudioEvent;
			
			Assert.assertTrue(events.length == 2);
			mce = events[0] as AudioEvent;
			Assert.assertNotNull(mce);
			Assert.assertTrue(mce.type == AudioEvent.MUTED_CHANGE);
			Assert.assertTrue(mce.muted);
			
			mce = events[1] as AudioEvent;
			Assert.assertNotNull(mce);
			Assert.assertTrue(mce.type == AudioEvent.MUTED_CHANGE);
			Assert.assertFalse(mce.muted);
		}
		
		[Test]
		public function testPan():void
		{
			audioTrait.addEventListener(AudioEvent.PAN_CHANGE, eventCatcher);
			
			Assert.assertTrue(audioTrait.pan == 0);
			
			audioTrait.pan = -1;
			Assert.assertTrue(audioTrait.pan == -1);
			
			audioTrait.pan = 1;
			Assert.assertTrue(audioTrait.pan == 1);
			
			audioTrait.pan = -10;
			Assert.assertTrue(audioTrait.pan == -1);
			
			audioTrait.pan = 10
			Assert.assertTrue(audioTrait.pan == 1);
			
			audioTrait.pan = 0.152
			Assert.assertTrue(audioTrait.pan == 0.152);
			
			// Should not trigger changed:
			audioTrait.pan = 0.152;
			
			var pce:AudioEvent;
			
			Assert.assertTrue(events.length == 5);
			pce = events[0] as AudioEvent;
			Assert.assertTrue(pce.type == AudioEvent.PAN_CHANGE);
			Assert.assertTrue(pce.pan == -1);
			
			pce = events[1] as AudioEvent;
			Assert.assertTrue(pce.type == AudioEvent.PAN_CHANGE);
			Assert.assertTrue(pce.pan == 1);
			
			pce = events[2] as AudioEvent;
			Assert.assertTrue(pce.type == AudioEvent.PAN_CHANGE);
			Assert.assertTrue(pce.pan == -1);
			
			pce = events[3] as AudioEvent;
			Assert.assertTrue(pce.type == AudioEvent.PAN_CHANGE);
			Assert.assertTrue(pce.pan == 1);
			
			pce = events[4] as AudioEvent;
			Assert.assertTrue(pce.type == AudioEvent.PAN_CHANGE);
			Assert.assertTrue(pce.pan == 0.152);
		}
		
		private function eventCatcher(event:Event):void
		{
			events.push(event);
		}
		
		private var audioTrait:AudioTrait;
		private var events:Vector.<Event>;
	}
}