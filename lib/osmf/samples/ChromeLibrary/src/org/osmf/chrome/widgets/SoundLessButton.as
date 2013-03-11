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
	import flash.events.MouseEvent;
	
	import org.osmf.events.AudioEvent;
	
	public class SoundLessButton extends SoundMoreButton
	{
		// Overrides
		//
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			if (audible)
			{
				audible.volume = Math.max(0, audible.volume - 0.2);
			} 
		}
		
		override protected function onVolumeChange(event:AudioEvent = null):void
		{
			enabled = audible ? audible.volume != 0 : false;
		}
	}
}