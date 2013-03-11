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
	
	public class TestBufferFragmentsMetric
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
		public function testBufferFragmentsMetricInit():void
		{
			metric = new BufferFragmentsMetric(qosInfoHistory);
			
			assertEquals(MetricType.BUFFER_FRAGMENTS, metric.type);
			var metricValue:MetricValue = metric.value;
			
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);	
		}
		
		[Test]
		public function testBufferFragmentsMetricGetValueBufferLessThanFragmentSum():void
		{
			metric = new BufferFragmentsMetric(qosInfoHistory);
			assertEquals(MetricType.BUFFER_FRAGMENTS, metric.type);
			
			var metricValue:MetricValue;

			addQoSInfo(generateQoSInfo(1111, 8, 4, new FragmentDetails(300000, 4.1 , 2, 0, "streamname")));			
			addQoSInfo(generateQoSInfo(2222, 9, 4, new FragmentDetails(300000, 3.9 , 2, 1, "streamname")));
			addQoSInfo(generateQoSInfo(3333, 9, 4, new FragmentDetails(300000, 4.2 , 2, 1, "streamname")));
			
			metricValue = metric.value;
			assertEquals(2, metricValue.value);
			assertTrue(metricValue.valid);
						
		}
		
		[Test]
		public function testBufferFragmentsMetricGetValueBufferLengthNegative():void
		{
			metric = new BufferFragmentsMetric(qosInfoHistory);
			assertEquals(MetricType.BUFFER_FRAGMENTS, metric.type);
			
			var metricValue:MetricValue;
			
			addQoSInfo(generateQoSInfo(1111, 8, 4, new FragmentDetails(300000, 4.1 , 2, 0, "streamname")));			
			addQoSInfo(generateQoSInfo(2222, 9, 4, new FragmentDetails(300000, 3.9 , 2, 1, "streamname")));
			addQoSInfo(generateQoSInfo(3333, -1, 4, new FragmentDetails(300000, 4.2 , 2, 1, "streamname")));
			
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
		}
		
		[Test]
		public function testBufferFragmentsMetricGetValueBufferLengthNaN():void
		{
			metric = new BufferFragmentsMetric(qosInfoHistory);
			assertEquals(MetricType.BUFFER_FRAGMENTS, metric.type);
			
			var metricValue:MetricValue;
			
			addQoSInfo(generateQoSInfo(1111, 8, 4, new FragmentDetails(300000, 4.1 , 2, 0, "streamname")));			
			addQoSInfo(generateQoSInfo(2222, 9, 4, new FragmentDetails(300000, 3.9 , 2, 1, "streamname")));
			addQoSInfo(generateQoSInfo(3333, NaN, 4, new FragmentDetails(300000, 4.2 , 2, 1, "streamname")));
			
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
		}
		
		
		[Test]
		public function testBufferFragmentsMetricGetValueBufferLengthZero():void
		{
			metric = new BufferFragmentsMetric(qosInfoHistory);
			assertEquals(MetricType.BUFFER_FRAGMENTS, metric.type);
			
			var metricValue:MetricValue;
			
			addQoSInfo(generateQoSInfo(1111, 8, 4, new FragmentDetails(300000, 4.1 , 2, 0, "streamname")));			
			addQoSInfo(generateQoSInfo(2222, 9, 4, new FragmentDetails(300000, 3.9 , 2, 1, "streamname")));
			addQoSInfo(generateQoSInfo(3333, 0, 4, new FragmentDetails(300000, 4.2 , 2, 1, "streamname")));
			
			metricValue = metric.value;
			assertEquals(0, metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		[Test]
		public function testBufferFragmentsMetricGetValueBufferLessThanLastFragment():void
		{
			metric = new BufferFragmentsMetric(qosInfoHistory);
			assertEquals(MetricType.BUFFER_FRAGMENTS, metric.type);
			
			var metricValue:MetricValue;
			
			addQoSInfo(generateQoSInfo(1111, 8, 4, new FragmentDetails(300000, 4.1 , 2, 0, "streamname")));			
			addQoSInfo(generateQoSInfo(2222, 9, 4, new FragmentDetails(300000, 3.9 , 2, 1, "streamname")));
			addQoSInfo(generateQoSInfo(3333, 3, 4, new FragmentDetails(300000, 4.2 , 2, 1, "streamname")));
			
			metricValue = metric.value;
			assertEquals(0, metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		[Test]
		public function testBufferFragmentsMetricGetValueBufferEqualToSumOfFragments():void
		{
			metric = new BufferFragmentsMetric(qosInfoHistory);
			assertEquals(MetricType.BUFFER_FRAGMENTS, metric.type);
			
			var metricValue:MetricValue;
			
			addQoSInfo(generateQoSInfo(1111, 8, 4, new FragmentDetails(300000, 4.1 , 2, 0, "streamname")));			
			addQoSInfo(generateQoSInfo(2222, 9, 4, new FragmentDetails(300000, 3.9 , 2, 1, "streamname")));
			addQoSInfo(generateQoSInfo(3333, 4.2+3.9, 4, new FragmentDetails(300000, 4.2 , 2, 1, "streamname")));
			
			metricValue = metric.value;
			assertEquals(2, metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		
		[Test]
		public function testBufferFragmentsMetricGetValueBufferLongerThanHistory():void
		{
			metric = new BufferFragmentsMetric(qosInfoHistory);
			assertEquals(MetricType.BUFFER_FRAGMENTS, metric.type);
			
			var metricValue:MetricValue;
			
			addQoSInfo(generateQoSInfo(1111, 8, 4, new FragmentDetails(300000, 4.1 , 2, 0, "streamname")));			
			addQoSInfo(generateQoSInfo(2222, 9, 4, new FragmentDetails(300000, 3.9 , 2, 1, "streamname")));
			addQoSInfo(generateQoSInfo(3333, 30, 4, new FragmentDetails(300000, 4.2 , 2, 1, "streamname")));
			
			metricValue = metric.value;
			assertEquals(3, metricValue.value);
			assertTrue(metricValue.valid);
		}
		
		//helper different from qosinfo tests functions
		
		private function generateQoSInfo(timestamp:Number, bufferLength:Number, bufferTime:Number, lastFragmentDetails:FragmentDetails):QoSInfo
		{
			var v:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 5; i++)
			{
				v[i] = new QualityLevel( i, 150+ 100*i, "test" + (150+ 100*i) );
			}
			return (new QoSInfo(timestamp, 5678+timestamp, v, 2, 2, lastFragmentDetails, 25, null, null, bufferLength, bufferTime));
		}
		
		//helper identical to qosinfo tests functions
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		private var metric:BufferFragmentsMetric;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		
	}
}