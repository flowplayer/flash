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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.flexunit.Assert;
	import org.osmf.events.SeekEvent;

	public class TestSeekTrait
	{
		[Before]
		public function setUp():void
		{
			_seekTrait = createInterfaceObject(new TimeTrait(totalDuration)) as SeekTrait;
			eventDispatcher = new EventDispatcher();
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
			return new SeekTrait(args.length > 0 ? args[0] : null);
		}

		protected function get maxSeekValue():Number
		{
			return 1;
		}

		protected function get totalDuration():Number
		{
			return 1;
		}
		
		protected function get processesSeekCompletion():Boolean
		{
			// Some implementations of ISeekable will signal completion 
			// of a seek, although the default implementation doesn't.
			// Subclasses can override this to indicate that they process
			// completion.
			return false;
		}
		
		[Test]
		public function testSeeking():void
		{
			Assert.assertFalse(seekTrait.seeking);
		}
		
		[Test]
		public function testCanSeekTo():void
		{
			Assert.assertFalse(seekTrait.canSeekTo(NaN));
			Assert.assertFalse(seekTrait.canSeekTo(-1));
			if (maxSeekValue > 0)
			{
				Assert.assertTrue(seekTrait.canSeekTo(maxSeekValue));
			}
			Assert.assertFalse(seekTrait.canSeekTo(maxSeekValue+1));
		}
		
		[Test]
		public function testSeekInvalid():void
		{
			if (maxSeekValue > 0)
			{
				seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, eventCatcher);
			
				Assert.assertFalse(seekTrait.canSeekTo(maxSeekValue + 1));
				
				seekTrait.seek(maxSeekValue + 1);
					
				// This should not cause any change events:
				Assert.assertTrue(events.length == 0);
			}
		}
		
		// Protected
		//
		
		protected function get seekTrait():SeekTrait
		{
			return _seekTrait;
		}
		
		// Internals
		//

		private function eventCatcher(event:Event):void
		{
			events.push(event);
		}

		private var _seekTrait:SeekTrait;
		private var events:Array;
		private var eventDispatcher:EventDispatcher;
	}
}