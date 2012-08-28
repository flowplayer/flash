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
	import flash.display.Sprite;
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	
	import org.osmf.elements.ParallelElement;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.DynamicDisplayObjectTrait;
	import org.osmf.utils.DynamicMediaElement;
	
	public class TestMediaElementLayoutTarget
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
		public function testMediaElementLayoutTarget():void
		{
			Assert.assertTrue(throws(function():void{MediaElementLayoutTarget.getInstance(null);}));
			
			var me:MediaElement = new MediaElement();
			var melt:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(me);
			
			melt.measure();
			
			Assert.assertNull(melt.displayObject);
			Assert.assertNotNull(melt.layoutMetadata);
			Assert.assertEquals(melt.layoutMetadata, me.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata);
			Assert.assertEquals(NaN, melt.measuredWidth);
			Assert.assertEquals(NaN, melt.measuredHeight);
			
			var lmd:LayoutMetadata = new LayoutMetadata();
			me.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, lmd);
			Assert.assertEquals(lmd, melt.layoutMetadata);
			
			var md:Metadata = new Metadata();
			me.addMetadata("test", md);
			
			me.removeMetadata("test");
			me.removeMetadata(LayoutMetadata.LAYOUT_NAMESPACE);
			Assert.assertFalse(melt.layoutMetadata == lmd);
		}
		
		[Test]
		public function testCompositeElement():void
		{
			var p:ParallelElement = new ParallelElement();
			var melt:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(p);
			
			var me:DynamicMediaElement = new DynamicMediaElement();
			var lts:LayoutTargetSprite = new LayoutTargetSprite(me.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata);
			var displayObjectTrait:DynamicDisplayObjectTrait = new DynamicDisplayObjectTrait(lts, 100, 200);
			me.doAddTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);
			
			melt.dispatchEvent
				( new LayoutTargetEvent
					( LayoutTargetEvent.ADD_CHILD_AT
					)
				);
			
			melt.dispatchEvent
				( new LayoutTargetEvent
					( LayoutTargetEvent.REMOVE_CHILD
					)
				);
			
			melt.dispatchEvent
				( new LayoutTargetEvent
					( LayoutTargetEvent.SET_CHILD_INDEX
					)
				);
		}
		
		[Test]
		public function testMediaElementLayoutTargetWithDisplayObjectTrait():void
		{
			var me:DynamicMediaElement = new DynamicMediaElement();
			
			var lt:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(me);
			
			var lts:LayoutTargetSprite = new LayoutTargetSprite(me.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata);
			var displayObjectTrait:DynamicDisplayObjectTrait = new DynamicDisplayObjectTrait(lts, 100, 200);
			me.doAddTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);
			
			lt.measure();
			
			Assert.assertEquals(lt.layoutMetadata, me.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata);
			Assert.assertEquals(lt.displayObject, lts);
			Assert.assertEquals(lt.measuredWidth, 100);
			Assert.assertEquals(lt.measuredHeight, 200); 
			
			var renderer:LayoutRendererBase = new LayoutRenderer();
			renderer.container = lts;
			
			var lastEvent:Event;
			var eventCounter:int = 0;
			
			function onEvent(event:Event):void
			{
				lastEvent = event;
				eventCounter++;
			}
			
			lt.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onEvent);
			lt.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onEvent);
			
			var sprite2:Sprite = new Sprite();
			displayObjectTrait.displayObject = sprite2;
			
			Assert.assertEquals(1, eventCounter);
			var vce:DisplayObjectEvent = lastEvent as DisplayObjectEvent;
			Assert.assertNotNull(vce);
			Assert.assertEquals(vce.oldDisplayObject, lts);
			Assert.assertEquals(vce.newDisplayObject, sprite2);
			
			displayObjectTrait.setSize(300,400);
			
			Assert.assertEquals(2, eventCounter);
			var dce:DisplayObjectEvent = lastEvent as DisplayObjectEvent;
			Assert.assertNotNull(dce);
			Assert.assertEquals(dce.oldWidth, 100);
			Assert.assertEquals(dce.oldHeight, 200);
			Assert.assertEquals(dce.newWidth, 300);
			Assert.assertEquals(dce.newHeight, 400);
		}
		
		[Test]
		public function testSingletonConstruction():void
		{
			var mediaElement:MediaElement = new MediaElement();
			
			var check:Boolean;
			try
			{
				new MediaElementLayoutTarget(null,null);
			}
			catch(e:Error)
			{
				check = true;
			}
			
			Assert.assertTrue(check);
			
			var melt:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(mediaElement);
			
			Assert.assertNotNull(melt);
			
			Assert.assertEquals(melt, MediaElementLayoutTarget.getInstance(mediaElement));
			Assert.assertEquals(melt, MediaElementLayoutTarget.getInstance(mediaElement));
		}
		
		private function throws(f:Function):Boolean
		{
			var result:Boolean;
			
			try
			{
				f();
			}
			catch(e:Error)
			{
				result = true;
			}
			
			return result;
		}
	}
}