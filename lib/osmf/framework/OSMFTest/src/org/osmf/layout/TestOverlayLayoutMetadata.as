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
	
	import org.osmf.events.MetadataEvent;
	import org.osmf.layout.ScaleMode;
	import org.osmf.metadata.NullMetadataSynthesizer;
	
	public class TestOverlayLayoutMetadata
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
		public function testChangeEventForIndex():void
		{
			var lastEvent:MetadataEvent;
			var eventCounter:int = 0;
			
			function onMetadataChange(event:MetadataEvent):void
			{
				lastEvent = event;
				eventCounter++;
			}
			
			var metadata:OverlayLayoutMetadata = new OverlayLayoutMetadata();
			metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
			
			metadata.index = 2;
			
			Assert.assertEquals(1, eventCounter);
			Assert.assertEquals(OverlayLayoutMetadata.INDEX, lastEvent.key);
			Assert.assertEquals(NaN, lastEvent.oldValue);
			Assert.assertEquals(2, lastEvent.value);
			Assert.assertEquals(metadata.index, metadata.getValue(OverlayLayoutMetadata.INDEX), 2);
			
		}
		
		[Test]
		public function testUndefinedGetValue():void
		{
			var metadata:OverlayLayoutMetadata = new OverlayLayoutMetadata();
			
			Assert.assertEquals(undefined, metadata.getValue(null));
			Assert.assertEquals(undefined, metadata.getValue("@*#$^98367423874"));
		}
		
		[Test]
		public function testSynthesizerMetadata():void
		{
			var metadata:OverlayLayoutMetadata = new OverlayLayoutMetadata();
			
			Assert.assertTrue(metadata.synthesizer is NullMetadataSynthesizer);
		}
	}
}