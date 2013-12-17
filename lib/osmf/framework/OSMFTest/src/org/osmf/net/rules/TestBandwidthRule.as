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
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.net.metrics.BandwidthMetric;
	import org.osmf.net.metrics.BandwidthMetricMocker;
	import org.osmf.net.metrics.DefaultMetricFactory;
	import org.osmf.net.metrics.DefaultMetricFactoryMocker;
	import org.osmf.net.metrics.FragmentCountMetric;
	import org.osmf.net.metrics.FragmentCountMetricMocker;
	import org.osmf.net.metrics.MetricFactory;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.metrics.MetricType;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;

	public class TestBandwidthRule
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
			
			bandwidthMetric =  metricRepository.getMetric(MetricType.BANDWIDTH, generateWeights(0.7, 0.3) ) as BandwidthMetricMocker;
			fragmentCountMetric = metricRepository.getMetric(MetricType.FRAGMENT_COUNT) as FragmentCountMetricMocker;
			
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
		
		
		[Test(expects="ArgumentError")]
		public function testBandwidthRuleInitWithNoFragments():void
		{
			
			rule = new BandwidthRule(metricRepository, new <Number>[]);	
		}
		
		[Test(expects="ArgumentError")]
		public function testBandwidthRuleInitWithNegativeWeight():void
		{			
			rule = new BandwidthRule(metricRepository, new <Number>[1, -0.1, -0.01, -0.001]);	
		}
		
		
		[Test(expects="ArgumentError")]
		public function testBandwidthRuleInitWithNaNWeight():void
		{			
			rule = new BandwidthRule(metricRepository, new <Number>[NaN, NaN, NaN, NaN]);	
		}
				
		[Test(expects="ArgumentError")]
		public function testBandwidthRuleInitWithZeroWeight():void
		{
			//create metric needed by specific rule
			bandwidthMetric =  metricRepository.getMetric(MetricType.BANDWIDTH, generateWeights(1,0.9, 0.9*0.9) ) as BandwidthMetricMocker;
			
			rule = new BandwidthRule(metricRepository, new <Number>[0, 0, 0, 0]);
			
			bandwidthMetric.internalValue=8000.1;
			bandwidthMetric.returnValid=true;
			
			fragmentCountMetric.internalValue=2;
			fragmentCountMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(RuleType.BANDWIDTH, recommendation.ruleType);
			assertEquals(8000.1 * 8 / 1000, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
			assertEquals(4, rule.weights.length);
		}
		
		[Test]
		public function testBandwidthRuleInvalidMetric():void
		{
			//create metric needed by specific rule
			bandwidthMetric =  metricRepository.getMetric(MetricType.BANDWIDTH, generateWeights(1,0.9, 0.9*0.9) ) as BandwidthMetricMocker;
			
			rule = new BandwidthRule(metricRepository, generateWeights(1, 0.9, 0.9*0.9));
			
			//both rules return invalid
			
			bandwidthMetric.internalValue=undefined;
			bandwidthMetric.returnValid=false;
			
			fragmentCountMetric.internalValue=undefined;
			fragmentCountMetric.returnValid=false;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
				
			//check: bandwidth returns invalid
			
			bandwidthMetric.internalValue=undefined;
			bandwidthMetric.returnValid=false;
			
			fragmentCountMetric.internalValue=1;
			fragmentCountMetric.returnValid=true;
			
			recommendation = rule.getRecommendation();
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
			
			//check: fragment count returns invalid
			
			bandwidthMetric.internalValue=690;
			bandwidthMetric.returnValid=true;
			
			fragmentCountMetric.internalValue=undefined;
			fragmentCountMetric.returnValid=false;
			
			recommendation = rule.getRecommendation();
			assertEquals(0, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);			
		}
		
		[Test]
		public function testBandwidthRuleValidMetric():void
		{
			// add sample qos info
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false,false , new QoSInfo()));
			
			//create metric needed by specific rule
			bandwidthMetric =  metricRepository.getMetric(MetricType.BANDWIDTH, generateWeights(1, 0.9, 0.9*0.9) ) as BandwidthMetricMocker;
			
			rule = new BandwidthRule(metricRepository, generateWeights(1, 0.9, 0.9*0.9));
			
			//less fragments than needed
			
			bandwidthMetric.internalValue=8000.1;
			bandwidthMetric.returnValid=true;
			
			fragmentCountMetric.internalValue=2;
			fragmentCountMetric.returnValid=true;
			
			var recommendation:Recommendation = rule.getRecommendation();
			assertEquals(8000.1 * 8 / 1000, recommendation.bitrate);
			assertEquals((1 + 0.9) / (1 + 0.9 + 0.9*0.9 ), recommendation.confidence);
			
			//more fragments than needed
			
			bandwidthMetric.internalValue=8000.1;
			bandwidthMetric.returnValid=true;
			
			fragmentCountMetric.internalValue=10;
			fragmentCountMetric.returnValid=true;
			
			recommendation = rule.getRecommendation();
			assertEquals(8000.1 * 8 / 1000, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
			
			// fragments exactly as needed
			
			bandwidthMetric.internalValue=8000.1;
			bandwidthMetric.returnValid=true;
			
			fragmentCountMetric.internalValue=3;
			fragmentCountMetric.returnValid=true;
			
			recommendation = rule.getRecommendation();
			assertEquals(8000.1 * 8 / 1000, recommendation.bitrate);
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
		
		private var rule:BandwidthRule;
		
		private var bandwidthMetric:BandwidthMetricMocker;
		private var fragmentCountMetric:FragmentCountMetricMocker;

		private var metric:FragmentCountMetric;
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		private var metricFactory:MetricFactory;
		private var metricRepository:MetricRepository;
	}
}