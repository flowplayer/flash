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
	import flash.utils.getTimer;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.events.TimeEvent;
	
	public class TestMetricRepository
	{
		[Before]
		public function setUp():void
		{
			metricRepository = new MetricRepository(new MetricFactoryMocker());
			
			metric1Value = new MetricValue("metric1value", true);
			metric2Value = new MetricValue("metric2value", true);
		}
		
		[After]
		public function tearDown():void
		{
			metricRepository = null;
		}
		
		/**
		 * Tests that the getMetric function returns the desired metric (type and params)
		 */
		[Test]
		public function testGetMetric():void
		{
			var metric:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value) as MetricMocker;
			
			assertNotNull(metric);
			assertEquals(metric.type, METRIC_TYPE_1);
			assertEquals(metric.value, metric1Value);
		}
		
		/**
		 * Tests that the getMetric returns correct init error 
		 */
		[Test(expects="ArgumentError")]
		public function testInitMetricRepository():void
		{
			metricRepository = new MetricRepository(null);
		}
		
		/**
		 * Tests that the same object is returned if we request the same metric type with the same params
		 * twice (no duplication of objects)
		 */
		[Test]
		public function testGetMetricNoDuplication():void
		{
			//create complex parameter
			var v:Vector.<MetricValue> = new Vector.<MetricValue>();
			v[0] = metric1Value;
			v[1] = metric2Value;
			
			var metric1:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, v) as MetricMocker;
			var metric1bis:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, v) as MetricMocker;
			
			assertNotNull(metric1);
			assertNotNull(metric1bis);
			assertStrictlyEquals(metric1, metric1bis);
		}
		
		/**
		 * Tests that the same object is returned if we request the same metric type with the same params
		 * twice (no duplication of objects)
		 */
		[Test]
		public function testGetMetricNoDuplicationDifferentObjects():void
		{
			//create complex parameter
			var v:Vector.<MetricValue> = new Vector.<MetricValue>();
			v.push(metric1Value);
			v.push(metric2Value);
			var u:Vector.<MetricValue> = new Vector.<MetricValue>();
			u.push(metric1Value);
			u.push(metric2Value);
			
			var metric1:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, v) as MetricMocker;
			var metric1bis:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, u) as MetricMocker;
			
			assertNotNull(metric1);
			assertNotNull(metric1bis);
			assertStrictlyEquals(metric1, metric1bis);
		}
		
		/**
		 * Tests that two different objects are returned if we request 2 metrics with the same
		 * type, but with different params
		 */
		[Test]
		public function testGetMetricSameTypeDifferentParams():void
		{
			//create complex parameter
			var v:Vector.<MetricValue> = new Vector.<MetricValue>();
			v.push(metric1Value);
			v.push(metric2Value);
			
			var metric1:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, v) as MetricMocker;
			var metric2:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric2Value, v) as MetricMocker;
			
			assertNotNull(metric1);
			assertNotNull(metric2);
			assertTrue(metric1 != metric2);
		}
		
		/**
		 * Tests that two different objects are returned if we request 2 metrics with the same
		 * type, but with different params
		 */
		[Test]
		public function testGetMetricSameTypeDifferentParamsComplex():void
		{
			//create complex parameter
			var v:Vector.<MetricValue> = new Vector.<MetricValue>();
			v.push(metric1Value);
			v.push(metric2Value);
			var u:Vector.<MetricValue> = new Vector.<MetricValue>();
			u.push(metric1Value);
			u.push(metric1Value);
			
			var a:Array = new Array();
			a.push(u);
			a.push(metric1Value);
			
			var metric1:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, u) as MetricMocker;
			var metric2:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, v) as MetricMocker;
			
			assertNotNull(metric1);
			assertNotNull(metric2);
			assertTrue(metric1 != metric2);
		}
		
		/**
		 * Tests that two different objects are returned if we request 2 metrics with the same
		 * type, but with different params
		 */
		[Test]
		public function testGetMetricSameTypeDifferentParamsComplexArray():void
		{
			//create complex parameter
			var u:Vector.<MetricValue> = new Vector.<MetricValue>();
			u.push(metric1Value);
			u.push(metric1Value);
			
			var a:Array = new Array();
			
			a.push(u);			
			a.push(metric1Value);
			
			
			var metric1:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, u, a) as MetricMocker;
			
			//modify array by changing the vector inside 
			u = new Vector.<MetricValue>();
			a = new Array();
			u.push(metric1Value);
			u.push(metric2Value);
			a.push(u);			
			a.push(metric1Value);
			
			var metric2:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, u, a) as MetricMocker;
			
			assertNotNull(metric1);
			assertNotNull(metric2);
			assertTrue(metric1 != metric2);
		}
		
		/**
		 * Tests that two different objects are returned if we request 2 metrics with the same
		 * type, and with same params
		 */
		[Test]
		public function testGetMetricSameTypeSameParamsComplex():void
		{
			//create complex parameter
			var v:Vector.<MetricValue> = new Vector.<MetricValue>();
			v.push(metric1Value);
			v.push(metric2Value);
			var u:Vector.<MetricValue> = new Vector.<MetricValue>();
			u.push(metric1Value);
			u.push(metric2Value);
			
			var metric1:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, u) as MetricMocker;
			var metric2:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, metric1Value, v) as MetricMocker;
			
			assertNotNull(metric1);
			assertNotNull(metric2);
			assertStrictlyEquals(metric1, metric2);
		}
		
		/**
		 * Tests that two different objects are returned if we request 2 metrics with the same
		 * type, and with null parameters
		 */
		[Test]
		public function testGetMetricSameTypeSameParamsNull():void
		{	
			var metric1:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, null, null) as MetricMocker;
			var metric2:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, null, null) as MetricMocker;
			
			assertNotNull(metric1);
			assertNotNull(metric2);
			assertStrictlyEquals(metric1, metric2);
		}
		
		/**
		 * Tests that two different objects are returned if we request 2 metrics with the same
		 * type, and with different and null parameters
		 */
		[Test]
		public function testGetMetricSameTypeDifferentParamsNull():void
		{	
			var metric1:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, null, 3) as MetricMocker;
			var metric2:MetricMocker = metricRepository.getMetric(METRIC_TYPE_1, null, 4) as MetricMocker;
			
			assertNotNull(metric1);
			assertNotNull(metric2);
			assertTrue(metric1 != metric2);
		}
				
		private var metricRepository:MetricRepository;
		
		private static const METRIC_TYPE_1:String = "com.example.metrics.sample";
		private static const MAX_RETRIEVING_TIME:int=1;
		private static const MAX_CREATING_TIME:int=4;
		
		private var metric1Value:MetricValue;
		private var metric2Value:MetricValue;
	}
}