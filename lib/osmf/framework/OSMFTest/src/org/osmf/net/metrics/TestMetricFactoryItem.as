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
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.internals.runners.statements.ExpectException;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QoSInfoHistoryGenerator;
	
	public class TestMetricFactoryItem
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
		public function testMetricFactoryItemGet():void
		{
			var f:Function = function(qosInfoHistory:QoSInfoHistory, ...args):MetricBase
			{
				return new MetricMocker(METRIC_TYPE_1, QoSInfoHistoryGenerator.generateEmptyQoSInfoHistory());
			};
			
			metricFactoryItem = new MetricFactoryItem(METRIC_TYPE_1, f);
			
			assertEquals(METRIC_TYPE_1, metricFactoryItem.type);
			assertStrictlyEquals(f, metricFactoryItem.metricCreationFunction);
			
			assertTrue(metricFactoryItem.metricCreationFunction(null) is MetricBase);
		}
		
		
		[Test(expects="ArgumentError")]
		public function testMetricFactoryItemInitTypeNull():void
		{
			metricFactoryItem = new MetricFactoryItem(null,
				function(qosInfoHistory:QoSInfoHistory, ...args):MetricBase
				{
					return new MetricMocker(METRIC_TYPE_1, qosInfoHistory);
				});
		}
		
		[Test(expects="ArgumentError")]
		public function testMetricFactoryItemInitFunctionNull():void
		{
			metricFactoryItem = new MetricFactoryItem(METRIC_TYPE_1,null);
		}
		
		private var metricFactoryItem:MetricFactoryItem;
		
		private static const METRIC_TYPE_1:String = "com.example.metrics.sample1";

	}
}