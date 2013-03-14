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
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * Empty Buffer Metric. 
	 * Signals whether an empty buffer interruption of playback
	 * was reported in the last QoSInfo. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class EmptyBufferMetric extends MetricBase
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
		public function EmptyBufferMetric(qosInfoHistory:QoSInfoHistory)
		{
			super(qosInfoHistory, MetricType.EMPTY_BUFFER);
		}
		
		/**
		 * Computes the value of the Empty Buffer Interruption Metric
		 * 
		 * @return The value of the empty buffer interruption flag in the last QoSInfo
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override protected function getValueForced():MetricValue
		{
			var latestQoSInfo:QoSInfo = qosInfoHistory.getLatestQoSInfo();
			
			CONFIG::LOGGING
			{
				logger.info("EmptyBuffer metric is valid and has value: " + latestQoSInfo.emptyBufferOccurred);
			}
			
			return new MetricValue(latestQoSInfo.emptyBufferOccurred, true);
		}
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.metrics.EmptyBufferMetric");
		}
	}
}