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
package org.osmf.examples.switchingproxy
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	/**
	 * SwitchingProxyElement is capable of switching between two MediaElements
	 * at runtime.
	 * 
	 * @param firstElement The first MediaElement to display.
	 * @param secondElement The MediaElement to switch to at runtime.
	 * @param switchTime The time (in seconds) at which to switch from the first to the second.
	 * @param numSwitches The number of switches back and forth to do.  Default is one.
	 **/
	public class SwitchingProxyElement extends ProxyElement
	{
		public function SwitchingProxyElement(firstElement:MediaElement, secondElement:MediaElement, switchTime:Number, numSwitches:int=1)
		{
			super(firstElement);
			
			this.firstElement = firstElement;
			this.secondElement = secondElement;
			this.switchTime = switchTime;
			
			switchTimer = new Timer(switchTime*1000, numSwitches);
			switchTimer.addEventListener(TimerEvent.TIMER, onSwitchTimer);
			
			// Make sure both elements are loaded up front, so that our switch
			// is seamless.
			var firstLoadTrait:LoadTrait = firstElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			if (firstLoadTrait != null && firstLoadTrait.loadState == LoadState.UNINITIALIZED)
			{
				firstLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange, false, 0, true);
				firstLoadTrait.load();
			}
			var secondLoadTrait:LoadTrait = secondElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			if (secondLoadTrait != null && secondLoadTrait.loadState == LoadState.UNINITIALIZED)
			{
				secondLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange, false, 0, true);
				secondLoadTrait.load();
			}			
		}

		private function onSwitchTimer(event:TimerEvent):void
		{
			// First pause the current one.
			var currentPlayTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if (currentPlayTrait != null && currentPlayTrait.playState == PlayState.PLAYING)
			{
				currentPlayTrait.pause();
			}
			
			// Then switch wrapped elements.
			proxiedElement = (proxiedElement == firstElement ? secondElement : firstElement);
			
			// Then play the new current one.
			currentPlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if (currentPlayTrait != null && currentPlayTrait.playState != PlayState.PLAYING)
			{
				currentPlayTrait.play();
			}
		}
		
		private function onLoadStateChange(event:LoadEvent):void
		{
			// Start our timer as soon as something is loaded.
			if (	event.loadState == LoadState.READY
				&& 	switchTimer.running == false
			   )
			{
				switchTimer.start();
			}
			
			// If one of the two elements is unloaded, we should force the other
			// to unload as well.
			if (	event.loadState == LoadState.UNLOADING
				&& 	event.target == proxiedElement.getTrait(MediaTraitType.LOAD)
			   )
			{
				var otherElement:MediaElement = (proxiedElement == firstElement ? secondElement : firstElement);
				var otherLoadTrait:LoadTrait = otherElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
				otherLoadTrait.unload();
			}
		}

		private var firstElement:MediaElement;
		private var secondElement:MediaElement;
		private var switchTime:Number;
		private var switchTimer:Timer;
	}
}