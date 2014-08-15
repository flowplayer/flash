/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.net.httpstreaming
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.NetStreamSwitchManagerBase;
	import org.osmf.net.NetStreamSwitcher;
	import org.osmf.net.RuleSwitchManagerBase;
	import org.osmf.net.SwitchingRuleBase;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastDVRTrait;
	import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastTimeTrait;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFactory;
	import org.osmf.net.metrics.DefaultMetricFactory;
	import org.osmf.net.metrics.MetricFactory;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.rtmpstreaming.DroppedFramesRule;
	import org.osmf.net.rules.AfterUpSwitchBufferBandwidthRule;
	import org.osmf.net.rules.BandwidthRule;
	import org.osmf.net.rules.BufferBandwidthRule;
	import org.osmf.net.rules.DroppedFPSRule;
	import org.osmf.net.rules.EmptyBufferRule;
	import org.osmf.net.rules.RuleBase;
	import org.osmf.traits.LoadState;

	/**
	 * HTTPStreamingNetLoader is a NetLoader that can load HTTP streams.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class HTTPStreamingNetLoader extends NetLoader
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPStreamingNetLoader()
		{
			// Connection sharing and custom NetConnectionFactory classes are
			// irrelevant for HTTP streaming connections, hence we don't allow
			// the client to pass those params in.
			super();
		}
		
		/**
		 * @private
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return (resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata) != null;
		}
		
		/**
		 * @private
		 */
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			var factory:HTTPStreamingFactory = createHTTPStreamingFactory();
			var httpNetStream:HTTPNetStream = new HTTPNetStream(connection, factory, resource);
			return httpNetStream;
		}
		
		/**
		 * @private
		 * 
		 * Overridden to allow the creation of a NetStreamSwitchManager object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource):NetStreamSwitchManagerBase
		{
			// Create a QoSInfoHistory, to hold a history of QoSInfo provided by the NetStream
			var netStreamQoSInfoHistory:QoSInfoHistory = createNetStreamQoSInfoHistory(netStream);
			
			// Create a MetricFactory, to be used by the metric repository for instantiating metrics
			var metricFactory:MetricFactory = createMetricFactory(netStreamQoSInfoHistory);
			
			// Create the MetricRepository, which caches metrics
			var metricRepository:MetricRepository = new MetricRepository(metricFactory);
			
			// Create the normal rule
			var normalRules:Vector.<RuleBase> = new Vector.<RuleBase>();
			var normalRuleWeights:Vector.<Number> = new Vector.<Number>();
			
			normalRules.push
				( new BufferBandwidthRule
				  ( metricRepository
				  , BANDWIDTH_BUFFER_RULE_WEIGHTS
				  , BANDWIDTH_BUFFER_RULE_BUFFER_FRAGMENTS_THRESHOLD
				  )
				);
			normalRuleWeights.push(1);
			
			// Create the emergency rules
			var emergencyRules:Vector.<RuleBase> = new Vector.<RuleBase>();
			
			emergencyRules.push(new DroppedFPSRule(metricRepository, 10, 0.1));
			
			emergencyRules.push
				( new EmptyBufferRule
				  ( metricRepository
				  , EMPTY_BUFFER_RULE_SCALE_DOWN_FACTOR
				  )
				);
			
			emergencyRules.push
				( new AfterUpSwitchBufferBandwidthRule
				  ( metricRepository
					, AFTER_UP_SWITCH_BANDWIDTH_BUFFER_RULE_BUFFER_FRAGMENTS_THRESHOLD
					, AFTER_UP_SWITCH_BANDWIDTH_BUFFER_RULE_MIN_RATIO
				  )
				);
			
			// Create a NetStreamSwitcher, which will handle the low-level details of NetStream
			// stream switching
			var nsSwitcher:NetStreamSwitcher = new NetStreamSwitcher(netStream, dsResource);
			
			// Finally, return an instance of the DefaultSwitchManager, passing it
			// the objects we instatiated above
			return new DefaultHTTPStreamingSwitchManager
				( netStream
				, nsSwitcher
				, metricRepository
				, emergencyRules
				, true
				, normalRules
				, normalRuleWeights
				);
		}
		
		/**
		 * @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		override protected function processFinishLoading(loadTrait:NetStreamLoadTrait):void
		{
			var resource:URLResource = loadTrait.resource as URLResource;
			
			if (!dvrMetadataPresent(resource))
			{
				updateLoadTrait(loadTrait, LoadState.READY);
				
				return;
			}

			var netStream:HTTPNetStream = loadTrait.netStream as HTTPNetStream;
			netStream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
			netStream.DVRGetStreamInfo(null);
			function onDVRStreamInfo(event:DVRStreamInfoEvent):void
			{
				netStream.removeEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
				
				loadTrait.setTrait(new HTTPStreamingDVRCastDVRTrait(loadTrait.connection, netStream, event.info as DVRInfo));
				loadTrait.setTrait(new HTTPStreamingDVRCastTimeTrait(loadTrait.connection, netStream, event.info as DVRInfo));
				updateLoadTrait(loadTrait, LoadState.READY);
			}
		}
		
		/**
		 * Creates a QoSInfoHistory to be used in Adaptive Bitrate switching
		 * by the metrics. Subclasses may override.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */		
		protected function createNetStreamQoSInfoHistory(netStream:NetStream):QoSInfoHistory
		{
			return new QoSInfoHistory(netStream, QOS_MAX_HISTORY_LENGTH);
		}
		
		/**
		 * Creates a MetricFactory to be used in Adaptive Bitrate switching for
		 * instantiating metrics. Subclasses may override.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		protected function createMetricFactory(netStreamQoSInfoHistory:QoSInfoHistory):MetricFactory
		{
			return new DefaultMetricFactory(netStreamQoSInfoHistory);
		}
		
		/**
		 * @private
		 * 
		 * Override this method to use a different factory object with HTTPNetStream objects.
		 */
		protected function createHTTPStreamingFactory():HTTPStreamingFactory
		{
			return new HTTPStreamingF4FFactory();
		}
		
		
		//
		// ABR protected constants
		//
		
		protected static const BANDWIDTH_BUFFER_RULE_WEIGHTS:Vector.<Number> = new <Number>[7, 3];
		protected static const BANDWIDTH_BUFFER_RULE_BUFFER_FRAGMENTS_THRESHOLD:uint = 2;
		protected static const AFTER_UP_SWITCH_BANDWIDTH_BUFFER_RULE_BUFFER_FRAGMENTS_THRESHOLD:uint = 2;
		protected static const AFTER_UP_SWITCH_BANDWIDTH_BUFFER_RULE_MIN_RATIO:Number = 0.5;
		protected static const EMPTY_BUFFER_RULE_SCALE_DOWN_FACTOR:Number = 0.4;
		
		//
		// Internal
		//

		private function dvrMetadataPresent(resource:URLResource):Boolean
		{
			var metadata:Metadata = resource.getMetadataValue(MetadataNamespaces.DVR_METADATA) as Metadata;
			
			return (metadata != null);
		}
		
		private static const QOS_MAX_HISTORY_LENGTH:Number = 10;
	}
}