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
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;

	public class TestAvailableQualityLevelsMetric
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
			metric=new AvailableQualityLevelsMetric(qosInfoHistory);
			assertEquals(MetricType.AVAILABLE_QUALITY_LEVELS, metric.type);
			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
		}
		
		[Test]
		public function testValueWhenQoSInfoHistoryIsPopulated():void
		{
			metric=new AvailableQualityLevelsMetric(qosInfoHistory);
			assertEquals(MetricType.AVAILABLE_QUALITY_LEVELS, metric.type);
			
			var metricValue:MetricValue;
			metricValue = metric.value;
			
			//check initial value
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
			addQoSInfo(generateQoSInfo(1111, 150, 250, 350));

			metricValue = metric.value;
			assertTrue(metricValue.valid);
			
			var v:Vector.<QualityLevel> = metricValue.value as Vector.<QualityLevel>;
			assertEquals(3, v.length);
			
			assertEquals(150, v[0].bitrate);
			assertEquals(250, v[1].bitrate);
			assertEquals(350, v[2].bitrate);
			
			assertEquals("test150", v[0].streamName);
			assertEquals("test250", v[1].streamName);
			assertEquals("test350", v[2].streamName);
			
			assertEquals(0, v[0].index);
			assertEquals(1, v[1].index);
			assertEquals(2, v[2].index);
			
			//check the latest value
			addQoSInfo(generateQoSInfo(2222, 151, 251, 351));
			
			metricValue = metric.value;

			v = metricValue.value as Vector.<QualityLevel>;
			assertEquals(3, v.length);
			
			assertEquals(151, v[0].bitrate);
			assertEquals(251, v[1].bitrate);
			assertEquals(351, v[2].bitrate);
			
			assertEquals("test151", v[0].streamName);
			assertEquals("test251", v[1].streamName);
			assertEquals("test351", v[2].streamName);
			
			assertEquals(0, v[0].index);
			assertEquals(1, v[1].index);
			assertEquals(2, v[2].index);
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
		
		private var metric:AvailableQualityLevelsMetric;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
	}
}