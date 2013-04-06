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
	import org.flexunit.asserts.assertTrue;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;
	
	public class TestActualBitrateMetric
	{		
		[Before]
		public function setUp():void
		{
			var conn:NetConnection = new NetConnection();
			conn.connect(null);
			netStream = new NetStream(conn);
			qosInfoHistory = new QoSInfoHistory(netStream);
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
		public function testActualBitrateMetric():void
		{
			metric = new ActualBitrateMetric(qosInfoHistory, 5);
			
			assertEquals(MetricType.ACTUAL_BITRATE, metric.type);
			assertEquals(5, metric.maxFragments);
			var metricValue:MetricValue = metric.value;
			
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
		}
		

		[Test(expects="ArgumentError")]
		public function testActualBitrateMetricZeroFragments():void
		{
			metric = new ActualBitrateMetric(qosInfoHistory, 0);
		}
		
		
		[Test]
		public function testGetValueForMoreFragmentsNoSimilarFragmentsOutside():void
		{
			metric = new ActualBitrateMetric(qosInfoHistory, 5);
			assertEquals(MetricType.ACTUAL_BITRATE, metric.type);
			
			addQoSInfo(generateQoSInfo(1111, 0, new FragmentDetails(1400000, 4010, 2001, 0)));
			addQoSInfo(generateQoSInfo(2222, 0, new FragmentDetails(2400000, 4020, 4001, 1)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500000, 4040, 6001, 1)));
			addQoSInfo(generateQoSInfo(4444, 1, new FragmentDetails(4600000, 4030, 8001, 0)));
			addQoSInfo(generateQoSInfo(5555, 0, new FragmentDetails(5400000, 4050, 3001, 1)));
			addQoSInfo(generateQoSInfo(6666, 1, new FragmentDetails(3200000, 4070, 5001, 2)));
			
			
			var metricValue:MetricValue = metric.value;
			
			assertEquals((2400000+3500000+5400000) / (4020+4040+4050)*8/1000, metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		[Test]
		public function testGetValueForMoreFragments():void
		{
			metric = new ActualBitrateMetric(qosInfoHistory, 5);
			assertEquals(MetricType.ACTUAL_BITRATE, metric.type);
			
			addQoSInfo(generateQoSInfo(1111, 0, new FragmentDetails(1400000, 4010, 2001, 0)));
			addQoSInfo(generateQoSInfo(2222, 0, new FragmentDetails(2400000, 4020, 4001, 1)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500000, 4040, 6001, 1)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500001, 4041, 6001, 1)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500002, 4042, 6001, 1)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500003, 4043, 6001, 1)));
			addQoSInfo(generateQoSInfo(4444, 1, new FragmentDetails(4600000, 4030, 8001, 0)));
			addQoSInfo(generateQoSInfo(5555, 0, new FragmentDetails(5400000, 4050, 3001, 1)));
			addQoSInfo(generateQoSInfo(6666, 1, new FragmentDetails(3200000, 4070, 5001, 2)));
			
			
			var metricValue:MetricValue = metric.value;
			
			assertEquals((3500002+3500003+5400000) / (4042+4043+4050)*8/1000, metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		[Test]
		public function testGetValueForLessFragmentsAndShortHistory():void
		{
			metric = new ActualBitrateMetric(qosInfoHistory, 5);
			assertEquals(MetricType.ACTUAL_BITRATE, metric.type);
			
			addQoSInfo(generateQoSInfo(1111, 0, new FragmentDetails(1400000, 4010, 2001, 0)));
			addQoSInfo(generateQoSInfo(2222, 0, new FragmentDetails(2400000, 4020, 4001, 1)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500000, 4040, 6001, 1)));
			
			
			var metricValue:MetricValue = metric.value;
			
			assertEquals((2400000+3500000) / (4020+4040)*8.0/1000, metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		[Test]
		public function testGetValueForIndexNotFound():void
		{
			metric = new ActualBitrateMetric(qosInfoHistory, 5);
			assertEquals(MetricType.ACTUAL_BITRATE, metric.type);
			
			addQoSInfo(generateQoSInfo(1111, 0, new FragmentDetails(1400000, 4010, 2001, 0)));
			addQoSInfo(generateQoSInfo(2222, 0, new FragmentDetails(2400000, 4020, 4001, 1)));
			addQoSInfo(generateQoSInfo(3333, 1, new FragmentDetails(3500000, 4040, 6001, 1)));
			addQoSInfo(generateQoSInfo(4444, 1, new FragmentDetails(4600000, 4030, 8001, 0)));
			addQoSInfo(generateQoSInfo(5555, 0, new FragmentDetails(5400000, 4050, 3001, 1)));
			addQoSInfo(generateQoSInfo(6666, 4, new FragmentDetails(3200000, 4070, 5001, 2)));
			
			
			var metricValue:MetricValue = metric.value;
			
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
		}
		
		
		//helper different from qosinfo tests functions
		
		private function generateQoSInfo(timestamp:Number, currentIndex:Number, fragmentDetails:FragmentDetails):QoSInfo
		{
			var v:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 3; i++)
			{
				v[i] = new QualityLevel( i, 150+ 100*i, "test" + (150+ 100*i) );
			}
			return (new QoSInfo(timestamp, 5678+timestamp, v, currentIndex, currentIndex, fragmentDetails));
		}
		
		//helper identical to qosinfo tests functions
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		private var metric:ActualBitrateMetric;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		
		
		
	}
}