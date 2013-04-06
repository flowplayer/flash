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
	import org.osmf.net.qos.PlaybackDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;

	public class TestDroppedFPSMetric
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
			metric=new DroppedFPSMetric(qosInfoHistory);
			assertEquals(MetricType.DROPPED_FPS, metric.type);
			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			assertEquals(10, metric.desiredSampleLength);
			
		}
		
		
		[Test(expects="ArgumentError")]
		public function testDesiredSampleLengthNegativeValue():void
		{
			metric=new DroppedFPSMetric(qosInfoHistory, -1);	
		}
		
		[Test(expects="ArgumentError")]
		public function testDesiredSampleLengthNaN():void
		{
			metric=new DroppedFPSMetric(qosInfoHistory, NaN);	
		}
		
		[Test]
		public function testDesiredSampleLengthDifferentValue():void
		{
			metric=new DroppedFPSMetric(qosInfoHistory, 6.78);
			assertEquals(MetricType.DROPPED_FPS, metric.type);
			
			//check initial value
			var metricValue:MetricValue;
			metricValue = metric.value;
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			assertEquals(6.78, metric.desiredSampleLength);
			
		}
		
		[Test]
		public function testValueWhenQoSInfoHistoryIsPopulated():void
		{
			metric=new DroppedFPSMetric(qosInfoHistory, 5);
			assertEquals(MetricType.DROPPED_FPS, metric.type);
			var timestamp:Number=1000;
			
			var metricValue:MetricValue;
			metricValue = metric.value;
			
			//check initial value
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
			//check one value
			addQoSInfo(generateQoSInfo(timestamp++, 0, 
				2, 7, 
				0, 0, 
				0, 0, 
				0, 0, 
				0, 0));

			metricValue = metric.value;
			assertTrue(metricValue.valid);
			assertEquals(7/2, metricValue.value);
			
			//check bad data
			addQoSInfo(generateQoSInfo(timestamp++, 4, 
				2, 7, 
				0, 0, 
				0, 0, 
				0, 0, 
				0, 0));
			
			metricValue = metric.value;
			assertFalse(metricValue.valid);
			assertEquals(undefined, metricValue.value);
			
			
			//check value when other streams have been played  (0 and 1)
			addQoSInfo(generateQoSInfo(timestamp++, 1, 
				2, 7, 
				3, 4, 
				5, 40, 
				7, 45, 
				9, 50));
			
			metricValue = metric.value;
			assertTrue(metricValue.valid);
			assertEquals(4/3, metricValue.value);
			
			
			//check that it sums 2 records, under the limit
			addQoSInfo(generateQoSInfo(timestamp++, 1, 
				2, 7, 
				1, 5, 
				5, 40, 
				7, 45, 
				9, 50));
			
			metricValue = metric.value;
			assertTrue(metricValue.valid);
			assertEquals((4+5)/(3+1), metricValue.value);
			
			//check that the limit stops the propagation
			addQoSInfo(generateQoSInfo(timestamp++, 1, 
				1, 7, 
				2, 23, 
				5, 40, 
				7, 45, 
				9, 50));
			
			addQoSInfo(generateQoSInfo(timestamp++, 1, 
				1, 7, 
				3, 34, 
				5, 40, 
				7, 45, 
				9, 50));
			
			
			metricValue = metric.value;
			assertTrue(metricValue.valid);
			assertEquals((23+34)/(2+3), metricValue.value);
			
			//check desiredSampleLength limit
			addQoSInfo(generateQoSInfo(timestamp++, 1, 
				2, 7, 
				6, 13, 
				5, 40, 
				7, 45, 
				9, 50));
			
			metricValue = metric.value;
			assertTrue(metricValue.valid);
			
			assertEquals(13/6, metricValue.value);
			
			//check undefined
			addQoSInfo(generateQoSInfo(timestamp++, 1, 
				2, 7, 
				6, 13, 
				5, 40, 
				7, 45, 
				9, 50));
			
			metricValue = metric.value;
			assertTrue(metricValue.valid);
			
			assertEquals(13/6, metricValue.value);
			
		}
		
		[Test]
		public function testValueForShortIntervals():void
		{
			metric=new DroppedFPSMetric(qosInfoHistory, 5);
			assertEquals(MetricType.DROPPED_FPS, metric.type);
			var timestamp:Number=2000;
			
			var metricValue:MetricValue;
			metricValue = metric.value;
			
			//check initial value
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
			//check minimum MINIMUM_CONTINUOUS_PLAYBACK_DURATION = 1
			
			addQoSInfo(generateQoSInfo(timestamp++, 0, 
				0.99, 3, 
				0, 0, 
				0, 0, 
				0, 0, 
				0, 0));
			
			metricValue = metric.value;
			assertFalse(metricValue.valid);
			assertEquals(undefined, metricValue.value);
			
			addQoSInfo(generateQoSInfo(timestamp++, 0, 
				4, 3, 
				0, 0, 
				0, 0, 
				0, 0, 
				0, 0));
			
			metricValue = metric.value;
			assertTrue(metricValue.valid);
			assertEquals(3 / 4, metricValue.value);
			
			//check minimum MINIMUM_TOTAL_PLAYBACK_DURATION = 2
			addQoSInfo(generateQoSInfo(timestamp++, 4, 
				2, 7, 
				0, 0, 
				0, 0, 
				0, 0, 
				1, 4));
			
			metricValue = metric.value;
			assertFalse(metricValue.valid);
			assertEquals(undefined, metricValue.value);
			
			addQoSInfo(generateQoSInfo(timestamp++, 4, 
				2, 7, 
				0, 0, 
				0, 0, 
				0, 0, 
				1, 5));
			
			metricValue = metric.value;
			assertTrue(metricValue.valid);
			assertEquals( (4 + 5) / 2, metricValue.value);
			
		}
		
		[Test]
		public function testValueForNegativeDroppedFrameValue():void
		{
			metric=new DroppedFPSMetric(qosInfoHistory, 5);
			assertEquals(MetricType.DROPPED_FPS, metric.type);
			var timestamp:Number=2000;
			
			var metricValue:MetricValue;
			metricValue = metric.value;
			
			//check initial value
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
			//check minimum MINIMUM_CONTINUOUS_PLAYBACK_DURATION = 1
			
			addQoSInfo(generateQoSInfo(timestamp++, 0, 
				8, -3, 
				0, 0, 
				0, 0, 
				0, 0, 
				0, 0));
			
			metricValue = metric.value;
			assertFalse(metricValue.valid);
			assertEquals(undefined, metricValue.value);
		}
		
		[Test]
		public function testValueForNegativeDurationValue():void
		{
			metric=new DroppedFPSMetric(qosInfoHistory, 5);
			assertEquals(MetricType.DROPPED_FPS, metric.type);
			var timestamp:Number=2000;
			
			var metricValue:MetricValue;
			metricValue = metric.value;
			
			//check initial value
			assertEquals(undefined, metricValue.value);
			assertFalse(metricValue.valid);
			
			//check minimum MINIMUM_CONTINUOUS_PLAYBACK_DURATION = 1
			
			addQoSInfo(generateQoSInfo(timestamp++, 0, 
				8, 3, 
				0, 0, 
				0, 0, 
				0, 0, 
				0, 0));

			metricValue = metric.value;
			assertTrue(metricValue.valid);
			assertEquals(3 / 8, metricValue.value);
			
			addQoSInfo(generateQoSInfo(timestamp++, 0, 
				-1, 4, 
				0, 0, 
				0, 0, 
				0, 0, 
				0, 0));
			
			metricValue = metric.value;
			assertFalse(metricValue.valid);
			assertEquals(undefined, metricValue.value);
			
		}
		
		//helper different from qosinfo tests functions
		
		private function generateQoSInfo(timestamp:Number, currentIndex:int, ... playbackArgs):QoSInfo
		{
			var v:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			var playbackDetails:Vector.<PlaybackDetails> = new Vector.<PlaybackDetails>;
			var i:int;
			for(i=0; i< playbackArgs.length; i+=2)
				playbackDetails.push(new PlaybackDetails(i/2, playbackArgs[i], playbackArgs[i+1]));
			
			for(i=0; i< 5; i++)
			{
				v[i] = new QualityLevel( i, 150+100*i , "test" + (150+100*i) );
			}
			return (new QoSInfo(timestamp, 5678, v, currentIndex, 0, new FragmentDetails(14000, 4000, 568, 2), 0, playbackDetails));
		}
		
		//helper identical to qosinfo tests functions
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		private var metric:DroppedFPSMetric;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
	}
}