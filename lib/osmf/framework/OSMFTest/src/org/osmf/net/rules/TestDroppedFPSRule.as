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
	import org.osmf.net.metrics.ActualBitrateMetricMocker;
	import org.osmf.net.metrics.AvailableQualityLevelsMetric;
	import org.osmf.net.metrics.AvailableQualityLevelsMetricMocker;
	import org.osmf.net.metrics.CurrentStatusMetric;
	import org.osmf.net.metrics.CurrentStatusMetricMocker;
	import org.osmf.net.metrics.DefaultMetricFactoryMocker;
	import org.osmf.net.metrics.DroppedFPSMetricMocker;
	import org.osmf.net.metrics.FPSMetricMocker;
	import org.osmf.net.metrics.MetricFactory;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.metrics.MetricType;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;

	public class TestDroppedFPSRule
	{
		[Before]
		public function setUp():void
		{
			var conn:NetConnection = new NetConnection();
			conn.connect(null);
			netStream = new NetStream(conn);
			var qosInfoHistory:QoSInfoHistory = new QoSInfoHistory(netStream);
			var metricFactory:DefaultMetricFactoryMocker = new DefaultMetricFactoryMocker(qosInfoHistory)
			metricRepository = new MetricRepository(metricFactory);
			
			droppedFPSMetric = metricRepository.getMetric(MetricType.DROPPED_FPS, DESIRED_SAMPLE_LENGTH) as DroppedFPSMetricMocker;
			fpsMetric = metricRepository.getMetric(MetricType.FPS) as FPSMetricMocker;	
			availableQualityLevelsMetric = metricRepository.getMetric(MetricType.AVAILABLE_QUALITY_LEVELS) as AvailableQualityLevelsMetricMocker;	
			
			actualBitrateMetric = metricRepository.getMetric(MetricType.ACTUAL_BITRATE) as ActualBitrateMetricMocker;
			currentStatusMetric = metricRepository.getMetric(MetricType.CURRENT_STATUS) as CurrentStatusMetricMocker;
		}
		
		[After]
		public function tearDown():void
		{
			currentStatusMetric = null;
			droppedFPSMetric = null;
			metricRepository = null;
			netStream = null;
		}

		[Test(expects="ArgumentError")]
		public function testInitInvalidMaximumDroppedFPSRatioNaN():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, 5, Number.NaN);
		}

		[Test(expects="ArgumentError")]
		public function testInitInvalidMaximumDroppedFPSRatioLessThanZero():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, 5, -0.1);
		}
		
		[Test(expects="ArgumentError")]
		public function testInitInvalidMaximumDroppedFPSRatioOverOne():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, 5, 1.1);
		}
		
		[Test(expects="ArgumentError")]
		public function testInitInvalidDesiredSampleLengthNaN():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, NaN, 0.1);
		}
		
		[Test(expects="ArgumentError")]
		public function testInitInvalidDesiredSampleLengthLessThanZero():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, -1, 0.1);
		}
		
		[Test(expects="ArgumentError")]
		public function testInitInvalidInvalidDesiredSampleLengthZero():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, 0, 1.1);
		}
		
		[Test]
		public function testDroppedFPSRuleInit():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			assertEquals(DESIRED_SAMPLE_LENGTH, dfpsRule.desiredSampleLength);
			assertEquals(0.2, dfpsRule.maximumDroppedFPSRatio);
		}
		
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationValidMetric():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 - 0.01;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals((29.7 * 0.2 - 0.01) / (29.7*0.2), recommendation.confidence);
			assertEquals(433.3 * (1 - (29.7 * 0.2 - 0.01) / 29.7) , recommendation.bitrate); //actualBitrate * (1 - droppedFPS / fps);
		}
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationValidMetricLowFPS():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 + 0.01;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(1, recommendation.confidence);
			assertEquals(433.3 * (1 - (29.7 * 0.2 + 0.01) / 29.7) , recommendation.bitrate); //actualBitrate * (1 - droppedFPS / fps);
		}
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationValidMetricRatioZero():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 0;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(0, recommendation.confidence);
			assertEquals(0, recommendation.bitrate); //actualBitrate * (1 - droppedFPS / fps);
		}
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationValidMetricBorderFPS():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 ;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(1, recommendation.confidence);
			assertEquals(433.3 * (1 - (29.7 * 0.2) / 29.7) , recommendation.bitrate); //actualBitrate * (1 - droppedFPS / fps);
			
		}
		
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationCurrentIndexDifferentFromActualIndex():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
			actualBitrateMetric.returnValid = true;
			
			currentStatusMetric.internalValue = new Vector.<uint>();
			currentStatusMetric.internalValue.push(2);
			currentStatusMetric.internalValue.push(1);
			currentStatusMetric.returnValid = true; 
			
			availableQualityLevelsMetric.internalValue = new Vector.<QualityLevel>();
			for(var i:uint=0; i< 5; i++)
			{
				availableQualityLevelsMetric.internalValue.push( 
					new QualityLevel( i, 100 * i + 150, "test" + (100 * i + 150) ));
			}
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 ;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(0, recommendation.confidence);
			assertEquals(0, recommendation.bitrate); //actualBitrate * (1 - droppedFPS / fps);
			
		}
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationInvalidActualBitrateMetric():void
		{
			//valid current status and available quality metrics
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 + 0.01;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(1, recommendation.confidence);
			assertEquals(350 * (1 - (29.7 * 0.2 + 0.01) / 29.7) , recommendation.bitrate); 	
		}
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationInvalidCurrentStatusMetric():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
			actualBitrateMetric.returnValid = true;
			
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 + 0.01;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(0, recommendation.confidence);
			assertEquals(0, recommendation.bitrate); 
		}
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationInvalidFPSMetric():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = false;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 + 0.01;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(0, recommendation.confidence);
			assertEquals(0 , recommendation.bitrate); 		
		}
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationInvalidDroppedFPSMetric():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 + 0.01;
			droppedFPSMetric.returnValid = false;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(0, recommendation.confidence);
			assertEquals(0 , recommendation.bitrate); 
		}
		
		
		//todo
		[Test]
		public function testDroppedFPSRuleGetRecommendationInvalidCurrentStatusMetricAndActualBitrate():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 + 0.01;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(0, recommendation.confidence);
			assertEquals(0, recommendation.bitrate); 
		}
		
		//todo
		[Test]
		public function testDroppedFPSRuleGetRecommendationInvalidActualBitrateAndAvailableQualityLevelMetric():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
			actualBitrateMetric.returnValid = true;
			
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
			availableQualityLevelsMetric.returnValid=false;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.7 * 0.2 + 0.01;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(0, recommendation.confidence);
			assertEquals(0, recommendation.bitrate); 
		}
		
		
		
		[Test]
		public function testDroppedFPSRuleGetRecommendationMoreDroppedFramesThanMax():void
		{
			var dfpsRule:DroppedFPSRule = new DroppedFPSRule(metricRepository, DESIRED_SAMPLE_LENGTH, 0.2);
			
			actualBitrateMetric.internalValue = 433.3;
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
			availableQualityLevelsMetric.returnValid=true;
			
			fpsMetric.internalValue = 29.7;
			fpsMetric.returnValid = true;
			
			droppedFPSMetric.internalValue = 29.71;
			droppedFPSMetric.returnValid = true;
			
			var recommendation:Recommendation = dfpsRule.getRecommendation();
			assertEquals(RuleType.DROPPED_FPS, recommendation.ruleType);
			assertEquals(1, recommendation.confidence);
			assertEquals(0 , recommendation.bitrate); //actualBitrate * (1 - droppedFPS / fps);
		}
		
		private var droppedFPSMetric:DroppedFPSMetricMocker;
		private var fpsMetric:FPSMetricMocker;
		private var currentStatusMetric:CurrentStatusMetricMocker;
		private var actualBitrateMetric:ActualBitrateMetricMocker;		
		private var availableQualityLevelsMetric:AvailableQualityLevelsMetricMocker;	
		
		
		private var netStream:NetStream;
		private var metricRepository:MetricRepository;
		
		private static const DESIRED_SAMPLE_LENGTH:Number = 5;
		private static const DESIRED_RATIO:Number = 0.1;
	}
}