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
	 * Bandwidth metric
	 * Measurement unit: bytes / seconds 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class BandwidthMetric extends MetricBase
	{
		/**
		 * Constructor.
		 * 
		 * @param qosInfoHistory The QoSInfoHistory to be used for computing the metric
		 * @param weights The weights of the fragments (first values are the weights of the most recent fragments) 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function BandwidthMetric(qosInfoHistory:QoSInfoHistory, weights:Vector.<Number>)
		{
			super(qosInfoHistory, MetricType.BANDWIDTH);
			
			// Validate the weights
			ABRUtils.validateWeights(weights);

			_weights = weights.slice();
		}
		
		/**
		 * The weights of the fragments (starting with the most recent) 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get weights():Vector.<Number>
		{
			return _weights;
		}
		
		/**
		 * Computes the value of the bandwidth (in bytes/second)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override protected function getValueForced():MetricValue
		{
			var history:Vector.<QoSInfo> = qosInfoHistory.getHistory(_weights.length);
			
			var bandwidth:Number = 0;
			var weightSum:Number = 0;
			
			for (var i:uint = 0; i < history.length; i++)
			{
				var fragmentDetails:FragmentDetails = history[i].lastDownloadedFragmentDetails;
				var fragmentBandwidth:Number = fragmentDetails.size / fragmentDetails.downloadDuration;
				
				bandwidth += fragmentBandwidth * _weights[i];
				weightSum += _weights[i];
			}
			
			bandwidth /= weightSum;
			
			CONFIG::LOGGING
			{
				logger.info("Bandwidth metric is valid and has value: " + ABRUtils.roundNumber(bandwidth) + " B/s");
			}
			
			return new MetricValue(bandwidth, true);
		}
		
		private var _weights:Vector.<Number>;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.metrics.BandwidthMetric");
		}
	}
}