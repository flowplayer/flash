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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class DefaultMetricFactoryMocker extends MetricFactory
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function DefaultMetricFactoryMocker(qosInfoHistory:QoSInfoHistory)
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
						return new ActualBitrateMetricMocker(qosInfoHistory, maxFragments);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.FRAGMENT_COUNT
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new FragmentCountMetricMocker(qosInfoHistory);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.AVAILABLE_QUALITY_LEVELS
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new AvailableQualityLevelsMetricMocker(qosInfoHistory);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.CURRENT_STATUS
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new CurrentStatusMetricMocker(qosInfoHistory);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.BANDWIDTH
					, function(qosInfoHistory:QoSInfoHistory, weights:Vector.<Number>):MetricBase
					{
						return new BandwidthMetricMocker(qosInfoHistory, weights);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.FPS
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new FPSMetricMocker(qosInfoHistory);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.DROPPED_FPS
					, function(qosInfoHistory:QoSInfoHistory, desiredSampleLength:Number = 10):MetricBase
					{
						return new DroppedFPSMetricMocker(qosInfoHistory, desiredSampleLength);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.BUFFER_OCCUPATION_RATIO
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new BufferOccupationRatioMetricMocker(qosInfoHistory);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.BUFFER_LENGTH
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new BufferLengthMetricMocker(qosInfoHistory);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.BUFFER_FRAGMENTS
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new BufferFragmentsMetricMocker(qosInfoHistory);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.EMPTY_BUFFER
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new EmptyBufferMetricMocker(qosInfoHistory);
					}
				)
			);
			
			addItem
			( new MetricFactoryItem
				( MetricType.RECENT_SWITCH
					, function(qosInfoHistory:QoSInfoHistory):MetricBase
					{
						return new RecentSwitchMetricMocker(qosInfoHistory);
					}
				)
			);
		}
		
		private function generateWeights(... weights):Vector.<Number>
		{
			var v:Vector.<Number> = new Vector.<Number>();
			for(var i:uint=0; i< weights.length; i++)
			{
				v[i] = weights[i] ;
			}
			return (v);
		}
		
	}
}