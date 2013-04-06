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
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;
	
	public class TestMetricBase
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
		public function testValueWhenQoSInfoHistoryIsEmpty():void
		{
			metric = new MetricComplexMocker("test", qosInfoHistory);
			assertEquals("test", metric.type);
			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
		}
		
		[Test(expects="ArgumentError")]
		public function testMetricInitWithNullQoSInfoHistory():void
		{
			metric = new MetricComplexMocker("test", null);
		}
		
		[Test]
		public function testValueWhenQoSInfoHistoryIsPopulated():void
		{
			metric=new MetricComplexMocker("test", qosInfoHistory);
			assertEquals("test", metric.type);
			
			var metricValue:MetricValue;
			metricValue = metric.value;
			
			//check initial value
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
			//add a new item in history, this will force refresh
			addQoSInfo(generateQoSInfo(1111, 150, 250, 350));
			
			metricValue = metric.value;
			assertEquals(1,metricValue.value);
			assertTrue(metricValue.valid);
			
			//add a new item in history, this will force refresh
			addQoSInfo(generateQoSInfo(2222, 151, 251, 351));
			
			metricValue = metric.value;
			assertEquals(2,metricValue.value);
			assertTrue(metricValue.valid);
			
			
			//get the cached value, this will not force refresh
			metricValue = metric.value;
			assertEquals(2,metricValue.value);
			assertTrue(metricValue.valid);
			
		}
		
		[Test]
		public function testValueWhenQoSInfoHistoryIsPopulatedAndFlushed():void
		{
			//create and populate the metric
			metric=new MetricComplexMocker("test", qosInfoHistory);
			assertEquals("test", metric.type);
			
			addQoSInfo(generateQoSInfo(1111, 150, 250, 350));

			var metricValue:MetricValue;
			metricValue = metric.value;
			
			//check initial value
			assertEquals(1, metricValue.value);
			assertTrue(metricValue.valid);
			
			//add a new item in history, this will force refresh
			addQoSInfo(generateQoSInfo(2222, 150, 250, 350));
			
			metricValue = metric.value;
			assertEquals(2, metricValue.value);
			assertTrue(metricValue.valid);
			
			//flush QosInfoHistory
			qosInfoHistory.flush();
			
			//check value, should default to not defined
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
		}
		
		//helper different from qosinfo tests functions
		
		private function generateQoSInfo(timestamp:Number, ... qualityLevels):QoSInfo
		{
			var v:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			for(var i:uint=0; i< qualityLevels.length; i++)
			{
				v[i] = new QualityLevel( i, qualityLevels[i], "test" + qualityLevels[i] );
			}
			return (new QoSInfo(timestamp, 5678, v, 0, 0, new FragmentDetails(14000, 4000, 568, 2)));
		}
		
		//helper identical to qosinfo tests functions
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		private var metric:MetricComplexMocker;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		
		
	}
}