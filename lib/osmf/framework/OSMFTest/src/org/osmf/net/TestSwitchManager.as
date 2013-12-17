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
package org.osmf.net
{
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.net.httpstreaming.DefaultHTTPStreamingSwitchManager;
	import org.osmf.net.metrics.ActualBitrateMetricMocker;
	import org.osmf.net.metrics.AvailableQualityLevelsMetricMocker;
	import org.osmf.net.metrics.BandwidthMetricMocker;
	import org.osmf.net.metrics.DefaultMetricFactoryMocker;
	import org.osmf.net.metrics.FragmentCountMetricMocker;
	import org.osmf.net.metrics.MetricFactory;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.metrics.MetricType;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;
	import org.osmf.net.rules.Recommendation;
	import org.osmf.net.rules.RuleBase;
	import org.osmf.net.rules.RuleMocker;
	
	public class TestSwitchManager
	{		
		[Before]
		public function setUp():void
		{
			var conn:NetConnection = new NetConnection();
			conn.connect(null);
			netStream = new NetStream(conn);
			netStream.client = new NetClient();
			qosInfoHistory = new QoSInfoHistory(netStream);
			//just to make the metrics work if the metrics have not mocked the getters for the value
			addQoSInfo(generateQoSInfo(mockTimestamp++, 150, 250, 350, 450, 550));

			metricFactory = new DefaultMetricFactoryMocker(qosInfoHistory);
			metricRepository = new MetricRepository(metricFactory);
			
			qualityLevels = new Vector.<QualityLevel>();
			for(var i:int = 0; i<5; i++)
				qualityLevels.push( new QualityLevel(i, 150+100*i, "test" + (150+100*i)));
			
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
		public function testDefaultSwitchManagerInitWith3Rules():void
		{
			var ruleWeights:Vector.<Number> = new Vector.<Number>();
			ruleWeights.push(0.7);
			ruleWeights.push(0.2);
			ruleWeights.push(0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push(new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push(new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push(new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights);
			
			assertTrue(switchManager.autoSwitch);
			assertEquals(3, switchManager.normalRuleWeights.length);
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(int.MAX_VALUE, switchManager.maxAllowedIndex);
			assertEquals(0, switchManager.currentIndex);
			assertEquals(12, switchManager.metricRepository.metricFactory.numItems);
			assertEquals(0.85, switchManager.minReliability);
			assertNull(switchManager.emergencyRules);
			assertEquals(0, switchManager.actualIndex);
			assertEquals(3, switchManager.normalRules.length);
			
			assertTrue(ABRTestUtils.equalRuleBaseVectors(rules, switchManager.normalRules));
						
			assertEquals(5, switchManager.minReliabilityRecordSize);
			assertEquals(30, switchManager.maxReliabilityRecordSize);
			
			assertEquals(0.9, switchManager.climbFactor);
			
			assertEquals(1, switchManager.maxUpSwitchLimit);
			assertEquals(2, switchManager.maxDownSwitchLimit);

			
		}
		
		
		[Test]
		public function testDefaultSwitchManagerInitNonDefault():void
		{
			var ruleWeights:Vector.<Number> = new Vector.<Number>();
			ruleWeights.push(0.7);
			ruleWeights.push(0.2);
			ruleWeights.push(0.1);
			
			rules = new Vector.<RuleBase>();
			
			emergencyRules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push(new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push(new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push(new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			emergencyRules.push(new RuleMocker(new Recommendation("emergencyrule1", 50, 1)));
			emergencyRules.push(new RuleMocker(new Recommendation("emergencyrule2", 60, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, emergencyRules, false, rules, ruleWeights, 0.89, 6, 16, 0.85, 3, 4);
			
			assertFalse(switchManager.autoSwitch);
			assertEquals(3, switchManager.normalRuleWeights.length);
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(int.MAX_VALUE, switchManager.maxAllowedIndex);
			assertEquals(0, switchManager.currentIndex);
			assertEquals(12 ,switchManager.metricRepository.metricFactory.numItems);
			assertNotNull(switchManager.emergencyRules);
			assertEquals(2, switchManager.emergencyRules.length);
			assertTrue(ABRTestUtils.equalRuleBaseVectors(emergencyRules, switchManager.emergencyRules));

			assertEquals(0, switchManager.actualIndex);
			assertEquals(3, switchManager.normalRules.length);
			assertTrue(ABRTestUtils.equalRuleBaseVectors(rules, switchManager.normalRules));

			assertEquals(0.89, switchManager.minReliability);
			
			assertEquals(6, switchManager.minReliabilityRecordSize);
			assertEquals(16, switchManager.maxReliabilityRecordSize);
			
			assertEquals(0.85, switchManager.climbFactor);
			
			assertEquals(3, switchManager.maxUpSwitchLimit);
			assertEquals(4, switchManager.maxDownSwitchLimit);
			
			assertFalse(switchManager.autoSwitch);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithNullNetStream():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(null, switcher, metricRepository, null, true, rules, ruleWeights);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithNullSwitcher():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, null, metricRepository, null, true, rules, ruleWeights);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithNullMetricRepository():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, null, null, true, rules, ruleWeights);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithNullRules():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, null, ruleWeights);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithEmptyRulesAndRuleWeights():void
		{
			var ruleWeights:Vector.<Number> = new Vector.<Number>();
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithNullRuleWeights():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, null);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithMinimumReliabilityNaN():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, null, NaN);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithNegativeMinimumReliability():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, -0.1 );
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithMinimumReliabilityGreaterThanOne():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 1.1);
		}
		
		[Test]
		public function testDefaultSwitchManagerInitWithMinimumReliabilityOne():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights,  1);
			assertEquals(1, switchManager.minReliability);
			
		}
		
		[Test]
		public function testDefaultSwitchManagerInitWithMinimumReliabilityZero():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 0);
			assertEquals(0, switchManager.minReliability);
			
		}
		
		public function testDefaultSwitchManagerInitWithIncorrectRecordSizeInterval():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 0.9, 20, 10);
			assertEquals(20, switchManager.minReliabilityRecordSize);
			assertEquals(20, switchManager.maxReliabilityRecordSize);
		}
		
		[Test(expects = "ArgumentError")]
		public function testDefaultSwitchManagerInitWithIncorrectRecordSizeMinimum():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 0.9, 0.5, 1, 14);
		}
		
		[Test]
		public function testDefaultSwitchManagerInitWithMinimumRecordInterval():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 0.9, 2, 2);
			
			assertEquals(2, switchManager.maxReliabilityRecordSize);
			assertEquals(2, switchManager.minReliabilityRecordSize);
		}
		
		
		public function testDefaultSwitchManagerInitWithZeroUpSwitchLimit():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 0.9, 4,29, 0.89, 0);
			assertEquals(-1, switchManager.maxUpSwitchLimit);
		}
		
		public function testDefaultSwitchManagerInitWithZeroDownSwitchLimit():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 0.9, 4,29, 0.89, 1, 0);
			assertEquals(-1, switchManager.maxUpSwitchLimit);
		}
		
		[Test]
		public function testDefaultSwitchManagerInitWithNegativeSwitchingLimits():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights,  1,5, 30, 0.9, -2, -3);
			assertEquals(-1, switchManager.maxUpSwitchLimit);
			assertEquals(-1, switchManager.maxDownSwitchLimit);
		}
		
		[Test]
		public function testSetMinimumReliability():void
		{
			createSwitchManager3Rules();
			switchManager.minReliability = 0.77;
			assertEquals(0.77, switchManager.minReliability);
			switchManager.minReliability = 0;
			assertEquals(0, switchManager.minReliability);
			switchManager.minReliability = 1;
			assertEquals(1, switchManager.minReliability);
		}
		
		[Test(expects = "ArgumentError")]
		public function testSetMinimumReliabilityNegative():void
		{
			createSwitchManager3Rules();
			switchManager.minReliability = -0.1;
		}
		
		[Test(expects = "ArgumentError")]
		public function testSetMinimumReliabilityGreaterThan1():void
		{
			createSwitchManager3Rules();
			switchManager.minReliability = 1.1;
		}
		
		[Test(expects = "ArgumentError")]
		public function testSetMinimumReliabilityNaN():void
		{
			createSwitchManager3Rules();
			switchManager.minReliability = NaN;
		}
		
		
		[Test(expects = "ArgumentError")]
		public function testSetClimbFactorNegative():void
		{
			createSwitchManager3Rules();
			switchManager.climbFactor = -0.1;
		}
		
		
		[Test(expects = "ArgumentError")]
		public function testSetClimbFactorNaN():void
		{
			createSwitchManager3Rules();
			switchManager.climbFactor = NaN;
		}
		
		[Test(expects = "ArgumentError")]
		public function testSetClimbFactorZero():void
		{
			createSwitchManager3Rules();
			switchManager.climbFactor = 0;
		}
		
		[Test]
		public function testGetAndSetRuleWeights():void
		{
			createSwitchManager3Rules();
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(0.2, switchManager.normalRuleWeights[1]);
			assertEquals(0.1, switchManager.normalRuleWeights[2]);
			switchManager.normalRuleWeights = generateWeights(10.1, 11.2, 12.3);
			
			assertEquals(10.1, switchManager.normalRuleWeights[0]);
			assertEquals(11.2, switchManager.normalRuleWeights[1]);
			assertEquals(12.3, switchManager.normalRuleWeights[2]);		
		}
		
		[Test]
		public function testGetAndSetRuleWeightsOneNotZero():void
		{
			createSwitchManager3Rules();
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(0.2, switchManager.normalRuleWeights[1]);
			assertEquals(0.1, switchManager.normalRuleWeights[2]);
			switchManager.normalRuleWeights = generateWeights(0, 2, 0);
			
			assertEquals(0, switchManager.normalRuleWeights[0]);
			assertEquals(2, switchManager.normalRuleWeights[1]);
			assertEquals(0, switchManager.normalRuleWeights[2]);		
		}
		
		[Test(expects = "ArgumentError")]
		public function testGetAndSetDifferentSizeRuleWeights():void
		{
			createSwitchManager3Rules();
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(0.2, switchManager.normalRuleWeights[1]);
			assertEquals(0.1, switchManager.normalRuleWeights[2]);
			switchManager.normalRuleWeights = generateWeights(10.1, 11.2, 12.3, 13.4);		
		}
		
		[Test(expects = "ArgumentError")]
		public function testGetAndSetAllZeroRuleWeights():void
		{
			createSwitchManager3Rules();
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(0.2, switchManager.normalRuleWeights[1]);
			assertEquals(0.1, switchManager.normalRuleWeights[2]);
			switchManager.normalRuleWeights = generateWeights(0, 0, 0);		
		}
		
		[Test(expects = "ArgumentError")]
		public function testGetAndSetNullRuleWeights():void
		{
			createSwitchManager3Rules();
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(0.2, switchManager.normalRuleWeights[1]);
			assertEquals(0.1, switchManager.normalRuleWeights[2]);
			switchManager.normalRuleWeights = null;		
		}
		
		
		[Test(expects = "ArgumentError")]
		public function testGetAndSetNegativeRuleWeights():void
		{
			createSwitchManager3Rules();
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(0.2, switchManager.normalRuleWeights[1]);
			assertEquals(0.1, switchManager.normalRuleWeights[2]);
			switchManager.normalRuleWeights = generateWeights(-2, 1, 1);		
		}
		
		[Test(expects = "ArgumentError")]
		public function testGetAndSetNaNRuleWeights():void
		{
			createSwitchManager3Rules();
			assertEquals(0.7, switchManager.normalRuleWeights[0]);
			assertEquals(0.2, switchManager.normalRuleWeights[1]);
			assertEquals(0.1, switchManager.normalRuleWeights[2]);
			switchManager.normalRuleWeights = generateWeights(NaN, 1, 1);		
		}
		
		public function testSetDownSwitchLimit():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			assertEquals(2, switchManager.maxDownSwitchLimit);
			switchManager.maxDownSwitchLimit = 0;
			assertEquals(-1, switchManager.maxDownSwitchLimit);
		}
		
		public function testSetUpSwitchLimit():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			assertEquals(1, switchManager.maxUpSwitchLimit);
			switchManager.maxUpSwitchLimit = 0;
			assertEquals(-1, switchManager.maxUpSwitchLimit);
		}
		
		[Test]
		public function testSetMaxDownAndUpSwitchLimit():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			assertEquals(1, switchManager.maxUpSwitchLimit);
			assertEquals(2, switchManager.maxDownSwitchLimit);
			switchManager.maxUpSwitchLimit = 3;	
			switchManager.maxDownSwitchLimit = 4;
			assertEquals(3, switchManager.maxUpSwitchLimit);
			assertEquals(4, switchManager.maxDownSwitchLimit);
			
			switchManager.maxUpSwitchLimit = -3;	
			switchManager.maxDownSwitchLimit = -4;
			assertEquals(-1, switchManager.maxUpSwitchLimit);
			assertEquals(-1, switchManager.maxDownSwitchLimit);
		}
		

		
		/**
		 * Test switch up 
		 * 
		 **/
		[Test]
		public function testGetNewIndexSwitchFrom0To1():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 320, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 310, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 300, 1);

			//should go to 250, switch up 1.
			assertEquals(1, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(250,true);
		}
		
		/**
		 * Test switch up blocked by security factor. 
		 * 
		 **/
		[Test]
		public function testGetNewIndexSwitchFrom2To3LimitedByFactor():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 420, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 410, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 400, 1);
			
			//setup: should go to 350, switch up 2.
			assertEquals(2, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(350,true);

			
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", (450 + (0.9-1) * 350) / 0.9 - 0.01, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 410, 0);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 400, 0);
			//instead of going to 450, switch up 3, should stay on 2
			assertEquals(2, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(350,true);

			
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", (450 + (0.9-1) * 350) / 0.9 + 0.01, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 410, 0);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 400, 0);
			//switch up to 450 = index 3 
			assertEquals(3, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(450,true);

		}
		
		
		/**
		 * Test switch down 
		 * 
		 **/
		[Test]
		public function testGetNewIndexSwitchFrom2To1():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 420, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 410, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 400, 1);
			
			//prepare switch, go to 350, switch up to stream 2.
			assertEquals(2, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(350,true);

			
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 320, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 310, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 300, 1);
			
			//should go to 250, switch down to 1.
			assertEquals(1, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(250,true);

		}
		
		
		
		/**
		 * Test unavailable AvailableBitratesMetric
		 * 
		 **/
		[Test(expects = "Error")]
		public function testGetNewIndexUnavailableAvailableBitratesMetric():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = false;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 320, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 310, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 300, 1);
						
			var i:int = switchManager.getNewIndex();

		}
		
		/**
		 * Test unavailable ActualBitrate
		 * Note: currentindex cannot be updated in unit tests, will test against a value of 0
		 * 
		 **/
		[Test]
		public function testGetNewIndexWhenActualBitrateIsInvalid():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 420, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 410, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 400, 1);
			
			//prepare switch, go to 350, switch up to stream 2.
			assertEquals(2, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			//make it invalid
			mockSwitchTo(350,false);
			
			//indirect evaluation of the currentIndex = 0
			//switch up to 2 should stop to 1
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 350*0.9 -0.01, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 310, 0);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 300, 0);
			
			
			assertEquals(1, switchManager.getNewIndex());
			
			mockSwitchTo(250,true);
			
		}
		
		[Test]
		public function testGetNewIndexSwitchOnSameIndex():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 420, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 410, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 400, 1);
			
			//prepare switch, go to 350, switch up to stream 2.
			assertEquals(2, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(350,true);
			
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 420, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 410, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 400, 1);
			
			//prepare switch, go to 350, switch up to stream 2.
			assertEquals(2, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(350,true);
			
		}
		
		/**
		 * Test switch up blocked by an unreliable bitrate level. 
		 * 
		 **/
		[Test]
		public function testGetNewIndexSwitchForUnreliableBitrate():void
		{
			//setup switches
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(3);
			mockRules(2);
			mockRules(3);
			mockRules(1);
			
			//real test, try to switch to 3
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 520, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 510, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 500, 1);
			//do not switch up due to low Reliability
			assertEquals(2, switchManager.getNewIndex());
			mockSwitchTo(350,true);
			
		}
		
		[Test]
		public function testGetReliability():void
		{
			//setup switches
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(3);
			mockRules(2);

			mockRules(3);
			
			var i:int;
			for (i = 0; i<5; i++)
				assertTrue(isNaN(switchManager.getCurrentReliability(i)));
			
			mockRules(1);
			
			assertEquals(1, switchManager.getCurrentReliability(0));
			assertTrue(isNaN(switchManager.getCurrentReliability(1)));
			assertEquals(1, switchManager.getCurrentReliability(2));
			assertEquals(1-(2*2)/(2*2), switchManager.getCurrentReliability(3));
			assertTrue(isNaN(switchManager.getCurrentReliability(4)));
			
			mockRules(2);
			mockRules(1);
			
			assertEquals(1, switchManager.getCurrentReliability(0));
			assertEquals(1, switchManager.getCurrentReliability(1));
			assertEquals(1-(1*1)/(2*3), switchManager.getCurrentReliability(2));
			assertEquals(1-(2*2)/(2*3), switchManager.getCurrentReliability(3));
			assertTrue(isNaN(switchManager.getCurrentReliability(4)));
		}
		
		[Test]
		public function testGetReliabilityforEmergencySwitches():void
		{
			//setup switches
			createSwitchManager3Rulesand2EmergencyRules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(3);
			mockRules(2);
			mockRules(4);
			
			var i:int;
			for (i = 0; i<5; i++)
				assertTrue(isNaN(switchManager.getCurrentReliability(i)));
			
			mockEmergencyRules(2);
			
			assertEquals(1, switchManager.getCurrentReliability(0));
			assertTrue(isNaN(switchManager.getCurrentReliability(1)));
			assertEquals(1, switchManager.getCurrentReliability(2));
			assertEquals(1-(1*1)/(1*2), switchManager.getCurrentReliability(3));
			assertEquals(0,switchManager.getCurrentReliability(4));
			
			mockRules(1);
			
			assertEquals(1, switchManager.getCurrentReliability(0));
			assertTrue(isNaN(switchManager.getCurrentReliability(1)));
			assertEquals(1-(1*1)/(2*3), switchManager.getCurrentReliability(2));
			assertEquals(1-(1*1)/(1*3), switchManager.getCurrentReliability(3));
			assertEquals(0,switchManager.getCurrentReliability(4));
			
			mockRules(1);
			
			assertEquals(1, switchManager.getCurrentReliability(0));
			assertEquals(1, switchManager.getCurrentReliability(1));
			assertEquals(1-(1*1)/(2*3), switchManager.getCurrentReliability(2));
			assertEquals(1-(1*1)/(1*3), switchManager.getCurrentReliability(3));
			assertEquals(0,switchManager.getCurrentReliability(4));
			
		}
		
		// http://bugs.adobe.com/jira/browse/FM-1493
		// [ABR] A stream should be marked unreliable if an emergency down switch occurred, even if the record is small
		[Test]
		public function testGetReliabilityforEmergencySwitchWithReliabilityRecordBelowMinThreshold():void
		{
			//setup switches
			createSwitchManager3Rulesand2EmergencyRules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(3);
			mockEmergencyRules(2);
			
			assertEquals(0,switchManager.getCurrentReliability(3));	
		}
		
		[Test]
		public function testGetReliabilityforEmergencySwitchesUpwards():void
		{
			//setup switches
			createSwitchManager3Rulesand2EmergencyRules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(1);
			mockRules(2);
			mockRules(2);
			mockRules(3);
			mockEmergencyRules(3);
			
			assertEquals(1, switchManager.getCurrentReliability(0));
			assertEquals(1, switchManager.getCurrentReliability(1));
			assertEquals(1, switchManager.getCurrentReliability(2));
			assertEquals(1, switchManager.getCurrentReliability(3));
			assertTrue(isNaN(switchManager.getCurrentReliability(4)));
			
			mockEmergencyRules(4);
			
			assertEquals(1, switchManager.getCurrentReliability(0));
			assertEquals(1, switchManager.getCurrentReliability(1));
			assertEquals(1, switchManager.getCurrentReliability(2));
			assertEquals(1, switchManager.getCurrentReliability(3));
			assertTrue(isNaN(switchManager.getCurrentReliability(4)));
			
			
		}
		
		
		/**
		 * Test PushToHistory indirect by checking reliability of an idex that should not be any more in history 
		 * 
		 **/
		[Test]
		public function testPushReliabilityToHistory():void
		{
			//setup switches 0/401230120101230/1
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			

			mockRules(4);
			mockRules(0);
			mockRules(1);
			mockRules(2);
			mockRules(3);
			mockRules(0);
			mockRules(1);
			mockRules(2);
			mockRules(0);
			mockRules(1);
			mockRules(0);
			mockRules(1);
			mockRules(2);
			mockRules(3);
			mockRules(0);
			assertEquals(1-(1*1)/(1*7), switchManager.getCurrentReliability(4));
			mockRules(1);
			//this is the main check
			assertTrue(isNaN(switchManager.getCurrentReliability(4)));
			
		}
		
		[Test]
		public function testGetNewIndexBitrateOverMax():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 3200, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 3100, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 3000, 1);
			
			//should go to 550, switch up 4.
			assertEquals(4, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(550,true);

		}
		
		[Test]
		public function testGetNewIndexBitrateUnderMin():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(4);

			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 32, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 31, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 30, 1);
			
			//should go to 150, switch down to 0.
			assertEquals(0, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(150,true);

		}
		
		[Test]
		public function testGetNewIndexBitrateIgnoreUnsureRules():void
		{
			createSwitchManager3Rules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(2);

			availableQualityMetric.returnValid = true;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 320, 0);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 310, 0);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 300, 0);
			
			//should stay on the same index
			assertEquals(2, switchManager.getNewIndex());
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(350,true);
		}
		
		
		[Test]
		public function testGetNewIndexForEmergencyRule():void
		{
			createSwitchManager3Rulesand2EmergencyRules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(3);
			
			mockRules(4);
			
			(emergencyRules[0] as RuleMocker).returnValue = new Recommendation("emergencyrule1", 320, 1);
			(emergencyRules[1] as RuleMocker).returnValue = new Recommendation("emergencyrule2", 220, 1);
			
			//call the algorithm run
			
			netStream.dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.RUN_ALGORITHM));
			
			//check the ideal zero-time switch result
			assertEquals(0, switcher.lastSwitchIndex);
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(150,true);
			
		}
		
		[Test]
		public function testGetNewIndexForUnsureEmergencyRule():void
		{
			createSwitchManager3Rulesand2EmergencyRules();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", 420, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 410, 1);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 400, 1);
			
			
			(emergencyRules[0] as RuleMocker).returnValue = new Recommendation("emergencyrule1", 320, 0.8);
			(emergencyRules[1] as RuleMocker).returnValue = new Recommendation("emergencyrule2", 220 ,0.6);
			//should go to 350
			//call the algorithm run
			
			netStream.dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.RUN_ALGORITHM));
			
			//check the ideal zero-time switch result
			assertEquals(2, switcher.lastSwitchIndex);
			
			//simmulate switch in metric 
			//the value should be around the declared bitrate
			mockSwitchTo(350,true);
		}
		
		
		/**
		 * Tests the initial value, more will be on integration tests
		 **/
		[Test]
		public function testGetCurrentIndex():void
		{
			createSwitchManager1Rule();
			assertEquals(0, switchManager.currentIndex);
		}
		
		[Test]
		public function testGetMetricRepository():void
		{
			createSwitchManager1Rule();
			assertTrue(switchManager.metricRepository is MetricRepository);
		}
		
		[Test]
		public function testGetCurrentReliability():void
		{
			createSwitchManager1Rule();
			assertTrue(isNaN(switchManager.getCurrentReliability(0)));
		}
		
		[Test]
		public function testAutoSwitch():void
		{
			//full test will be done in integration suite
			createSwitchManager1Rule();
			assertTrue( switchManager.autoSwitch);
			
			switchManager.autoSwitch = false;
			assertFalse(switchManager.autoSwitch);
			
	
			switchManager.autoSwitch = true;
			assertTrue( switchManager.autoSwitch);
		}
		
		
		/**
		 * Tests setting a maxallowedindex
		 * No negative tests, nothing is enforced
		 */
		[Test]
		public function testSetMaxAllowedIndex():void
		{
			createSwitchManager1Rule();
			assertEquals(int.MAX_VALUE, switchManager.maxAllowedIndex);
			
			switchManager.maxAllowedIndex = 4;
			assertEquals(4, switchManager.maxAllowedIndex);
			
		}
		
		[Test]
		public function testSwitchTo():void
		{
			createSwitchManager1Rule();
			switchManager.autoSwitch = false;
			switchManager.switchTo(3);
			
			assertEquals(3, (switcher as NetStreamSwitcherMocker).lastSwitchIndex);
		}
		
		[Test(expects = "flash.errors.IllegalOperationError")]
		public function testSwitchToInAutoSwitchMode():void
		{
			createSwitchManager1Rule();
			switchManager.switchTo(3);
		}
		
		
		[Test]
		public function testGetNewIndexForDownSwitchLimit():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(1);
			mockRules(2);
			mockRules(3);
			mockRules(4);
			//real test
			mockRules(0,2);
			
		}
		
		[Test]
		public function testGetNewIndexForUpSwitchLimit():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(4, 1);
			
		}
		
		[Test]
		public function testGetNewIndexForDownSwitchLimitAndUnreliable():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			switchManager.maxUpSwitchLimit = 10;
			
			mockRules(1);
			mockRules(2);
			mockEmergencyRules(1);
			mockRules(3);
			mockRules(4);
			//real test
			mockRules(0, 3);
			
		}
		
		[Test]
		public function testGetNewIndexForUpSwitchLimitAndUnreliable():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(1);
			mockRules(2);
			mockRules(3);
			mockEmergencyRules(2);
			mockRules(4, 2);
			
		}
		
		//this might overlap with another test
		[Test]
		public function testGetNewIndexForUpSwitchLimitAndUnreliableModifiedLimit():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			switchManager.maxUpSwitchLimit = 2;
			
			mockRules(1);
			mockRules(2);
			mockRules(3);
			mockRules(4);
			mockEmergencyRules(2);
			mockRules(4, 3);
		}
		
		
		[Test]
		public function testGetNewIndexForUpSwitchLimitAndNegativeMaxUpSwitchLimit():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit(-1,2);
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
		
			mockRules(4);
		}
		
		[Test]
		public function testGetNewIndexForDownSwitchLimitAndNegativeMaxDownSwitchLimit():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit(1,-1);
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(1);
			mockRules(2);
			mockRules(3);
			mockRules(4);
			
			mockRules(0);
		}
		
		[Test]
		public function testGetNewIndexForSwitchLimitAndNegativeMaxSwitchLimits():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit(-1,-1);
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(4);
			
			mockRules(0);
		}
		
		[Test]
		public function testGetNewIndexForUpSwitchEmergency():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;

			mockEmergencyRules(4);
		}
		
		[Test]
		public function testGetNewIndexForDownSwitchEmergency():void
		{
			createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit();
			availableQualityMetric.internalValue = qualityLevels;
			availableQualityMetric.returnValid = true;
			
			mockRules(1);
			mockRules(2);
			mockRules(3);
			mockRules(4);
			
			mockEmergencyRules(0);
		}
		
		
		
		private function createSwitchManager1Rule():void
		{
			var ruleWeights:Vector.<Number> =  generateWeights(0.6);
			
			rules = new Vector.<RuleBase>();
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");
			
			dsResource.streamItems = new Vector.<DynamicStreamingItem>();
			for (var i:uint = 0; i < 5; i++)
			{
				var streamItem:DynamicStreamingItem = new DynamicStreamingItem("stream" + i, 150 + i * 100);
				dsResource.streamItems.push(streamItem);
			}
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 0.91, 6, 16, 0.9, uint.MAX_VALUE, uint.MAX_VALUE);
			
			initMetrics();
			
		}
		
		private function createSwitchManager3Rules():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, null, true, rules, ruleWeights, 0.85, 5, 15, 0.9, uint.MAX_VALUE, uint.MAX_VALUE);
			
			initMetrics();
		}
		
		
		private function createSwitchManager3Rulesand2EmergencyRules():void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			emergencyRules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			emergencyRules.push( new RuleMocker(new Recommendation("emergencyrule1", 50, 0)));
			emergencyRules.push( new RuleMocker(new Recommendation("emergencyrule2", 60, 0)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, emergencyRules, true, rules, ruleWeights, 0.9, 5, 15, 0.9, uint.MAX_VALUE, uint.MAX_VALUE);
			
			initMetrics();
		}
		
		private function createSwitchManager3Rulesand2EmergencyRulesAndSwitchLimit(maxUp:int = 1, maxDown:int = 2):void
		{
			var ruleWeights:Vector.<Number> = generateWeights(0.7, 0.2, 0.1);
			
			rules = new Vector.<RuleBase>();
			emergencyRules = new Vector.<RuleBase>();
			
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("http://example.com/vod");			
			
			rules.push( new RuleMocker(new Recommendation("rule1", 500, 1)));
			rules.push( new RuleMocker(new Recommendation("rule2", 600, 1)));
			rules.push( new RuleMocker(new Recommendation("rule3", 700, 1)));
			
			emergencyRules.push( new RuleMocker(new Recommendation("emergencyrule1", 50, 0)));
			emergencyRules.push( new RuleMocker(new Recommendation("emergencyrule2", 60, 0)));
			
			switcher = new NetStreamSwitcherMocker(netStream, dsResource); 
			
			switchManager = new DefaultHTTPStreamingSwitchManager(netStream, switcher, metricRepository, emergencyRules, true, rules, ruleWeights, 0.9, 5, 15, 0.9, maxUp, maxDown);
			
			initMetrics();
		}
		
		private function initMetrics():void
		{
			availableQualityMetric = metricRepository.getMetric(MetricType.AVAILABLE_QUALITY_LEVELS) as AvailableQualityLevelsMetricMocker;
			actualBitrateMetric = metricRepository.getMetric(MetricType.ACTUAL_BITRATE, 10) as ActualBitrateMetricMocker;
			
			availableQualityMetric.returnValid = true;
			availableQualityMetric.internalValue = qualityLevels;
			
			mockSwitchTo(150,true);
		}
		
		
		private function generateWeights(... weights):Vector.<Number>
		{
			var v:Vector.<Number> = new Vector.<Number>();
			for(var i:uint = 0; i< weights.length; i++)
			{
				v[i] = weights[i] ;
			}
			return (v);
		}
		
		private function mockSwitchTo(value:Number, valid:Boolean = true):void
		{
			//simmulate switch in metric and switcher 
			//the value should be around the declared bitrate
			//qos needs to be updated to get the non-cached value
			actualBitrateMetric.internalValue = value;
			actualBitrateMetric.returnValid = valid;
			addQoSInfo(generateQoSInfo(mockTimestamp++, 150, 250, 350, 450, 550));	
			(switcher as NetStreamSwitcherMocker).actualIndex = (value - 150) / 100;
		}
		
		private function mockRules(index:int, targetIndex:int = -1):void
		{
			if (targetIndex==-1)
				targetIndex=index;
			var bitrate:Number = 150 + 100*index + 80;
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", bitrate, 1);
			(rules[1] as RuleMocker).returnValue = new Recommendation("rule2", 510, 0);
			(rules[2] as RuleMocker).returnValue = new Recommendation("rule3", 500, 0);
			
			//initiate and check if the correct switch is done
			netStream.dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.RUN_ALGORITHM));
			
			var newBitrate:Number = 150 + 100 * targetIndex + 80;
			//check the ideal zero-time switch result
			assertEquals(targetIndex, switcher.lastSwitchIndex);
			
			//simulate switch behind the scenes;
			mockSwitchTo(newBitrate, true);
			
			//clear emergency rules for a possible new switch
			(rules[0] as RuleMocker).returnValue = new Recommendation("rule1", newBitrate, 0);
		}
		
		private function mockEmergencyRules(index:int, targetIndex:int = -1):void
		{
			if (targetIndex==-1)
				targetIndex=index;
			var bitrate:Number = 150 + 100*index + 80;
			(emergencyRules[0] as RuleMocker).returnValue = new Recommendation("emergencyRule1", bitrate, 1);
			(emergencyRules[1] as RuleMocker).returnValue = new Recommendation("emergencyRule2", bitrate, 0);
			//initiate and check if the correct switch is done
			netStream.dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.RUN_ALGORITHM));
			//check the ideal zero-time switch result
			assertEquals(targetIndex, switcher.lastSwitchIndex);
			
			//simulate switch behind the scenes;
			
			var newBitrate:Number = 150 + 100 * targetIndex + 80;

			mockSwitchTo(newBitrate, true);
			//clear emergency rules for a possible new switch
			(emergencyRules[0] as RuleMocker).returnValue = new Recommendation("emergencyRule1", newBitrate, 0);
		}
		
		//helper different from qosinfo tests functions
		
		private function generateQoSInfo(timestamp:Number, ... qualityLevels):QoSInfo
		{
			var v:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			for(var i:uint = 0; i< qualityLevels.length; i++)
			{
				v[i] = new QualityLevel( i, qualityLevels[i], "test" + qualityLevels[i] );
			}
			return (new QoSInfo(timestamp, timestamp+5678, v, 0, 0, new FragmentDetails(14000, 4000, 568, 2)));
		}
		
		//helper identical to qosinfo tests functions
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		private var metricFactory:MetricFactory;
		private var metricRepository:MetricRepository;
		private var switchManager:DefaultHTTPStreamingSwitchManager;
		private var switcher:NetStreamSwitcherMocker;
		private var rules:Vector.<RuleBase>;
		private var emergencyRules:Vector.<RuleBase>;

		
		private var availableQualityMetric:AvailableQualityLevelsMetricMocker;
		private var actualBitrateMetric:ActualBitrateMetricMocker;
		
		private var qualityLevels:Vector.<QualityLevel>;
		
		private var mockTimestamp:int = 0;

		
	}
}