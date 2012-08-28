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
package org.osmf.vast.parser
{
	import flexunit.framework.TestCase;
	
	import org.osmf.vast.model.VASTAd;
	import org.osmf.vast.model.VASTCompanionAd;
	import org.osmf.vast.model.VASTDocument;
	import org.osmf.vast.model.VASTInlineAd;
	import org.osmf.vast.model.VASTMediaFile;
	import org.osmf.vast.model.VASTNonLinearAd;
	import org.osmf.vast.model.VASTResourceType;
	import org.osmf.vast.model.VASTTrackingEvent;
	import org.osmf.vast.model.VASTTrackingEventType;
	import org.osmf.vast.model.VASTUrl;
	import org.osmf.vast.model.VASTVideo;
	import org.osmf.vast.model.VASTVideoClick;
	import org.osmf.vast.model.VASTWrapperAd;
		
	public class TestVASTParser extends TestCase
	{
		override public function setUp():void
		{
			super.setUp();
			
			parser = new VASTParser();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			parser = null;
		}
		
		//---------------------------------------------------------------------
		
		// Success cases
		//

		public function testParseInvalidDocuments():void
		{
			assertTrue(parser.parse(new XML()) == null);
			assertTrue(parser.parse(<foo/>) == null);
			
			try
			{
				parser.parse(null);
				
				fail();
			}
			catch (error:ArgumentError)
			{
				// Swallow.
			}
		}
		
		public function testParseInlineAd():void
		{
			var document:VASTDocument = parser.parse(INLINE_VAST_DOCUMENT);
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == "myinlinead");
			assertTrue(vastAd.inlineAd != null);
			assertTrue(vastAd.wrapperAd == null);
			
			var inlineAd:VASTInlineAd = vastAd.inlineAd;
			
			assertTrue(inlineAd.adSystem == "DART");
			assertTrue(inlineAd.adTitle == "Spiderman 3 Trailer");
			assertTrue(inlineAd.description == "Spiderman video trailer");
			assertTrue(inlineAd.errorURL == "http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false");
			assertTrue(inlineAd.surveyURL == "http://www.dynamiclogic.com/tracker?campaignId=234&site=yahoo");
			
			assertTrue(inlineAd.impressions != null);
			assertTrue(inlineAd.impressions.length == 2);
			var impression:VASTUrl = inlineAd.impressions[0];
			assertTrue(impression.id == "myadsever");
			assertTrue(impression.url == "http://www.primarysite.com/tracker?imp");
			impression = inlineAd.impressions[1];
			assertTrue(impression.id == "anotheradsever");
			assertTrue(impression.url == "http://www.thirdparty.com/tracker?imp");
			
			assertTrue(inlineAd.trackingEvents != null);
			assertTrue(inlineAd.trackingEvents.length == 10);
			
			var trackingEvent:VASTTrackingEvent = inlineAd.trackingEvents[0];
			assertTrue(trackingEvent.type == VASTTrackingEventType.START);
			assertTrue(trackingEvent.urls.length == 1);
			var trackingURL:VASTUrl = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?start");
			
			trackingEvent = inlineAd.trackingEvents[1];
			assertTrue(trackingEvent.type == VASTTrackingEventType.MIDPOINT);
			assertTrue(trackingEvent.urls.length == 2);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mid");
			trackingURL = trackingEvent.urls[1];
			assertTrue(trackingURL.id == "anotheradsever");
			assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?mid");

			trackingEvent = inlineAd.trackingEvents[2];
			assertTrue(trackingEvent.type == VASTTrackingEventType.FIRST_QUARTILE);
			assertTrue(trackingEvent.urls.length == 2);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?fqtl");
			trackingURL = trackingEvent.urls[1];
			assertTrue(trackingURL.id == "anotheradsever");
			assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?fqtl");

			trackingEvent = inlineAd.trackingEvents[3];
			assertTrue(trackingEvent.type == VASTTrackingEventType.THIRD_QUARTILE);
			assertTrue(trackingEvent.urls.length == 2);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?tqtl");
			trackingURL = trackingEvent.urls[1];
			assertTrue(trackingURL.id == "anotheradsever");
			assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?tqtl");

			trackingEvent = inlineAd.trackingEvents[4];
			assertTrue(trackingEvent.type == VASTTrackingEventType.COMPLETE);
			assertTrue(trackingEvent.urls.length == 2);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?comp");
			trackingURL = trackingEvent.urls[1];
			assertTrue(trackingURL.id == "anotheradsever");
			assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?comp");

			trackingEvent = inlineAd.trackingEvents[5];
			assertTrue(trackingEvent.type == VASTTrackingEventType.MUTE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mute");

			trackingEvent = inlineAd.trackingEvents[6];
			assertTrue(trackingEvent.type == VASTTrackingEventType.PAUSE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?pause");

			trackingEvent = inlineAd.trackingEvents[7];
			assertTrue(trackingEvent.type == VASTTrackingEventType.REPLAY);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?replay");

			trackingEvent = inlineAd.trackingEvents[8];
			assertTrue(trackingEvent.type == VASTTrackingEventType.FULLSCREEN);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?full");

			trackingEvent = inlineAd.trackingEvents[9];
			assertTrue(trackingEvent.type == VASTTrackingEventType.STOP);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?stop");
			
			var video:VASTVideo = inlineAd.video;
			assertTrue(video != null);
			assertTrue(video.duration == "00:00:15");
			assertTrue(video.adID == "AdID");
			
			assertTrue(video.videoClick != null);
			var videoClick:VASTVideoClick = video.videoClick;
			
			assertTrue(videoClick.clickThrough != null);
			assertTrue(videoClick.clickThrough.id == "myadsever");
			assertTrue(videoClick.clickThrough.url == "http://www.primarysite.com/tracker?clickthrough");
			
			assertTrue(videoClick.clickTrackings != null);
			assertTrue(videoClick.clickTrackings.length == 2);
			var clickTracking:VASTUrl = videoClick.clickTrackings[0];
			assertTrue(clickTracking.id == "anotheradsever");
			assertTrue(clickTracking.url == "http://www.thirdparty.com/tracker?click1");
			clickTracking = videoClick.clickTrackings[1];
			assertTrue(clickTracking.id == "athirdadsever");
			assertTrue(clickTracking.url == "http://www.thirdparty.com/tracker?click2");
			
			assertTrue(videoClick.customClicks != null);
			assertTrue(videoClick.customClicks.length == 2);
			var customClick:VASTUrl = videoClick.customClicks[0];
			assertTrue(customClick.id == "redclick");
			assertTrue(customClick.url == "http://www.thirdparty.com/tracker?redclick");
			customClick = videoClick.customClicks[1];
			assertTrue(customClick.id == "blueclick");
			assertTrue(customClick.url == "http://www.thirdparty.com/tracker?blueclick");
			
			assertTrue(video.mediaFiles != null);
			assertTrue(video.mediaFiles.length == 6);
			
			var mediaFile:VASTMediaFile = video.mediaFiles[0];
			assertTrue(mediaFile.id == "mymedia");
			assertTrue(mediaFile.url == "rtmp://streamingserver/streamingpath/medium/filename.flv");
			assertTrue(mediaFile.delivery == "streaming");
			assertTrue(mediaFile.bitrate == 250);
			assertTrue(mediaFile.width == 200);
			assertTrue(mediaFile.height == 200);
			assertTrue(mediaFile.type == "video/x-flv");
			
			mediaFile = video.mediaFiles[1];
			assertTrue(mediaFile.id == null);
			assertTrue(mediaFile.url == "http://progressive.hostlocation.com//high/filename.flv");
			assertTrue(mediaFile.delivery == "progressive");
			assertTrue(mediaFile.bitrate == 400);
			assertTrue(mediaFile.width == 200);
			assertTrue(mediaFile.height == 200);
			assertTrue(mediaFile.type == "video/x-flv");

			mediaFile = video.mediaFiles[2];
			assertTrue(mediaFile.id == null);
			assertTrue(mediaFile.url == "mms://streaming.hostlocaltion.com/ondemand/streamingpath/high/filename.wmv");
			assertTrue(mediaFile.delivery == "streaming");
			assertTrue(mediaFile.bitrate == 400);
			assertTrue(mediaFile.width == 200);
			assertTrue(mediaFile.height == 200);
			assertTrue(mediaFile.type == "video/x-ms-wmv");

			mediaFile = video.mediaFiles[3];
			assertTrue(mediaFile.id == null);
			assertTrue(mediaFile.url == "http://progressive.hostlocation.com//high/filename.wmv");
			assertTrue(mediaFile.delivery == "progressive");
			assertTrue(mediaFile.bitrate == 400);
			assertTrue(mediaFile.width == 200);
			assertTrue(mediaFile.height == 200);
			assertTrue(mediaFile.type == "video/x-ms-wmv");

			mediaFile = video.mediaFiles[4];
			assertTrue(mediaFile.id == null);
			assertTrue(mediaFile.url == "rtsp://streaming.hostlocaltion.com/ondemand/streamingpath/low/filename.ra");
			assertTrue(mediaFile.delivery == "streaming");
			assertTrue(mediaFile.bitrate == 75);
			assertTrue(mediaFile.width == 200);
			assertTrue(mediaFile.height == 200);
			assertTrue(mediaFile.type == "video/x-ra");
			
			mediaFile = video.mediaFiles[5];
			assertTrue(mediaFile.id == null);
			assertTrue(mediaFile.url == "http://progressive.hostlocation.com/progressivepath/low/filename.ra");
			assertTrue(mediaFile.delivery == "progressive");
			assertTrue(mediaFile.bitrate == 75);
			assertTrue(mediaFile.width == 200);
			assertTrue(mediaFile.height == 200);
			assertTrue(mediaFile.type == "video/x-ra");
	
			assertTrue(inlineAd.companionAds != null);
			assertTrue(inlineAd.companionAds.length == 4);
			
			var companion:VASTCompanionAd = inlineAd.companionAds[0];
			assertTrue(companion.id == "rich media banner");
			assertTrue(companion.width == 468);
			assertTrue(companion.height == 60);
			assertTrue(companion.resourceType == VASTResourceType.IFRAME);
			assertTrue(companion.creativeType == "any");
			assertTrue(companion.url == "http://ad.server.com/adi/etc.html");
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == null);
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);

			companion = inlineAd.companionAds[1];
			assertTrue(companion.id == "banner1");
			assertTrue(companion.width == 728);
			assertTrue(companion.height == 90);
			assertTrue(companion.resourceType == VASTResourceType.SCRIPT);
			assertTrue(companion.creativeType == "any");
			assertTrue(companion.url == "http://ad.server.com/adj/etc.js");
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == null);
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);

			companion = inlineAd.companionAds[2];
			assertTrue(companion.id == "banner2");
			assertTrue(companion.width == 468);
			assertTrue(companion.height == 60);
			assertTrue(companion.resourceType == VASTResourceType.STATIC);
			assertTrue(companion.creativeType == "JPEG");
			assertTrue(companion.url == "http://media.doubleclick.net/foo.jpg");
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == "http://www.primarysite.com/tracker?click");
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);

			companion = inlineAd.companionAds[3];
			assertTrue(companion.id == "banner3");
			assertTrue(companion.width == 468);
			assertTrue(companion.height == 60);
			assertTrue(companion.resourceType == VASTResourceType.STATIC);
			assertTrue(companion.creativeType == "JPEG");
			assertTrue(companion.url == null);
			assertTrue(companion.adParameters == "param=value");
			assertTrue(companion.altText == "some alt text");
			assertTrue(companion.clickThroughURL == "http://www.primarysite.com/tracker?click");
			assertTrue(companion.code == "insert code here");
			assertTrue(companion.expandedWidth == 728);
			assertTrue(companion.expandedHeight == 90);

			assertTrue(inlineAd.nonLinearAds != null);
			assertTrue(inlineAd.nonLinearAds.length == 3);
			
			var nonLinearAd:VASTNonLinearAd = inlineAd.nonLinearAds[0];
			assertTrue(nonLinearAd.id == "overlay");
			assertTrue(nonLinearAd.width == 150);
			assertTrue(nonLinearAd.height == 60);
			assertTrue(nonLinearAd.resourceType == VASTResourceType.STATIC);
			assertTrue(nonLinearAd.creativeType == "SWF");
			assertTrue(nonLinearAd.url == "http://ad.server.com/adx/etc.xml");
			assertTrue(nonLinearAd.adParameters == null);
			assertTrue(nonLinearAd.clickThroughURL == "http://www.thirdparty.com/tracker?click");
			assertTrue(nonLinearAd.code == null);
			assertTrue(nonLinearAd.expandedWidth == 0);
			assertTrue(nonLinearAd.expandedHeight == 0);
			assertTrue(nonLinearAd.scalable == false);
			assertTrue(nonLinearAd.maintainAspectRatio == false);
			assertTrue(nonLinearAd.apiFramework == "IAB");

			nonLinearAd = inlineAd.nonLinearAds[1];
			assertTrue(nonLinearAd.id == "bumper");
			assertTrue(nonLinearAd.width == 250);
			assertTrue(nonLinearAd.height == 300);
			assertTrue(nonLinearAd.resourceType == VASTResourceType.STATIC);
			assertTrue(nonLinearAd.creativeType == "JPEG");
			assertTrue(nonLinearAd.url == "http://ad.doubleclick.net/adx/etc.jpg");
			assertTrue(nonLinearAd.adParameters == null);
			assertTrue(nonLinearAd.clickThroughURL == "http://www.thirdparty.com/tracker?click");
			assertTrue(nonLinearAd.code == null);
			assertTrue(nonLinearAd.expandedWidth == 0);
			assertTrue(nonLinearAd.expandedHeight == 0);
			assertTrue(nonLinearAd.scalable == false);
			assertTrue(nonLinearAd.maintainAspectRatio == false);
			assertTrue(nonLinearAd.apiFramework == null);
			
			nonLinearAd = inlineAd.nonLinearAds[2];
			assertTrue(nonLinearAd.id == "overlay2");
			assertTrue(nonLinearAd.width == 350);
			assertTrue(nonLinearAd.height == 100);
			assertTrue(nonLinearAd.resourceType == VASTResourceType.OTHER);
			assertTrue(nonLinearAd.creativeType == "JPEG");
			assertTrue(nonLinearAd.adParameters == "param=value");
			assertTrue(nonLinearAd.clickThroughURL == "http://www.thirdparty.com/tracker?click2");
			assertTrue(nonLinearAd.code == "insert code here");
			assertTrue(nonLinearAd.expandedWidth == 728);
			assertTrue(nonLinearAd.expandedHeight == 90);
			assertTrue(nonLinearAd.scalable == true);
			assertTrue(nonLinearAd.maintainAspectRatio == true);
			assertTrue(nonLinearAd.apiFramework == null);
			
			assertTrue(inlineAd.extensions != null);
			assertTrue(inlineAd.extensions.length == 1);
			
			var extension:XML = inlineAd.extensions[0];
			var expectedXML:XML =
				<Extension type="adServer" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
					<TemplateVersion>3.002</TemplateVersion>
					<AdServingData>
						<DeliveryData>
							<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
							<MyAdId>43534850</MyAdId>
						</DeliveryData>
					</AdServingData>
				</Extension>;
			assertTrue(extension.toXMLString() == expectedXML.toXMLString());
		}

		public function testParseWrapperAd():void
		{
			var document:VASTDocument = parser.parse(WRAPPER_VAST_DOCUMENT);
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == "mywrapperad");
			assertTrue(vastAd.inlineAd == null);
			assertTrue(vastAd.wrapperAd != null);
			
			var wrapperAd:VASTWrapperAd = vastAd.wrapperAd;
			assertTrue(wrapperAd.vastAdTagURL == "http://www.secondaryadserver.com/ad/tag/parameters?time=1234567");
			assertTrue(wrapperAd.adSystem == "MyAdSystem");
			assertTrue(wrapperAd.errorURL == "http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false");
			
			assertTrue(wrapperAd.impressions != null);
			assertTrue(wrapperAd.impressions.length == 1);
			var impression:VASTUrl = wrapperAd.impressions[0];
			assertTrue(impression.id == "myadsever");
			assertTrue(impression.url == "http://www.primarysite.com/tracker?imp");
			
			assertTrue(wrapperAd.trackingEvents != null);
			assertTrue(wrapperAd.trackingEvents.length == 8);
			
			var trackingEvent:VASTTrackingEvent = wrapperAd.trackingEvents[0];
			assertTrue(trackingEvent.type == VASTTrackingEventType.MIDPOINT);
			assertTrue(trackingEvent.urls.length == 1);
			var trackingURL:VASTUrl = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mid");
			
			trackingEvent = wrapperAd.trackingEvents[1];
			assertTrue(trackingEvent.type == VASTTrackingEventType.FIRST_QUARTILE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?fqtl");

			trackingEvent = wrapperAd.trackingEvents[2];
			assertTrue(trackingEvent.type == VASTTrackingEventType.THIRD_QUARTILE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?tqtl");

			trackingEvent = wrapperAd.trackingEvents[3];
			assertTrue(trackingEvent.type == VASTTrackingEventType.COMPLETE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?comp");

			trackingEvent = wrapperAd.trackingEvents[4];
			assertTrue(trackingEvent.type == VASTTrackingEventType.MUTE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mute");

			trackingEvent = wrapperAd.trackingEvents[5];
			assertTrue(trackingEvent.type == VASTTrackingEventType.PAUSE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?pause");

			trackingEvent = wrapperAd.trackingEvents[6];
			assertTrue(trackingEvent.type == VASTTrackingEventType.REPLAY);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?replay");

			trackingEvent = wrapperAd.trackingEvents[7];
			assertTrue(trackingEvent.type == VASTTrackingEventType.FULLSCREEN);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?full");
			
			assertTrue(wrapperAd.videoClick != null);
			var videoClick:VASTVideoClick = wrapperAd.videoClick;
			
			assertTrue(videoClick.clickThrough != null);
			assertTrue(videoClick.clickThrough.id == "myadsever");
			assertTrue(videoClick.clickThrough.url == "http://www.primarysite.com/tracker?clickthrough");
			
			assertTrue(videoClick.clickTrackings != null);
			assertTrue(videoClick.clickTrackings.length == 2);
			var clickTracking:VASTUrl = videoClick.clickTrackings[0];
			assertTrue(clickTracking.id == "myadsever");
			assertTrue(clickTracking.url == "http://www.primarysite.com/tracker?click1");
			clickTracking = videoClick.clickTrackings[1];
			assertTrue(clickTracking.id == "myadsever");
			assertTrue(clickTracking.url == "http://www.primarysite.com/tracker?click2");
			
			assertTrue(videoClick.customClicks != null);
			assertTrue(videoClick.customClicks.length == 2);
			var customClick:VASTUrl = videoClick.customClicks[0];
			assertTrue(customClick.id == "myadsever");
			assertTrue(customClick.url == "http://www.primarysite.com/tracker?customclick1");
			customClick = videoClick.customClicks[1];
			assertTrue(customClick.id == "myadsever");
			assertTrue(customClick.url == "http://www.primarysite.com/tracker?customclick2");
			
			assertTrue(wrapperAd.companionImpressions != null);
			assertTrue(wrapperAd.companionImpressions.length == 2);
			var companionImpression:VASTUrl = wrapperAd.companionImpressions[0];
			assertTrue(companionImpression.id == "myadsever");
			assertTrue(companionImpression.url == "http://www.primarysite.com/tracker?comp1");
			companionImpression = wrapperAd.companionImpressions[1];
			assertTrue(companionImpression.id == "myadsever");
			assertTrue(companionImpression.url == "http://www.primarysite.com/tracker?comp2");
			assertTrue(wrapperAd.companionAdTag == null);

			assertTrue(wrapperAd.nonLinearImpressions != null);
			assertTrue(wrapperAd.nonLinearImpressions.length == 2);
			var nonLinearImpression:VASTUrl = wrapperAd.nonLinearImpressions[0];
			assertTrue(nonLinearImpression.id == "myadsever");
			assertTrue(nonLinearImpression.url == "http://www.primarysite.com/tracker?nl1");
			nonLinearImpression = wrapperAd.nonLinearImpressions[1];
			assertTrue(nonLinearImpression.id == "myadsever");
			assertTrue(nonLinearImpression.url == "http://www.primarysite.com/tracker?nl2");
			assertTrue(wrapperAd.nonLinearAdTag == null);
			
			assertTrue(wrapperAd.extensions != null);
			assertTrue(wrapperAd.extensions.length == 1);
			
			var extension:XML = wrapperAd.extensions[0];
			var expectedXML:XML =
				<Extension type="adServer" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
					<TemplateVersion>3.002</TemplateVersion>
					<AdServingData>
						<DeliveryData>
							<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
							<MyAdId>43534850</MyAdId>
						</DeliveryData>
					</AdServingData>
				</Extension>;
			assertTrue(extension.toXMLString() == expectedXML.toXMLString());
		}
		
		public function testParseEmptyInlineAd():void
		{
			// Parse without using strict mode, so that errors are ignored.
			var document:VASTDocument = parser.parse(EMPTY_INLINE_VAST_DOCUMENT, false);
			assertTrue(document != null);
			
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == null);
			assertTrue(vastAd.inlineAd != null);
			assertTrue(vastAd.wrapperAd == null);
			
			var inlineAd:VASTInlineAd = vastAd.inlineAd;
			
			assertTrue(inlineAd.adSystem == null);
			assertTrue(inlineAd.adTitle == null);
			assertTrue(inlineAd.description == null);
			assertTrue(inlineAd.errorURL == null);
			assertTrue(inlineAd.surveyURL == null);
			
			assertTrue(inlineAd.impressions != null);
			assertTrue(inlineAd.impressions.length == 0);
			
			assertTrue(inlineAd.trackingEvents != null);
			assertTrue(inlineAd.trackingEvents.length == 2);
			var trackingEvent:VASTTrackingEvent = inlineAd.trackingEvents[0];
			assertTrue(trackingEvent.type == VASTTrackingEventType.START);
			assertTrue(trackingEvent.urls != null);
			assertTrue(trackingEvent.urls.length == 0);
			trackingEvent = inlineAd.trackingEvents[1];
			assertTrue(trackingEvent.type == null);
			assertTrue(trackingEvent.urls != null);
			assertTrue(trackingEvent.urls.length == 1);
			var trackingURL:VASTUrl = trackingEvent.urls[0];
			assertTrue(trackingURL.id == null);
			assertTrue(trackingURL.url == null);
			
			var video:VASTVideo = inlineAd.video;
			assertTrue(video != null);
			assertTrue(video.duration == null);
			assertTrue(video.adID == null);
			
			assertTrue(video.videoClick != null);
			var videoClick:VASTVideoClick = video.videoClick;
			
			assertTrue(videoClick.clickThrough == null);
			
			assertTrue(videoClick.clickTrackings != null);
			assertTrue(videoClick.clickTrackings.length == 0);
			
			assertTrue(videoClick.customClicks != null);
			assertTrue(videoClick.customClicks.length == 0);
			
			assertTrue(video.mediaFiles != null);
			assertTrue(video.mediaFiles.length == 2);
			
			var mediaFile:VASTMediaFile = video.mediaFiles[0];
			assertTrue(mediaFile.id == null);
			assertTrue(mediaFile.url == null);
			assertTrue(mediaFile.delivery == null);
			assertTrue(mediaFile.bitrate == 0);
			assertTrue(mediaFile.width == 0);
			assertTrue(mediaFile.height == 0);
			assertTrue(mediaFile.type == null);

			mediaFile = video.mediaFiles[1];
			assertTrue(mediaFile.id == null);
			assertTrue(mediaFile.url == null);
			assertTrue(mediaFile.delivery == null);
			assertTrue(mediaFile.bitrate == 0);
			assertTrue(mediaFile.width == 0);
			assertTrue(mediaFile.height == 0);
			assertTrue(mediaFile.type == null);
			
			assertTrue(inlineAd.companionAds != null);
			assertTrue(inlineAd.companionAds.length == 3);
			
			var companion:VASTCompanionAd = inlineAd.companionAds[0];
			assertTrue(companion.id == null);
			assertTrue(companion.width == 0);
			assertTrue(companion.height == 0);
			assertTrue(companion.resourceType == null);
			assertTrue(companion.creativeType ==null);
			assertTrue(companion.url == null);
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == null);
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);

			companion = inlineAd.companionAds[1];
			assertTrue(companion.id == null);
			assertTrue(companion.width == 0);
			assertTrue(companion.height == 0);
			assertTrue(companion.resourceType == null);
			assertTrue(companion.creativeType ==null);
			assertTrue(companion.url == null);
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == null);
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);

			companion = inlineAd.companionAds[2];
			assertTrue(companion.id == null);
			assertTrue(companion.width == 0);
			assertTrue(companion.height == 0);
			assertTrue(companion.resourceType == null);
			assertTrue(companion.creativeType ==null);
			assertTrue(companion.url == null);
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == null);
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);
			
			assertTrue(inlineAd.nonLinearAds != null);
			assertTrue(inlineAd.nonLinearAds.length == 3);
			
			var nonLinearAd:VASTNonLinearAd = inlineAd.nonLinearAds[0];
			assertTrue(nonLinearAd.id == null);
			assertTrue(nonLinearAd.width == 0);
			assertTrue(nonLinearAd.height == 0);
			assertTrue(nonLinearAd.resourceType == null);
			assertTrue(nonLinearAd.creativeType == null);
			assertTrue(nonLinearAd.url == null);
			assertTrue(nonLinearAd.adParameters == null);
			assertTrue(nonLinearAd.clickThroughURL == null);
			assertTrue(nonLinearAd.code == null);
			assertTrue(nonLinearAd.expandedWidth == 0);
			assertTrue(nonLinearAd.expandedHeight == 0);
			assertTrue(nonLinearAd.scalable == false);
			assertTrue(nonLinearAd.maintainAspectRatio == false);
			assertTrue(nonLinearAd.apiFramework == null);

			nonLinearAd = inlineAd.nonLinearAds[1];
			assertTrue(nonLinearAd.id == null);
			assertTrue(nonLinearAd.width == 0);
			assertTrue(nonLinearAd.height == 0);
			assertTrue(nonLinearAd.resourceType == null);
			assertTrue(nonLinearAd.creativeType == null);
			assertTrue(nonLinearAd.url == null);
			assertTrue(nonLinearAd.adParameters == null);
			assertTrue(nonLinearAd.clickThroughURL == null);
			assertTrue(nonLinearAd.code == null);
			assertTrue(nonLinearAd.expandedWidth == 0);
			assertTrue(nonLinearAd.expandedHeight == 0);
			assertTrue(nonLinearAd.scalable == false);
			assertTrue(nonLinearAd.maintainAspectRatio == false);
			assertTrue(nonLinearAd.apiFramework == null);

			nonLinearAd = inlineAd.nonLinearAds[2];
			assertTrue(nonLinearAd.id == null);
			assertTrue(nonLinearAd.width == 0);
			assertTrue(nonLinearAd.height == 0);
			assertTrue(nonLinearAd.resourceType == null);
			assertTrue(nonLinearAd.creativeType == null);
			assertTrue(nonLinearAd.url == null);
			assertTrue(nonLinearAd.adParameters == null);
			assertTrue(nonLinearAd.clickThroughURL == null);
			assertTrue(nonLinearAd.code == null);
			assertTrue(nonLinearAd.expandedWidth == 0);
			assertTrue(nonLinearAd.expandedHeight == 0);
			assertTrue(nonLinearAd.scalable == false);
			assertTrue(nonLinearAd.maintainAspectRatio == false);
			assertTrue(nonLinearAd.apiFramework == null);
			
			assertTrue(inlineAd.extensions != null);
			assertTrue(inlineAd.extensions.length == 0);
		}
		
		public function testParseWrapperAdWithCompanionAndNonLinearAdTags():void
		{
			var document:VASTDocument = parser.parse(WRAPPER_VAST_DOCUMENT_WITH_AD_TAGS);
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == "mywrapperad");
			assertTrue(vastAd.inlineAd == null);
			assertTrue(vastAd.wrapperAd != null);
			
			var wrapperAd:VASTWrapperAd = vastAd.wrapperAd;

			assertTrue(wrapperAd.companionImpressions != null);
			assertTrue(wrapperAd.companionImpressions.length == 0);
			assertTrue(wrapperAd.companionAdTag != null);
			assertTrue(wrapperAd.companionAdTag.id == "myadsever");
			assertTrue(wrapperAd.companionAdTag.url == "http://www.primarysite.com/tracker?comp");

			assertTrue(wrapperAd.nonLinearImpressions != null);
			assertTrue(wrapperAd.nonLinearImpressions.length == 0);
			assertTrue(wrapperAd.nonLinearAdTag != null);
			assertTrue(wrapperAd.nonLinearAdTag.id == "myadsever");
			assertTrue(wrapperAd.nonLinearAdTag.url == "http://www.primarysite.com/tracker?nl");
		}

		public function testParseWrapperAdWithTooManyCompanionAndNonLinearAdTagURLs():void
		{
			var document:VASTDocument = parser.parse(WRAPPER_VAST_DOCUMENT_WITH_TOO_MANY_AD_TAG_URLS);
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == "mywrapperad");
			assertTrue(vastAd.inlineAd == null);
			assertTrue(vastAd.wrapperAd != null);
			
			var wrapperAd:VASTWrapperAd = vastAd.wrapperAd;

			assertTrue(wrapperAd.companionImpressions != null);
			assertTrue(wrapperAd.companionImpressions.length == 0);
			assertTrue(wrapperAd.companionAdTag != null);
			assertTrue(wrapperAd.companionAdTag.id == "myadsever");
			assertTrue(wrapperAd.companionAdTag.url == "http://www.primarysite.com/tracker?comp1");

			assertTrue(wrapperAd.nonLinearImpressions != null);
			assertTrue(wrapperAd.nonLinearImpressions.length == 0);
			assertTrue(wrapperAd.nonLinearAdTag != null);
			assertTrue(wrapperAd.nonLinearAdTag.id == "myadsever");
			assertTrue(wrapperAd.nonLinearAdTag.url == "http://www.primarysite.com/tracker?nl1");
		}
		
		public function testParseWithInvalidDocuments():void
		{
			assertTrue(parser.parse(DUPLICATE_INLINE_WRAPPER_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_AD_SYSTEM_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_AD_TITLE_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_IMPRESSION_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_TRACKING_EVENT_TYPE_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_VIDEO_DURATION_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_VIDEO_URL_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_VIDEO_BITRATE_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_VIDEO_DELIVERY_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_VIDEO_WIDTH_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_VIDEO_HEIGHT_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_COMPANION_AD_WIDTH_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_COMPANION_AD_HEIGHT_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_COMPANION_AD_RESOURCE_TYPE_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_NON_LINEAR_AD_WIDTH_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_NON_LINEAR_AD_HEIGHT_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_INLINE_NON_LINEAR_AD_RESOURCE_TYPE_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_WRAPPER_AD_SYSTEM_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_WRAPPER_VAST_AD_TAG_URL_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_WRAPPER_IMPRESSION_VAST_DOCUMENT) == null);
			assertTrue(parser.parse(MISSING_WRAPPER_TRACKING_EVENT_TYPE_VAST_DOCUMENT) == null);
		}

		private var parser:VASTParser;
		
		private static const INLINE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad id="myinlinead">
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
						<Description>Spiderman video trailer</Description>
						<Survey>
							<URL><![CDATA[ http://www.dynamiclogic.com/tracker?campaignId=234&site=yahoo]]></URL>
						</Survey>
						<Error>
							<URL><![CDATA[http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false]]></URL>
						</Error>
						<Impression>
							<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
							<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?imp]]></URL>
						</Impression>
						<TrackingEvents>
							<Tracking event="start">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?start]]></URL>
							</Tracking>
							<Tracking event="midpoint">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mid]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?mid]]></URL>
							</Tracking>
							<Tracking event="firstQuartile">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?fqtl]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?fqtl]]></URL>
							</Tracking>
							<Tracking event="thirdQuartile">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?tqtl]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?tqtl]]></URL>
							</Tracking>
							<Tracking event="complete">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?comp]]></URL>
							</Tracking>
							<Tracking event="mute">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mute]]></URL>
							</Tracking>
							<Tracking event="pause">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?pause]]></URL>
							</Tracking>
							<Tracking event="replay">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?replay]]></URL>
							</Tracking>
							<Tracking event="fullscreen">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?full]]></URL>
							</Tracking>
							<Tracking event="stop">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?stop]]></URL>
							</Tracking>
						</TrackingEvents>
						<Video>
							<Duration>00:00:15</Duration>
							<AdID>AdID</AdID>
							<VideoClicks>
								<ClickThrough>
									<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?clickthrough]]></URL>
								</ClickThrough>
								<ClickTracking>
									<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?click1]]></URL>
									<URL id="athirdadsever"><![CDATA[http://www.thirdparty.com/tracker?click2]]></URL>
								</ClickTracking>
								<CustomClick>
									<URL id="redclick"><![CDATA[http://www.thirdparty.com/tracker?redclick]]></URL>
									<URL id="blueclick"><![CDATA[http://www.thirdparty.com/tracker?blueclick]]></URL>
								</CustomClick>
							</VideoClicks>
							<MediaFiles>
								<MediaFile id="mymedia" delivery="streaming" bitrate="250" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/medium/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="400" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[http://progressive.hostlocation.com//high/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="streaming" bitrate="400" width="200" height="200" type="video/x-ms-wmv">
									<URL><![CDATA[mms://streaming.hostlocaltion.com/ondemand/streamingpath/high/filename.wmv]]></URL>
					            </MediaFile>
					            <MediaFile delivery="progressive" bitrate="400" width="200" height="200" type="video/x-ms-wmv">
					                <URL><![CDATA[http://progressive.hostlocation.com//high/filename.wmv]]></URL>
								</MediaFile>
					            <MediaFile delivery="streaming" bitrate="75" width="200" height="200" type="video/x-ra">
					                <URL><![CDATA[rtsp://streaming.hostlocaltion.com/ondemand/streamingpath/low/filename.ra]]></URL>
					            </MediaFile>
								<MediaFile delivery="progressive" bitrate="75" width="200" height="200" type="video/x-ra">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/low/filename.ra]]></URL>
								</MediaFile>
							</MediaFiles>
						</Video>
						<CompanionAds>
							<Companion id="rich media banner" width="468" height="60" resourceType="iframe" creativeType="any">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</Companion>
							<Companion id="banner1" width="728" height="90" resourceType="script" creativeType="any">
								<URL><![CDATA[http://ad.server.com/adj/etc.js]]></URL>
							</Companion>
							<Companion id="banner2" width="468" height="60" resourceType="static" creativeType="JPEG">
								<URL><![CDATA[http://media.doubleclick.net/foo.jpg]]></URL>
								<CompanionClickThrough>
									<URL><![CDATA[http://www.primarysite.com/tracker?click]]></URL>
								</CompanionClickThrough>
							</Companion>
							<Companion id="banner3" width="468" height="60" resourceType="static" creativeType="JPEG" expandedWidth="728" expandedHeight="90">
								<Code>insert code here</Code>
								<CompanionClickThrough>
									<URL><![CDATA[http://www.primarysite.com/tracker?click]]></URL>
								</CompanionClickThrough>
								<AltText>some alt text</AltText>
								<AdParameters apiFramework="FlashVars">param=value</AdParameters>
							</Companion>
						</CompanionAds>
						<NonLinearAds>
							<NonLinear id="overlay" width="150" height="60" resourceType="static" creativeType="SWF" apiFramework="IAB">
								<URL><![CDATA[http://ad.server.com/adx/etc.xml]]></URL>
								<NonLinearClickThrough>
									<URL><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</NonLinearClickThrough>
							</NonLinear>
							<NonLinear id="bumper" width="250" height="300" resourceType="static" creativeType="JPEG">
								<URL><![CDATA[http://ad.doubleclick.net/adx/etc.jpg]]></URL>
								<NonLinearClickThrough>
									<URL><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</NonLinearClickThrough>
							</NonLinear>
							<NonLinear id="overlay2" width="350" height="100" resourceType="other" creativeType="JPEG" expandedWidth="728" expandedHeight="90" scalable="true" maintainAspectRatio="true">
								<Code>insert code here</Code>
								<NonLinearClickThrough>
									<URL><![CDATA[http://www.thirdparty.com/tracker?click2]]></URL>
								</NonLinearClickThrough>
								<AdParameters apiFramework="FlashVars">param=value</AdParameters>
							</NonLinear>
						</NonLinearAds>
						<Extensions>
							<Extension type="adServer">
								<TemplateVersion>3.002</TemplateVersion>
								<AdServingData>
									<DeliveryData>
										<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
										<MyAdId>43534850</MyAdId>
									</DeliveryData>
								</AdServingData>
							</Extension>
						</Extensions>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const WRAPPER_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="mywrapperad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
			    </VASTAdTagURL>
			    <Error>
			        <URL><![CDATA[http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false]]></URL>
			    </Error>
			    <Impression>
			        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
			    </Impression>
			    <TrackingEvents>
			        <Tracking event="midpoint">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mid]]></URL>
			        </Tracking>
			        <Tracking event="firstQuartile">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?fqtl]]></URL>
			        </Tracking>
			        <Tracking event="thirdQuartile">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?tqtl]]></URL>
			        </Tracking>
			        <Tracking event="complete">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp]]></URL>
			        </Tracking>
			        <Tracking event="mute">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mute]]></URL>
			        </Tracking>
			        <Tracking event="pause">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?pause]]></URL>
			        </Tracking>
			        <Tracking event="replay">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?replay]]></URL>
			        </Tracking>
			        <Tracking event="fullscreen">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?full]]></URL>
			        </Tracking>
			     </TrackingEvents>
				 <CompanionAds>
					<CompanionImpression>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp2]]></URL>
					</CompanionImpression>
				 </CompanionAds>
				 <NonLinearAds>
					<NonLinearImpression>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl2]]></URL>
					</NonLinearImpression>
				 </NonLinearAds>
		         <VideoClicks>
		            <ClickTracking>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?click1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?click2]]></URL>
		            </ClickTracking>
		            <ClickThrough>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?clickthrough]]></URL>
		            </ClickThrough>
		            <CustomClick>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?customclick1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?customclick2]]></URL>
		            </CustomClick>
		         </VideoClicks>
				 <Extensions>
					<Extension type="adServer">
						<TemplateVersion>3.002</TemplateVersion>
						<AdServingData>
							<DeliveryData>
								<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
								<MyAdId>43534850</MyAdId>
							</DeliveryData>
						</AdServingData>
					</Extension>
				 </Extensions>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;
			
		private static const WRAPPER_VAST_DOCUMENT_WITH_AD_TAGS:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="mywrapperad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
			    </VASTAdTagURL>
			    <Impression>
			        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
			    </Impression>
				<CompanionAds>
					<CompanionAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp]]></URL>
					</CompanionAdTag>
				</CompanionAds>
				<NonLinearAds>
					<NonLinearAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl]]></URL>
					</NonLinearAdTag>
				</NonLinearAds>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;

		private static const WRAPPER_VAST_DOCUMENT_WITH_TOO_MANY_AD_TAG_URLS:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="mywrapperad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
			    </VASTAdTagURL>
			    <Impression>
			        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
			    </Impression>
				<CompanionAds>
					<CompanionAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp2]]></URL>
					</CompanionAdTag>
				</CompanionAds>
				<NonLinearAds>
					<NonLinearAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl2]]></URL>
					</NonLinearAdTag>
				</NonLinearAds>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;
			
		private static const EMPTY_INLINE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem/>
						<AdTitle/>
						<Description/>
						<Survey/>
						<Error>
							<URL/>
						</Error>
						<Impression/>
						<TrackingEvents>
							<Tracking event="start"/>
							<Tracking>
								<URL/>
							</Tracking>
						</TrackingEvents>
						<Video>
							<Duration/>
							<AdID/>
							<VideoClicks>
								<ClickThrough/>
								<ClickTracking/>
								<CustomClick/>
							</VideoClicks>
							<MediaFiles>
								<MediaFile/>
								<MediaFile>
									<URL/>
								</MediaFile>
							</MediaFiles>
						</Video>
						<CompanionAds>
							<Companion/>
							<Companion>
								<URL/>
							</Companion>
							<Companion>
								<Code/>
								<CompanionClickThrough/>
								<AltText/>
								<AdParameters/>
							</Companion>
						</CompanionAds>
						<NonLinearAds>
							<NonLinear/>
							<NonLinear>
								<URL/>
								<NonLinearClickThrough/>
							</NonLinear>
							<NonLinear>
								<Code/>
								<NonLinearClickThrough/>
								<AdParameters/>
							</NonLinear>
						</NonLinearAds>
						<Extensions/>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const DUPLICATE_INLINE_WRAPPER_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine/>
					<Wrapper/>
				</Ad>
			</VideoAdServingTemplate>

		private static const MISSING_INLINE_AD_SYSTEM_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;

		private static const MISSING_INLINE_AD_TITLE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_INLINE_IMPRESSION_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_INLINE_TRACKING_EVENT_TYPE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
					    <TrackingEvents>
					        <Tracking event="wrong">
					            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mid]]></URL>
					        </Tracking>
					    </TrackingEvents>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
		
		private static const MISSING_INLINE_VIDEO_DURATION_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
						<Video/>					    
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;

		private static const MISSING_INLINE_VIDEO_URL_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
						<Video>
							<Duration>00:15:00</Duration>
							<MediaFiles>
								<MediaFile delivery="streaming" bitrate="250" width="200" height="200"/>
							</MediaFiles>
						</Video>					    
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
		
		private static const MISSING_INLINE_VIDEO_BITRATE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
						<Video>
							<Duration>00:15:00</Duration>
							<MediaFiles>
								<MediaFile delivery="streaming" width="200" height="200">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/medium/filename.flv]]></URL>
								</MediaFile>
							</MediaFiles>
						</Video>					    
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_INLINE_VIDEO_DELIVERY_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
						<Video>
							<Duration>00:15:00</Duration>
							<MediaFiles>
								<MediaFile bitrate="250" width="200" height="200">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/medium/filename.flv]]></URL>
								</MediaFile>
							</MediaFiles>
						</Video>					    
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_INLINE_VIDEO_WIDTH_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
						<Video>
							<Duration>00:15:00</Duration>
							<MediaFiles>
								<MediaFile delivery="streaming" bitrate="250" height="200">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/medium/filename.flv]]></URL>
								</MediaFile>
							</MediaFiles>
						</Video>					    
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_INLINE_VIDEO_HEIGHT_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
						<Video>
							<Duration>00:15:00</Duration>
							<MediaFiles>
								<MediaFile delivery="streaming" bitrate="250" width="200">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/medium/filename.flv]]></URL>
								</MediaFile>
							</MediaFiles>
						</Video>					    
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_INLINE_COMPANION_AD_WIDTH_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
   						<CompanionAds>
							<Companion height="60" resourceType="iframe">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</Companion>
						</CompanionAds>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;

		private static const MISSING_INLINE_COMPANION_AD_HEIGHT_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
   						<CompanionAds>
							<Companion width="468" resourceType="iframe">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</Companion>
						</CompanionAds>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;

		private static const MISSING_INLINE_COMPANION_AD_RESOURCE_TYPE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
   						<CompanionAds>
							<Companion width="468" height="60">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</Companion>
						</CompanionAds>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_INLINE_NON_LINEAR_AD_WIDTH_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
   						<NonLinearAds>
							<NonLinear height="60" resourceType="iframe">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</NonLinear>
						</NonLinearAds>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;

		private static const MISSING_INLINE_NON_LINEAR_AD_HEIGHT_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
   						<NonLinearAds>
							<NonLinear width="468" resourceType="iframe">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</NonLinear>
						</NonLinearAds>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;

		private static const MISSING_INLINE_NON_LINEAR_AD_RESOURCE_TYPE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
   						<NonLinearAds>
							<NonLinear width="468" height="60">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</NonLinear>
						</NonLinearAds>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_WRAPPER_AD_SYSTEM_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<Wrapper>
					    <VASTAdTagURL>
					        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
					    </VASTAdTagURL>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
					</Wrapper>
				</Ad>
			</VideoAdServingTemplate>;

		private static const MISSING_WRAPPER_VAST_AD_TAG_URL_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<Wrapper>
						<AdSystem>DART</AdSystem>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
					</Wrapper>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_WRAPPER_IMPRESSION_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<Wrapper>
						<AdSystem>DART</AdSystem>
					    <VASTAdTagURL>
					        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
					    </VASTAdTagURL>
					</Wrapper>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const MISSING_WRAPPER_TRACKING_EVENT_TYPE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad>
					<Wrapper>
						<AdSystem>DART</AdSystem>
					    <VASTAdTagURL>
					        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
					    </VASTAdTagURL>
					    <Impression>
					        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
					    </Impression>
					    <TrackingEvents>
					        <Tracking event="wrong">
					            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mid]]></URL>
					        </Tracking>
					    </TrackingEvents>
					</Wrapper>
				</Ad>
			</VideoAdServingTemplate>;
	}
}