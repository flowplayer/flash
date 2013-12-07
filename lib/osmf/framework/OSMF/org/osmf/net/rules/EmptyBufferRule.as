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
	 * EmptyBufferRule is an emergency rule that kicks in when a
	 * playback interruption caused by buffering occurred recently. 
	 * It recommends a configurable fraction of the current bitrate.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class EmptyBufferRule extends RuleBase
	{
		/**
		 * Constructor.
		 * 
		 * @param metricRepository The metric repository from which to retrieve the necessary metrics
		 * @param scaleDownFactor The factor to be applied to the current downloading bitrate
		 *        in order to compute this rule's recommendation
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function EmptyBufferRule
			( metricRepository:MetricRepository
			, scaleDownFactor:Number
			)
		{
			super(metricRepository);
			
			this.scaleDownFactor = scaleDownFactor;
		}
		
		/**
		 * The factor to be applied to the current downloading bitrate in order to compute this
		 * rule's recommendation
		 * 
		 * @throws ArgumentError If the scaleDownFactor is set to a value outside
		 *         the [0, 1] interval (inclusive)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get scaleDownFactor():Number
		{
			return _scaleDownFactor;
		}
		
		public function set scaleDownFactor(value:Number):void
		{
			if (isNaN(value) || value < 0 || value > 1)
			{
				throw new ArgumentError("Invalid scaleDownFactor");
			}
			
			_scaleDownFactor = value;
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
			if (emptyBufferInterruptionMetric == null)
			{
				emptyBufferInterruptionMetric = metricRepository.getMetric(MetricType.EMPTY_BUFFER);
			}
			var emptyBufferInterruptionMetricValue:MetricValue = emptyBufferInterruptionMetric.value;
			
			if (!emptyBufferInterruptionMetricValue.valid || emptyBufferInterruptionMetricValue.value == false)
			{
				// If the metric is invalid or reports that no empty buffer interruption occurred recently
				// then this rule doesn't have anything to do
				
				CONFIG::LOGGING
				{
					logger.info
						( "The EmptyBuffer metric is invalid or reports no recent interruptions. " +
						  "Returning a zero-confidence recommendation."
						);
				}
				
				return new Recommendation(RuleType.EMPTY_BUFFER, 0, 0);
			}
			
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
			
			var currentBitrate:Number = RuleUtils.computeActualBitrate(actualBitrateMetric, availableQualityLevelsMetric, currentStatusMetric);
			
			if (isNaN(currentBitrate))
			{
				CONFIG::LOGGING
				{
					logger.info("An empty buffer playback interruption occurred, but some required metrics are invalid. Recommending switch to lowest quality.");
				}
				
				return new Recommendation(RuleType.EMPTY_BUFFER, 0, 1);
			}
			
			var bitrate:Number = currentBitrate * scaleDownFactor;
			
			CONFIG::LOGGING
			{
				logger.info("Recommend: bitrate = " + ABRUtils.roundNumber(bitrate) + " kbps; confidence = 1");
			}
			
			return new Recommendation(RuleType.EMPTY_BUFFER, bitrate, 1);
		}
		
		private var _scaleDownFactor:Number;
		
		// Metrics
		private var emptyBufferInterruptionMetric:MetricBase;
		private var actualBitrateMetric:MetricBase;
		private var currentStatusMetric:MetricBase;
		private var availableQualityLevelsMetric:MetricBase;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rules.EmptyBufferRule");
		}
	}
}