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
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	
	import org.osmf.utils.OSMFStrings;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	[Event(name="runAlgorithm", type="org.osmf.net.abr.ABREvent")]

	/**
	 * Controller of the NetStream regarding switching. Intended to be used by an adaptive bitrate switch manager
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class NetStreamSwitcher extends EventDispatcher
	{
		/**
		 * Constructor.
		 * 
		 * @param The NetStream object to be controlled
		 * @param dsResource The dynamic streaming resource
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function NetStreamSwitcher(netStream:NetStream, dsResource:DynamicStreamingResource)
		{
			if (netStream == null)
			{
				throw new ArgumentError("Invalid netStream");
			}
			
			if (dsResource == null)
			{
				throw new ArgumentError("Invalid dynamic streaming resource");
			}
			
			this.netStream = netStream;
			this.dsResource = dsResource;
			
			_currentIndex = Math.max(0, dsResource.initialIndex);
			
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			// Make sure we get onPlayStatus first (by setting a higher priority)
			// so that we can expose a consistent state to clients.
			var client:NetClient = netStream.client as NetClient;
			if (client != null)
			{
				NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS, onPlayStatus, int.MAX_VALUE);
			}
			else
			{
				throw new Error("The netStream does not have a NetClient associated.");
			}
		}
		
		/**
		 * Index of the quality level currently being played
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get currentIndex():uint
		{
			return _currentIndex;
		}
		
		/**
		 * The index of the quality level currently being downloaded 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get actualIndex():int
		{
			return _actualIndex == -1 ? _currentIndex : _actualIndex;
		}
		
		/**
		 * Flag indicating whether the NetStreamSwitcher is currently in a switching process. <br />
		 * This is set to true when a switch is initiated and is set back to false when the NetStream
		 * reports having initiated the transition (NetStatusEvent.TRANSITION).
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get switching():Boolean
		{
			return _switching;
		}
		
		/**
		 * Initiates a switch to the specified index
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function switchTo(index:int):void
		{
			if (index < 0)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
			}
			
			if (_actualIndex == -1)
			{
				prepareForSwitching();
			}
			executeSwitch(index);
		}
		
		private function setCurrentIndex(value:uint):void
		{
			var oldValue:uint = _currentIndex;
			_currentIndex = value;
		}
		
		private function setActualIndex(value:int):void
		{
			var oldValue:int = _actualIndex;
			_actualIndex = value;
		}
		
		/**
		 * Executes the switch to the specified index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private function executeSwitch(targetIndex:int):void 
		{
			var nso:NetStreamPlayOptions = new NetStreamPlayOptions();
			
			var playArgs:Object = NetStreamUtils.getPlayArgsForResource(dsResource);
			
			nso.start = playArgs.start;
			nso.len = playArgs.len;
			
			nso.streamName = dsResource.streamItems[targetIndex].streamName;
			
			// FM-925, it seems that the oldStreamName cannot contain parameters,
			// therefore we must remove them
			var sn:String = oldStreamName;
			if (sn != null && sn.indexOf("?") >= 0)
			{
				nso.oldStreamName = sn.substr(0, sn.indexOf("?"));
			}
			else
			{
				nso.oldStreamName = oldStreamName;
			}
			
			nso.transition = NetStreamPlayTransitions.SWITCH;
			
			CONFIG::LOGGING
			{
				logger.debug("executeSwitch() - Switching to index " + (targetIndex) + " at " + Math.round(dsResource.streamItems[targetIndex].bitrate) + " kbps");
			}
			
			_switching = true;
			
			netStream.play2(nso);
			
			oldStreamName = dsResource.streamItems[targetIndex].streamName;
		}
		
		/**
		 * Prepare the manager for switching.  Note that this doesn't necessarily
		 * mean a switch is imminent.
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private function prepareForSwitching():void
		{
			_actualIndex = 0;
			// lastTransitionIndex = -1;
			
			if ((dsResource.initialIndex >= 0) && (dsResource.initialIndex < dsResource.streamItems.length))
			{
				_actualIndex = dsResource.initialIndex;
			}
			
			CONFIG::LOGGING
			{
				logger.debug("prepareForSwitching() - Starting with stream index " + _actualIndex + " at " + Math.round(dsResource.streamItems[_actualIndex].bitrate) + " kbps");
			}
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("onNetStatus() - event.info.code = " + event.info.code);
			}
			
			switch (event.info.code) 
			{
				case NetStreamCodes.NETSTREAM_PLAY_START:
					if (_actualIndex == -1)
					{
						prepareForSwitching();
					}
					break;
				case NetStreamCodes.NETSTREAM_PLAY_TRANSITION:
					// Issue: http://bugs.adobe.com/jira/browse/FM-1474
					// We need to check whether this was a video transition,
					// because the same event is dispatched in case of an audio transition.
					// We do this by checking whether the url the transition
					// was initated to is indeed a video stream
					var index:int = dsResource.indexFromName(event.info.details);
					if (index >= 0)
					{
						setActualIndex(index);
						
						CONFIG::LOGGING
						{
							logger.debug("event.info.details (index) = " + index);
						}
						
						if (_actualIndex > -1)
						{
							_switching = false;
						}
					}
					break;
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:
					_switching  = false;
					break;
				case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
					_switching  = false;
					setCurrentIndex(actualIndex);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_STOP:
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
					var index:int = dsResource.indexFromName(info.details);
					
					if (index >= 0)
					{
						setCurrentIndex(index);
						
						CONFIG::LOGGING
						{
							logger.debug("onPlayStatus() - Transition complete to index: " + index + " at " + Math.round(dsResource.streamItems[index].bitrate) + " kbps");
						}
					}
					
					break;
			}
		}
		
		private var oldStreamName:String;
		private var netStream:NetStream = null;
		private var dsResource:DynamicStreamingResource = null;
		private var _currentIndex:uint = 0;
		private var _actualIndex:int = -1;
		private var _switching:Boolean;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.NetStreamSwitcher");
		}
	}
}