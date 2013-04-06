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
	 * DroppedFPSRule is an emergency rule that recommends a bitrate that would 
	 * cause an acceptable number of dropped frames per second
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class DroppedFPSRule extends RuleBase
	{
		/**
		 * Constructor.
		 * 
		 * @param metricRepository The metric repository from which to retrieve the necessary metrics
		 * @param desiredSampleLength The desired length of the content (in seconds) on which to compute the dropped FPS metric
		 * @param maximumDroppedFPSRatio The maximum acceptable ratio of dropped FPS (droppedFPS / FPS)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function DroppedFPSRule
			( metricRepository:MetricRepository
			, desiredSampleLength:Number
			, maximumDroppedFPSRatio:Number
			)
		{
			super(metricRepository);
			
			this.desiredSampleLength = desiredSampleLength;
			this.maximumDroppedFPSRatio = maximumDroppedFPSRatio;
		}
		
		/**
		 * The desired length of the content (in seconds) on which to compute the dropped FPS metric
		 * 
		 * @throws ArgumentError If the desiredSampleLength is set to NaN, zero or a negative number
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get desiredSampleLength():Number
		{
			return _desiredSampleLength;
		}
		
		public function set desiredSampleLength(value:Number):void
		{
			if (isNaN(value) || value <= 0)
			{
				throw new ArgumentError("Invalid desiredSampleLength");
			}
			_desiredSampleLength = value;
		}
		
		/**
		 * The maximum acceptable ratio of dropped FPS (droppedFPS / FPS)
		 * 
		 * @throws ArgumentError If the maximumDroppedFramesRatio is set to a value outside
		 *         the [0, 1] interval (inclusive)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get maximumDroppedFPSRatio():Number
		{
			return _maximumDroppedFPSRatio;
		}
		
		public function set maximumDroppedFPSRatio(value:Number):void
		{
			if (isNaN(value) || value < 0 || value > 1)
			{
				throw new ArgumentError("Invalid maximumDroppedFPSRatio");
			}
			_maximumDroppedFPSRatio = value;
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
			if (actualBitrateMetric == null)
			{
				actualBitrateMetric = metricRepository.getMetric(MetricType.ACTUAL_BITRATE);
			}
			
			if (currentStatusMetric == null)
			{
				currentStatusMetric = metricRepository.getMetric(MetricType.CURRENT_STATUS);
			}
			
			var actualBitrateMetricValue:MetricValue = actualBitrateMetric.value;
			var currentStatusMetricValue:MetricValue = currentStatusMetric.value;
			
			if (!currentStatusMetricValue.valid)
			{
				CONFIG::LOGGING
				{
					logger.info("One of the required metrics is not valid so return a zero-confidence recommendation.");
				}
				
				return new Recommendation(RuleType.DROPPED_FPS, 0, 0);
			}
			
			var currentIndex:uint = (currentStatusMetricValue.value as Vector.<uint>)[0];
			var actualIndex:uint = (currentStatusMetricValue.value as Vector.<uint>)[1];
			
			// If the downloading index is different than the playing one, the dropped frames are irrelevant
			if (currentIndex != actualIndex)
			{
				CONFIG::LOGGING
				{
					logger.info
						( "The current index (" + currentIndex + ") is different than the " +
						  "actual index (" + actualIndex + "), so the rule does not apply. " +
						  "Returning a zero-confidence recommendation."
						);
				}
				return new Recommendation(RuleType.DROPPED_FPS, 0, 0);
			}
			
			if (availableQualityLevelsMetric == null)
			{
				availableQualityLevelsMetric = metricRepository.getMetric(MetricType.AVAILABLE_QUALITY_LEVELS);
			}

			var currentBitrate:Number = RuleUtils.computeActualBitrate(actualBitrateMetric, availableQualityLevelsMetric, currentStatusMetric);
			
			if (isNaN(currentBitrate))
			{
				return new Recommendation(RuleType.DROPPED_FPS, 0, 0);
			}
			
			
			if (fpsMetric == null)
			{
				fpsMetric = metricRepository.getMetric(MetricType.FPS);
			}
			
			if (droppedFPSMetric == null)
			{
				droppedFPSMetric = metricRepository.getMetric(MetricType.DROPPED_FPS, _desiredSampleLength);
			}
			
			var fpsMetricValue:MetricValue = fpsMetric.value;
			var droppedFPSMetricValue:MetricValue = droppedFPSMetric.value;
			
			if (!fpsMetricValue.valid || !droppedFPSMetricValue.valid)
			{
				CONFIG::LOGGING
				{
					logger.info("One of the required metrics is not valid so return a zero-confidence recommendation.");
				}
				
				return new Recommendation(RuleType.DROPPED_FPS, 0, 0);
			}
			
			var droppedFPS:Number = droppedFPSMetricValue.value;
			var fps:Number = fpsMetricValue.value;
			
			if (droppedFPS > fps)
			{
				// If the reported droppedFPS is larger than the FPS, than
				// this means that all the frames were dropped.
				// It does not make sense to drop more frames than available
				droppedFPS = fps;
			}
			
			var bitrate:Number = currentBitrate * (1 - droppedFPS / fps);
			var confidence:Number = 0;
			
			// Perform this check now so we avoid division by 0
			if (_maximumDroppedFPSRatio == 0 && droppedFPS == 0)
			{
				CONFIG::LOGGING
				{
					logger.info
						( "The maximumDroppedFPSRatio is 0 and we had no dropped frames. " +
						  "Return a zero-confidence recommendation."
						);
				}
				return new Recommendation(RuleType.DROPPED_FPS, 0, 0);
			}
			
			if (droppedFPS / fps > _maximumDroppedFPSRatio)
			{
				confidence = 1;
			}
			else
			{
				confidence = droppedFPS / (fps * _maximumDroppedFPSRatio);
			}

			CONFIG::LOGGING
			{
				logger.info("Recommend: bitrate = " + ABRUtils.roundNumber(bitrate) + " kbps; confidence = " + ABRUtils.roundNumber(confidence));
			}
			
			return new Recommendation(RuleType.DROPPED_FPS, bitrate, confidence);
		}
		
		private var _minimumFPS:Number;
		private var _maximumDroppedFPSRatio:Number;
		private var _desiredSampleLength:Number;
		
		// Metrics
		private var actualBitrateMetric:MetricBase;
		private var currentStatusMetric:MetricBase;
		private var availableQualityLevelsMetric:MetricBase;
		private var fpsMetric:MetricBase;
		private var droppedFPSMetric:MetricBase;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rules.DroppedFPSRule");
		}
	}
}
