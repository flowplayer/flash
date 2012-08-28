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
	import flash.events.Event;
	
	import org.flexunit.Assert;

	public class TestDisplayObjectTrait
	{
		[Before]
		public function setUp():void
		{
			displayObjectTrait = createInterfaceObject() as DisplayObjectTrait;
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
			return new DisplayObjectTrait(args.length > 0 ? args[0] : null, args.length > 1 ? args[1] : 0, args.length > 2 ? args[2] : 0);
		}
		
		[Test]
		public function testDisplayObject():void
		{
			var nullDisplayObjectTrait:DisplayObjectTrait = createInterfaceObject() as DisplayObjectTrait;
			Assert.assertTrue(nullDisplayObjectTrait.displayObject == null);
			
			var sprite:Sprite = new Sprite();
			
			var nonNullDisplayObjectTrait:DisplayObjectTrait = createInterfaceObject(sprite) as DisplayObjectTrait;
			Assert.assertTrue(nonNullDisplayObjectTrait.displayObject == sprite);
		}

		[Test]
		public function testMediaDimensions():void
		{
			Assert.assertTrue(displayObjectTrait.mediaWidth == 0);
			Assert.assertTrue(displayObjectTrait.mediaHeight == 0);
			
			var sprite:Sprite = new Sprite();
			
			var spatialDisplayObjectTrait:DisplayObjectTrait = createInterfaceObject(sprite, 33, 66) as DisplayObjectTrait;
			
			Assert.assertTrue(spatialDisplayObjectTrait.mediaWidth == 33);
			Assert.assertTrue(spatialDisplayObjectTrait.mediaHeight == 66);
		}
		
		// Utils
		//
		
		protected var displayObjectTrait:DisplayObjectTrait;
		protected var events:Array;
		
		protected function eventCatcher(event:Event):void
		{
			events.push(event);
		}
	}
}