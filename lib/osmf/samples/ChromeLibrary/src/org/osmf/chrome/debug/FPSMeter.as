/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.chrome.debug
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import org.osmf.chrome.widgets.LabelWidget;
	
	public class FPSMeter extends LabelWidget
	{
		public function FPSMeter()
		{
			super();
		
			ticks = getTimer();
			frames = 0;	
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			frames++;
			var currentTicks:uint = getTimer();
			if (currentTicks - ticks > 1000)
			{
				text = (frames / ((currentTicks - ticks) / 1000)).toFixed(3) + " Flash frames/sec."; 
				frames = 0;
				ticks = currentTicks;
			} 
		}
		
		private var frames:uint;
		private var ticks:uint;
		private var timer:uint; 
	}
}