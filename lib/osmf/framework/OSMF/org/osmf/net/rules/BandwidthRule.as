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
package org.osmf.net.rules
{
	import flash.utils.getTimer;
	
	import org.osmf.net.ABRUtils;
	import org.osmf.net.metrics.BandwidthMetric;
	import org.osmf.net.metrics.MetricBase;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.metrics.MetricType;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * BandwidthRule recommends the value of the BandwidthMetric
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class BandwidthRule extends RuleBase 
	{
		/**
		 * Constructor.
		 * 
		 * @param metricRepository The metric repository from which to retrieve the necessary metrics
		 * @param weights The weights of the fragments (first values are the weights of the most recent fragments)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function BandwidthRule(metricRepository:MetricRepository, weights:Vector.<Number>)
		{
			super(metricRepository);
			
			// Validate the weights
			ABRUtils.validateWeights(weights);
			
			_weights = weights.slice();
		}
		
		/**
		 * The weights of the fragments (first values are the weights of the most recent fragments
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
		 * The recommendation:
		 * <ul>
		 *  <li><b>Bitrate:</b> The value of the BandwidthMetric</li>
		 *  <li><b>Confidence:</b> Scaled according to the weights and the number of available fragments</li>
		 * </ul>
		 * <br />
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override public function getRecommendation():Recommendation
		{
			if (bandwidthMetric == null)
			{
				bandwidthMetric = _metricRepository.getMetric(MetricType.BANDWIDTH, _weights);
			}
			
			if (fragmentCountMetric == null)
			{
				fragmentCountMetric = _metricRepository.getMetric(MetricType.FRAGMENT_COUNT);
			}
						
			if (!bandwidthMetric.value.valid || !fragmentCountMetric.value.valid)
			{
				CONFIG::LOGGING
				{
					logger.info("One of the required metrics is not valid so return a zero-confidence recommendation.");
				}
				return new Recommendation(RuleType.BANDWIDTH, 0, 0);
			}
			
			var bitrate:Number = (bandwidthMetric.value.value as Number) / 1000 * 8; // convert from B/s to kbps
			
			CONFIG::LOGGING
			{
				logger.info("Computed bitrate: " + ABRUtils.roundNumber(bitrate) + " kbps");
			}
			
			var fragmentCount:uint = fragmentCountMetric.value.value as uint;
			
			if (fragmentCount > _weights.length)
			{
				fragmentCount = _weights.length;
			}
			
			var confidence:Number = 0;
			var weightSum:Number = 0;
			for (var i:uint = 0; i < _weights.length; i++)
			{
				weightSum += _weights[i];
				if (i < fragmentCount)
				{
					confidence += _weights[i];
				}
			}
			
			confidence /= weightSum;
			
			CONFIG::LOGGING
			{
				logger.info("Recommend: bitrate = " + ABRUtils.roundNumber(bitrate) + " kbps; confidence = " + ABRUtils.roundNumber(confidence));
			}
			
			return new Recommendation(RuleType.BANDWIDTH, bitrate, confidence);
		}

		private var _weights:Vector.<Number>;
		
		// Metrics
		private var bandwidthMetric:MetricBase;
		private var fragmentCountMetric:MetricBase;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rules.BandwidthRule");
		}
	}
}