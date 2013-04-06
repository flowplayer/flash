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

package org.osmf.chrome.widgets
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class QualityDecreaseButton extends QualityIncreaseButton
	{
		// Overrides
		//
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			dynamicStream.switchTo(dynamicStream.currentIndex - 1);
		}
		
		override protected function visibilityDeterminingEventHandler(event:Event = null):void
		{
			visible
				=	dynamicStream != null
				&&	dynamicStream.autoSwitch == false;
				
			enabled
				=	dynamicStream != null
				&&	dynamicStream.switching == false
				&&	dynamicStream.currentIndex != 0;
		}
	}
}