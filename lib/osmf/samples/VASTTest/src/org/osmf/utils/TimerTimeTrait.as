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
package org.osmf.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TimeTrait;
	
	/**
	 * TimeTrait which keeps its current time in sync with the playing state of a
	 * PlayTrait, via a Timer.  Useful for testing.
	 **/
	public class TimerTimeTrait extends TimeTrait
	{
		public function TimerTimeTrait(duration:Number, playTrait:PlayTrait)
		{
			super(duration);
			
			setCurrentTime(0);
			this.playTrait = playTrait;
			
			playheadTimer = new Timer(250);
			playheadTimer.addEventListener(TimerEvent.TIMER, onPlayheadTimer);
			
			playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
		}
		
		override protected function signalComplete():void
		{
			super.signalComplete();
			
			playheadTimer.stop();
		}
		
		private function onPlayStateChange(event:PlayEvent):void
		{
			if (event.playState == PlayState.PLAYING)
			{
				playheadTimer.start();
			}
			else
			{
				playheadTimer.stop();
			}
		}
		
		private function onPlayheadTimer(event:TimerEvent):void
		{
			setCurrentTime(currentTime + 0.25);
		}
		
		private var playTrait:PlayTrait;
		private var playheadTimer:Timer;
	}
}