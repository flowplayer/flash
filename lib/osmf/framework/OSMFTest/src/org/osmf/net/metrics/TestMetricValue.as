/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net.metrics
{
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	
	public class TestMetricValue
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
		public function testMetricValueNumber():void
		{
			metricValue = new MetricValue(101.3456);
			assertEquals(101.3456, metricValue.value);
			assertEquals(true, metricValue.valid);
		}
		
		[Test]
		public function testMetricValueString():void
		{
			metricValue = new MetricValue("testvalue");
			assertEquals("testvalue", metricValue.value);
			assertEquals(true, metricValue.valid);
		}
		
		[Test]
		public function testMetricValueNull():void
		{
			metricValue = new MetricValue(null);
			assertNull(metricValue.value);
			assertEquals(true, metricValue.valid);
		}
		
		[Test]
		public function testMetricValueBool():void
		{
			metricValue = new MetricValue(true);
			assertTrue(metricValue.value);
			assertEquals(true, metricValue.valid);
		}
		
		[Test]
		public function testMetricValueUndefined():void
		{
			metricValue = new MetricValue(undefined);
			assertEquals(undefined, metricValue.value);
		}
		
		[Test]
		public function testMetricValidityValid():void
		{
			metricValue = new MetricValue(10, true);
			assertEquals(10,metricValue.value);
			assertTrue(metricValue.valid);
		}
		[Test]
		public function testMetricValidityInvalid():void
		{
			metricValue = new MetricValue(11, false);
			assertEquals(11, metricValue.value);
			assertFalse(metricValue.valid);
		}
		
		private var metricValue:MetricValue;
	}
}