/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.traits
{
	import flash.errors.*;
	import flash.events.*;
	
	import org.flexunit.Assert;
	import org.osmf.events.DynamicStreamEvent;
	
	public class TestDynamicStreamTrait
	{
		[Before]
		public function setUp():void
		{
			_dynamicStreamTrait = createInterfaceObject(true, 0, 4) as DynamicStreamTrait;
			eventDispatcher = new EventDispatcher();
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
			return new DynamicStreamTrait(args.length > 0 ? args[0] : true, args.length > 1 ? args[1] : 0, args.length > 2 ? args[2] : 1);
		}

		protected function get dynamicStreamTrait():DynamicStreamTrait
		{
			return _dynamicStreamTrait;
		}
		
		[Test(expects="RangeError")]
		public function testBadMaxAllowedIndex():void
		{
			dynamicStreamTrait.maxAllowedIndex = 99;			
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function testBadSwitch1():void
		{
			Assert.assertTrue(dynamicStreamTrait.autoSwitch);
			dynamicStreamTrait.switchTo(1);
		}
		
		[Test(expects="RangeError")]
		public function testBadSwitch2():void
		{
			Assert.assertTrue(dynamicStreamTrait.autoSwitch);
			dynamicStreamTrait.autoSwitch = false;
			
			dynamicStreamTrait.switchTo(-1);
		}

		[Test(expects="RangeError")]
		public function testBadSwitch3():void
		{
			Assert.assertTrue(dynamicStreamTrait.autoSwitch);
			dynamicStreamTrait.autoSwitch = false;
			dynamicStreamTrait.switchTo(99);
		}
		
		[Test(expects="RangeError")]
		public function testGetBitrateForIndex():void
		{				
			Assert.assertEquals(0, dynamicStreamTrait.getBitrateForIndex(0));
			
			dynamicStreamTrait.getBitrateForIndex(-1);
		}
		
		private var _dynamicStreamTrait:DynamicStreamTrait;
		private var eventDispatcher:EventDispatcher;
	}
}
