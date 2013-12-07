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
package org.osmf.net
{
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.osmf.net.qos.PlaybackDetails;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * @private
	 * 
	 * PlaybackDetailsRecorder holds PlaybackDetails records
	 * between ABREvent.QOS_UPDATE events
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class NetStreamPlaybackDetailsRecorder
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function NetStreamPlaybackDetailsRecorder(netStream:NetStream, netClient:NetClient, resource:DynamicStreamingResource)
		{
			super();
			
			this.netStream = netStream;
			this.resource = resource;
			
			_playingIndex = Math.max(resource.initialIndex, 0);
			
			resetRecord();
			
			timer = new Timer(DFPS_AFTER_TRANSITION_IGNORE_TIME, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netClient.addHandler("onPlayStatus", onPlayStatus);
		}
		
		/**
		 * Compute the playback details for the currently playing index
		 * 
		 * @return Record of the playback details since the last time this function was called
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function computeAndGetRecord():Vector.<PlaybackDetails>
		{
			CONFIG::LOGGING
			{
				logger.debug("Received command to compute now.");
			}
			
			if (!seeking)
			{
				CONFIG::LOGGING
				{
					logger.info("Computing the record for the currently playing index: " + _playingIndex);
				}
				performComputation();
			}
			else
			{
				CONFIG::LOGGING
				{
					logger.info("The NetStream is currently seeking. Providing cached record.");
				}
			}
			
			// Create a copy of the record
			var pdr:Vector.<PlaybackDetails> = playbackDetailsRecord.slice();

			// Reset the record
			resetRecord();
			
			// Return the copy of the record
			return pdr;
		}

		/**
		 * The currently playing index.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get playingIndex():uint
		{
			return _playingIndex;
		}
		
		/**
		 * Resets the playback details record.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function resetRecord():void
		{
			playbackDetailsRecord = new Vector.<PlaybackDetails>();
			lastNetStreamTime = netStream.time;
			lastDroppedFrames = netStream.info.droppedFrames;
			
			CONFIG::LOGGING
			{
				logger.debug("Resetting playback details record. lastNetStreamTime = " + lastNetStreamTime + "; lastDroppedFrames = " + lastDroppedFrames);
			}
		}
		
		
		private function onTimer(event:TimerEvent):void
		{
			timer.reset();
			
			// Work-around for runtime issue: dropped frames are reported incorrectly in
			// the first two seconds after a switch
			CONFIG::LOGGING
			{
				logger.debug
					(
						"Ignoring " + (netStream.info.droppedFrames - lastDroppedFrames) + " dropped frames, " +
						"because they are right after a transition."
					);
			}
			lastDroppedFrames = netStream.info.droppedFrames;
		}
		
		private function performComputation():void
		{
			var newNetStreamTime:Number = netStream.time;
			var newDroppedFrames:Number = netStream.info.droppedFrames;
			
			if (getTimer() - lastTransitionTime < DFPS_AFTER_TRANSITION_IGNORE_TIME)
			{
				// Work-around for runtime issue: dropped frames are reported incorrectly in
				// the first two seconds after a switch
				CONFIG::LOGGING
				{
					logger.debug
						(
							"Ignoring " + (newDroppedFrames - lastDroppedFrames) + " dropped frames, " +
							"because they are right after a transition."
						);
				}
				lastDroppedFrames = newDroppedFrames;
			}
			
			var duration:Number = newNetStreamTime - lastNetStreamTime;
			var droppedFrames:Number = newDroppedFrames - lastDroppedFrames;
			
			CONFIG::LOGGING
			{
				logger.debug
					(
						"Recording playback details for played index (" + _playingIndex + "): " + 
						_playingIndex + ", " + duration + ", " + droppedFrames
					);
			}
			
			var alreadyPlayed:Boolean = false;
			for each (var pd:PlaybackDetails in playbackDetailsRecord)
			{
				if (pd.index == _playingIndex)
				{
					alreadyPlayed = true;
					pd.duration += duration;
					pd.droppedFrames += droppedFrames;
					
					break;
				}
			}
			
			if (!alreadyPlayed)
			{
				var playbackDetails:PlaybackDetails = new PlaybackDetails(_playingIndex, duration, droppedFrames);
				playbackDetailsRecord.push(playbackDetails);
			}

			lastNetStreamTime = newNetStreamTime;
			lastDroppedFrames = newDroppedFrames;
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("onNetStatus() - event.info.code=" + event.info.code);
			}
			
			switch (event.info.code) 
			{
				case NetStreamCodes.NETSTREAM_SEEK_START:
					CONFIG::LOGGING
					{
						logger.debug("Seek initiated, need to pause computation");
					}
					performComputation();
					seeking = true;
					break;
				
				case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
					CONFIG::LOGGING
					{
						logger.debug("Seek complete to time: " + netStream.time);
					}
					resetRecord();
					seeking = false;
					break;
				
				case NetStreamCodes.NETSTREAM_PLAY_STOP:
					resetRecord();
					break;
			}
		}
		
		private function onPlayStatus(info:Object):void
		{
			switch (info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE:
					// Issue: http://bugs.adobe.com/jira/browse/FM-1474
					// We need to check whether this was a video transition,
					// because the same event is dispatched in case of an audio transition.
					// We do this by checking whether the url the transition
					// completed to is indeed a video stream
					var newIndex:int = resource.indexFromName(info.details);
					if (newIndex >= 0)
					{
						CONFIG::LOGGING
						{
							logger.debug("Transition complete from " + _playingIndex + " to " + newIndex + ". Computing playback details.");
						}
						
						if (!seeking)
						{
							// Only perform computation if we're not currently seeking.
							// The only time when we might be seeking is when the following happen:
							// 1. TransitionStart (NetStatus: NetStream.Play.Transition)
							// 2. SeekStart (NetStatus: NetStream.Seek.Start)
							// 3. TransitionComplete (PlayStatus: NetStream.Play.TransitionComplete
							// 4. SeekComplete (NetStatus: NetStream.Seek.Notify)
							//
							// This is a rare case, as usually seekComplete is dispatched before transitionComplete
							performComputation();
						}
						
						_playingIndex = newIndex;
						
						timer.start();
						lastTransitionTime = getTimer();
					}
					break;
			}
		}
		
		private var _playingIndex:uint;
		private var netStream:NetStream;
		private var lastDroppedFrames:Number;
		private var lastNetStreamTime:Number;
		private var lastTransitionTime:Number = Number.NEGATIVE_INFINITY;
		private var resource:DynamicStreamingResource;
		private var playbackDetailsRecord:Vector.<PlaybackDetails>;
		private var timer:Timer;
		private var seeking:Boolean = false;
		
		private static const DFPS_AFTER_TRANSITION_IGNORE_TIME:Number = 2000;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.httpstreaming.PlaybackDetailsRecorder");
		}
	}
}
