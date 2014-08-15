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
*  Contributor(s): Adobe Systems Incorporated.
* 
*****************************************************/
package org.osmf.net
{
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.utils.OSMFStrings;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * @private
	 * 
	 * The NetStreamDynamicStreamTrait class extends DynamicStreamTrait for NetStream-based
	 * dynamic streaming.
	 */   
	public class NetStreamDynamicStreamTrait extends DynamicStreamTrait
	{
		/**
		 * Constructor.
		 * 
		 * @param netStream The NetStream object the class will work with.
		 * @param switchManager The NetStreamSwitchManagerBase which will perform MBR switches.
		 * @param dsResource The DynamicStreamingResource the class will use.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetStreamDynamicStreamTrait(netStream:NetStream, switchManager:NetStreamSwitchManagerBase, dsResource:DynamicStreamingResource)
		{
			super(switchManager.autoSwitch, switchManager.currentIndex, dsResource.streamItems.length);	
			
			this.netStream = netStream;
			this.switchManager = switchManager;
			this.dsResource = dsResource;
									
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, int.MAX_VALUE);
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS, onPlayStatus);
		}
		
		override public function dispose():void
		{
			netStream = null;
			switchManager = null;
		}
		
		/**
		 * @private
		 */
		override public function getBitrateForIndex(index:int):Number
		{
			if (index > numDynamicStreams - 1 || index < 0)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
			}

			return dsResource.streamItems[index].bitrate;
		}	
				
		/**
		 * @private
		 */
		override protected function switchingChangeStart(newSwitching:Boolean, index:int):void
		{
			CONFIG::LOGGING
			{
				logger.debug("switchingChangeStart: newSwitching = " + newSwitching + "; index = " + index + "; inSetSwitching = " + inSetSwitching);
			}
			
			if (newSwitching && !inSetSwitching)
			{
				// Keep track of the target index, we don't want to begin
				// the switch now since our switching state won't be
				// updated until the switchingChangeEnd method is called.
				indexToSwitchTo = index;
			}
		}
		
		/**
		 * @private
		 */
		override protected function switchingChangeEnd(index:int):void
		{
			CONFIG::LOGGING
			{
				logger.debug("switchingChangeEnd: index = " + index + "; inSetSwitching = " + inSetSwitching);
			}
			
			// We don't want to call super's switchingChangeEnd 
			// (which dispatches a DynamicStreamEvent.SWITCHING_CHANGE)
			// for switches issued by the user.
			//
			// This ensures that the DynamicStreamEvent.SWITCHING_CHANGE 
			// is now dispatched only on two occasions:
			//
			//  - When a transition has been acknowledged by the NetStream
			//    (in this case the switching property of the event is true)
			// 
			//  - When the transition has been completed
			//    (in this case the switching property of the event is false)
			//
			if (!switching || inSetSwitching)
			{
				super.switchingChangeEnd(index);
			}
			else
			{
				// http://bugs.adobe.com/jira/browse/FM-1512
				// If we know what the actualIndex is, we can prevent
				// switches to that index, by declaring the switch complete
				// right now
				//
				// It's ok not to do this in RTMP, since the NetStream
				// accepts switches to the same index and it dispatches
				// the corresponding NetStatus.TRANSITION and 
				// PlayStatus.TRANSITION_COMPLETE events
				//
				// In HDS however, allowing this kind of transitions are
				// ignored by the HTTPNetStream.
				// We would never get a NetStatus.TRANSITION and 
				// more importantly a PlayStatus.TRANSITION_COMPLETE
				// so we would be stuck in a switching state
				var actualIndex:int = -1;
				if (switchManager.hasOwnProperty("actualIndex"))
				{
					actualIndex = switchManager["actualIndex"];
				}
				
				if (indexToSwitchTo != actualIndex)
				{
					switchManager.switchTo(indexToSwitchTo);
				}
				else
				{
					// Finish up the switch operation artificially
					setSwitching(false, indexToSwitchTo);
				}
			}
		}
			
		/**
		 * @private
		 */
		override protected function autoSwitchChangeStart(value:Boolean):void
		{
			switchManager.autoSwitch = value;
		}
		
		/**
		 * @private
		 */ 
		override protected function maxAllowedIndexChangeStart(value:int):void
		{
			switchManager.maxAllowedIndex = value;
		}
						
		private function onNetStatus(event:NetStatusEvent):void
		{			
			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_START:
					// Don't try to grab the index if there is no stream name
					if(event.info.details)
					{
						index = dsResource.indexFromName(event.info.details);
						
						// If starting a stream that is not the current index, let the system know that it is transitioning
						if(index != this.currentIndex)
						{
							inSetSwitching = true;
							setSwitching(true, index);
							inSetSwitching = false;
						}
						
						// Notify the system that the stream has transitioned
						setSwitching(false, index);
					}
					break;
				
				case NetStreamCodes.NETSTREAM_PLAY_TRANSITION:
					// This switch is driven by the NetStream, we set a member
					// variable so that we don't assume it's being requested by
					// the client (and thus trigger a second switch).					
					
					CONFIG::LOGGING
					{
						logger.debug("NetStatus event:NetStream.Play.Transition");
					}
					
					// Issue: http://bugs.adobe.com/jira/browse/FM-1474
					// We need to check whether this was a video transition,
					// because the same event is dispatched in case of an audio transition.
					// We do this by checking whether the url the transition
					// was initiated to is indeed a video stream
					
					index = dsResource.indexFromName(event.info.details);
					
					if (index >= 0)
					{
						// Only initiate the switching if the new index is different than the currently downloading one (actual index)
						// At this moment, RTMP Switch Manager does not provide an actual index. HDS does.
						
						var actualIndex:int = -1;
						if (switchManager.hasOwnProperty("actualIndex"))
						{
							actualIndex = switchManager["actualIndex"];
						}
						
						if (index != actualIndex)
						{
							inSetSwitching = true;
							setSwitching(true, index);
							inSetSwitching = false;
						}
					}
					break;
				
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:
					setSwitching(false, currentIndex);					
					break;
			}
		}
		
		private function onPlayStatus(event:Object):void
		{
			switch (event.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE:
					// Issue: http://bugs.adobe.com/jira/browse/FM-1474
					// We need to check whether this was a video transition,
					// because the same event is dispatched in case of an audio transition.
					// We do this by checking whether the url the transition
					// completed to is indeed a video stream
					
					// We must only check for this only if the event has a details field
					// holding the url, because in RTMP the url is not set in the event
					if (!event.hasOwnProperty("details") || dsResource.indexFromName(event.details) >= 0)
					{
						// If we're here it means that either the details property does not exist (RTMP)
						// or the property exists and in addition it holds a url of a video stream
						
						// When a switch finishes, make sure our current index and
						// switching state reflect the changes to the NetStream.
						setSwitching(false, switchManager.currentIndex);
					}
					break;
			}
		}
		
		private var netStream:NetStream;
		private var switchManager:NetStreamSwitchManagerBase;
		private var inSetSwitching:Boolean;
		private var dsResource:DynamicStreamingResource;
		private var indexToSwitchTo:int;
		private var index:int;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.NetStreamDynamicStreamTrait");
		}
	}
}
