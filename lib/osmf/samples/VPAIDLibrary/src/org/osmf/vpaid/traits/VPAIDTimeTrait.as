/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vpaid.traits
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.traits.TimeTrait;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * Attached to Linear VPAIDElements. Takes the duration of the creative as a paramater.
	 * The VPAIDElement notifies the VPAIDTimeTrait with the remaining time left in the ad.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class VPAIDTimeTrait extends TimeTrait
	{
		private var vpaidTimer:Timer;
		
		public function VPAIDTimeTrait(duration:Number=NaN)
		{
			super(duration);
			
		}
		
		
	/**
		VPAIDElement updates the timer. Timer keeps track of time
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
		public function updateRemainingTime(remaingTime:Number):void
		{
			if(remaingTime <= 0){
				signalComplete();
				cleanUpTimer();
			}else{
				setDuration(remaingTime);
				setCurrentTime(0); //Restart at zero everytime
				countCurrentTime(duration);
			}
		}
	
	/**
		Called to pause the counting of the current time
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
		public function pauseTimer():void
		{
			CONFIG::LOGGING
			{
				if(duration && currentTime)
				{
					var remainingTime:Number = duration - currentTime;
					logger.debug("[VPAID] Pausing timer, remaining time: " + remainingTime +" current time: " + currentTime);
				}
			}
			cleanUpTimer();
		}
		
	/**
		Called to resume the counting of the current time
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
		public function resumeTimer():void
		{
			if(duration && currentTime)
			{
				var remainingTime:Number = duration - currentTime;
				CONFIG::LOGGING
				{
					logger.debug("[VPAID] Resuming timer, remaining time: " + remainingTime +" current time: " + currentTime);
				}
				countCurrentTime(Math.max(0,remainingTime));
			}
		}

		override protected function signalComplete():void
		{
			cleanUpTimer();
			dispatchEvent(new TimeEvent(TimeEvent.COMPLETE));
		}
		
		//Counts up to the duration of the VPAID creative. Calls onTimer every 1 sec.
		private function countCurrentTime(time:Number):void
		{
			cleanUpTimer();
			vpaidTimer = new Timer(1000, time);
			vpaidTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			vpaidTimer.addEventListener(TimerEvent.TIMER, onTimer);
			vpaidTimer.start();
		
		}
		
		//Timer needs to be completely cleared from memory so that it doesn't fire when it is not needed
		private function cleanUpTimer():void
		{
			if(vpaidTimer)
			{
				vpaidTimer.stop();
				vpaidTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				vpaidTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				
			}
		}
		
		private function onTimerComplete(event:TimerEvent):void
		{
			setDuration(0);
			cleanUpTimer();
		}
		
		//Adds one second to the current time
		private function onTimer(event:TimerEvent):void
		{
			var newTime:Number = Math.min(duration, currentTime + 1);
			setCurrentTime(newTime);
			//trace("current time: " + currentTime);
		}
		
		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vpaid.traits.VPAIDTimeTrait");
	}
}
