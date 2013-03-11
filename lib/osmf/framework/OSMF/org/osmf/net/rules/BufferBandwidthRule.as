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
	import org.osmf.net.metrics.MetricBase;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.metrics.MetricType;
	import org.osmf.net.metrics.MetricValue;
	import org.osmf.net.qos.QualityLevel;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * BufferBandwidthRule is an enhanced version of BandwidthRule<br />
	 * The change is that if the BandwidthRule recommends a lower bitrate than the current one,
	 * the BufferBandwidthRule overrides that low recommendation with the current bitrate if
	 * there are enough fragments in the buffer (we can afford to stick to this bitrate for now, 
	 * since we have a large enough buffer)
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class BufferBandwidthRule extends BandwidthRule
	{
		/**
		 * Constructor.
		 * 
		 * @param metricRepository The metric repository from which to retrieve the necessary metrics
		 * @param weights The weights of the fragments (first values are the weights of the most recent fragments) 
		 * @param bufferFragmentsThreshold The number of fragments in the buffer above which no lower bitrates are recomended.<br />
		 *   For example, assume the bandwidth has a value of 3000 kbps and the actual bitrate is 5000 kbps.<br />
		 *   If the number of fragments in the buffer is below the threshold, the rule will recommend 3000 kbps; otherwise, it will recommend 5000 kbps
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function BufferBandwidthRule
			( metricRepository:MetricRepository
			, weights:Vector.<Number>
			, bufferFragmentsThreshold:Number
			)
		{
			super(metricRepository, weights);
			this.bufferFragmentsThreshold = bufferFragmentsThreshold;
		}
		
		/**
		 * The number of fragments in the buffer above which no lower bitrates are recomended.<br />
		 * For example, assume the bandwidth has a value of 3000 kbps and the actual bitrate is 5000 kbps.<br />
		 * If the number of fragments in the buffer is below the threshold, the rule will recommend 3000 kbps; otherwise, it will recommend 5000 kbps
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get bufferFragmentsThreshold():Number
		{
			return _bufferFragmentsThreshold;
		}
		
		public function set bufferFragmentsThreshold(value:Number):void
		{
			if (isNaN(value) || value < 0)
			{
				throw new ArgumentError("Invalid bufferLengthThreshold");
			}
			_bufferFragmentsThreshold = value;
		}
		
		/**
		 * The recommendation
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override public function getRecommendation():Recommendation
		{
			var rec:Recommendation = super.getRecommendation();
			var recBitrate:Number = rec.bitrate;
			var recConfidence:Number = rec.confidence;
			rec = null;
			
			if (recConfidence > 0)
			{
				if (actualBitrateMetric == null)
				{
					actualBitrateMetric = metricRepository.getMetric(MetricType.ACTUAL_BITRATE);
				}
				
				if (availableQualityLevelsMetric == null)
				{
					availableQualityLevelsMetric = metricRepository.getMetric(MetricType.AVAILABLE_QUALITY_LEVELS);
				}
				
				if (currentStatusMetric == null)
				{
					currentStatusMetric = metricRepository.getMetric(MetricType.CURRENT_STATUS);
				}
				var actualBitrate:Number = RuleUtils.computeActualBitrate(actualBitrateMetric, availableQualityLevelsMetric, currentStatusMetric);
				
				if (isNaN(actualBitrate))
				{
					return new Recommendation(RuleType.BUFFER_BANDWIDTH, 0, 0);
				}
				
				// If the bandwidth rule recommends a lower bitrate than the actual one, we check the buffer
				// If the buffer is sufficient, we change the bitrate recommendation to the actual bitrate
				if (recBitrate < actualBitrate)
				{
					if (bufferFragmentsMetric == null)
					{
						bufferFragmentsMetric = metricRepository.getMetric(MetricType.BUFFER_FRAGMENTS);
					}
					var bufferFragmentsMetricValue:MetricValue = bufferFragmentsMetric.value;
					
					if (bufferFragmentsMetricValue.valid)
					{
						var bufferFragments:Number = bufferFragmentsMetricValue.value;
						
						if (bufferFragments > _bufferFragmentsThreshold)
						{
							CONFIG::LOGGING
							{
								logger.info("There are more fragments in the buffer (" + bufferFragments + ") than required by the threshold (" + _bufferFragmentsThreshold + "). Recommending actual bitrate: " + actualBitrate);
							}
							recBitrate = actualBitrate;
						}
					}
				}
			}
			
			CONFIG::LOGGING
			{
				logger.info("Recommend: bitrate = " + ABRUtils.roundNumber(recBitrate) + "; confidence = " + ABRUtils.roundNumber(recConfidence));
			}
			
			return new Recommendation(RuleType.BUFFER_BANDWIDTH, recBitrate, recConfidence);
		}
		
		private var _bufferFragmentsThreshold:Number;
		
		// Metrics
		private var actualBitrateMetric:MetricBase;
		private var bufferFragmentsMetric:MetricBase;
		private var currentStatusMetric:MetricBase;
		private var availableQualityLevelsMetric:MetricBase;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rules.BufferBandwidthRule");
		}
	}
}