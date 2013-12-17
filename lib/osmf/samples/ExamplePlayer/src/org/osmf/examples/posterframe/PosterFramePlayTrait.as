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
package org.osmf.examples.posterframe
{
	import org.osmf.media.MediaElement;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	internal class PosterFramePlayTrait extends PlayTrait
	{
		public function PosterFramePlayTrait()
		{
			super();
		}
		
		override public function get canPause():Boolean
		{
			return false;
		}
		
		override protected function playStateChangeEnd():void
		{
			super.playStateChangeEnd();
			
			if (playState == PlayState.PLAYING)
			{
				// When the play() is finished, we reset our state to "not playing",
				// since this trait has completed its work.
				stop();
			}
		}
	}
}