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
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.internals.runners.statements.ExpectException;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QoSInfoHistoryGenerator;

	public class TestMetricFactory
	{
		[Before]
		public function setUp():void
		{
			var conn:NetConnection = new NetConnection();
			conn.connect(null);
			var ns:NetStream = new NetStream(conn);
			var qosInfoHistory:QoSInfoHistory = new QoSInfoHistory(ns);
			factory = new MetricFactory(qosInfoHistory);
		}
		
		[After]
		public function tearDown():void
		{
			factory = null;
		}
		
		[Test]
		public function testAddItem():void
		{
			
			//check initial conditions
			assertEquals(factory.numItems, 0);
			assertNotNull(factory.getItems());
			assertEquals(0,factory.getItems().length);

			// create a MetricFactoryItem
			var item:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			
			//checks the type of the item
			assertEquals(METRIC_TYPE_1, item.type);

			// add the item
			factory.addItem(item);
			
			// check that the item is the only one in the list
			assertEquals(factory.numItems, 1);
			assertEquals(factory.getItem(METRIC_TYPE_1), item);
		}
		
		[Test]
		public function testRemoveItem():void
		{
			// create a MetricFactoryItem
			var item:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			
			// add the item
			factory.addItem(item);
			
			// remove the item
			factory.removeItem(item);
			
			// check that the factory has no items
			assertEquals(factory.numItems, 0);
			assertNull(factory.getItem(METRIC_TYPE_1));
		}
		
		[Test]
		public function testRemoveNonExistingItem():void
		{
			// create a MetricFactoryItem
			var item:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			
			var item2:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_3);
			
			// add the item
			factory.addItem(item);
			
			// remove the item
			factory.removeItem(item2);
			
			// check that the factory still has 1 item
			assertEquals(factory.numItems, 1);
		}
		
		
		[Test(expects="ArgumentError")]
		public function testRemoveNullItem():void
		{
			// create a MetricFactoryItem
			var item:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			
			// add the item
			factory.addItem(item);
			
			// remove the item
			factory.removeItem(null);

		}
		
		[Test(expects="ArgumentError")]
		public function testAddNullItem():void
		{
			// add the item
			factory.addItem(null);	
		}
		
		[Test]
		public function testGetItemList():void
		{
			// create two items
			var item1:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			var item2:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_2);
			
			// add them to the factory
			factory.addItem(item1);
			factory.addItem(item2);
			
			// check that the list contains them both
			var itemList:Vector.<MetricFactoryItem> = factory.getItems();
			
			assertEquals(itemList.length, 2);
			var item1Found:Boolean = false;
			var item2Found:Boolean = false;
			
			for each (var item:MetricFactoryItem in itemList)
			{
				if (item == item1)
				{
					item1Found = true;
				}
				else if (item == item2)
				{
					item2Found = true;
				}
			}
			
			assertTrue(item1Found && item2Found);
		}
		
		[Test]
		public function testBuildMetricValid():void
		{
			// create two items
			var item1:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			var item2:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_2);
			
			// add them to the factory
			factory.addItem(item1);
			factory.addItem(item2);
			
			var metric:MetricMocker = factory.buildMetric(METRIC_TYPE_1, null) as MetricMocker;
			
			assertEquals(metric.type, METRIC_TYPE_1);
		}
		
		[Test]
		public function testBuildMetricAddSimilarMetricTwice():void
		{
			// create two items
			var item1:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			var item2:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			
			// add them to the factory
			factory.addItem(item1);
			factory.addItem(item2);
			
			var metric:MetricMocker = factory.buildMetric(METRIC_TYPE_1, null) as MetricMocker;
			
			assertEquals(1,factory.numItems);
			assertStrictlyEquals(item2,factory.getItem(METRIC_TYPE_1));
			
			assertEquals(metric.type, METRIC_TYPE_1);
		}
		
		[Test]
		public function testBuildMetricAddSameMetricTwice():void
		{
			// create two items
			var item1:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			
			// add them to the factory
			factory.addItem(item1);
			factory.addItem(item1);
			
			assertEquals(1,factory.numItems);
			var metric:MetricMocker = factory.buildMetric(METRIC_TYPE_1, null) as MetricMocker;
			
			assertEquals(metric.type, METRIC_TYPE_1);
		}
		
		
		[Test]
		public function testGetItemByType():void
		{	
			// create a MetricFactoryItem
			var item:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			
			// add the item
			factory.addItem(item);
			
			// check that the item is the only one in the list
			assertEquals(factory.numItems, 1);
			assertEquals(factory.getItem(METRIC_TYPE_1), item);
			
			//check 2 negative tests
			assertNull(factory.getItem(METRIC_TYPE_3));
			assertNull(factory.getItem(null));
			
		}
		
		[Test(expects="org.osmf.events.MetricError")]
		public function testBuildMetricInvalid():void
		{
			// create two items
			var item1:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_1);
			var item2:MetricFactoryItem = getMetricFactoryItem(METRIC_TYPE_2);
			
			// add them to the factory
			factory.addItem(item1);
			factory.addItem(item2);
			
			var metric:MetricMocker = factory.buildMetric(METRIC_TYPE_3, null) as MetricMocker;
		}
		
		[Test(expects="org.osmf.events.MetricError")]
		public function testBuildMetricNullType():void
		{
			
			var metric:MetricMocker = factory.buildMetric(null, 4) as MetricMocker;
		}
		[Test(expects="org.osmf.events.MetricError")]
		public function testBuildMetricEmptyType():void
		{
			
			var metric:MetricMocker = factory.buildMetric("", 4) as MetricMocker;
		}
				
		private function getMetricFactoryItem(type:String):MetricFactoryItem
		{
			return new MetricFactoryItem
				( type
					, function(qosInfoHistory:QoSInfoHistory, ...args):MetricBase
					{
						return new MetricMocker(type, QoSInfoHistoryGenerator.generateSampleQoSInfoHistory());
					}
				);
		}
		
		private var factory:MetricFactory;
		
		private static const METRIC_TYPE_1:String = "com.example.metrics.sample1";
		private static const METRIC_TYPE_2:String = "com.example.metrics.sample2";
		private static const METRIC_TYPE_3:String = "com.example.metrics.sample3";
	}
}