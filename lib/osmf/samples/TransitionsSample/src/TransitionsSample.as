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
	import flash.events.MouseEvent;
	
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	[SWF(backgroundColor=0x000000)]
	public class TransitionsSample extends Sprite
	{
		public function TransitionsSample()
		{
			// Necessary to prevent the MPS from scaling via scaleX and scaleY.
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Create the container class that displays the media.
			mps = new MediaPlayerSprite();	
			mps.scaleMode = ScaleMode.STRETCH;
			
			addChild(mps);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			var imageElem:MediaElement = new DurationElement(30, new ImageElement(new URLResource(REMOTE_IMAGE)));
			var videoElem:MediaElement = new VideoElement(new URLResource(REMOTE_PROGRESSIVE));
			var serialElem:SerialElement = new SerialElement();
			
			serialElem.addChild(imageElem);
			serialElem.addChild(videoElem);
						
			new MediaElementEffect(10, imageElem);
			new MediaElementEffect(10, videoElem);
			
			mps.media = serialElem;	
			
			var layout:LayoutMetadata = new LayoutMetadata();
			layout.scaleMode = ScaleMode.LETTERBOX;
			layout.percentWidth = 100;
			layout.percentHeight = 100;	
			layout.verticalAlign = VerticalAlign.MIDDLE;
			layout.horizontalAlign = HorizontalAlign.CENTER;
					
			serialElem.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
						
			// Update the MPS to the initial size.
			onResize();	
		}
		
		private function onClick(event:Event):void
		{
			if (mps.mediaPlayer.canPlay)
			{
				mps.mediaPlayer.play();
			}
		}
				
		private function onResize(event:Event = null):void
		{				
			mps.width = stage.stageWidth;
			mps.height = stage.stageHeight;
		}
		
		private static const REMOTE_IMAGE:String				= "http://mediapm.edgesuite.net/strobe/content/test/train.jpg";
		private static const REMOTE_PROGRESSIVE:String 			= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
		private var mps:MediaPlayerSprite;
	}
}