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
	import org.osmf.events.BufferEvent;
	import org.osmf.utils.DynamicBufferTrait;
	
	import flexunit.framework.Assert;

	public class TestBufferTraitAsSubclass extends TestBufferTrait
	{
		override protected function createInterfaceObject(... args):Object
		{
			return new DynamicBufferTrait();
		}
		
		[Test]
		override public function testBuffering():void
		{
			super.testBuffering();
			
			dynamicBufferTrait.addEventListener(BufferEvent.BUFFERING_CHANGE, eventCatcher);
			
			Assert.assertFalse(dynamicBufferTrait.buffering);
			
			dynamicBufferTrait.buffering = true;
			
			Assert.assertTrue(dynamicBufferTrait.buffering);
			
			dynamicBufferTrait.buffering = false;
			Assert.assertFalse(dynamicBufferTrait.buffering);
			
			// Should not trigger a change event:
			dynamicBufferTrait.buffering = false;
			
			Assert.assertTrue(events.length == 2);
			
			var bce:BufferEvent;
			
			bce = events[0] as BufferEvent;
			Assert.assertNotNull(bce);
			Assert.assertTrue(bce.buffering);
			
			bce = events[1] as BufferEvent;
			Assert.assertNotNull(bce);
			Assert.assertFalse(bce.buffering);
		}
		
		[Test]
		override public function testBufferLength():void
		{
			super.testBufferLength();
			
			dynamicBufferTrait.bufferLength = 10;

			Assert.assertTrue(dynamicBufferTrait.bufferLength == 10);
		}
		
		private function get dynamicBufferTrait():DynamicBufferTrait
		{
			return bufferTrait as DynamicBufferTrait;
		}
	}
}
