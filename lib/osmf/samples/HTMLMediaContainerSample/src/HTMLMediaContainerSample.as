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
	import org.osmf.containers.HTMLMediaContainer;
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.HTMLElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;

	[SWF(backgroundColor='#333333', frameRate='30', width='640', height='358')]
	public class HTMLMediaContainerSample extends MediaContainer
	{
		public function HTMLMediaContainerSample()
		{
			runSample1();
			//runSample2(); --> uncomment to run sample 2 (and comment out the line above).
		}
		
		/**
		 * Sample 1 demonstrates how a banner area in HTML can be controlled from
		 * the framework using composition:
		 * 
		 * A parallel element gets defined that holds a video element, and a serial
		 * element. The serial element contains three HTMLElements that reference the
		 * URLs to banner images. The serial element gets assigned to an HTMLContainer
		 * instance.
		 * 
		 * On the JavaScript side (see [project root]/html-template/index.template.html)
		 * the HTMLElements have a load, play- and time trait implemented. This way, each
		 * of the three banner images assigned will show for 5 seconds. After the last
		 * image was shown, it gets removed. 
		 */		
		private function runSample1():void
		{
			var htmlContainer:HTMLMediaContainer = new HTMLMediaContainer("bannerContainer");
			
			var rootElement:ParallelElement = new ParallelElement();
			
				var banners:SerialElement = new SerialElement();
				rootElement.addChild(banners);
				
					var banner1:HTMLElement = new HTMLElement();
					banner1.resource = new URLResource(BANNER_1);
					banners.addChild(banner1);
					
					var banner2:HTMLElement = new HTMLElement();
					banner2.resource = new URLResource(BANNER_2);
					banners.addChild(banner2);
					
					var banner3:HTMLElement = new HTMLElement();
					banner3.resource = new URLResource(BANNER_3);
					banners.addChild(banner3);
				
				var video:VideoElement = constructVideo(REMOTE_PROGRESSIVE);
				rootElement.addChild(video);
			
			addMediaElement(rootElement);
			htmlContainer.addMediaElement(banner1);
			htmlContainer.addMediaElement(banner2);
			htmlContainer.addMediaElement(banner3);
			
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			mediaPlayer.autoPlay = true;
			mediaPlayer.media = rootElement;
		}
		
		/**
		 * Sample 2 demonstrates how multiple HTMLContainer instances can be used
		 * in parallel.
		 * 
		 * A parallel element gets defined that holds a video element, and three
		 * HTMLElement instance. Each of the HTMLElements gets assigned to an
		 * individual HTMLContainer instance.
		 * 
		 * On the JavaScript side (see [project root]/html-template/index.template.html),
		 * the HTMLElements have a load trait implemented. This results in all of
		 * the banners showing in parallel at different locations (defined in HTML as
		 * image tags that the JavaScript load trait implementation interacts with).
		 */		
		private function runSample2():void
		{
			var htmlContainer1:HTMLMediaContainer = new HTMLMediaContainer("bannerContainer1");
			var htmlContainer2:HTMLMediaContainer = new HTMLMediaContainer("bannerContainer2");
			var htmlContainer3:HTMLMediaContainer = new HTMLMediaContainer("bannerContainer3");
			
			var rootElement:ParallelElement = new ParallelElement();
			
				var banner1:HTMLElement = new HTMLElement();
				banner1.resource = new URLResource(BANNER_1);
				rootElement.addChild(banner1);
					
				var banner2:HTMLElement = new HTMLElement();
				banner2.resource = new URLResource(BANNER_2);
				rootElement.addChild(banner2);
				
				var banner3:HTMLElement = new HTMLElement();
				banner3.resource = new URLResource(BANNER_3);
				rootElement.addChild(banner3);
					
				var video:VideoElement = constructVideo(REMOTE_PROGRESSIVE);
				rootElement.addChild(video);
			
			addMediaElement(rootElement);
			
			htmlContainer1.addMediaElement(banner1);
			htmlContainer2.addMediaElement(banner2);
			htmlContainer3.addMediaElement(banner3);
			
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			mediaPlayer.autoPlay = true;
			mediaPlayer.media = rootElement;
		}
		
		private function constructVideo(url:String):VideoElement
		{
			return new VideoElement
					( new URLResource(url)
					);
		}
		
		private static const REMOTE_PROGRESSIVE:String
			= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
			
		private static const BANNER_1:String
			= "http://www.iab.net/media/image/468x60.gif";
			
		private static const BANNER_2:String
			= "http://www.iab.net/media/image/234x60.gif";
			
		private static const BANNER_3:String
			= "http://www.iab.net/media/image/120x60.gif";
	}
}
