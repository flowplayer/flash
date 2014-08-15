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
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;

	[SWF(backgroundColor='#333333', frameRate='30')]
	public class MediaContainerSample extends Sprite
	{
		public function MediaContainerSample()
		{
			// Setup the Flash stage:
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            runSample();
  		} 
        
        private function runSample():void
        {   
			// Construct a small tree of media elements:
			
			var rootElement:ParallelElement = new ParallelElement();
			
				var mainContent:VideoElement = constructVideo(REMOTE_PROGRESSIVE);
				rootElement.addChild(mainContent);
				var banners:SerialElement = new SerialElement();
					banners.addChild(constructBanner(BANNER_1));
					banners.addChild(constructBanner(BANNER_2));
					banners.addChild(constructBanner(BANNER_3));
				rootElement.addChild(banners);
				var skyScraper:MediaElement = constructImage(SKY_SCRAPER_1);
				rootElement.addChild(skyScraper);
				
			// Next, decorate the content tree with attributes:
			
			var bannersLayout:LayoutMetadata = new LayoutMetadata();
			banners.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, bannersLayout);
			bannersLayout.percentWidth = 100;
			bannersLayout.percentHeight = 100;
			bannersLayout.scaleMode = ScaleMode.NONE;
			bannersLayout.verticalAlign = VerticalAlign.BOTTOM;
			bannersLayout.horizontalAlign = HorizontalAlign.CENTER;
			
			var mainLayout:LayoutMetadata = new LayoutMetadata();
			mainContent.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, mainLayout);
			mainLayout.percentWidth = 100;
			mainLayout.percentHeight = 100;
			mainLayout.scaleMode = ScaleMode.LETTERBOX;
			mainLayout.verticalAlign = VerticalAlign.TOP;
			mainLayout.horizontalAlign = HorizontalAlign.CENTER;
			
			// Consruct 3 regions:

			var bannerContainer:MediaContainer = new MediaContainer();
			bannerContainer.width = 600;
			bannerContainer.height = 70;
			bannerContainer.backgroundColor = 0xFF0000;
			bannerContainer.backgroundAlpha = .2;
			addChild(bannerContainer);

			var mainContainer:MediaContainer = new MediaContainer();
			mainContainer.width = 600;
			mainContainer.height = 400;
			mainContainer.backgroundColor = 0xFFFFFF;
			mainContainer.backgroundAlpha = .2;
			mainContainer.y = 80;
			addChild(mainContainer);
			
			var skyScraperContainer:MediaContainer = new MediaContainer();
			skyScraperContainer.width = 120;
			skyScraperContainer.height = 600;
			skyScraperContainer.backgroundColor = 0xFF00;
			skyScraperContainer.backgroundAlpha = .2;
			skyScraperContainer.x = 610;
			skyScraperContainer.y = 10;
			addChild(skyScraperContainer);
			
			// Bind media elements to their target regions:
			
			bannerContainer.addMediaElement(banners);
			mainContainer.addMediaElement(mainContent);
			skyScraperContainer.addMediaElement(skyScraper); 
			
			// To operate playback of the content tree, construct a
			// media player. Assignment of the root element to its source will
			// automatically start its loading and playback:
			
			var player:MediaPlayer = new MediaPlayer();
			player.media = rootElement;
			
			// Next, to make things more interesting by adding some interactivity:
			// Let's create another region, at the bottom of the main content. Now,
			// if we click the top banner, let's have it moved to this region, and
			// vice-versa:
			
			var bottomBannerContainer:MediaContainer = new MediaContainer();
			bottomBannerContainer.width = 600;
			bottomBannerContainer.height = 70;
			bottomBannerContainer.backgroundColor = 0xFF;
			bottomBannerContainer.backgroundAlpha = .2;
			bottomBannerContainer.y = 490;
			addChild(bottomBannerContainer);
			
			bannerContainer.addEventListener
				( MouseEvent.CLICK
				, function (event:MouseEvent):void
					{
						bottomBannerContainer.addMediaElement(banners);		
					}
				);
				
			bottomBannerContainer.addEventListener
				( MouseEvent.CLICK
				, function (event:MouseEvent):void
					{
						bannerContainer.addMediaElement(banners);		
					}
				);
				
			// Let's link to the IAB site on the sky-scraper being clicked:
			skyScraperContainer.addEventListener
				( MouseEvent.CLICK
				, function (event:MouseEvent):void	
					{
						navigateToURL(new URLRequest(IAB_URL));
					}
				);
		}
		
		// Utilities
		//
		
		private function constructBanner(url:String):MediaElement
		{
			return new DurationElement
					( BANNER_INTERVAL
					, constructImage(url)
					);
		}
		
		private function constructImage(url:String):MediaElement
		{
			return new ImageElement
					( new URLResource(url)
					) 
				
		}
		
		private function constructVideo(url:String):VideoElement
		{
			return new VideoElement
					( new URLResource(url)
					);
		}
				
		private static const BANNER_INTERVAL:int = 5;
		
		private static const REMOTE_PROGRESSIVE:String
			= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
			
		// IAB standard banners from:
		private static const IAB_URL:String
			= "http://www.iab.net/iab_products_and_industry_services/1421/1443/1452";
		
		private static const BANNER_1:String
			= "http://www.iab.net/media/image/468x60.gif";
			
		private static const BANNER_2:String
			= "http://www.iab.net/media/image/234x60.gif";
			
		private static const BANNER_3:String
			= "http://www.iab.net/media/image/120x60.gif";
			
		private static const SKY_SCRAPER_1:String
			= "http://www.iab.net/media/image/120x600.gif"
		
	}
}
