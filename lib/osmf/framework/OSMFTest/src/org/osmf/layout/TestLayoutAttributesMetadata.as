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
	
	import org.osmf.layout.ScaleMode;
	import org.osmf.events.MetadataEvent;
	import org.osmf.metadata.NullMetadataSynthesizer;
	
	public class TestLayoutAttributesMetadata
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
		public function testChangeEventVerticalAlign():void
		{
			var lastEvent:MetadataEvent;
			var eventCounter:int = 0;
			
			function onMetadataChange(event:MetadataEvent):void
			{
				lastEvent = event;
				eventCounter++;
			}
			
			var metadata:LayoutAttributesMetadata = new LayoutAttributesMetadata();
			metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
			
			metadata.verticalAlign = VerticalAlign.BOTTOM;
			
			Assert.assertEquals(1, eventCounter);
			Assert.assertEquals(LayoutAttributesMetadata.VERTICAL_ALIGN, lastEvent.key);
			Assert.assertEquals(null, lastEvent.oldValue);
			Assert.assertEquals(VerticalAlign.BOTTOM, lastEvent.value);
			Assert.assertEquals(metadata.verticalAlign, metadata.getValue(LayoutAttributesMetadata.VERTICAL_ALIGN), VerticalAlign.BOTTOM);
		}
		
		[Test]
		public function testChangeEventHorizontalAlign():void
		{
			var lastEvent:MetadataEvent;
			var eventCounter:int = 0;
			
			function onMetadataChange(event:MetadataEvent):void
			{
				lastEvent = event;
				eventCounter++;
			}
			
			var metadata:LayoutAttributesMetadata = new LayoutAttributesMetadata();
			metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
			
			metadata.horizontalAlign = HorizontalAlign.RIGHT;
			
			Assert.assertEquals(1, eventCounter);
			Assert.assertEquals(LayoutAttributesMetadata.HORIZONTAL_ALIGN, lastEvent.key);
			Assert.assertEquals(null, lastEvent.oldValue);
			Assert.assertEquals(HorizontalAlign.RIGHT, lastEvent.value);
			Assert.assertEquals(metadata.horizontalAlign, metadata.getValue(LayoutAttributesMetadata.HORIZONTAL_ALIGN), HorizontalAlign.RIGHT);
		}
		
		[Test]
		public function testChangeEventSnapToPixel():void
		{
			var lastEvent:MetadataEvent;
			var eventCounter:int = 0;
			
			function onMetadataChange(event:MetadataEvent):void
			{
				lastEvent = event;
				eventCounter++;
			}
			
			var metadata:LayoutAttributesMetadata = new LayoutAttributesMetadata();
			metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
			
			metadata.snapToPixel = false;
			
			Assert.assertEquals(1, eventCounter);
			Assert.assertEquals(LayoutAttributesMetadata.SNAP_TO_PIXEL, lastEvent.key);
			Assert.assertEquals(true, lastEvent.oldValue);
			Assert.assertEquals(false, lastEvent.value);
			Assert.assertEquals(metadata.snapToPixel, metadata.getValue(LayoutAttributesMetadata.SNAP_TO_PIXEL), false);
		}
		
		[Test]
		public function testChangeEventScaleMode():void
		{
			var lastEvent:MetadataEvent;
			var eventCounter:int = 0;
			
			function onMetadataChange(event:MetadataEvent):void
			{
				lastEvent = event;
				eventCounter++;
			}
			
			var metadata:LayoutAttributesMetadata = new LayoutAttributesMetadata();
			metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
			
			metadata.scaleMode = ScaleMode.LETTERBOX;
			
			Assert.assertEquals(1, eventCounter);
			Assert.assertEquals(LayoutAttributesMetadata.SCALE_MODE, lastEvent.key);
			Assert.assertEquals(null, lastEvent.oldValue);
			Assert.assertEquals(ScaleMode.LETTERBOX, lastEvent.value);
			Assert.assertEquals(metadata.scaleMode, metadata.getValue(LayoutAttributesMetadata.SCALE_MODE), ScaleMode.LETTERBOX);
		}
		
		[Test]
		public function testUndefinedGetValue():void
		{
			var metadata:LayoutAttributesMetadata = new LayoutAttributesMetadata();
			
			Assert.assertEquals(undefined, metadata.getValue(null));
			Assert.assertEquals(undefined, metadata.getValue("@*#$^98367423874"));
		}
		
		[Test]
		public function testSynthesizerMetadata():void
		{			
			var metadata:LayoutAttributesMetadata = new LayoutAttributesMetadata();
			
			Assert.assertTrue(metadata.synthesizer is NullMetadataSynthesizer);
		}
	}
}