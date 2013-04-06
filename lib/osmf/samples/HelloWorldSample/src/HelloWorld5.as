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
package
{
	import flash.display.Sprite;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;

	/**
	 * Variation on HelloWorld, using MediaPlayer + DisplayObjectTrait
	 * rather than MediaPlayerSprite.
	 **/
	[SWF(width="640", height="352")]
	public class HelloWorld5 extends Sprite
	{
		public function HelloWorld5()
		{
			mediaPlayer = new MediaPlayer();
			mediaPlayer.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);

			var resource:URLResource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			
			// Set the MediaElement on the MediaPlayer.  Because
			// autoPlay defaults to true, playback begins immediately.
			mediaPlayer.media = new VideoElement(resource);
		}
		
		private function onDisplayObjectChange(event:DisplayObjectEvent):void
		{
			addChild(mediaPlayer.displayObject);
		}
		
		private var mediaPlayer:MediaPlayer;
	}
}
