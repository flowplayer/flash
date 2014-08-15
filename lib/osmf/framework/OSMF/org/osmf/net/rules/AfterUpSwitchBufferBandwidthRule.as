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
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * <p>AfterUpSwitchBufferBandwidthRule is an emergency rule based on BufferBandwidthRule.
	 * It kicks in if the last fragment downloaded is higher quality than the previous one
	 * and it recommends a lower bitrate if the current quality is cleary unsustainable.</p>
	 * 
	 * <p>It works like the BufferBandwidthRule, only on a single fragment (the last downloaded)
	 * and only if that fragment is the first from a higher quality level. In addition to
	 * the BufferBandwidthRule, this rule will not kick in (will return a zero-confidence 
	 * recommendation) if the bandwidth is above an acceptable level.</p>
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class AfterUpSwitchBufferBandwidthRule extends BufferBandwidthRule
	{
		/**
		 * Constructor.
		 * 
		 * @param metricRepository The metric repository from which to retrieve the necessary metrics
		 * 
		 * @param bufferFragmentsThreshold The number of fragments in the buffer above which no lower bitrates are recomended.<br />
		 *   For example, assume the bandwidth has a value of 3000 kbps and the actual bitrate is 5000 kbps.<br />
		 *   If the number of fragments in the buffer is below the threshold, the rule will recommend 3000 kbps; otherwise, it will recommend 5000 kbps
		 * 
		 * @param minBandwidthToBitrateRatio The minimum acceptable value of the <b>bandwidth / bitrate</b> fraction.<br />
		 *        This is taken into consideration only if the bufferFragmentsThreshold constraint is not satisfied.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function AfterUpSwitchBufferBandwidthRule
			( metricRepository:MetricRepository
			, bufferFragmentsThreshold:Number
			, minBandwidthToBitrateRatio:Number
			)
		{
			super(metricRepository, new <Number>[1], bufferFragmentsThreshold);
			
			this.minBandwidthToBitrateRatio = minBandwidthToBitrateRatio;
		}
		
		/**
		 * The minimum acceptable value of the <b>bandwidth / bitrate</b> fraction.<br />
		 * This is taken into consideration only if the bufferFragmentsThreshold constraint is not satisfied.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get minBandwidthToBitrateRatio():Number
		{
			return _minBandwidthToBitrateRatio;
		}
		
		public function set minBandwidthToBitrateRatio(value:Number):void
		{
			if (isNaN(value) || value < 0)
			{
				throw new ArgumentError("Invalid value for minBandwidthToBitrateRatio");
			}
			
			_minBandwidthToBitrateRatio = value;
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
			if (upSwitchMetric == null)
			{
				upSwitchMetric = metricRepository.getMetric(MetricType.RECENT_SWITCH);
			}
			
			var upSwitchMetricValue:MetricValue = upSwitchMetric.value;
			
			// Check to see if any up-switch occurred
			if (!upSwitchMetricValue.valid || (upSwitchMetricValue.value as int) <= 0)
			{
				CONFIG::LOGGING
				{
					logger.info("No up-switch is reported to have occurred recently so return a zero-confidence recommendation.");
				}
				return new Recommendation(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, 0, 0);
			}
			
			var rec:Recommendation = super.getRecommendation();
			
			if (rec.confidence == 0)
			{
				CONFIG::LOGGING
				{
					logger.info("The BandwidthBufferRule returns a zero-confidence recommendations. In this case, we do so as well.");
				}
				return new Recommendation(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, 0, 0);
			}
			
			var bandwidth:Number = rec.bitrate;
			
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
				return new Recommendation(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, 0, 0);
			}
			
			var confidence:Number = 0;
			
			// Check if the bitrate is unsustainable
			if (bandwidth / actualBitrate < minBandwidthToBitrateRatio)
			{
				confidence = 1;
			}
			
			CONFIG::LOGGING
			{
				logger.info("Recommend: bitrate = " + ABRUtils.roundNumber(bandwidth) + " kbps; confidence = " + ABRUtils.roundNumber(confidence));
			}

			return new Recommendation(RuleType.AFTER_UP_SWITCH_BUFFER_BANDWIDTH, bandwidth, confidence);
		}

		private var _minBandwidthToBitrateRatio:Number;
		
		// Metrics
		private var upSwitchMetric:MetricBase;
		private var actualBitrateMetric:MetricBase;
		private var availableQualityLevelsMetric:MetricBase;
		private var currentStatusMetric:MetricBase;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rules.AfterUpSwitchBufferBandwidthRule");
		}
	}
}