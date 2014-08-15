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

package org.osmf.player.debug
{
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.TraitEventDispatcher;

	public class DebuggerElementProxy extends ProxyElement
	{
		public function DebuggerElementProxy(wrappedElement:MediaElement, debugger:Debugger)
		{
			super(wrappedElement);
			this.debugger = debugger;
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
					
		}
		
		// Overrides
		//
		
		private function processAutoSwitchChange(event:DynamicStreamEvent):void
		{
			debugger.send("EVENT","autoSwitchChange", event.autoSwitch);
		}
		
		private function processBufferingChange(event:BufferEvent):void
		{
			debugger.send("EVENT","bufferingChange", event.buffering);
		}
		
		private function processBufferTimeChange(event:BufferEvent):void
		{
			debugger.send("EVENT","bufferTimeChange", event.bufferTime);
		}
		
		private function processComplete(event:TimeEvent):void
		{
			debugger.send("EVENT","complete");
		}
		
		private function processCanPauseChange(event:PlayEvent):void
		{
			debugger.send("EVENT","canPauseChange", event.canPause);
		}
		
		private function processDisplayObjectChange(event:DisplayObjectEvent):void
		{
			debugger.send("EVENT","displayObjectChange");
		}
		
		private function processDurationChange(event:TimeEvent):void
		{
			debugger.send("EVENT","durantionChange", event.time);
		}
		
		private function processLoadStateChange(event:LoadEvent):void
		{
			debugger.send("EVENT","loadStateChange", event.loadState);
		}
		
		private function processBytesTotalChange(event:LoadEvent):void
		{
			debugger.send("EVENT","bytesTotalChange", event.bytes);
		}
		
		private function processMediaSizeChange(event:DisplayObjectEvent):void
		{
			debugger.send("EVENT","mediaSizeChange", "[" + event.newWidth + ", " + event.newHeight + "]");
		}
		
		private function processMutedChange(event:AudioEvent):void
		{
			debugger.send("EVENT","mutedChange", event.muted);
		}
		
		private function processNumDynamicStreamsChange(event:DynamicStreamEvent):void
		{
			debugger.send("EVENT","numDynamicStreamsChange");
		}
		
		private function processPanChange(event:AudioEvent):void
		{
			debugger.send("EVENT","panChange", event.pan);
		}
		
		private function processPlayStateChange(event:PlayEvent):void
		{
			debugger.send("EVENT","playStateChange", event.playState);
		}
		
		private function processSeekingChange(event:SeekEvent):void
		{
			debugger.send("EVENT","seekingChange", event.seeking + ", " + event.time);
		}
		
		private function processSwitchingChange(event:DynamicStreamEvent):void
		{
			debugger.send("EVENT","switchingChange", event.switching);
		}
		
		private function processVolumeChange(event:AudioEvent):void
		{
			debugger.send("EVENT","volumeChange", event.volume);
		}
		
		private function processDRMStateChange(event:DRMEvent):void
		{
			var error:String = event.mediaError ? "ErrorID: " + event.mediaError.errorID + ", Message: " + event.mediaError.message + ", Detail: " + event.mediaError.detail  : "";
			debugger.send("EVENT","drmStateChange", event.drmState, "[", error, "]");
		}
		
		// Internals
		//
		
		private var dispatcher:TraitEventDispatcher;		
		private var debugger:Debugger;
	}
}