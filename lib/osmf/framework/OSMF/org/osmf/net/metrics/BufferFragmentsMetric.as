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
	 * BufferFragmentsMetric computes the number of fragments in the buffer
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class BufferFragmentsMetric extends MetricBase
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
		public function BufferFragmentsMetric(qosInfoHistory:QoSInfoHistory)
		{
			super(qosInfoHistory, MetricType.BUFFER_FRAGMENTS);
		}
		
		/**
		 * Computes the number of fragments in the buffer (only the whole fragments)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override protected function getValueForced():MetricValue
		{
			var history:Vector.<QoSInfo> = qosInfoHistory.getHistory();

			var bufferLength:Number = history[0].bufferLength;
			
			if (isNaN(bufferLength) || bufferLength < 0)
			{
				CONFIG::LOGGING
				{
					logger.info("Buffer fragments metric is not valid, as the bufferLength is not available in the QoSInfo");
				}
				return new MetricValue(undefined, false);
			}
			
			var fragmentsPlayDuration:Number = 0;
			var count:Number = 0;
			
			while (count < history.length)
			{
				var qosInfo:QoSInfo = history[count];
				fragmentsPlayDuration += qosInfo.lastDownloadedFragmentDetails.playDuration;
				if (fragmentsPlayDuration > bufferLength)
				{
					break;
				}
				count++;
			}
			
			CONFIG::LOGGING
			{
				logger.info("Buffer fragments metric is valid and has value: " + count);
			}
			
			return new MetricValue(count, true);
		}
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.metrics.BufferFragmentsMetric");
		}
	}
}