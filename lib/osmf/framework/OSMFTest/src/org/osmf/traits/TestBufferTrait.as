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
	import org.osmf.events.BufferEvent;

	public class TestBufferTrait
	{
		[Before]
		public function setUp():void
		{
			_bufferTrait = createInterfaceObject() as BufferTrait;
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
		
		protected function createInterfaceObject(... args):Object
		{
			return new BufferTrait();
		}
		
		[Test]
		public function testBufferLength():void
		{
			Assert.assertTrue(bufferTrait.bufferLength == 0);
		}

		[Test]
		public function testBuffering():void
		{
			Assert.assertTrue(bufferTrait.buffering == false);
		}
		
		[Test]
		public function testBufferTime():void
		{
			bufferTrait.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, eventCatcher);
			
			var oldTime:Number = bufferTrait.bufferTime;
			
			bufferTrait.bufferTime = 5;
			Assert.assertTrue(bufferTrait.bufferTime == 5);
			
			bufferTrait.bufferTime = 10;
			Assert.assertTrue(bufferTrait.bufferTime == 10);
			
			bufferTrait.bufferTime = -100;
			Assert.assertTrue(bufferTrait.bufferTime == 0);
			
			// Should not trigger an event.
			bufferTrait.bufferTime = 0;
			
			var bsce:BufferEvent;
			
			Assert.assertTrue(events.length == 3);
			
			bsce = events[0] as BufferEvent;
			Assert.assertNotNull(bsce);
			Assert.assertTrue(bsce.type == BufferEvent.BUFFER_TIME_CHANGE);
			Assert.assertTrue(bsce.bufferTime == 5);
			
			bsce = events[1] as BufferEvent;
			Assert.assertNotNull(bsce);
			Assert.assertTrue(bsce.type == BufferEvent.BUFFER_TIME_CHANGE);
			Assert.assertTrue(bsce.bufferTime == 10);
			
			bsce = events[2] as BufferEvent;
			Assert.assertNotNull(bsce);
			Assert.assertTrue(bsce.type == BufferEvent.BUFFER_TIME_CHANGE);
			Assert.assertTrue(bsce.bufferTime == 0);
		}
		
		protected final function get bufferTrait():BufferTrait
		{
			return _bufferTrait;
		}

		protected function eventCatcher(event:Event):void
		{
			events.push(event);
		}
				
		protected var events:Array;

		private var _bufferTrait:BufferTrait;
	}
}