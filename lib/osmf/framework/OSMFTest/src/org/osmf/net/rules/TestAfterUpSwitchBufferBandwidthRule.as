/*****************************************************
 *  
 *  Copyright 2012 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2012 Adobe Systems 
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
	import org.osmf.net.metrics.RecentSwitchMetricMocker;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;
	
	public class TestAfterUpSwitchBufferBandwidthRule
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
			
			
			bandwidthMetric =  metricRepository.getMetric(MetricType.BANDWIDTH, generateWeights(1)) as BandwidthMetricMocker;
			
			fragmentCountMetric = metricRepository.getMetric(MetricType.FRAGMENT_COUNT) as FragmentCountMetricMocker;
			bufferFragmentsMetric = metricRepository.getMetric(MetricType.BUFFER_FRAGMENTS) as BufferFragmentsMetricMocker;
			
			actualBitrateMetric = metricRepository.getMetric(MetricType.ACTUAL_BITRATE) as ActualBitrateMetricMocker;
			bufferFragmentsMetric = metricRepository.getMetric(MetricType.BUFFER_FRAGMENTS) as BufferFragmentsMetricMocker;
			availableQualityLevelsMetric = metricRepository.getMetric(MetricType.AVAILABLE_QUALITY_LEVELS) as AvailableQualityLevelsMetricMocker;
			currentStatusMetric = metricRepository.getMetric(MetricType.CURRENT_STATUS) as CurrentStatusMetricMocker;
			recentSwitchMetric = metricRepository.getMetric(MetricType.RECENT_SWITCH) as RecentSwitchMetricMocker;
			
		}
		
		[After]
		public function tearDown():void
		{
			netStream = null;
			qosInfoHistory = null;
			metricFactory =  null;
			metricRepository = null;
			
			
			bandwidthMetric =  null;
			
			fragmentCountMetric = null;
			bufferFragmentsMetric = null;
			
			actualBitrateMetric = null;
			bufferFragmentsMetric = null;
			availableQualityLevelsMetric = null;
			currentStatusMetric = null;
			recentSwitchMetric = null;
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
		public function testAfterUpSwitchBandwidthBufferRuleInit():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.6);
			assertEquals(0.6, rule.minBandwidthToBitrateRatio);
			assertEquals(4, rule.bufferFragmentsThreshold);
			assertEquals(1, rule.weights.length);
		}
		
		[Test]
		public function testAfterUpSwitchBandwidthBufferRuleInitRatioZero():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0);
			assertEquals(0, rule.minBandwidthToBitrateRatio);
			assertEquals(4, rule.bufferFragmentsThreshold);
			assertEquals(1, rule.weights.length);
		}
		
		[Test(expects="ArgumentError")]
		public function testAfterUpSwitchBandwidthBufferRuleInitRatioNaN():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, NaN);
		}
		
		[Test(expects="ArgumentError")]
		public function testAfterUpSwitchBandwidthBufferRuleInitRatioNegative():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, -0.1);
		}

		
		[Test]
		public function testAfterUpSwitchBandwidthBufferRule_Set_minBandwidthToBitrateRatio():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.6);
			assertEquals(0.6, rule.minBandwidthToBitrateRatio);
	
			rule.minBandwidthToBitrateRatio = 0.7;
			
			assertEquals(0.7, rule.minBandwidthToBitrateRatio);
		}
		
		[Test]
		public function testAfterUpSwitchBandwidthBufferRule_Set_minBandwidthToBitrateRatioZero():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.6);
			assertEquals(0.6, rule.minBandwidthToBitrateRatio);
			
			rule.minBandwidthToBitrateRatio = 0;
			
			assertEquals(0, rule.minBandwidthToBitrateRatio);
		}
		
		[Test(expects="ArgumentError")]
		public function testAfterUpSwitchBandwidthBufferRule_Set_minBandwidthToBitrateRatioNaN():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.6);
			assertEquals(0.6, rule.minBandwidthToBitrateRatio);
			
			rule.minBandwidthToBitrateRatio = NaN;
		}
		
		[Test(expects="ArgumentError")]
		public function testAfterUpSwitchBandwidthBufferRule_Set_minBandwidthToBitrateRatioNegative():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.6);
			assertEquals(0.6, rule.minBandwidthToBitrateRatio);
			
			rule.minBandwidthToBitrateRatio = -0.1;
		}
		
		
		[Test]
		public function testGetRecommendationInvalidRecentSwitchMetric():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.624);

			recentSwitchMetric.internalValue = -2;
			recentSwitchMetric.returnValid = false;
			
			bandwidthMetric.internalValue = 8000.1;
			bandwidthMetric.returnValid = true;
			
			fragmentCountMetric.internalValue = 10;
			fragmentCountMetric.returnValid = true;
			 
			actualBitrateMetric.internalValue = 501;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:int=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, recommendation.ruleType);
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
		}
		
		[Test]
		public function testGetRecommendationRecentSwitchMetricZero():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.624);
			
			recentSwitchMetric.internalValue = 0;
			recentSwitchMetric.returnValid = true;
			
			bandwidthMetric.internalValue = 8000.1;
			bandwidthMetric.returnValid = true;
			
			fragmentCountMetric.internalValue = 10;
			fragmentCountMetric.returnValid = true;
			
			actualBitrateMetric.internalValue = 501;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:int = 0; i < 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, recommendation.ruleType);
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
		}
		
		[Test]
		public function testGetRecommendationRecentSwitchMetricNegative():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.624);
			
			recentSwitchMetric.internalValue = -2;
			recentSwitchMetric.returnValid = true;
			
			bandwidthMetric.internalValue = (800.1 - 0.1) * 1000 / 8 * 0.624;
			bandwidthMetric.returnValid = true;
			
			fragmentCountMetric.internalValue = 10;
			fragmentCountMetric.returnValid = true;
			
			actualBitrateMetric.internalValue = 800.1;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:int=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, recommendation.ruleType);
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
		}
		
		[Test]
		public function testGetRecommendationRecentSwitchMetricPositive_BandwidthInvalid():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.624);
			
			recentSwitchMetric.internalValue = 2;
			recentSwitchMetric.returnValid = true;
			
			bandwidthMetric.internalValue = (800.1 - 0.1) * 1000 / 8 * 0.624;
			bandwidthMetric.returnValid = false;
			
			fragmentCountMetric.internalValue = 10;
			fragmentCountMetric.returnValid = true;
			
			actualBitrateMetric.internalValue = 800.1;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:int = 0; i < 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, recommendation.ruleType);
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
		}
		
		[Test]
		public function testGetRecommendationRecentSwitchMetricPositive_ActualBitrateValid_LowBandwidth():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.624);
			
			recentSwitchMetric.internalValue = 2;
			recentSwitchMetric.returnValid = true;
			
			bandwidthMetric.internalValue = (800.1 - 0.1) * 1000 / 8 * 0.624;
			bandwidthMetric.returnValid = true;
			
			fragmentCountMetric.internalValue = 10;
			fragmentCountMetric.returnValid = true;
			
			actualBitrateMetric.internalValue = 800.1;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:int = 0; i < 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, recommendation.ruleType);
			assertEquals((800.1 - 0.1) * 0.624, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
		}
		
		[Test]
		public function testGetRecommendationRecentSwitchMetricPositive_ActualBitrateValid_EqualBandwidth():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.624);
			
			recentSwitchMetric.internalValue = 2;
			recentSwitchMetric.returnValid = true;
			
			bandwidthMetric.internalValue = (800.1 + 0.0) * 1000.0 / 8.0 * 0.624;
			bandwidthMetric.returnValid = true;
			
			fragmentCountMetric.internalValue = 10;
			fragmentCountMetric.returnValid = true;
			
			actualBitrateMetric.internalValue = 800.1;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for( var i:int = 0; i < 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, recommendation.ruleType);
			assertEquals((800.1 + 0.0) * 0.624, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
		}
		
		[Test]
		public function testGetRecommendationRecentSwitchMetricPositive_ActualBitrateValid_HighBandwidth():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.624);
			
			recentSwitchMetric.internalValue = 2;
			recentSwitchMetric.returnValid = true;
			
			bandwidthMetric.internalValue = (800.1 + 0.1) * 1000.0 / 8.0 * 0.624;
			bandwidthMetric.returnValid = true;
			
			fragmentCountMetric.internalValue = 10;
			fragmentCountMetric.returnValid = true;
			
			actualBitrateMetric.internalValue = 800.1;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:int = 0; i < 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, recommendation.ruleType);
			assertEquals((800.1 + 0.1) * 1000.0 / 8.0 * 0.624 / 1000.0 * 8.0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
		}
		
		[Test]
		public function testGetRecommendationRecentSwitchMetricPositive_ActualBitrateInvalid_CurrentStatusValid_AvailableQualityValid_LowBandwidth():void
		{
			rule = new AfterUpSwitchBufferBandwidthRule(metricRepository, 4, 0.624);
			
			recentSwitchMetric.internalValue = 2;
			recentSwitchMetric.returnValid = true;
			
			bandwidthMetric.internalValue = (350.0 - 0.1) * 1000.0 / 8.0 * 0.624 ;
			bandwidthMetric.returnValid = true;
			
			fragmentCountMetric.internalValue = 10;
			fragmentCountMetric.returnValid = true;
			
			actualBitrateMetric.internalValue = 800.1;
			actualBitrateMetric.returnValid = false;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:int = 0; i < 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, recommendation.ruleType);
			assertEquals((350.0 - 0.1) * 1000.0 / 8.0 * 0.624 / 1000.0 * 8.0, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
		}
		
		
		private function generateWeights(... weights):Vector.<Number>
		{
			var v:Vector.<Number> = new Vector.<Number>();
			for(var i:int=0; i< weights.length; i++)
			{
				v[i] = weights[i] ;
			}
			return (v);
		}
		
		private var rule:AfterUpSwitchBufferBandwidthRule;
		
		//metrics for super
		private var bandwidthMetric:BandwidthMetricMocker;
		private var fragmentCountMetric:FragmentCountMetricMocker;
		private var bufferFragmentsMetric:BufferFragmentsMetricMocker;
		
		private var actualBitrateMetric:ActualBitrateMetricMocker;
		private var currentStatusMetric:CurrentStatusMetricMocker;
		private var availableQualityLevelsMetric:AvailableQualityLevelsMetricMocker;
		private var recentSwitchMetric:RecentSwitchMetricMocker;

		
		
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		private var metricFactory:MetricFactory;
		private var metricRepository:MetricRepository;
		
	}
}