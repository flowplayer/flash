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
package org.osmf.examples.traceproxy
{
	import org.osmf.elements.*;
	import org.osmf.events.*;
	import org.osmf.media.*;
	import org.osmf.metadata.*;
	import org.osmf.traits.*;
	
	public class TraceListenerProxyElement extends ProxyElement
	{
		public function TraceListenerProxyElement(wrappedElement:MediaElement)
		{
			super(wrappedElement);
			
			dispatcher = new TraitEventDispatcher();
			dispatcher.media = wrappedElement;
						
			dispatcher.addEventListener(AudioEvent.MUTED_CHANGE, processMutedChange); 
			dispatcher.addEventListener(AudioEvent.PAN_CHANGE, processPanChange); 
			dispatcher.addEventListener(AudioEvent.VOLUME_CHANGE, processVolumeChange); 
			dispatcher.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, processBufferTimeChange); 
			dispatcher.addEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange); 
			dispatcher.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, processDisplayObjectChange); 
			dispatcher.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, processMediaSizeChange); 
			dispatcher.addEventListener(DRMEvent.DRM_STATE_CHANGE, processDRMStateChange); 
			dispatcher.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, processAutoSwitchChange); 
			dispatcher.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, processNumDynamicStreamsChange); 
			dispatcher.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, processSwitchingChange); 
			dispatcher.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, processBytesTotalChange);
			dispatcher.addEventListener(LoadEvent.LOAD_STATE_CHANGE, processLoadStateChange);  
			dispatcher.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, processCanPauseChange); 
			dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange); 
			dispatcher.addEventListener(SeekEvent.SEEKING_CHANGE, processSeekingChange); 
			dispatcher.addEventListener(TimeEvent.COMPLETE, processComplete); 
			dispatcher.addEventListener(TimeEvent.DURATION_CHANGE, processDurationChange); 
			
			wrappedElement.addEventListener(MediaElementEvent.TRAIT_ADD, processTraitAdd);
			wrappedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, processTraitRemove);			
		}
		
		
		// Overrides
		//
		
		private function processAutoSwitchChange(event:DynamicStreamEvent):void
		{
			trace("autoSwitchChange", event.autoSwitch);
		}
		
		private function processBufferingChange(event:BufferEvent):void
		{
			trace("bufferingChange", event.buffering);
		}
		
		private function processBufferTimeChange(event:BufferEvent):void
		{
			trace("bufferTimeChange", event.bufferTime);
		}
		
		private function processComplete(event:TimeEvent):void
		{
			trace("complete");
		}
		
		private function processCanPauseChange(event:PlayEvent):void
		{
			trace("canPauseChange", event.canPause);
		}
		
		private function processDisplayObjectChange(event:DisplayObjectEvent):void
		{
			trace("displayObjectChange");
		}
		
		private function processDurationChange(event:TimeEvent):void
		{
			trace("durationChange", event.time);
		}
		
		private function processLoadStateChange(event:LoadEvent):void
		{
			trace("loadStateChange", event.loadState);
		}
		
		private function processBytesTotalChange(event:LoadEvent):void
		{
			trace("bytesTotalChange", event.bytes);
		}
		
		
		private function processMediaSizeChange(event:DisplayObjectEvent):void
		{
			trace("mediaSizeChange", event.newWidth, event.newHeight);
		}
		
		private function processMutedChange(event:AudioEvent):void
		{
			trace("mutedChange", event.muted);
		}
		
		private function processNumDynamicStreamsChange(event:DynamicStreamEvent):void
		{
			trace("numDynamicStreamsChange");
		}
		
		private function processPanChange(event:AudioEvent):void
		{
			trace("panChange", event.pan);
		}
		
		private function processPlayStateChange(event:PlayEvent):void
		{
			trace("playStateChange", event.playState);
		}
		
		private function processSeekingChange(event:SeekEvent):void
		{
			trace("seekingChange", event.seeking, event.time);
		}
		
		private function processSwitchingChange(event:DynamicStreamEvent):void
		{
			trace("switchingChange", event.switching);
		}
		
		private function processVolumeChange(event:AudioEvent):void
		{
			trace("volumeChange", event.volume);
		}
		
		private function processDRMStateChange(event:DRMEvent):void
		{
			trace("drmStateChange", event.drmState);
		}
		
		private function processTraitAdd(event:MediaElementEvent):void
		{
			trace("Trait Add: " + event.traitType);
		}
	
		private function processTraitRemove(event:MediaElementEvent):void
		{
			trace("Trait Remove: " + event.traitType);
		}
	
		
		private var dispatcher:TraitEventDispatcher;
	}
}