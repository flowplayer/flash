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
	import org.flexunit.Assert;
	
	import org.osmf.events.MetadataEvent;
	import org.osmf.metadata.NullMetadataSynthesizer;
	
	public class TestBoxAttributesMetadata
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
		public function testChangeEventForAbsoluteSum():void
		{
			var lastEvent:MetadataEvent;
			var eventCounter:int = 0;
			
			function onMetadataChange(event:MetadataEvent):void
			{
				lastEvent = event;
				eventCounter++;
			}
			
			var metadata:BoxAttributesMetadata = new BoxAttributesMetadata();
			metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
			
			metadata.absoluteSum = 1;
			
			Assert.assertEquals(1, eventCounter);
			Assert.assertEquals(BoxAttributesMetadata.ABSOLUTE_SUM, lastEvent.key);
			Assert.assertEquals(0, lastEvent.oldValue);
			Assert.assertEquals(1, lastEvent.value);
			Assert.assertEquals(metadata.absoluteSum, metadata.getValue(BoxAttributesMetadata.ABSOLUTE_SUM), 1);
			
			metadata.absoluteSum = 1;
			Assert.assertEquals(metadata.absoluteSum, metadata.getValue(BoxAttributesMetadata.ABSOLUTE_SUM), 1);
		}
		
		[Test]
		public function testChangeEventForRelativeSum():void
		{
			var lastEvent:MetadataEvent;
			var eventCounter:int = 0;
			
			function onMetadataChange(event:MetadataEvent):void
			{
				lastEvent = event;
				eventCounter++;
			}
			
			var metadata:BoxAttributesMetadata = new BoxAttributesMetadata();
			metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
			metadata.relativeSum = 2;
			
			Assert.assertEquals(1, eventCounter);
			Assert.assertEquals(BoxAttributesMetadata.RELATIVE_SUM, lastEvent.key);
			Assert.assertEquals(0, lastEvent.oldValue);
			Assert.assertEquals(2, lastEvent.value);
			Assert.assertEquals(metadata.relativeSum, metadata.getValue(BoxAttributesMetadata.RELATIVE_SUM), 2);
			
			metadata.relativeSum = 2;
			Assert.assertEquals(metadata.relativeSum, metadata.getValue(BoxAttributesMetadata.RELATIVE_SUM), 2);
		}
		
		[Test]
		public function testUndefinedGetValue():void
		{			
			var metadata:BoxAttributesMetadata = new BoxAttributesMetadata();	
			
			Assert.assertEquals(undefined, metadata.getValue(null));
			Assert.assertEquals(undefined, metadata.getValue("@*#$^98367423874"));
		}
		
		[Test]
		public function testSynthesizerMetadata():void
		{			
			var metadata:BoxAttributesMetadata = new BoxAttributesMetadata();
			
			Assert.assertTrue(metadata.synthesizer is NullMetadataSynthesizer);
		}
	}
}