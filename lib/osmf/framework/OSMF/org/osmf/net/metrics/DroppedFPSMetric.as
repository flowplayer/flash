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
	import org.osmf.net.qos.PlaybackDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * Dropped frames per second metric <br />
	 * Measurement unit: frames / second 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class DroppedFPSMetric extends MetricBase
	{
		/**
		 * Constructor.
		 * 
		 * @param qosInfoHistory The QoSInfoHistory to be used for computing the metric
		 * @param desiredSampleLength The desired length of the content (in seconds) on which the metric is computed
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function DroppedFPSMetric(qosInfoHistory:QoSInfoHistory, desiredSampleLength:Number = 10)
		{
			super(qosInfoHistory, MetricType.DROPPED_FPS);
			
			this.desiredSampleLength = desiredSampleLength;
		}
		
		/**
		 * The desired length of the content (in seconds) on which the metric is computed 
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
			if (isNaN(value) || value < 0)
			{
				throw new ArgumentError("Invalid desiredSampleLength");
			}
			
			_desiredSampleLength = value;
		}
		
		/**
		 * Computes the value of the dropped FPS (no caching)
		 * 
		 * @return The value of the dropped FPS
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override protected function getValueForced():MetricValue
		{
			var history:Vector.<QoSInfo> = qosInfoHistory.getHistory();
			
			var totalPlayDuration:Number = 0;
			var totalDroppedFrames:Number = 0;
			
			var currentIndex:uint = history[0].currentIndex;
			
			CONFIG::LOGGING
			{
				logger.debug("Computing dfps metric for currently playing index (" + currentIndex + ").");
			}
			
			for (var i:uint = 0; i < history.length; i++)
			{
				var pdr:Vector.<PlaybackDetails> = history[i].playbackDetailsRecord;
				
				for each (var pd:PlaybackDetails in pdr)
				{
					if (pd.duration < 0 || pd.droppedFrames < 0)
					{
						// Corrupt QoS Information
						CONFIG::LOGGING
						{
							logger.warn("The QoSInfo playback details are corrupt (negative value found for playback duration or dropped frames.");
						}
						return new MetricValue(undefined, false);
					}
					
					// The NetStream seems to be reporting erratic data for very short
					// periods of playback (e.g. higher number of dropped frames than available frames)
					// This is why we only look at periods at least as long as MINIMUM_CONTINUOUS_PLAYBACK_DURATION
					if (pd.index == currentIndex && pd.duration >= MINIMUM_CONTINUOUS_PLAYBACK_DURATION)
					{	
						totalPlayDuration += pd.duration;
						totalDroppedFrames += pd.droppedFrames;
						
						break;
					}
				}
				
				if (totalPlayDuration >= desiredSampleLength)
				{
					break;
				}
			}
			
			if (totalPlayDuration < MINIMUM_TOTAL_PLAYBACK_DURATION)
			{
				CONFIG::LOGGING
				{
					logger.info("DroppedFPS metric is not valid as there is not enough data in the QoSInfoHistory regarding playback of the current stream (index " + currentIndex + ").");
					logger.debug("There were " + totalPlayDuration + " seconds available and the required amount of data is: " + MINIMUM_TOTAL_PLAYBACK_DURATION + " seconds.");
				}
				
				return new MetricValue(undefined, false);
			}
			
			CONFIG::LOGGING
			{
				logger.info("DroppedFPS metric is valid and has value: " + ABRUtils.roundNumber(totalDroppedFrames / totalPlayDuration));
			}
			
			return new MetricValue(totalDroppedFrames / totalPlayDuration, true);
		}
		
		private var _desiredSampleLength:Number = 10;
		
		private static const MINIMUM_CONTINUOUS_PLAYBACK_DURATION:Number = 1;
		private static const MINIMUM_TOTAL_PLAYBACK_DURATION:Number = 2;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.metrics.DroppedFPSMetric");
		}
	}
}