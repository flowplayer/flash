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
	import org.osmf.events.TimeEvent;
	import org.osmf.utils.DynamicTimeTrait;
	
	import flexunit.framework.Assert;

	public class TestTimeTraitAsSubclass extends TestTimeTrait
	{
		override protected function createInterfaceObject(... args):Object
		{
			return new DynamicTimeTrait();
		}
		
		[Test]
		override public function testCurrentTime():void
		{
			super.testCurrentTime();
			
			var dynamicTimeTrait:DynamicTimeTrait = timeTrait as DynamicTimeTrait;

			// Current time must never exceed duration.
			dynamicTimeTrait.currentTime = 10;
			Assert.assertTrue(dynamicTimeTrait.currentTime == 0);

			dynamicTimeTrait.duration = 25;
			dynamicTimeTrait.currentTime = 10;
			Assert.assertTrue(dynamicTimeTrait.currentTime == 10);
			dynamicTimeTrait.currentTime = 50;
			Assert.assertTrue(dynamicTimeTrait.currentTime == 25);
			dynamicTimeTrait.duration = 5;
			Assert.assertTrue(dynamicTimeTrait.currentTime == 5);
			
			// Setting the currentTime to the duration should cause the
			// complete event to fire.
			
			dynamicTimeTrait.addEventListener(TimeEvent.COMPLETE, eventCatcher);
			
			dynamicTimeTrait.duration = 20;
			dynamicTimeTrait.currentTime = 20;
			
			Assert.assertTrue(events.length == 1);
			
			var dre:TimeEvent;
			dre = events[0] as TimeEvent;
			Assert.assertNotNull(dre && dre.type == TimeEvent.COMPLETE);
			
			// Current time changes shouldn't trigger events.
			dynamicTimeTrait.currentTime = 20;
			dynamicTimeTrait.currentTime = 10;
			dynamicTimeTrait.currentTime = NaN;
			Assert.assertTrue(events.length == 1);
		}
		
		[Test]
		override public function testDuration():void
		{
			super.testDuration();
			
			var dynamicTimeTrait:DynamicTimeTrait = timeTrait as DynamicTimeTrait;
			
			dynamicTimeTrait.addEventListener(TimeEvent.DURATION_CHANGE, eventCatcher);
			
			Assert.assertTrue(isNaN(dynamicTimeTrait.duration));
			
			dynamicTimeTrait.duration = 10;
			Assert.assertTrue(dynamicTimeTrait.duration == 10);
			
			dynamicTimeTrait.duration = 20;
			Assert.assertTrue(dynamicTimeTrait.duration == 20);
			
			Assert.assertTrue(events.length == 2);
			
			var dce:TimeEvent;
			
			dce = events[0] as TimeEvent;
			Assert.assertNotNull(dce);
			Assert.assertTrue(dce.type == TimeEvent.DURATION_CHANGE);
			Assert.assertTrue(dce.time == 10);
			
			dce = events[1] as TimeEvent;
			Assert.assertNotNull(dce);
			Assert.assertTrue(dce.type == TimeEvent.DURATION_CHANGE);
			Assert.assertTrue(dce.time == 20); 
			
			// No event should fire if the value is the same.
			dynamicTimeTrait.duration = 20;
			Assert.assertTrue(events.length == 2);
		}
	}
}
