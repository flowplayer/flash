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
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;
	
	public class TestEmptyBufferInterruptionMetric
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
			netStream = null;
			qosInfoHistory = null;
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
		public function testEmptyBufferInterruptionMetricWhenQoSIsEmpty():void
		{
			metric=new EmptyBufferMetric(qosInfoHistory);
			assertEquals(MetricType.EMPTY_BUFFER, metric.type);
			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
		}
		
		
		[Test]
		public function testEmptyBufferInterruptionMetricForQoSPresent():void
		{
			metric=new EmptyBufferMetric(qosInfoHistory);
			assertEquals(MetricType.EMPTY_BUFFER, metric.type);
			
			addQoSInfo(generateQoSInfo(1111, false));
			//check 1st value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertFalse(metricValue.value);
			assertTrue(metricValue.valid);
			
			addQoSInfo(generateQoSInfo(2222, true));
			//check 2nd value
			metricValue = metric.value;
			assertTrue(metricValue.value);
			assertTrue(metricValue.valid);
			
			addQoSInfo(generateQoSInfo(3333, false));
			//check another value
			metricValue = metric.value;
			assertFalse(metricValue.value);
			assertTrue(metricValue.valid);

		}
		
		//helper different from qosinfo tests functions
		
		private function generateQoSInfo(timestamp:Number, bufferEmpty:Boolean):QoSInfo
		{
			var v:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 3; i++)
			{
				v[i] = new QualityLevel( i, 150+ 100*i, "test" + (150+ 100*i) );
			}
			return (new QoSInfo(timestamp, 5678, v, 2, 2, null, NaN, null, null, NaN, NaN, bufferEmpty ));
		}
		
		//helper identical to qosinfo tests functions
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		
		private var metric:EmptyBufferMetric;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		
	}
}