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
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	
	public class TestRecommendation
	{		
		[Before]
		public function setUp():void
		{
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
		public function testGet():void
		{
			recommendation = new Recommendation(RULE_TYPE, 467.8, 0.88);
			assertEquals(RULE_TYPE, recommendation.ruleType);
			assertEquals(467.8, recommendation.bitrate);
			assertEquals(0.88, recommendation.confidence);
		}
		
		
		[Test]
		public function testRecommendationInitValidConfidence():void
		{
			recommendation = new Recommendation(RULE_TYPE, 467.8, 0);
			assertEquals(RULE_TYPE, recommendation.ruleType);
			assertEquals(467.8, recommendation.bitrate);
			assertEquals(0, recommendation.confidence);
			
			recommendation = new Recommendation(RULE_TYPE, 467.8, 1);
			assertEquals(467.8, recommendation.bitrate);
			assertEquals(1, recommendation.confidence);
			
			recommendation = new Recommendation(RULE_TYPE, 467.8, 0.2);
			assertEquals(467.8, recommendation.bitrate);
			assertEquals(0.2, recommendation.confidence);
		}
		
		[Test]
		public function testRecommendationInitValidBitrate():void
		{
			recommendation = new Recommendation(RULE_TYPE, 0, 0.5);
			assertEquals(0, recommendation.bitrate);
			assertEquals(0.5, recommendation.confidence);
			
			recommendation = new Recommendation(RULE_TYPE, 467, 0.5);
			assertEquals(467, recommendation.bitrate);
			assertEquals(0.5, recommendation.confidence);
			
			recommendation = new Recommendation(RULE_TYPE, 467.8, 0.5);
			assertEquals(467.8, recommendation.bitrate);
			assertEquals(0.5, recommendation.confidence);
		}
		
		[Test(expects="ArgumentError")]
		public function testRecommendationInvalidConfidenceNaN():void
		{
			recommendation = new Recommendation(RULE_TYPE, 400, Number.NaN);
		}
		[Test(expects="ArgumentError")]
		public function testRecommendationInvalidConfidenceNegative():void
		{
			recommendation = new Recommendation(RULE_TYPE, 400, -0.1);
		}
		[Test(expects="ArgumentError")]
		public function testRecommendationInvalidConfidenceOverOne():void
		{
			recommendation = new Recommendation(RULE_TYPE, 400, 1.1);
		}
		
		[Test(expects="ArgumentError")]
		public function testRecommendationInvalidBitrateNegative():void
		{
			recommendation = new Recommendation(RULE_TYPE, -0.1, 0.5);
		}
		[Test(expects="ArgumentError")]
		public function testRecommendationInvalidBitrateNaN():void
		{
			recommendation = new Recommendation(RULE_TYPE, Number.NaN, 0.5);
		}
		[Test(expects="ArgumentError")]
		public function testRecommendationInvalidRuleType():void
		{
			recommendation = new Recommendation(null, 400, 0.5);
		}
		
		private var recommendation:Recommendation;
		private static const RULE_TYPE:String = "sample_rule_type";
	}
}