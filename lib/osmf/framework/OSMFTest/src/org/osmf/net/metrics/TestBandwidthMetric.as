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
	
	import flashx.textLayout.debug.assert;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;
	
	public class TestBandwidthMetric
	{		
		[Before]
		public function setUp():void
		{
			var conn:NetConnection = new NetConnection();
			conn.connect(null);
			netStream = new NetStream(conn);
			qosInfoHistory = new QoSInfoHistory(netStream, 4);
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
		public function testBandwidthMetricWhenQoSInfoHistoryIsEmpty():void
		{
			metric=new BandwidthMetric(qosInfoHistory, generateWeights(0.5, 0.5) );
			assertEquals(MetricType.BANDWIDTH, metric.type);
			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
		}
		
		[Test(expects="ArgumentError")]
		public function testBandwidthMetricWhenQoSInfoHistoryIsNull():void
		{
			metric=new BandwidthMetric(null, generateWeights(0.5, 0.5) );
		}
		
		[Test]
		public function testBandwidthMetricWhenQoSInfoHistoryIsFilledWithMoreValues():void
		{
			metric=new BandwidthMetric(qosInfoHistory, generateWeights(0.6, 0.4) );
			assertEquals(MetricType.BANDWIDTH, metric.type);
			
			addQoSInfo(generateQoSInfo(1111, 0, new FragmentDetails(1400000, 4010, 2001, 0)));
			addQoSInfo(generateQoSInfo(2222, 0, new FragmentDetails(2400000, 4020, 4001, 0)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500000, 4040, 6001, 1)));

			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals((3500000 / 6001.0 * 0.6 + 2400000 / 4001.0 * 0.4 ) / (0.6 + 0.4), metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		[Test]
		public function testBandwidthMetricWhenQoSInfoHistoryIsFilledWithLessValues():void
		{
			metric=new BandwidthMetric(qosInfoHistory, generateWeights(0.6, 0.4, 0.3) );
			assertEquals(MetricType.BANDWIDTH, metric.type);
			
			addQoSInfo(generateQoSInfo(1111, 0, new FragmentDetails(1400000, 4010, 2001, 0)));
			addQoSInfo(generateQoSInfo(2222, 0, new FragmentDetails(2400000, 4020, 4001, 0)));
			
			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals( (2400000 / 4001.0 * 0.6 + 1400000 / 2001.0 * 0.4) / (0.6 + 0.4), metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		[Test]
		public function testBandwidthMetricWithZeroWeight():void
		{
			metric=new BandwidthMetric(qosInfoHistory, generateWeights(0.0, 0.4) );
			assertEquals(MetricType.BANDWIDTH, metric.type);
			
			addQoSInfo(generateQoSInfo(1111, 0, new FragmentDetails(1400000, 4010, 2001, 0)));
			addQoSInfo(generateQoSInfo(2222, 0, new FragmentDetails(2400000, 4020, 4001, 0)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500000, 4040, 6001, 1)));
			
			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals((3500000 / 6001.0 * 0.0 + 2400000 / 4001.0 * 0.4 ) / (0.0 + 0.4), metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		
		[Test(expects="ArgumentError")]
		public function testBandwidthMetricWithAllZeroWeight():void
		{
			metric=new BandwidthMetric(qosInfoHistory, generateWeights(0.0, 0.0) );

		}
		
		[Test(expects="ArgumentError")]
		public function testBandwidthMetricWithNegativeWeight():void
		{
			metric=new BandwidthMetric(qosInfoHistory, generateWeights(-1.0, 0.4) );
		}
		
		[Test(expects="ArgumentError")]
		public function testBandwidthMetricWithNullWeight():void
		{
			metric=new BandwidthMetric(qosInfoHistory, null );
		}
		
		[Test]
		public function testGet_weights():void
		{
			metric=new BandwidthMetric(qosInfoHistory, generateWeights(0.01, 0.4, 0.3) );
			var v:Vector.<Number> = metric.weights;
			assertNotNull(v);
			assertEquals(3, v.length);
			assertEquals(0.01, v[0]);
			assertEquals(0.4, v[1]);
			assertEquals(0.3, v[2]);
		}
		
		[Test]
		public function testMetricGetType():void
		{
			metric=new BandwidthMetric(qosInfoHistory, generateWeights(1) );
			assertEquals(MetricType.BANDWIDTH, metric.type);
		}
		
		//helper different from qosinfo tests functions
		
		private function generateQoSInfo(timestamp:Number, currentBitrate:Number, fragmentDetails:FragmentDetails):QoSInfo
		{
			var v:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 3; i++)
			{
				v[i] = new QualityLevel( i, 150+ 100*i, "test" + (150+ 100*i) );
			}
			return (new QoSInfo(timestamp, 5678, v, currentBitrate, currentBitrate, fragmentDetails ));
		}
		
		//helper identical to qosinfo tests functions
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		
		private function generateWeights(... weights):Vector.<Number>
		{
			var v:Vector.<Number> = new Vector.<Number>();
			for(var i:uint=0; i< weights.length; i++)
			{
				v[i] = weights[i] ;
			}
			return (v);
		}
		
		private var metric:BandwidthMetric;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		
	}
}