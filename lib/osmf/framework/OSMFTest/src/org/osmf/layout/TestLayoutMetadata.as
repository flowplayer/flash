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
	
	public class TestLayoutMetadata
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
		
		//TODO: refactor this in many smaller tests
		[Test]
		public function testLayoutUtils():void
		{
			var lm:LayoutMetadata = new LayoutMetadata();
			
			Assert.assertEquals(NaN, lm.index);
			Assert.assertEquals(null, lm.scaleMode);
			Assert.assertEquals(null, lm.verticalAlign);
			Assert.assertEquals(null, lm.horizontalAlign);
			Assert.assertEquals(true, lm.snapToPixel);
			Assert.assertEquals(LayoutMode.NONE, lm.layoutMode);
			
			Assert.assertEquals(NaN, lm.x);
			Assert.assertEquals(NaN, lm.y);			
			Assert.assertEquals(NaN, lm.width);
			Assert.assertEquals(NaN, lm.height);
			
			Assert.assertEquals(NaN, lm.percentX);
			Assert.assertEquals(NaN, lm.percentY);
			Assert.assertEquals(NaN, lm.percentWidth);
			Assert.assertEquals(NaN, lm.percentHeight);
			
			Assert.assertEquals(NaN, lm.left);
			Assert.assertEquals(NaN, lm.right);
			Assert.assertEquals(NaN, lm.top);
			Assert.assertEquals(NaN, lm.bottom);
			
			Assert.assertEquals(NaN, lm.paddingLeft);
			Assert.assertEquals(NaN, lm.paddingRight);
			Assert.assertEquals(NaN, lm.paddingTop);
			Assert.assertEquals(NaN, lm.paddingBottom);
			
			// Check all routines twice; first time around, a metadata object
			// could be created.
			for (var i:int = 0; i<2; i++)
			{
				lm.index = 1;
				Assert.assertEquals(1, lm.index);
				
				lm.verticalAlign = VerticalAlign.BOTTOM;
				Assert.assertEquals(VerticalAlign.BOTTOM, lm.verticalAlign);
				
				lm.horizontalAlign = HorizontalAlign.CENTER;
				Assert.assertEquals(HorizontalAlign.CENTER, lm.horizontalAlign);
				
				lm.scaleMode = ScaleMode.LETTERBOX;
				Assert.assertEquals(ScaleMode.LETTERBOX, lm.scaleMode);
				
				lm.snapToPixel = true;
				Assert.assertTrue(lm.snapToPixel);
				
				lm.layoutMode = LayoutMode.HORIZONTAL;
				Assert.assertEquals(LayoutMode.HORIZONTAL, lm.layoutMode); 
				
				lm.x = 1;
				Assert.assertEquals(1, lm.x);
				
				lm.y = 2;
				Assert.assertEquals(2, lm.y);
				
				lm.width = 3;
				Assert.assertEquals(3, lm.width);
				
				lm.height = 4;
				Assert.assertEquals(4, lm.height);
				
				lm.percentX = 5;
				Assert.assertEquals(5, lm.percentX);
				
				lm.percentY = 6;
				Assert.assertEquals(6, lm.percentY);
				
				lm.percentWidth = 7;
				Assert.assertEquals(7, lm.percentWidth);
				
				lm.percentWidth = 8;
				Assert.assertEquals(8, lm.percentWidth);
				
				lm.left = 9;
				Assert.assertEquals(9, lm.left);
				
				lm.right = 10;
				Assert.assertEquals(10, lm.right);
				
				lm.top = 11;
				Assert.assertEquals(11, lm.top);
				
				lm.bottom = 12;
				Assert.assertEquals(12, lm.bottom);
				
				lm.paddingLeft = 13;
				Assert.assertEquals(13, lm.paddingLeft);
				
				lm.paddingRight = 14;
				Assert.assertEquals(14, lm.paddingRight);
				
				lm.paddingTop = 15;
				Assert.assertEquals(15, lm.paddingTop);
				
				lm.paddingBottom = 16;
				Assert.assertEquals(16, lm.paddingBottom);
			} 
		}
	}
}