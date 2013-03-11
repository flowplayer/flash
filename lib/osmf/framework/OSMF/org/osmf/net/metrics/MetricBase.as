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
	import flash.errors.IllegalOperationError;
	import flash.utils.getTimer;
	
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * <p>MetricBase is a base class for metrics used for Adaptive Bitrate.
	 * A metric's value is computed based on QoSInfoHistory.
	 * A metric is identified by its type.</p>
	 * 
	 * <p>The base class handles the caching of the computed value.
	 * The subclasses should only implement the actual computation.</p>
	 * 
	 * <p>All subclasses should have <code>qosInfoHistory</code> as the first parameter in the constructor.</p>
	 * <p>All subclasses must set the <code>_type</code> in the constructor.</p>
	 * 
	 *  @see org.osmf.net.abr.MetricType
	 *  @see org.osmf.net.abr.MetricValue
	 * 	@see org.osmf.net.abr.QoSInfoHistory
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class MetricBase
	{
		/**
		 * Constructor.
		 * 
		 * @param qosInfoHistory The QoSInfoHistory to be used for computing the metric
		 * @param type The type of the metric
		 */
		public function MetricBase(qosInfoHistory:QoSInfoHistory, type:String)
		{
			if (qosInfoHistory == null)
			{
				throw new ArgumentError("qosInfoHistory cannot be null.");
			}
			_qosInfoHistory = qosInfoHistory;
			
			_type = type;
			
			lastValue = new MetricValue(undefined, false);
		}
		
		/**
		 * The type of the metric
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get type():String
		{
			return _type;
		}
		
		/**
		 * The value of this metric<br /> 
		 * If the value has already been computed for the most recent QoSInfo,
		 * return the cached result.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public final function get value():MetricValue
		{
			// Defer the computation to an internal function
			// This will make it easier to create metric mockers
			return getValue();
		}
		
		/**
		 * The value of this metric<br /> 
		 * If the value has already been computed for the most recent QoSInfo,
		 * return the cached result.<br />
		 * 
		 * This method is internal so it can be overriden by metric mockers, 
		 * for testing purposes
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		internal function getValue():MetricValue
		{
			CONFIG::LOGGING
			{
				var beginTime:int = getTimer();
			}
			
			var history:Vector.<QoSInfo> = _qosInfoHistory.getHistory();
			if (history.length > 0)
			{
				if (history[0].timestamp != lastMachineTime)
				{
					lastValue = getValueForced();
					lastMachineTime = history[0].timestamp;
					
					CONFIG::LOGGING
					{
						logger.debug("The value of the '" + _type + "' metric was computed in: " + ((getTimer() - beginTime) / 1000.0) + " seconds.");
					}
				}
				else
				{
					CONFIG::LOGGING
					{
						logger.debug("The value of the '" + _type + "' metric is cached. Fetching it took: " + ((getTimer() - beginTime) / 1000.0) + " seconds.");
					}
				}
				
				return lastValue;
			}
			else
			{
				CONFIG::LOGGING
				{
					logger.info("No QoS history available. Returning undefined value for metric '" + _type + "'.");
				}
				return new MetricValue(undefined, false);
			}
		}
		
		/**
		 * Computes the value of this metric
		 * <br />
		 * Subclasses must override to provide a specific implementation.
		 * 
		 * @return The MetricValue result of the computation
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		protected function getValueForced():MetricValue
		{
			throw new IllegalOperationError("The getValueForced() method must be overridden by the derived class.");
		}
		
		/**
		 * The QoSInfoHistory object used to compute the metric.
		 * <br />
		 * It is only accessible to sublcasses.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		protected function get qosInfoHistory():QoSInfoHistory
		{
			return _qosInfoHistory;
		}
		
		/**
		 * The type of the metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private var _type:String = null;
		
		/**
		 * <p>The value of the machineTime property of the most recent QoSInfo
		 * in the QoSInfoHistory.</p>
		 * 
		 * <p>It is used in order to cache results and avoid recomputation of the metric.</p>
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private var lastMachineTime:Number = NaN;
		
		/**
		 * Stores the last computed value of the metric.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private var lastValue:MetricValue;
		
		/**
		 * The QoSInfoHistory object used to compute the metric.<br />
		 * The subclasses have read-only access to it via the qosInfoHistory getter.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private var _qosInfoHistory:QoSInfoHistory;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.metrics.MetricBase");
		}
	}
}