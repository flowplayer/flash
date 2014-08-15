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
package org.osmf.net.rules
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.net.metrics.ActualBitrateMetric;
	import org.osmf.net.metrics.ActualBitrateMetricMocker;
	import org.osmf.net.metrics.AvailableQualityLevelsMetric;
	import org.osmf.net.metrics.AvailableQualityLevelsMetricMocker;
	import org.osmf.net.metrics.BandwidthMetric;
	import org.osmf.net.metrics.BandwidthMetricMocker;
	import org.osmf.net.metrics.BufferFragmentsMetric;
	import org.osmf.net.metrics.BufferFragmentsMetricMocker;
	import org.osmf.net.metrics.CurrentStatusMetric;
	import org.osmf.net.metrics.CurrentStatusMetricMocker;
	import org.osmf.net.metrics.DefaultMetricFactory;
	import org.osmf.net.metrics.DefaultMetricFactoryMocker;
	import org.osmf.net.metrics.FragmentCountMetric;
	import org.osmf.net.metrics.FragmentCountMetricMocker;
	import org.osmf.net.metrics.MetricFactory;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.metrics.MetricType;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;

	public class TestRuleUtils
	{
		[Before]
		public function setUp():void
		{
			var conn:NetConnection = new NetConnection();
			conn.connect(null);
			netStream = new NetStream(conn);
			qosInfoHistory = new QoSInfoHistory(netStream);
			metricFactory = new DefaultMetricFactoryMocker(qosInfoHistory);
			metricRepository = new MetricRepository(metricFactory);
			
			
			bandwidthMetric =  metricRepository.getMetric(MetricType.BANDWIDTH, generateWeights(1,0.9, 0.9*0.9) ) as BandwidthMetricMocker;

			fragmentCountMetric = metricRepository.getMetric(MetricType.FRAGMENT_COUNT) as FragmentCountMetricMocker;
			bufferFragmentsMetric = metricRepository.getMetric(MetricType.BUFFER_FRAGMENTS) as BufferFragmentsMetricMocker;
			
			actualBitrateMetric = metricRepository.getMetric(MetricType.ACTUAL_BITRATE) as ActualBitrateMetricMocker;
			bufferFragmentsMetric = metricRepository.getMetric(MetricType.BUFFER_FRAGMENTS) as BufferFragmentsMetricMocker;
			availableQualityLevelsMetric = metricRepository.getMetric(MetricType.AVAILABLE_QUALITY_LEVELS) as AvailableQualityLevelsMetricMocker;
			currentStatusMetric = metricRepository.getMetric(MetricType.CURRENT_STATUS) as CurrentStatusMetricMocker;
		}
		
		[After]
		public function tearDown():void
		{
			fragmentCountMetric = null;
			bandwidthMetric = null;
			metricRepository = null;
			metricFactory = null;
			qosInfoHistory = null;
			netStream = null;
		}
		
		
		[Test]
		public function testComputeActualBitrateWhenActualBitrateMetricIsValid():void
		{
			
			actualBitrateMetric.internalValue = 846;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid = true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid = true;

			var bitrate:Number = RuleUtils.computeActualBitrate(actualBitrateMetric, availableQualityLevelsMetric, currentStatusMetric);			
			assertEquals(846, bitrate);
		}
		
		
		[Test]
		public function testComputeActualBitrateWhenActualBitrateMetricIsInvalidAndCurrentStatusIsValidAndAvailableQualityLevelsMetricIsValid():void
		{
			
			actualBitrateMetric.internalValue = 846;
			actualBitrateMetric.returnValid = false;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid = true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid = true;
			
			var bitrate:Number = RuleUtils.computeActualBitrate(actualBitrateMetric, availableQualityLevelsMetric, currentStatusMetric);
			assertEquals(350, bitrate);
		}
		
		
		[Test]
		public function testComputeActualBitrateWhenActualBitrateMetricIsInvalidAndCurrentStatusIsInvalidAndAvailableQualityLevelsMetricIsValid():void
		{
			
			actualBitrateMetric.internalValue = 846;
			actualBitrateMetric.returnValid = false;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid = false;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid = true;
			
			var bitrate:Number = RuleUtils.computeActualBitrate(actualBitrateMetric, availableQualityLevelsMetric, currentStatusMetric);
			assertTrue(isNaN(bitrate));
		}
		
		[Test]
		public function testComputeActualBitrateWhenActualBitrateMetricIsInvalidAndCurrentStatusIsValidAndAvailableQualityLevelsMetricIsInvalid():void
		{
			
			actualBitrateMetric.internalValue = 846;
			actualBitrateMetric.returnValid = false;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid = true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid = false;
			
			var bitrate:Number = RuleUtils.computeActualBitrate(actualBitrateMetric, availableQualityLevelsMetric, currentStatusMetric);
			assertTrue(isNaN(bitrate));
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
		
		
		//metrics for input
		private var bandwidthMetric:BandwidthMetricMocker;
		private var fragmentCountMetric:FragmentCountMetricMocker;
		private var bufferFragmentsMetric:BufferFragmentsMetricMocker;
		
		private var actualBitrateMetric:ActualBitrateMetricMocker;
		private var currentStatusMetric:CurrentStatusMetricMocker;
		private var availableQualityLevelsMetric:AvailableQualityLevelsMetricMocker;

		
		
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		private var metricFactory:MetricFactory;
		private var metricRepository:MetricRepository;
	}
}