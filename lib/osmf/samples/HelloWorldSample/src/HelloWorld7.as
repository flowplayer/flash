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
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;

	/**
	 * Another simple OSMF application, building on HelloWorld2.as.
	 * 
	 * Plays a video, then shows a SWF, then plays another video.
	 **/
	[SWF(backgroundColor="0x333333")]
	public class HelloWorld7 extends Sprite
	{
		public function HelloWorld7()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
 
 			// Create the container class that displays the media.
 			container = new MediaContainer();
			addChild(container);

			// Set the container's size to match that of the stage, and
			// prevent the content from being scaled.
			container.width = stage.stageWidth;
			container.height = stage.stageHeight;

			// Make sure we resize the container when the stage dimensions
			// change.
			stage.addEventListener(Event.RESIZE, onStageResize);

			// Create the resource to play.
			var resource:URLResource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			
			// Create a composite MediaElement, consisting of a video
			// followed by a SWF, followed by another video.
			var mediaElement:MediaElement = createMediaElement();
			
			// Assign some layout metadata to the MediaElement.  This will cause
			// it to be centered in the container, with no scaling of content.
			var layoutMetadata:LayoutMetadata = new LayoutMetadata();
			layoutMetadata.scaleMode = ScaleMode.NONE;
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);
			
			// Add the MediaElement to our container class, so that it gets
			// displayed.
			container.addMediaElement(mediaElement);
			
			// Set the MediaElement on a MediaPlayer.  Because autoPlay
			// defaults to true, playback begins immediately.
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			mediaPlayer.media = mediaElement;
		}
		
		private function createMediaElement():MediaElement
		{
			var serialElement:SerialElement = new SerialElement();
			
			// First child is a progressive video.
			serialElement.addChild
				( new VideoElement
					( new URLResource(REMOTE_PROGRESSIVE)
					)
				);

			// Second child is a SWF that shows for three seconds.
			serialElement.addChild
				( new DurationElement
					( 3
					, new SWFElement
						( new URLResource(REMOTE_SWF)
						)
					)
				);

			// Third child is a progressive video.
			serialElement.addChild
				( new VideoElement
					( new URLResource(REMOTE_STREAM)
					)
				);
				
			return serialElement;
		}
		
		private function onStageResize(event:Event):void
		{
			container.width = stage.stageWidth;
			container.height = stage.stageHeight;
		}
		
		private var container:MediaContainer;
		
		private static const REMOTE_PROGRESSIVE:String
			= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
			
		private static const REMOTE_SWF:String
			= "http://mediapm.edgesuite.net/osmf/swf/ReferenceSampleSWF.swf";
			
		private static const REMOTE_STREAM:String
			= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
	}
}
