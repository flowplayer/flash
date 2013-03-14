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
	import org.osmf.net.qos.QoSInfoHistory;

	/**
	 * DefaultMetricFactory is the default implementation of the MetricFactory.
	 * <p>
	 * The default metric factory can construct metrics of the following types:
	 * 
	 * <ul>
	 * <li>ActualBitrateMetric</li>
	 * <li>FragmentCountMetric</li>
	 * <li>AvailableQualityLevelsMetric</li>
	 * <li>BandwidthMetric</li>
	 * <li>FPSMetric</li>
	 * <li>DroppedFPSMetric</li>
	 * <li>BufferOccupationRatioMetric</li>
	 * <li>BufferLengthMetric</li>
	 * <li>BufferFragmentsMetric</li>
	 * <li>EmptyBufferInterruptionMetric</li>
	 * </ul>
	 * </p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class DefaultMetricFactory extends MetricFactory
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function DefaultMetricFactory(qosInfoHistory:QoSInfoHistory)
		{
			super(qosInfoHistory);
			
			init();
		}
		
		private function init():void
		{
			addItem
				( new MetricFactoryItem
					( MetricType.ACTUAL_BITRATE
					, function(qosInfoHistory:QoSInfoHistory, maxFragments:uint = 5):MetricBase
						{
							return new ActualBitrateMetric(qosInfoHistory, maxFragments);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.FRAGMENT_COUNT
						, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new FragmentCountMetric(qosInfoHistory);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.AVAILABLE_QUALITY_LEVELS
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new AvailableQualityLevelsMetric(qosInfoHistory);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.CURRENT_STATUS
						, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new CurrentStatusMetric(qosInfoHistory);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.BANDWIDTH
					, function(qosInfoHistory:QoSInfoHistory, weights:Vector.<Number>):MetricBase
						{
							return new BandwidthMetric(qosInfoHistory, weights);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.FPS
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new FPSMetric(qosInfoHistory);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.DROPPED_FPS
						, function(qosInfoHistory:QoSInfoHistory, desiredSampleLength:Number = 10):MetricBase
						{
							return new DroppedFPSMetric(qosInfoHistory, desiredSampleLength);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.BUFFER_OCCUPATION_RATIO
						, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new BufferOccupationRatioMetric(qosInfoHistory);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.BUFFER_LENGTH
						, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new BufferLengthMetric(qosInfoHistory);
						}
					)
				);
			
			addItem
				( new MetricFactoryItem
					( MetricType.BUFFER_FRAGMENTS
						, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new BufferFragmentsMetric(qosInfoHistory);
						}
					)
				);
			
			addItem
				( new MetricFactoryItem
					( MetricType.EMPTY_BUFFER
						, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new EmptyBufferMetric(qosInfoHistory);
						}
					)
				);
				
			addItem
				( new MetricFactoryItem
					( MetricType.RECENT_SWITCH
						, function(qosInfoHistory:QoSInfoHistory):MetricBase
						{
							return new RecentSwitchMetric(qosInfoHistory);
						}
					)
				);
		}
	}
}