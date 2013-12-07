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
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import org.osmf.net.qos.QoSInfoHistory;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * MetricRepository is responsible with storing metrics.<br />
	 * It responds to requests containing the metric type and its parameters.<br />
	 * The MetricRepository will make use of a MetricFactory to create new metrics.<br />
	 * 
	 * @see org.osmf.net.abr.MetricFactory
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class MetricRepository
	{
		/**
		 * Constructor. Initializes the dictionary meant to hold the metrics.
		 * 
		 * @param metricFactory The MetricFactory object to be used for creating new metrics.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function MetricRepository(metricFactory:MetricFactory)
		{
			metrics = new Dictionary();
			
			if (metricFactory == null)
			{
				throw new ArgumentError("The metricFactory should not be null!");
			}
			_metricFactory = metricFactory;
		}
		
		/**
		 * The MetricFactory object to be used for creating new metrics.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get metricFactory():MetricFactory
		{
			return _metricFactory;
		}
		
		/**
		 * Returns a reference to a MetricBase of the specified type, 
		 * with the specified arguments. 
		 * 
		 * @param type The type of the metric
		 * @param args The arguments to be passed to the metric's constructor
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getMetric(type:String, ...args):MetricBase
		{
			var beginTime:int = getTimer();
			var keyArray:Array = args.slice();
			keyArray.splice(0, 0, type);
						
			if (metrics[type] == null)
			{
				metrics[type] = new Vector.<Array>;
			}
			
			for each (var entry:Array in metrics[type])
			{
				if (match(entry.slice(1), keyArray))
				{
					CONFIG::LOGGING
					{
						logger.debug("The metric of type '" + type + "' with the desired parameters is already in the repository. Finding it took: " + ((getTimer() - beginTime) / 1000.0) + " seconds.");
					}
					return entry[0];
				}
			}
			
			var newMetric:MetricBase = _metricFactory.buildMetric.apply(null, keyArray);
			keyArray.splice(0, 0, newMetric);
			
			metrics[type].push(keyArray);
			
			CONFIG::LOGGING
			{
				logger.debug("A new metric of type '" + type + "' had to be instantiated. This took: " + ((getTimer() - beginTime) / 1000.0) + " seconds.");
			}
			
			return newMetric;
		}

		private function match(a:*, b:*):Boolean
		{
			if (a == b)
			{
				return true;
			}
			
			if (a == null && b == null)
			{
				return true;
			}
			
			if (a is Number && b is Number && isNaN(a) && isNaN(b))
			{
				return true;
			}

			if ((isVector(a) && isVector(b)) || (a is Array && b is Array))
			{
				if (a.length != b.length)
				{
					return false;
				}
				
				for (var i:uint = 0; i < a.length; i++)
				{
					if (!match(a[i], b[i]))
					{
						return false;
					}
				}
				
				return true;
			}
			
			return false;
		}
		
		private function isVector(object:Object):Boolean 
		{
			var class_name:String = getQualifiedClassName(object);
			return class_name.indexOf("__AS3__.vec::Vector.") === 0;
		}
		
		/**
		 * The dictionary used to store the metrics. <br/>
		 * The keys are are arrays containing the type of the metric and its arguments.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private var metrics:Dictionary;
		
		private var lastKey:String;
		private var lastKeyByteArray:ByteArray;
		
		private var _metricFactory:MetricFactory = null;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.metrics.MetricRepository");
		}
	}
}