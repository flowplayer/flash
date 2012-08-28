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
	import flash.display.Sprite;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.utils.DynamicDisplayObjectTrait;

	import flexunit.framework.Assert;
	
	public class TestDisplayObjectTraitAsSubclass extends TestDisplayObjectTrait
	{
		override protected function createInterfaceObject(... args):Object
		{
			return new DynamicDisplayObjectTrait(args.length > 0 ? args[0] : null, args.length > 1 ? args[1] : 0, args.length > 2 ? args[2] : 0);
		}
		
		[Test]
		override public function testDisplayObject():void
		{
			super.testDisplayObject();
			
			var dynamicDisplayObjectTrait:DynamicDisplayObjectTrait = displayObjectTrait as DynamicDisplayObjectTrait;
			
			dynamicDisplayObjectTrait.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, eventCatcher);

			Assert.assertNull(dynamicDisplayObjectTrait.displayObject);
			
			var displayObject1:Sprite = new Sprite();
			var displayObject2:Sprite = new Sprite();			
			
			dynamicDisplayObjectTrait.displayObject = displayObject1;
			Assert.assertTrue(dynamicDisplayObjectTrait.displayObject == displayObject1);
			
			dynamicDisplayObjectTrait.displayObject = displayObject2;
			Assert.assertTrue(dynamicDisplayObjectTrait.displayObject == displayObject2);
			
			// Should not cause a change event:
			dynamicDisplayObjectTrait.displayObject = displayObject2;
			
			var vce:DisplayObjectEvent;
			
			Assert.assertTrue(events.length == 2);
			
			vce = events[0] as DisplayObjectEvent;
			Assert.assertNotNull(vce);
			Assert.assertTrue(vce.type == DisplayObjectEvent.DISPLAY_OBJECT_CHANGE);
			Assert.assertTrue(vce.oldDisplayObject == null);
			Assert.assertTrue(vce.newDisplayObject == displayObject1);
			
			vce = events[1] as DisplayObjectEvent;
			Assert.assertNotNull(vce);
			Assert.assertTrue(vce.type == DisplayObjectEvent.DISPLAY_OBJECT_CHANGE);
			Assert.assertTrue(vce.oldDisplayObject == displayObject1);
			Assert.assertTrue(vce.newDisplayObject == displayObject2);
		}
		
		[Test]
		override public function testMediaDimensions():void
		{
			super.testMediaDimensions();
			
			var dynamicDisplayObjectTrait:DynamicDisplayObjectTrait = displayObjectTrait as DynamicDisplayObjectTrait;
			
			dynamicDisplayObjectTrait.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, eventCatcher);
			
			// Should not cause a change event:
			dynamicDisplayObjectTrait.setSize(0, 0);
			
			Assert.assertTrue(events.length == 0);
			
			dynamicDisplayObjectTrait.setSize(30, 60);
			
			Assert.assertTrue(events.length == 1);
			
			var dce:DisplayObjectEvent = events[0] as DisplayObjectEvent;
			Assert.assertNotNull(dce);
			Assert.assertTrue(dce.type == DisplayObjectEvent.MEDIA_SIZE_CHANGE);
			Assert.assertTrue(dce.oldWidth == 0);
			Assert.assertTrue(dce.oldHeight == 0);
			Assert.assertTrue(dce.newWidth == 30);
			Assert.assertTrue(dce.newHeight == 60);
		}
	}
}
