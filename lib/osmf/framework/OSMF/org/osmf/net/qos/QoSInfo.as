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
package org.osmf.net.qos
{
	import flash.net.NetStreamInfo;
	
	import org.osmf.net.ABRUtils;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * QoSInfo holds Quality of Service information of the media.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class QoSInfo
	{
		/**
		 * Constructor.
		 * 
		 * @param timestamp The machine time when this QoSInfo was created 
		 *        (number of milliseconds since midnight January 1, 1970, universal time)
		 * @param playheadTime The playhead time when this QoSInfo was created (time in the stream, in seconds)
		 * @param availableQualityLevels The available quality levels
		 * @param currentIndex The index of the currently playing quality level
		 * @param actualIndex The index of the currently downloading quality level
		 * @param lastDownloadedFragmentDetails The fragment details of the last downloaded fragment (HDS only)
		 * @param maxFPS The maximum value of the frames per second recorded until now 
		 *        (usually used as an approximation to the asset's characteristic FPS)
		 * @param playbackDetailsRecord A record of the content played back since the last QOS_UPDATE event. It is a list of PlaybackDetails objects.
		 * @param nsInfo The NetStreamInfo of the NetStream
		 * @param bufferLength The lengths of the buffer (in seconds)
		 * @param bufferTime The minimum buffer time (in seconds)
		 * @param emptyBufferOccurred Signals whether there was any playback interruption caused by 
		 *        an empty buffer since the last QoSInfo was provided 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function QoSInfo
			( timestamp:Number = Number.NaN
			, playheadTime:Number = Number.NaN
			, availableQualityLevels:Vector.<QualityLevel> = null
			, currentIndex:int = -1
			, actualIndex:int = -1
			, lastDownloadedFragmentDetails:FragmentDetails = null
			, maxFPS:Number = Number.NaN
			, playbackDetailsRecord:Vector.<PlaybackDetails> = null
			, nsInfo:NetStreamInfo = null
			, bufferLength:Number = Number.NaN
			, bufferTime:Number = Number.NaN
			, emptyBufferOccurred:Boolean = false 
			)
		{
			_timestamp = timestamp;
			_playheadTime = playheadTime;
			_availableQualityLevels = availableQualityLevels;
			_currentIndex = currentIndex;
			_actualIndex = actualIndex;
			_lastDownloadedFragmentDetails = lastDownloadedFragmentDetails;
			_maxFPS = maxFPS;
			_playbackDetailsRecord = playbackDetailsRecord;
			_nsInfo = nsInfo;
			_bufferLength = bufferLength;
			_bufferTime = bufferTime;
			_emptyBufferOccurred = emptyBufferOccurred;
		}
		
		/**
		 * The machine time when this QoSInfo was created
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get timestamp():Number
		{
			return _timestamp;
		}
		
		/**
		 * The playhead time when this QoSInfo was created (time in the stream)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get playheadTime():Number
		{
			return _playheadTime;
		}
		
		/**
		 * The available quality levels
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get availableQualityLevels():Vector.<QualityLevel>
		{
			return _availableQualityLevels;
		}
		
		/**
		 * The index of the currently playing quality level
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get currentIndex():int
		{
			return _currentIndex;
		}
		
		/**
		 * The index of the currently downloading quality level
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get actualIndex():int
		{
			return _actualIndex;
		}
		
		/**
		 * The fragment details of the last downloaded fragment (HDS only)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get lastDownloadedFragmentDetails():FragmentDetails
		{
			return _lastDownloadedFragmentDetails;
		}
		
		/**
		 * The maximum value of the frames per second recorded until now
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get maxFPS():Number
		{
			return _maxFPS;
		}
		
		/**
		 * The NetStreamInfo of the NetStream
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get nsInfo():NetStreamInfo
		{
			return _nsInfo;
		}
		
		/**
		 * The record containing playback details on the quality levels played since last
		 * ABREvent.QOS_UPDATE event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get playbackDetailsRecord():Vector.<PlaybackDetails>
		{
			return _playbackDetailsRecord;
		}
		
		/**
		 * The length of the buffer (in seconds)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get bufferLength():Number
		{
			return _bufferLength;
		}
		
		/**
		 * The minimum buffer time (in seconds)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get bufferTime():Number
		{
			return _bufferTime;
		}
		
		/**
		 * Signals whether there was any playback interruption caused by 
		 * an empty buffer since the last QoSInfo was provided
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get emptyBufferOccurred():Boolean
		{
			return _emptyBufferOccurred;
		}
		
		CONFIG::LOGGING
		{
			public function logInformation():void
			{
				logger.info(" Available quality levels: (index, streamName, bitrate)"); 
				for each (var q:QualityLevel in availableQualityLevels)
				{
					logger.info("  (" + q.index + ", " + q.streamName + ", " + q.bitrate + " kbps" + ")");
				}
				
				logger.info(" currentIndex (playing): " + currentIndex);
				logger.info(" actualIndex (downloading): " + actualIndex);
				
				logger.info(" Max FPS: " + ABRUtils.roundNumber(maxFPS));
				
				logger.info(" EmptyBufferInterruption: " + emptyBufferOccurred);
				
				var machineDate:Date = new Date(timestamp);
				
				logger.info(" Machine time: " + timestamp + " (" + machineDate.toLocaleString() + "." + machineDate.milliseconds + "); Playhead time: " + playheadTime);
				
				var fd:FragmentDetails = lastDownloadedFragmentDetails;
				if (fd != null)
				{
					logger.info
						(
							" Last downloaded fragment details:" +
							" (index = " + fd.index + 
							", size = " + fd.size + " B" + 
							", downloadDuration = " + fd.downloadDuration + " s" +
							", playDuration = " + fd.playDuration +  " s" +
							", fragmentIdentifier = " + fd.fragmentIdentifier + ")"
						);
				}
				
				var playbackDetailsRecord:Vector.<PlaybackDetails> = playbackDetailsRecord;
				if (playbackDetailsRecord != null)
				{
					logger.info(" Since last QoS update, the following quality levels have been played: ");
					for each (var pd:PlaybackDetails in playbackDetailsRecord)
					{
						logger.info("  index = " + pd.index + ", duration = " + ABRUtils.roundNumber(pd.duration) + " s, dropped frames = " + pd.droppedFrames);
					}
				}
			}
		}
		
		private var _currentIndex:int = -1;
		private var _actualIndex:int = -1;
		private var _lastDownloadedFragmentDetails:FragmentDetails = null;
		private var _timestamp:Number = Number.NaN;
		private var _playheadTime:Number = Number.NaN;
		private var _availableQualityLevels:Vector.<QualityLevel> = null;
		private var _maxFPS:Number = Number.NaN;
		private var _nsInfo:NetStreamInfo = null;
		private var _playbackDetailsRecord:Vector.<PlaybackDetails> = null;
		private var _bufferTime:Number = Number.NaN;
		private var _bufferLength:Number = Number.NaN;
		private var _emptyBufferOccurred:Boolean = false;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.qos.QoSInfo");
		}
	}
}