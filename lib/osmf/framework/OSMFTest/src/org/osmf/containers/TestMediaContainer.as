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
package org.osmf.containers
{
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	
	import org.flexunit.Assert;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutRenderer;
	import org.osmf.layout.LayoutRendererBase;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.TesterSprite;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.DynamicMediaElement;

	public class TestMediaContainer
	{
		public function constructContainer(renderer:LayoutRendererBase=null):MediaContainer
		{
			return new MediaContainer(renderer);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function testAddChildNull():void
		{
			var container:MediaContainer = constructContainer();
			container.addChild(null);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function testAddChildAtNull():void
		{
			var container:MediaContainer = constructContainer();
			container.addChildAt(null, 0);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function testRemoveChildNull():void
		{
			var container:MediaContainer = constructContainer();
			container.removeChild(null);
		}
		
		[Test(expects="RangeError")]
		public function testRemoveChildAtNull():void
		{
			var container:MediaContainer = constructContainer();
			container.removeChildAt(0);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function testSetChildIndexNull():void
		{
			var container:MediaContainer = constructContainer();
			container.setChildIndex(null,0);
		}
		
		[Test]
		public function testContainerMediaElements():void
		{
			var renderer:LayoutRenderer = new LayoutRenderer();
			var parent:MediaContainer = constructContainer(renderer);
			parent.backgroundColor = 0xff0000;
			parent.backgroundAlpha = 1;
			parent.clipChildren = true;
			
			myAssertThrows(parent.addMediaElement,null);
			
			var element1:DynamicMediaElement = new DynamicMediaElement();
			var element2:DynamicMediaElement = new DynamicMediaElement();
			
			Assert.assertNotNull(parent);
			Assert.assertFalse(parent.containsMediaElement(element1));
			Assert.assertFalse(parent.containsMediaElement(element2));
			
			parent.addMediaElement(element1);
			Assert.assertTrue(parent.containsMediaElement(element1));
			
			myAssertThrows(parent.addMediaElement,element1);
			
			parent.addMediaElement(element2);
			Assert.assertTrue(parent.containsMediaElement(element2));
			
			Assert.assertTrue(element1 == parent.removeMediaElement(element1));
			Assert.assertFalse(parent.containsMediaElement(element1));
			
			var c2:MediaContainer = constructContainer();
			c2.addMediaElement(element2);
			
			Assert.assertFalse(parent.containsMediaElement(element2));
			
			var error:Error;
			try
			{
				parent.removeMediaElement(element1);
			}
			catch(e:Error)
			{
				error = e;
			}
			
			Assert.assertNotNull(error);
			Assert.assertTrue(error is IllegalOperationError);
			
			myAssertThrows(parent.removeMediaElement, null);
		}
		
		
		[Test]
		public function testContainerScaleAndAlign():void
		{
			// Child
			
			var mediaElement:DynamicMediaElement = new DynamicMediaElement();
			
			var viewSprite:Sprite = new TesterSprite();
			var viewTrait:DisplayObjectTrait = new DisplayObjectTrait(viewSprite, 486, 60);
			mediaElement.doAddTrait(MediaTraitType.DISPLAY_OBJECT, viewTrait);
			var layout:LayoutMetadata = new LayoutMetadata();
			mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
			layout.scaleMode = ScaleMode.NONE;
			layout.verticalAlign = VerticalAlign.MIDDLE;
			layout.horizontalAlign = HorizontalAlign.CENTER;
			
			var container:MediaContainer = constructContainer();
			container.width = 800;
			container.height = 80;
			
			container.addMediaElement(mediaElement);
			
			container.validateNow();
			
			Assert.assertEquals(486, viewSprite.width);
			Assert.assertEquals(60, viewSprite.height);
			
			Assert.assertEquals(800/2 - 486/2, viewSprite.x);
			Assert.assertEquals(80/2 - 60/2, viewSprite.y);
		}
		
		[Test]
		public function testContainerAttributes():void
		{
			var container:MediaContainer = constructContainer();
			container.width = 500;
			container.height = 400;
			
			Assert.assertTrue(isNaN(container.backgroundColor));
			Assert.assertTrue(isNaN(container.backgroundAlpha));
			
			container.backgroundColor = 0xFF00FF;
			Assert.assertEquals(0xFF00FF, container.backgroundColor);
			
			container.backgroundColor = 0xFF00FF;
			Assert.assertEquals(0xFF00FF, container.backgroundColor);
			
			container.backgroundAlpha = 0.5;
			Assert.assertEquals(0.5, container.backgroundAlpha);
			
			container.backgroundAlpha = 0.5;
			Assert.assertEquals(0.5, container.backgroundAlpha);
			
			Assert.assertFalse(container.clipChildren);
			container.clipChildren = true;
			Assert.assertTrue(container.clipChildren);
			
			container.clipChildren = true;
			Assert.assertTrue(container.clipChildren);
			
			container.clipChildren = false;
			Assert.assertFalse(container.clipChildren);
			
			container.validateNow();
			Assert.assertEquals(500, container.width);
			Assert.assertEquals(400, container.height);
		}
		
		[Test]
		public function testConstructor():void
		{
			var renderer:LayoutRenderer = new LayoutRenderer();
			var container:MediaContainer = constructContainer(renderer);
			Assert.assertEquals(renderer, container.layoutRenderer);
			
			var container2:MediaContainer = new MediaContainer();
			Assert.assertNotNull(container2.layoutRenderer);
		}
		
		private function myAssertThrows(f:Function, ...arguments):*
		{
			var result:*;
			
			try
			{
				result = f.apply(null,arguments);
				Assert.fail();
			}
			catch(e:Error)
			{	
			}
			
			return result;
		}
	}
}