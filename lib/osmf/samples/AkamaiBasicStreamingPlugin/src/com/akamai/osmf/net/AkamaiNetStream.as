/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/

package com.akamai.osmf.net
{
	import com.akamai.osmf.AkamaiBasicStreamingPluginInfo;
	
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetClient;
	import org.osmf.traits.LoadTrait;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.*;		
	}
	

	/**
	 * The AkamaiNetStream class extends NetStream to provide
	 * Akamai CDN-specific streaming behavior.
	 **/
	public class AkamaiNetStream extends NetStream
	{
		/**
		 * Constructor.
		 * 
		 * @param connection The NetConnection object the stream will use.
 		 * @param resource The URLResource representing the media.
 		 * @param netLoader The AkamaiNetLoader used to instantiated this class. This
 		 * parameter is necessary to allow this class to issue MediaError events on
 		 * the load trait.
 		 * 
		 * @throws ArgumentError If connection param is null or is not an AkamaiNetConnection.
 		 **/
		public function AkamaiNetStream(connection:NetConnection, resource:URLResource, netLoader:AkamaiNetLoader)
		{
			super(connection);
			_nc = connection as AkamaiNetConnection;

			if (_nc == null && ((connection as NetConnection) == null))
			{
				throw new ArgumentError("The connection argument must be a valid NetConnection object!");
			}

			_resource = resource;
			_netLoader = netLoader;
			
			// Set default values
			_liveRetryInterval = LIVE_RETRY_INTERVAL;
			_liveStreamMasterTimeout = LIVE_RETRY_TIMEOUT;
			_retryLiveStreamsIfUnavailable = true;
			this.bufferTime = (resource is DynamicStreamingResource) ? DEFAULT_MBR_BUFFER_TIME : DEFAULT_BUFFER_TIME;
			
			// Check for plugin metadata that might override the default values
			processPluginMetadata();
			
			if (_nc != null && _nc.isLive)
			{
				// Add a callback for the FCSubscribe call
				(_nc.client as NetClient).addHandler("onFCSubscribe", this.onFCSubscribe);
				
				addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
								
				_liveStreamRetryTimer = new Timer(_liveRetryInterval);
				_liveStreamRetryTimer.addEventListener(TimerEvent.TIMER, onRetryLiveStream);
				
				_liveStreamTimeoutTimer = new Timer(_liveStreamMasterTimeout, 1);
				_liveStreamTimeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onLiveStreamTimeout);
			}
			
			// Check for resource metadata
			var metadata:Metadata = resource.getMetadataValue(AkamaiBasicStreamingPluginInfo.AKAMAI_METADATA_NAMESPACE) as Metadata;
			if (metadata)
			{
				processResourceMetadata(metadata);
			}
		}
		
		/**
		 * @inheritDoc
		 **/		
		override public function play(...arguments):void
		{
			// If we have auth params, append them
			if (authParams && authParams.length > 0)
			{
				var streamName:String = arguments[0] as String;
				arguments[0] = streamName.indexOf("?") != -1 ? streamName + "&" + authParams : streamName + "?" + authParams;
			}
			
			if (_nc != null && _nc.isLive)
			{
				_pendingLiveStreamName = arguments[0] as String;
				arguments[1] = -1;
				_liveStreamTimeoutTimer.reset();
				_liveStreamTimeoutTimer.start();
			}
			
			super.play.apply(this, arguments);
		}
		
		/**
		 * @inheritDoc
		 **/
		override public function play2(nso:NetStreamPlayOptions):void
		{
			var firstPlay:Boolean = (nso.oldStreamName == null);
			
			// Strip off the auth params unless this is the first play
			if (!firstPlay)
			{
				nso.streamName = nso.streamName.split("?")[0];
				nso.oldStreamName = nso.oldStreamName.split("?")[0];
			}
			else if (authParams && authParams.length > 0)
			{
				nso.streamName = nso.streamName.indexOf("?") != -1 ? 
									nso.streamName + "&" + authParams : 
									nso.streamName + "?" + authParams;
			}
			
			super.play2(nso);

			if (_nc != null && _nc.isLive)
			{
				_pendingLiveStreamName = nso.streamName;
				_liveStreamTimeoutTimer.reset();
				_liveStreamTimeoutTimer.start();
			}
		}
			
		/**
		 * @inheritDoc
		 **/
		override public function close():void
		{
			debug("close() method called.");
			super.close();
			
			if (_nc != null && _nc.isLive)
			{
				cleanupAllLiveTimers();
				removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
		}
			
		/**
		 * If this property is true, then if a live stream is playing 
		 * and becomes unpublished due to both the primary and backup 
		 * encoders ceasing to publish, the class will automatically 
		 * enter into a retry cycle, where it will attempt to play the 
		 * streams again. Similarly, if a play request is made and the 
		 * live stream is not found, the class will reattempt the 
		 * streams at a predefined interval. This interval is set by 
		 * the liveRetryInterval. The retries will cease and timeout 
		 * once the liveRetryTimeout value has elapsed without a 
		 * successfull play. 
		 *
		 * @default true
		 **/
		public function get retryLiveStreamsIfUnavailable():Boolean 
		{
			return _retryLiveStreamsIfUnavailable;
		}
		
		public function set retryLiveStreamsIfUnavailable(value:Boolean):void 
		{
			_retryLiveStreamsIfUnavailable = value;
		}
		
		/**
		 * Defines the live stream retry interval in seconds 
		 *
		 * @default 15 seconds
		 * @see #retryLiveStreamsIfUnavailable
		 **/
		public function get liveRetryInterval():Number 
		{
			return _liveRetryInterval/1000;
		}
		
		public function set liveRetryInterval(value:Number):void 
		{
			_liveRetryInterval = value*1000;
		}
		
		/**
		 * The maximum number of seconds the class should wait before 
		 * timing out while trying to locate a live stream on the network. 
		 * This time begins decrementing the moment a <code>play</code> 
		 * request is made against a live stream, or after the class 
		 * receives an UnpublishNotify event while still playing a live 
		 * stream, in which case it attempts to automatically reconnect. 
		 * After this master time out has been triggered, the class will issue
		 * a MediaErrorEvent on the LoadTrait with a MediaErrorCode of 
		 * NETSTREAM_STREAM_NOT_FOUND.
		 *
		 * @default 1200
		 **/
		public function get liveStreamMasterTimeout():Number 
		{
			return _liveStreamMasterTimeout / 1000;
		}
		
		public function set liveStreamMasterTimeout(numOfSeconds:Number):void 
		{
			_liveStreamMasterTimeout = numOfSeconds * 1000;
			_liveStreamTimeoutTimer.delay = _liveStreamMasterTimeout;
		}
		
		/**
		 * Looks for any plugin metadata and sets private variables 
		 * directly. This method is safe to call from the constructor 
		 * since no properties or methods of this class are called.
		 **/
		private function processPluginMetadata():void
		{
			var metadata:Metadata = _netLoader.pluginMetadata;
			if (metadata != null)
			{
				// The master time out for playing a live stream (in seconds)
				var value:Object = metadata.getValue(AkamaiBasicStreamingPluginInfo.AKAMAI_METADATA_KEY_LIVE_TIMEOUT);
				if (value != null && Number(value) > 0)
				{
					_liveStreamMasterTimeout = Number(value) * 1000;
				}
				
				// Determines whether we should retry live streams when they fail
				value = metadata.getValue(AkamaiBasicStreamingPluginInfo.AKAMAI_METADATA_KEY_RETRY_LIVE);
				if (value != null)
				{
					_retryLiveStreamsIfUnavailable = value as Boolean;
				}

				// The interval at which live streams will be retried if encoders fail
				value = metadata.getValue(AkamaiBasicStreamingPluginInfo.AKAMAI_METADATA_KEY_RETRY_INTERVAL);
				if (value != null && Number(value) > 0)
				{
					_liveRetryInterval = Number(value) * 1000;
				}
			}
		}
		
		/**
		 * Looks for any resource metadata.
		 **/
		private function processResourceMetadata(metadata:Metadata):void
		{
			authParams = metadata.getValue(AkamaiBasicStreamingPluginInfo.AKAMAI_METADATA_KEY_STREAM_AUTH_PARAMS) as String;
		}
		
		/**
		 * Makes the FCSubscribe call to the server and 
		 * starts the timeout timers.
		 **/
		private function fcsubscribe(streamName:String):void 
		{
			_nc.call("FCSubscribe", null, streamName);
		}		
		
		/**
		 * Handles the case of never being able to successfully start
		 * the live stream. This is the master timeout.
		 **/
		private function onLiveStreamTimeout(e:TimerEvent):void 
		{
			cleanupAllLiveTimers();
			
			if (_resource != null && _netLoader != null && _netLoader is AkamaiNetLoader)
			{
				var loadTrait:LoadTrait = _netLoader.getLoadTrait(_resource);
				debug("onLiveStreamTimeout() about to dispatch a MediaError with code MediaErrorCodes.NETSTREAM_STREAM_NOT_FOUND due to time out.");
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, 
										new MediaError(MediaErrorCodes.NETSTREAM_STREAM_NOT_FOUND, "Live stream timed out.")));
			}
		}
			
		/**
		 * Retries the FCSubscribe call on the server.
		 * <p/>
		 * If the primary and secondary encoders crash, the stream
		 * is cleaned up and no longer subscribed to through the live chain, so
		 * we need to issue an FCSubscribe again and the player will need to
		 * re-issue a play request on either the play trait or the MediaPlayer
		 * or the stream doesn't get subscribed to all the way from the
		 * entry point.
		 **/
		private function onRetryLiveStream(e:TimerEvent):void 
		{
			debug("onRetryLiveStream() called.");
			if (_retryLiveStreamsIfUnavailable)
			{
				// When subscribing to a live stream we need to strip off query params
				fcsubscribe(_pendingLiveStreamName.split("?")[0].toString());
			}
			else
			{
				onLiveStreamTimeout(null);
			}
		}
			
		/**
		 * Resets all timers.
		 **/			
		private function resetAllLiveTimers(restart:Boolean=false):void 
		{
			if (_liveStreamRetryTimer != null && _liveStreamTimeoutTimer != null)
			{
				_liveStreamRetryTimer.reset();
				_liveStreamTimeoutTimer.reset();
				
				if (restart)
				{
					_liveStreamRetryTimer.start();
					_liveStreamTimeoutTimer.start();
				}
			}
		}

		/**
		 * Cleans up all live timers and their listeners.
		 **/
		private function cleanupAllLiveTimers():void
		{
			if (_liveStreamRetryTimer != null)
			{
				_liveStreamRetryTimer.stop();
				_liveStreamRetryTimer.removeEventListener(TimerEvent.TIMER, onRetryLiveStream);
				_liveStreamRetryTimer = null;
			}
			
			if (_liveStreamTimeoutTimer != null)
			{
				_liveStreamTimeoutTimer.stop();
				_liveStreamTimeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onLiveStreamTimeout);
				_liveStreamTimeoutTimer = null;
			}
		}
		
		/**
		 * The callback function from the FCSubscribe call.
		 * These are the only two info.codes available.
		 **/
		private function onFCSubscribe(info:Object):void 
		{	
			debug("onFCSubscribe() - info.code="+info.code);
					
			switch (info.code) 
			{
				case "NetStream.Play.Start":
					resetAllLiveTimers();
					break;				
				case "NetStream.Play.StreamNotFound":
					if (_liveStreamRetryTimer != null && !_liveStreamRetryTimer.running)
					{
						// If our first play attempt has failed, let's try to resubscribe right away
						onRetryLiveStream(null);
						_liveStreamRetryTimer.reset();
						_liveStreamRetryTimer.start();
					}
					break;
			} 			
		}
		
		private function onNetStatus(event:NetStatusEvent):void 
		{
			debug("onNetStatus() - event.info.code="+event.info.code);
			
			switch (event.info.code) 
			{
				case "NetStream.Play.PublishNotify":
					resetAllLiveTimers();
					break;
				case "NetStream.Play.UnpublishNotify":
					if (!_liveStreamRetryTimer.running)
					{
						onRetryLiveStream(null);
						resetAllLiveTimers(true);
					}
					break;
			}
		}
				
		private function debug(msg:String):void
		{
			CONFIG::LOGGING
			{
				if (logger != null)
				{
					logger.debug(msg);
				}
			}
		}
		
		private var _nc:AkamaiNetConnection;
		private var _netLoader:AkamaiNetLoader;
		private var _pendingLiveStreamName:String;
		private var _resource:URLResource
		private var _liveStreamRetryTimer:Timer;
		private var _liveStreamTimeoutTimer:Timer;
		private var _liveRetryInterval:Number;
		private var _liveStreamMasterTimeout:Number;
		private var _retryLiveStreamsIfUnavailable:Boolean;
		private var authParams:String;
		
		private const LIVE_RETRY_INTERVAL:Number		= 15000;	// 15 seconds
		private const LIVE_RETRY_TIMEOUT:Number			= 1200000;	// 20 minutes
		private const DEFAULT_BUFFER_TIME:Number		= 3;
		private const DEFAULT_MBR_BUFFER_TIME:Number 	= 8;
		
		CONFIG::LOGGING
		{	
			private static const logger:org.osmf.logging.Logger = 
									org.osmf.logging.Log.getLogger("com.akamai.osmf.net.AkamaiNetStream");		
		}	
	}
}
