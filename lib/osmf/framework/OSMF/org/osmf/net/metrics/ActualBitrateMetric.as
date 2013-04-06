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
	import org.osmf.net.ABRUtils;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * Metric computing the actual bitrate of the currently downloading quality level.<br />
	 * This metric's type is MetricType.ACTUAL_BITRATE (<i>org.osmf.net.abr.metrics.actualBitrate</i>)
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class ActualBitrateMetric extends MetricBase
	{
		/**
		 * Constructor.
		 * 
		 * @param qosInfoHistory The QoSInfoHistory to be used for computing the metric 
		 * @param maxFragments The maximum number of fragments on which to compute the metric.
		 *        The metric will be computed on a lower number of fragments, if less than
		 *        maxFragments fragments are available in the QoSInfoHistory.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function ActualBitrateMetric(qosInfoHistory:QoSInfoHistory, maxFragments:uint = 5)
		{
			super(qosInfoHistory, MetricType.ACTUAL_BITRATE);
			
			this.maxFragments = maxFragments;
		}
		
		/**
		 * The maximum number of fragments on which to compute the metric.
		 * The metric will be computed on a lower number of fragments, if less than
		 * <code>maxFragments</code> fragments are available in the QoSInfoHistory.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get maxFragments():uint
		{
			return _maxFragments;
		}
		
		public function set maxFragments(value:uint):void
		{
			if (value < 1)
			{
				throw new ArgumentError("Invalid value for 'maxFragments'.");
			}
			
			_maxFragments = value;
		}
		
		/**
		 * Computes the value of the actual bitrate (in kbps) of the currently downloading quality level
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override protected function getValueForced():MetricValue
		{
			var history:Vector.<QoSInfo> = qosInfoHistory.getHistory(_maxFragments);
			
			var actualIndex:int = history[0].actualIndex;
			
			var totalSize:Number = 0;
			var totalPlayDuration:Number = 0;
			
			CONFIG::LOGGING
			{
				logger.debug("Fragments considered in computation:");
			}

			for each (var qosInfo:QoSInfo in history)
			{
				if (qosInfo.lastDownloadedFragmentDetails.index == actualIndex)
				{
					var fragmentDetails:FragmentDetails = qosInfo.lastDownloadedFragmentDetails;
					totalSize += fragmentDetails.size;
					totalPlayDuration += fragmentDetails.playDuration;
					
					CONFIG::LOGGING
					{
						logger.debug(" Fragment. Size = " + fragmentDetails.size + "; playDuration = " + fragmentDetails.playDuration);
					}
				}
			}
			
			if (totalPlayDuration == 0)
			{
				CONFIG::LOGGING
				{
					logger.info("Actual bitrate metric is invalid, as the total play duration of the fragments is 0.");
				}
				return new MetricValue(undefined, false);
			}
			
			var actualBitrate:Number = totalSize / totalPlayDuration * 8 / 1000;
			
			CONFIG::LOGGING
			{
				logger.info("Actual bitrate metric is valid and has value: " + ABRUtils.roundNumber(actualBitrate));
			}
			
			return new MetricValue(actualBitrate, true);
		}
		
		private var _maxFragments:uint;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.metrics.ActualBitrateMetric");
		}
	}
}