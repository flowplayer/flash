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
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * Metric specifying whether a switch occurred recently
	 * (checks if the last downloaded fragment is from a different quality than the previous one).<br /> 
	 * The metric will specify the switch type (up-switch or down-switch).<br />
	 * This metric's type is MetricType.RECENT_SWITCH (<i>org.osmf.net.abr.metrics.recentSwitch</i>)
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class RecentSwitchMetric extends MetricBase
	{
		/**
		 * Constructor.
		 * 
		 * @param qosInfoHistory The QoSInfoHistory to be used for computing the metric 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function RecentSwitchMetric(qosInfoHistory:QoSInfoHistory)
		{
			super(qosInfoHistory, MetricType.RECENT_SWITCH);
		}
		
		/**
		 * Specifies the difference between the indices of the last downloaded fragment
		 * and the previous one. In case only one fragment is in the history, the metric will return 0.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override protected function getValueForced():MetricValue
		{
			var history:Vector.<QoSInfo> = qosInfoHistory.getHistory(2);

			var difference:int = 0;
			
			if (history.length >= 2)
			{
				var newFragmentDetails:FragmentDetails = history[0].lastDownloadedFragmentDetails;
				var oldFragmentDetails:FragmentDetails = history[1].lastDownloadedFragmentDetails;
				
				if (newFragmentDetails == null || oldFragmentDetails == null)
				{
					CONFIG::LOGGING
					{
						logger.info("Recent switch metric is invalid, since fragment details are not present in QoS");
					}
					
					return new MetricValue(undefined, false);
				}
				
				difference = newFragmentDetails.index - oldFragmentDetails.index;
			}
			else
			{
				CONFIG::LOGGING
				{
					logger.info("Recent switch metric is invalid, since fragment details are not present in QoS");
				}
				
				return new MetricValue(undefined, false);
			}
			
			CONFIG::LOGGING
			{
				logger.info("Recent switch metric is valid and has value: " + difference);
			}
			
			return new MetricValue(difference, true);
		}
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.metrics.RecentSwitchMetric");
		}
	}
}