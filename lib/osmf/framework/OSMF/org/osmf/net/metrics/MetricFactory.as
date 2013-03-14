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
	import flash.utils.Dictionary;
	
	import org.osmf.events.MetricError;
	import org.osmf.events.MetricErrorCodes;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.utils.OSMFStrings;

	/**
	 * MetricFactory represents a factory class for metrics.
	 * 
	 * <p>The factory operation produces a MetricBase as output.</p>
	 * <p>The MetricFactory maintains a list of MetricFactoryItem objects,
	 * each of which encapsulates all the information necessary to create 
	 * a specific metric.</p>
	 * 
	 * @see org.osmf.net.abr.MetricBase
	 * @see org.osmf.net.abr.DefaultMetricFactory
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 * 
	 */	
	public class MetricFactory
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function MetricFactory(qosInfoHistory:QoSInfoHistory)
		{
			_qosInfoHistory = qosInfoHistory;
			items = new Dictionary();
			_numItems = 0;
		}
		
		/**
		 * Adds the specified MetricFactoryItem to the factory.
		 * 
		 * If a MetricFactoryItem with the same ID already exists in this
		 * factory, the new MetricFactoryItem object replaces it.
		 * 
		 * @param item The MetricFactoryItem to add.
		 * 
		 * @throws ArgumentError If the argument is <code>null</code> or if the argument
		 * has a <code>null</code> type field.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function addItem(item:MetricFactoryItem):void
		{
			if (item == null || item.type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			// increase the number of items in case it's a new type
			if (items[item.type] == null)
			{
				_numItems++;
			}
			
			// Overwrite in case an item with the same type already exists
			items[item.type] = item;
		}
		
		/**
		 * Removes the specified MetricFactoryItem from the factory.
		 * 
		 * If no such MetricFactoryItem exists in this factory, does nothing.
		 * 
		 * @param item The MetricFactoryItem to remove.
		 * 
		 * @throws ArgumentError If the argument is <code>null</code> or if the argument
		 * has a <code>null</code> type field.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function removeItem(item:MetricFactoryItem):void
		{
			if (item == null || item.type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}

			// Decrease the number of items if there was in fact an item with the specified type
			if (items[item.type] != null)
			{
				_numItems--;
			}
			
			items[item.type] = null;
			// Nothing happens if no MetricFactoryItem with the specified type exists
		}
		
		/**
		 * The registered items
		 * 
		 * @return A new Vector.&lt;MetricFactoryItem&gt; containing the registered items
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getItems():Vector.<MetricFactoryItem>
		{
			var itemList:Vector.<MetricFactoryItem> = new Vector.<MetricFactoryItem>;
			
			for each (var value:MetricFactoryItem in items)
			{
				itemList.push(value);
			}
			
			return itemList;
		}
		
		/**
		 * The item corresponding to the specified metric type
		 *  
		 * @return The item corresponding to the specified type or null if no such item exists
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getItem(type:String):MetricFactoryItem
		{
			return items[type];
		}
		
		/**
		 * The number of items
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get numItems():Number
		{
			return _numItems;
		}
		
		/**
		 * Produces a MetricBase.
		 * 
		 * @param type The type of the metric to create.
		 * @param args The arguments to be passed to the metric's constructor (except the qosInfoHistory)
		 * 
		 * @return A new MetricBase of the desired type with the specified parameters
		 * 
		 * @throws ABRError If the type is not registered with any MetricFactoryItem.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function buildMetric(type:String, ...args):MetricBase
		{
			if (items[type] == null)
			{
				throw new MetricError(MetricErrorCodes.INVALID_METRIC_TYPE);
			}
			
			var item:MetricFactoryItem = items[type] as MetricFactoryItem;
			
			args.splice(0, 0, _qosInfoHistory);
			
			return item.metricCreationFunction.apply(null, args);
		}
		
		private var items:Dictionary;
		private var _numItems:Number;
		private var _qosInfoHistory:QoSInfoHistory;
	}
}