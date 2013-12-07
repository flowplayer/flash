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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.URLResource;
	
	/**
	 * A simple demonstration of the MediaPlayerSprite.  This sample will
	 * show how the MediaPlayerSprite can take a URLResource, and create a video
	 * with a letterbox layout, and scaling capability in 9 lines of code.
	 **/
	[SWF(backgroundColor=0x000000)]
	public class MediaPlayerSpriteSample extends Sprite
	{	
		public function MediaPlayerSpriteSample()
		{		
			//Neccesary to prevent the MPS from scaling via ScaleX and ScaleY.
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
						
			// Create the container class that displays the media.
			mps = new MediaPlayerSprite();	
			addChild(mps);
				
			stage.addEventListener(Event.RESIZE, onResize);
			
			mps.resource = new URLResource(REMOTE_PROGRESSIVE);		
				
			//Update the MPS to the initial size.
			onResize();		
		}
		
		/**
		 * Resizes the component when the stage resizes.  Matches
		 * the width and height the stage.
		 */ 
		private function onResize(event:Event = null):void
		{			
			mps.width = stage.stageWidth;
			mps.height = stage.stageHeight;
		}
		
		private static const REMOTE_PROGRESSIVE:String 			= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
		private var mps:MediaPlayerSprite;				
	}
}


