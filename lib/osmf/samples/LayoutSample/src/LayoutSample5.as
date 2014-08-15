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

package 
{
	import flash.display.Sprite;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.utils.OSMFSettings;
	
	import spark.layouts.supportClasses.LayoutBase;

	[SWF(backgroundColor="0x000000", frameRate="25", width="640", height="360")]
	public class LayoutSample5 extends Sprite
	{
		public function LayoutSample5()
		{
			OSMFSettings.enableStageVideo=false;
			// Contstruct and image element:
			var logo:ImageElement = new ImageElement(new URLResource(LOGO_PNG));
			logo.smoothing = true;

			// Construct a layout properties object for the logo:			
			var logoLayout:LayoutMetadata = new LayoutMetadata();
			logo.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, logoLayout);
			

			logoLayout.x = 5;
			logoLayout.paddingBottom=10;
			logoLayout.paddingLeft=10;
			logoLayout.paddingRight=10;
			logoLayout.paddingTop=10;
			
			
			
			// Set the image to scale, keeping aspect ratio:
			logoLayout.scaleMode = ScaleMode.NONE;
			
			// Instruct the image to be moved to the right hand side, should
			// any surplus horizontal space be available after scaling:
			//logoLayout.horizontalAlign = HorizontalAlign.RIGHT;
			
			
			// Construct a video element:
			var resource:URLResource = new URLResource(LOGO_VID);
			var mediaFactory:MediaFactory = new DefaultMediaFactory();
			var video:MediaElement = mediaFactory.createMediaElement(resource);
			
			var videoLayout: LayoutMetadata = new LayoutMetadata();
			videoLayout.scaleMode = ScaleMode.LETTERBOX;
			videoLayout.bottom=0;
			videoLayout.percentHeight=90;
			
			video.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, videoLayout);
			
			
			

			var parallel:ParallelElement = new ParallelElement();
		
			parallel.addChild(video);
			parallel.addChild(logo);


			var parallelLayout:LayoutMetadata = new LayoutMetadata();
			parallel.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, parallelLayout);
			parallelLayout.width = stage.stageWidth;
			parallelLayout.height = stage.stageHeight;


			var container:MediaContainer = new MediaContainer()
			container.addMediaElement(parallel);
			addChild(container);
			
			var player:MediaPlayer = new MediaPlayer(parallel);
			player.loop = true;
			
			parallelLayout.layoutMode= LayoutMode.NONE;
			//videoLayout.index = 10;
		}
		
		private static const LOGO_PNG:String = "http://dl.dropbox.com/u/2980264/OSMF/logo_white.png";
		
		private static const LOGO_VID:String = "http://zeridemo-f.akamaihd.net/content/inoutedit-mbr/inoutedit_h264_3000.f4m";
		//private static const LOGO_VID:String = "http://mediapm.edgesuite.net/osmf/content/test/logo_animated.flv";

	}
}
