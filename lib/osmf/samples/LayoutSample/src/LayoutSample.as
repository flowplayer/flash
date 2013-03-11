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
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;

	[SWF(backgroundColor="0x000000", frameRate="25", width="640", height="360")]
	public class LayoutSample extends Sprite
	{
		public function LayoutSample()
		{
			// Contstruct and image element:
			var logo:ImageElement = new ImageElement(new URLResource(LOGO_PNG));
			logo.smoothing = true;

			// Construct a layout properties object for the logo:			
			var logoLayout:LayoutMetadata = new LayoutMetadata();
			logo.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, logoLayout);;
			
			// Set the image to take 30% of its parent's width and height: 
			logoLayout.percentWidth = 30;
			logoLayout.percentHeight = 30;
			
			// Position the image's bottom-right corner 20 pixels away from
			// the container's bottom-right corner:
			logoLayout.bottom = 20;
			logoLayout.right = 20;
			
			// Set the image to scale, keeping aspect ratio:
			logoLayout.scaleMode = ScaleMode.LETTERBOX;
			
			// Instruct the image to be moved to the right hand side, should
			// any surplus horizontal space be available after scaling:
			logoLayout.horizontalAlign = HorizontalAlign.RIGHT;
			
			// Construct a video element:
			var video:MediaElement = new VideoElement(new URLResource(LOGO_VID));
			
			// If no layout properties have been set on an element when it gets
			// added to a parent, then the the parent will set the target to
			// scale letter-box mode, vertical alignment to center, horizontal
			// alignment to middle, and set width and height to 100% of the
			// parent. This is fine for the video element at hand, so no additional
			// layout properties are set for it.		
			
			// Construct a parallel element that holds both the video and the
			// logo still: 
			var parallel:ParallelElement = new ParallelElement();
			parallel.addChild(video);
			parallel.addChild(logo);
			
			// Give the parallel element a fixed width and height. Both the
			// video element and the logo will base their appearance of these
			// metrics:
			var parallelLayout:LayoutMetadata = new LayoutMetadata();
			parallel.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, parallelLayout);
			parallelLayout.width = stage.stageWidth;
			parallelLayout.height = stage.stageHeight;
			
			// Construct a container that will display the parallel media
			// element:
			var container:MediaContainer = new MediaContainer()
			container.addMediaElement(parallel);
			addChild(container);
			
			// Construct a player to load and play the parallel element:
			var player:MediaPlayer = new MediaPlayer(parallel);
			player.loop = true;
		}
		
		private static const LOGO_PNG:String = "http://dl.dropbox.com/u/2980264/OSMF/logo_white.png";
		private static const LOGO_VID:String = "http://mediapm.edgesuite.net/osmf/content/test/logo_animated.flv";
	}
}
