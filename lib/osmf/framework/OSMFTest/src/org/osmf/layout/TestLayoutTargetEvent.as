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
	import flash.display.Sprite;
	
	public class TestLayoutTargetEvent
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
		public function testLayoutTargetEvent():void
		{
			var renderer:LayoutRenderer = new LayoutRenderer();
			var layoutTarget:LayoutTargetSprite = new LayoutTargetSprite();
			var displayObject:Sprite = new Sprite();
			
			var lte:LayoutTargetEvent
			= new LayoutTargetEvent
				( LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER
					, true, true
					, renderer
					, layoutTarget
					, displayObject
					, 10
				);
			
			Assert.assertEquals(LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER, lte.type);
			Assert.assertTrue(lte.bubbles);
			Assert.assertTrue(lte.cancelable);
			Assert.assertEquals(lte.layoutRenderer, renderer);
			Assert.assertEquals(lte.layoutTarget, layoutTarget);
			Assert.assertEquals(lte.displayObject, displayObject);
			Assert.assertEquals(lte.index, 10);
		}
		
		[Test]
		public function testLayoutTargetEventClone():void
		{
			var renderer:LayoutRenderer = new LayoutRenderer();
			var layoutTarget:LayoutTargetSprite = new LayoutTargetSprite();
			var displayObject:Sprite = new Sprite();
			
			var lte:LayoutTargetEvent
			= new LayoutTargetEvent
				( LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER
					, true, true
					, renderer
					, layoutTarget
					, displayObject
					, 10
				);
			
			var clone:LayoutTargetEvent = lte.clone() as LayoutTargetEvent;
			
			Assert.assertEquals(LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER, clone.type);
			Assert.assertTrue(clone.bubbles);
			Assert.assertTrue(clone.cancelable);
			Assert.assertEquals(clone.layoutRenderer, renderer);
			Assert.assertEquals(clone.layoutTarget, layoutTarget);
			Assert.assertEquals(clone.displayObject, displayObject);
			Assert.assertEquals(clone.index, 10);
			
		}
	}
}