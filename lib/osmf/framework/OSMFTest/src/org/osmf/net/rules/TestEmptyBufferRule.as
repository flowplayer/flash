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
	
	import org.flexunit.Assert;
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
	import org.osmf.net.metrics.EmptyBufferMetricMocker;
	import org.osmf.net.metrics.FragmentCountMetric;
	import org.osmf.net.metrics.FragmentCountMetricMocker;
	import org.osmf.net.metrics.MetricFactory;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.metrics.MetricType;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;
	
	public class TestEmptyBufferRule
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
			emptyBufferInterruptionMetric = metricRepository.getMetric(MetricType.EMPTY_BUFFER) as EmptyBufferMetricMocker;

		}
		
		[After]
		public function tearDown():void
		{

			bandwidthMetric =  null;
			
			fragmentCountMetric = null;
			bufferFragmentsMetric = null;
			
			actualBitrateMetric = null;
			bufferFragmentsMetric = null;
			availableQualityLevelsMetric = null;
			currentStatusMetric = null;
			emptyBufferInterruptionMetric = null;
			
			metricRepository = null;
			metricFactory = null;
			qosInfoHistory = null;
			netStream = null;
			
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
		public function testEmptyBufferInterruptionRuleInit():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.4);
			assertEquals(0.4, rule.scaleDownFactor);
		}
		
		[Test(expects="ArgumentError")]
		public function testEmptyBufferInterruptionRuleInitNaN():void
		{
			rule = new EmptyBufferRule(metricRepository, NaN);
		}
		
		[Test(expects="ArgumentError")]
		public function testEmptyBufferInterruptionRuleInitGreaterThanOne():void
		{
			rule = new EmptyBufferRule(metricRepository, 1.01);
		}
		
		[Test(expects="ArgumentError")]
		public function testEmptyBufferInterruptionRuleInitNegative():void
		{
			rule = new EmptyBufferRule(metricRepository, -0.1);
		}
		
		[Test]
		public function testEmptyBufferInterruptionRuleInitOne():void
		{
			rule = new EmptyBufferRule(metricRepository, 1);
			assertEquals(1, rule.scaleDownFactor);

		}
		
		[Test]
		public function testEmptyBufferInterruptionRuleInitZero():void
		{
			rule = new EmptyBufferRule(metricRepository, 0);
			assertEquals(0, rule.scaleDownFactor);
			
		}
		
		[Test]
		public function testEmptyBufferInterruptionRuleSet_scaleDownFactor():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);
			rule.scaleDownFactor = 0.8;
			assertEquals(0.8, rule.scaleDownFactor);
			rule.scaleDownFactor = 0;
			assertEquals(0, rule.scaleDownFactor);
			rule.scaleDownFactor = 1;
			assertEquals(1, rule.scaleDownFactor);
		}
		
		[Test(expects = "ArgumentError")]
		public function testEmptyBufferInterruptionRuleSet_scaleDownFactorNaN():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);
			rule.scaleDownFactor = NaN;
		}
		
		[Test(expects = "ArgumentError")]
		public function testEmptyBufferInterruptionRuleSet_scaleDownFactorNegative():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);
			rule.scaleDownFactor = -0.1;
		}
		
		[Test(expects = "ArgumentError")]
		public function testEmptyBufferInterruptionRuleSet_scaleDownFactorGreaterThanOne():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);
			rule.scaleDownFactor = 1.1;
		}
		
		
		
		[Test]
		public function testEmptyBufferInterruptionRule_GetRecommendation_InvalidEmptyBufferInterruptMetric():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);

			emptyBufferInterruptionMetric = metricRepository.getMetric(MetricType.EMPTY_BUFFER) as EmptyBufferMetricMocker;
			emptyBufferInterruptionMetric.returnValid=false;
			emptyBufferInterruptionMetric.internalValue=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.EMPTY_BUFFER, recommendation.ruleType);
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
		}
		
		[Test]
		public function testEmptyBufferInterruptionRule_GetRecommendation_FalseEmptyBufferInterruptMetric():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);

			emptyBufferInterruptionMetric = metricRepository.getMetric(MetricType.EMPTY_BUFFER) as EmptyBufferMetricMocker;
			emptyBufferInterruptionMetric.returnValid=true;
			emptyBufferInterruptionMetric.internalValue=false;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.EMPTY_BUFFER, recommendation.ruleType);
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
		}
		
		[Test]
		public function testEmptyBufferInterruptionRule_GetRecommendation_TrueEmptyBufferInterruptMetric_ValidActualBitrate():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);

			emptyBufferInterruptionMetric = metricRepository.getMetric(MetricType.EMPTY_BUFFER) as EmptyBufferMetricMocker;
			emptyBufferInterruptionMetric.returnValid=true;
			emptyBufferInterruptionMetric.internalValue=true;
			
			actualBitrateMetric.returnValid=true;
			actualBitrateMetric.internalValue=333;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.EMPTY_BUFFER, recommendation.ruleType);
			assertEquals(333*0.5, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
		}
		
		[Test]
		public function testEmptyBufferInterruptionRule_GetRecommendation_EmptyBuffer_InvalidActualBitrate_ValidCurrent_ValidAvailableQuality():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);

			emptyBufferInterruptionMetric = metricRepository.getMetric(MetricType.EMPTY_BUFFER) as EmptyBufferMetricMocker;
			emptyBufferInterruptionMetric.returnValid=true;
			emptyBufferInterruptionMetric.internalValue=true;
			
			actualBitrateMetric.returnValid=false;
			actualBitrateMetric.internalValue=333;
			
			currentStatusMetric.internalValue=new Vector.<uint>();
			currentStatusMetric.internalValue.push(3);
			currentStatusMetric.internalValue.push(3);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			var i:int;
			for(i=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.EMPTY_BUFFER, recommendation.ruleType);
			assertEquals(450*0.5, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
		}
		
		[Test]
		public function testEmptyBufferInterruptionRule_GetRecommendation_EmptyBuffer_InvalidActualBitrate_InvalidCurrent_ValidAvailableQuality():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);

			emptyBufferInterruptionMetric = metricRepository.getMetric(MetricType.EMPTY_BUFFER) as EmptyBufferMetricMocker;
			emptyBufferInterruptionMetric.returnValid=true;
			emptyBufferInterruptionMetric.internalValue=true;
			
			actualBitrateMetric.returnValid=false;
			actualBitrateMetric.internalValue=333;
			
			currentStatusMetric.internalValue=new Vector.<uint>();
			currentStatusMetric.internalValue.push(3);
			currentStatusMetric.internalValue.push(3);
			currentStatusMetric.returnValid=false;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			var i:int;
			for(i=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.EMPTY_BUFFER, recommendation.ruleType);
			assertEquals(0, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
		}
		
		[Test]
		public function testEmptyBufferInterruptionRule_GetRecommendation_EmptyBuffer_InvalidActualBitrate_ValidCurrent_InvalidAvailableQuality():void
		{
			rule = new EmptyBufferRule(metricRepository, 0.5);

			emptyBufferInterruptionMetric = metricRepository.getMetric(MetricType.EMPTY_BUFFER) as EmptyBufferMetricMocker;
			emptyBufferInterruptionMetric.returnValid=true;
			emptyBufferInterruptionMetric.internalValue=true;
			
			actualBitrateMetric.returnValid=false;
			actualBitrateMetric.internalValue=333;
			
			currentStatusMetric.internalValue=new Vector.<uint>();
			currentStatusMetric.internalValue.push(3);
			currentStatusMetric.internalValue.push(3);
			currentStatusMetric.returnValid=true;
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			var i:int;
			for(i=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=false;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.EMPTY_BUFFER, recommendation.ruleType);
			assertEquals(0, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
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
		
		private var rule:EmptyBufferRule;
		
		//metrics for super
		private var bandwidthMetric:BandwidthMetricMocker;
		private var fragmentCountMetric:FragmentCountMetricMocker;
		private var bufferFragmentsMetric:BufferFragmentsMetricMocker;
		
		private var actualBitrateMetric:ActualBitrateMetricMocker;
		private var currentStatusMetric:CurrentStatusMetricMocker;
		private var availableQualityLevelsMetric:AvailableQualityLevelsMetricMocker;
		private var emptyBufferInterruptionMetric:EmptyBufferMetricMocker;

		
		
		
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		private var metricFactory:MetricFactory;
		private var metricRepository:MetricRepository;
	}
}