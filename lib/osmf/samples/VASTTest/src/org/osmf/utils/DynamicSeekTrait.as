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
	
	import org.osmf.events.SeekEvent;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	public class DynamicSeekTrait extends SeekTrait
	{
		public function DynamicSeekTrait(timeTrait:TimeTrait)
		{
			super(timeTrait);
			
			addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
			
			_autoCompleteSeek = true;
		}
		
		public function set autoCompleteSeek(value:Boolean):void
		{
			_autoCompleteSeek = value;
		}
		
		public function get autoCompleteSeek():Boolean
		{
			return _autoCompleteSeek;
		}
		
		public function completeSeek(time:Number):void
		{
			var dynamicTimeTrait:DynamicTimeTrait = timeTrait as DynamicTimeTrait;
			if (dynamicTimeTrait != null)
			{
				dynamicTimeTrait.currentTime = time;
			}
			
			super.setSeeking(false, time);
		}
		
		// Internals
		//
		
		private function onSeekingChange(event:SeekEvent):void
		{
			if (event.seeking && autoCompleteSeek)
			{
				seekTargetTime = event.time;

				// Complete the seek shortly after it begins.
				var timer:Timer = new Timer(500, 1);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
				timer.start();
				
				function onTimer(timerEvent:TimerEvent):void
				{
					timer.removeEventListener(TimerEvent.TIMER, onTimer);
					
					setSeeking(false, seekTargetTime);
				}
			}
		}
		
		private var _autoCompleteSeek:Boolean;
		private var seekTargetTime:Number;
	}
}