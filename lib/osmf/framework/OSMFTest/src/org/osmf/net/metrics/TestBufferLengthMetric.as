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
	
	public class TestBufferLengthMetric
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
		public function testBufferLengthMetricInit():void
		{
			metric = new BufferLengthMetric(qosInfoHistory);
			
			assertEquals(MetricType.BUFFER_LENGTH, metric.type);
			var metricValue:MetricValue = metric.value;
			
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);	
		}
		
		[Test]
		public function testBufferLengthMetricGetValue():void
		{
			metric = new BufferLengthMetric(qosInfoHistory);
			assertEquals(MetricType.BUFFER_LENGTH, metric.type);
			
			var metricValue:MetricValue;

			addQoSInfo(generateQoSInfo(1111, 3, 4));			
			metricValue = metric.value;
			assertEquals(3, metricValue.value);
			assertTrue(metricValue.valid);
			
			addQoSInfo(generateQoSInfo(2222, -1, 4));
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
			addQoSInfo(generateQoSInfo(3333, NaN, 4));
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
			addQoSInfo(generateQoSInfo(4444, 0, 4));
			metricValue = metric.value;
			assertEquals(0, metricValue.value);
			assertTrue(metricValue.valid);
			
		}
		
		//helper different from qosinfo tests functions
		
		private function generateQoSInfo(timestamp:Number, bufferLength:Number, bufferTime:Number):QoSInfo
		{
			var v:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 5; i++)
			{
				v[i] = new QualityLevel( i, 150+ 100*i, "test" + (150+ 100*i) );
			}
			return (new QoSInfo(timestamp, 5678+timestamp, v, 2, 2, null, 25, null, null, bufferLength, bufferTime));
		}
		
		//helper identical to qosinfo tests functions
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		private var metric:BufferLengthMetric;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		
	}
}