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
	
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;

	/**
	 * Variation on HelloWorld, using MediaElement + DisplayObjectTrait
	 * rather than MediaPlayerSprite.  This example uses LightweightVideoElement
	 * instead of VideoElement.  LightweightVideoElement has a smaller footprint,
	 * but only supports progressive and simple streaming.
	 **/
	[SWF(width="640", height="352")]
	public class HelloWorld6 extends Sprite
	{
		public function HelloWorld6()
		{
			var resource:URLResource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			videoElement = new LightweightVideoElement(resource);
			
			var loadTrait:LoadTrait = videoElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onReady);
			loadTrait.load();
		}
		
		private function onReady(event:LoadEvent):void
		{
			if (event.loadState == LoadState.READY)
			{
				var loadTrait:LoadTrait = videoElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
				loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onReady);
				
				var playTrait:PlayTrait = videoElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
				playTrait.play();
				
				var displayObjectTrait:DisplayObjectTrait = videoElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
				addChild(displayObjectTrait.displayObject);
			}
		}
		
		private var videoElement:LightweightVideoElement;
	}
}
