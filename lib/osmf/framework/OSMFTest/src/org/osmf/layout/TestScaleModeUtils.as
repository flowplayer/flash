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
package org.osmf.layout
{
	import flash.geom.Point;
	
	import flexunit.framework.Assert;
	
	public class TestScaleModeUtils
	{		
		[Before]
		public function setUp():void
		{
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
		
		[Test]
		public function testScaleModeNone():void
		{			
			var point:Point = ScaleModeUtils.getScaledSize(ScaleMode.NONE, 1000, 900, 800, 700);
			Assert.assertTrue(point.x == 800);
			Assert.assertTrue(point.y == 700);
			
			point = ScaleModeUtils.getScaledSize(ScaleMode.NONE, 1000, 900, NaN, NaN);
			Assert.assertTrue(point.x == 1000);
			Assert.assertTrue(point.y == 900);
		}
		
		[Test]
		public function testScaleModeStretch():void
		{			
			var point:Point = ScaleModeUtils.getScaledSize(ScaleMode.STRETCH, 1000, 900, 800, 700);
			Assert.assertTrue(point.x == 1000);
			Assert.assertTrue(point.y == 900);
		}
		
		[Test]
		public function testScaleModeLetterbox():void
		{
			var point:Point = ScaleModeUtils.getScaledSize(ScaleMode.LETTERBOX, 1000, 500, 880, 800);
			Assert.assertTrue(point.x == 550);
			Assert.assertTrue(point.y == 500);
			
			point = ScaleModeUtils.getScaledSize(ScaleMode.LETTERBOX, 500, 1000, 800, 700);
			Assert.assertTrue(point.x == 500);
			Assert.assertTrue(point.y == 437.5);
		}
		
		[Test]
		public function testScaleModeZoom():void
		{
			var point:Point = ScaleModeUtils.getScaledSize(ScaleMode.ZOOM, 1000, 500, 800, 700);
			Assert.assertTrue(point.x == 1000);
			Assert.assertTrue(point.y == 875);
			
			point = ScaleModeUtils.getScaledSize(ScaleMode.ZOOM, 500, 1000, 880, 800);
			Assert.assertTrue(point.x == 1100);
			Assert.assertTrue(point.y == 1000);
		}
	}
}