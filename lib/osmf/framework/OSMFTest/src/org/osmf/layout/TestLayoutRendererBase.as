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
	import flexunit.framework.Assert;
	
	public class TestLayoutRendererBase
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
		public function testLayoutRenderer():void
		{
			var renderer:LayoutRendererBase = new LayoutRendererBase();
			Assert.assertNotNull(renderer);
			
			var c:TesterLayoutTargetSprite = new TesterLayoutTargetSprite();
			
			var l1:TesterLayoutTargetSprite = new TesterLayoutTargetSprite();
			l1.setIntrinsicDimensions(50,200);
			
			var l2:TesterLayoutTargetSprite = new TesterLayoutTargetSprite();
			l2.setIntrinsicDimensions(100,150);
			
			renderer.container = c;
			
			renderer.addTarget(l1);
			renderer.addTarget(l2);
			
			renderer.validateNow();
			
			Assert.assertEquals(50, l1.measuredWidth);
			Assert.assertEquals(200, l1.measuredHeight);
			
			Assert.assertEquals(100, l2.measuredWidth);
			Assert.assertEquals(150, l2.measuredHeight);
			
			// The base renderer does not calculate aggregate bounds:
			Assert.assertEquals(NaN, c.measuredWidth);
			Assert.assertEquals(NaN, c.measuredHeight);
		}
	}
}