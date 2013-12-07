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
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.net.ABRTestUtils;
	import org.osmf.net.qos.QoSInfoHistory;

	public class TestDefaultMetricFactory
	{
		[Before]
		public function setUp():void
		{
			var conn:NetConnection = new NetConnection();
			conn.connect(null);
			var ns:NetStream = new NetStream(conn);
			var qosInfoHistory:QoSInfoHistory = new QoSInfoHistory(ns);
			factory = new DefaultMetricFactory(qosInfoHistory);
		}
		
		[After]
		public function tearDown():void
		{
			factory = null;
		}
		
		[Test]
		public function testBuildMetricsInit():void
		{
			assertEquals(12, factory.numItems);
			assertEquals(12, factory.getItems().length);
			
			assertTrue(factory.buildMetric(MetricType.ACTUAL_BITRATE, 10) is ActualBitrateMetric);
			
			assertTrue(factory.buildMetric(MetricType.FRAGMENT_COUNT) is FragmentCountMetric);
			
			assertTrue(factory.buildMetric(MetricType.AVAILABLE_QUALITY_LEVELS) is AvailableQualityLevelsMetric);
			
			var weights:Vector.<Number> = new Vector.<Number>();
			weights.push(0.8);
			weights.push(0.2);
			assertTrue(factory.buildMetric(MetricType.BANDWIDTH, weights) is BandwidthMetric);
			
			assertTrue(factory.buildMetric(MetricType.FPS) is FPSMetric);
			
			assertTrue(factory.buildMetric(MetricType.DROPPED_FPS) is DroppedFPSMetric);
			
			assertTrue(factory.buildMetric(MetricType.CURRENT_STATUS) is CurrentStatusMetric);
			
			assertTrue(factory.buildMetric(MetricType.BUFFER_LENGTH) is BufferLengthMetric);
			
			assertTrue(factory.buildMetric(MetricType.BUFFER_OCCUPATION_RATIO) is BufferOccupationRatioMetric);
			
			assertTrue(factory.buildMetric(MetricType.BUFFER_FRAGMENTS) is BufferFragmentsMetric);
			
			assertTrue(factory.buildMetric(MetricType.EMPTY_BUFFER) is EmptyBufferMetric);
			
			assertTrue(factory.buildMetric(MetricType.RECENT_SWITCH) is RecentSwitchMetric);
		}
		
		[Test]
		public function testBuildActualBitrateMetric():void
		{
			var metric:ActualBitrateMetric = factory.buildMetric(MetricType.ACTUAL_BITRATE, 4) as ActualBitrateMetric;
			
			assertNotNull(metric);
			assertEquals(metric.maxFragments, 4);			
		}
		
		[Test]
		public function testBuildBandwidthMetric():void
		{
			var weights:Vector.<Number> = new Vector.<Number>();
			weights.push(4);
			weights.push(3);
			weights.push(1);
			
			var metric:BandwidthMetric = factory.buildMetric(MetricType.BANDWIDTH, weights) as BandwidthMetric;
			
			assertNotNull(metric);
			assertTrue(ABRTestUtils.equalNumberVectors(metric.weights, weights));
		}
		
		private var factory:MetricFactory;
		
		private static const MAX_FRAGMENTS:Number = 10;
	}
}
