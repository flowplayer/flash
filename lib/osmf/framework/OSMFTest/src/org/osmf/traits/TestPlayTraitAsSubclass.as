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
	import flash.errors.IllegalOperationError;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.utils.DynamicPlayTrait;
	
	import flexunit.framework.Assert;

	public class TestPlayTraitAsSubclass extends TestPlayTrait
	{
		override protected function createInterfaceObject(... args):Object
		{
			return new DynamicPlayTrait();
		}
		
		[Test]
		override public function testCanPause():void
		{
			super.testCanPause();
			
			var dynamicPlayTrait:DynamicPlayTrait = playTrait as DynamicPlayTrait;
			
			dynamicPlayTrait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, eventCatcher);
			dynamicPlayTrait.canPause = false;
			
			Assert.assertTrue(dynamicPlayTrait.canPause == false);
			
			Assert.assertTrue(events.length == 1);
			
			var cpe:PlayEvent;
			
			cpe = events[0] as PlayEvent;
			Assert.assertNotNull(cpe);
			Assert.assertTrue(cpe.type == PlayEvent.CAN_PAUSE_CHANGE);
			
			// Now that we can't pause, verify as much.
			try
			{
				dynamicPlayTrait.pause();
				
				Assert.assertTrue(false);
			}
			catch (error:IllegalOperationError)
			{
			}
			
			// Repeating the call is a no-op, event-wise.
			dynamicPlayTrait.canPause = false;
			Assert.assertTrue(events.length == 1);
		}
	}
}
