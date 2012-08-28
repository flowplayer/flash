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
package org.osmf.vast.media
{
	import __AS3__.vec.Vector;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;
	import org.osmf.utils.TestConstants;
	import org.osmf.vast.model.VASTAd;
	import org.osmf.vast.model.VASTDocument;
	import org.osmf.vast.model.VASTInlineAd;
	import org.osmf.vast.model.VASTMediaFile;
	import org.osmf.vast.model.VASTTrackingEvent;
	import org.osmf.vast.model.VASTTrackingEventType;
	import org.osmf.vast.model.VASTUrl;
	import org.osmf.vast.model.VASTVideo;
	import org.osmf.vast.model.VASTWrapperAd;
	
	public class TestVASTMediaGenerator extends TestCase
	{
		public function testCreateMediaElementsWithNoResults():void
		{
			var generator:VASTMediaGenerator = new VASTMediaGenerator();
			
			var document:VASTDocument = new VASTDocument();
			
			// Empty document should produce no MediaElements.
			var mediaElements:Vector.<MediaElement> = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 0);
			
			var vastAd:VASTAd = new VASTAd("myad");
			document.addAd(vastAd);
			
			// Same for an empty VASTAd.
			mediaElements = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 0);

			vastAd.wrapperAd = new VASTWrapperAd();

			// Same for a VASTAd with a wrapper.
			mediaElements = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 0);
			
			vastAd.wrapperAd = null;
			var inlineAd:VASTInlineAd = new VASTInlineAd();
			vastAd.inlineAd = inlineAd;

			// Same for a VASTAd with an empty inline ad.
			mediaElements = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 0);
			
			var vastVideo:VASTVideo = new VASTVideo();
			inlineAd.video = vastVideo;

			// Same for a VASTAd with a video but no media files.
			mediaElements = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 0);
			
			inlineAd.addImpression(new VASTUrl("http://example.com"));
			var trackingEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.START);
			trackingEvent.urls.push(new VASTUrl("http://example.com"));
			inlineAd.addTrackingEvent(trackingEvent);

			// Same for a VASTAd with impressions and tracking events, but no
			// media files.
			mediaElements = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 0);
		}
		
		public function testCreateMediaElements():void
		{
			var generator:VASTMediaGenerator = new VASTMediaGenerator();
			
			var document:VASTDocument = new VASTDocument();
			var vastAd:VASTAd = new VASTAd("myad1");
			document.addAd(vastAd);
			vastAd.inlineAd = new VASTInlineAd();
			vastAd.inlineAd.video = new VASTVideo();
			var mediaFile:VASTMediaFile = new VASTMediaFile();
			vastAd.inlineAd.video.mediaFiles.push(mediaFile);
			mediaFile.url = TestConstants.REMOTE_STREAMING_VIDEO;
			mediaFile.delivery = VASTMediaFile.DELIVERY_STREAMING;
			mediaFile.type = "video/x-flv";

			vastAd = new VASTAd("myad2");
			document.addAd(vastAd);
			vastAd.inlineAd = new VASTInlineAd();
			vastAd.inlineAd.video = new VASTVideo();
			mediaFile = new VASTMediaFile();
			vastAd.inlineAd.video.mediaFiles.push(mediaFile);
			mediaFile.url = TestConstants.REMOTE_PROGRESSIVE_VIDEO;
			mediaFile.delivery = VASTMediaFile.DELIVERY_PROGRESSIVE;
			mediaFile.type = "video/x-flv";

			// Should get two VideoElements back.			
			var mediaElements:Vector.<MediaElement> = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 2);
			
			var mediaElement:MediaElement = mediaElements[0];
			assertTrue(mediaElement is VideoElement);
			var resource:URLResource = mediaElement.resource as URLResource;
			assertTrue(resource != null);
			assertTrue(resource.url != null);
			
			// The .flv extension should have been stripped.
			assertTrue(resource.url == TestConstants.REMOTE_STREAMING_VIDEO.substring(0,	TestConstants.REMOTE_STREAMING_VIDEO.length-4));

			mediaElement = mediaElements[1];
			assertTrue(mediaElement is VideoElement);
			resource = mediaElement.resource as URLResource;
			assertTrue(resource != null);
			assertTrue(resource.url != null);
			assertTrue(resource.url == TestConstants.REMOTE_PROGRESSIVE_VIDEO);
		}
		
		public function testCreateMediaElementsWithMediaFileResolver():void
		{
			var generator:VASTMediaGenerator = new VASTMediaGenerator();
			
			var document:VASTDocument = new VASTDocument();
			var vastAd:VASTAd = new VASTAd("myad1");
			document.addAd(vastAd);
			vastAd.inlineAd = new VASTInlineAd();
			vastAd.inlineAd.video = new VASTVideo();
			
			var mediaFile:VASTMediaFile = new VASTMediaFile();
			vastAd.inlineAd.video.mediaFiles.push(mediaFile);
			mediaFile.url = TestConstants.REMOTE_STREAMING_VIDEO;
			mediaFile.delivery = VASTMediaFile.DELIVERY_STREAMING;
			mediaFile.type = "video/x-ms-wmv";

			mediaFile = new VASTMediaFile();
			vastAd.inlineAd.video.mediaFiles.push(mediaFile);
			mediaFile.url = TestConstants.REMOTE_PROGRESSIVE_VIDEO;
			mediaFile.delivery = VASTMediaFile.DELIVERY_PROGRESSIVE;
			mediaFile.type = "video/x-flv";

			// Should get the VideoElement with the supported MIME type back.			
			var mediaElements:Vector.<MediaElement> = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 1);
			
			var mediaElement:MediaElement = mediaElements[0];
			assertTrue(mediaElement is VideoElement);
			var resource:URLResource = mediaElement.resource as URLResource;
			assertTrue(resource != null);
			assertTrue(resource.url != null);
			assertTrue(resource.url == TestConstants.REMOTE_PROGRESSIVE_VIDEO);
		}
		
		public function testCreateMediaElementsWithMediaFactory():void
		{
			var createdCount:int = 0;
			
			var factory:MediaFactory = new DefaultMediaFactory();
			factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onElementCreate);
			var generator:VASTMediaGenerator = new VASTMediaGenerator(null, factory);
			
			var document:VASTDocument = new VASTDocument();
			var vastAd:VASTAd = new VASTAd("myad1");
			document.addAd(vastAd);
			vastAd.inlineAd = new VASTInlineAd();
			vastAd.inlineAd.video = new VASTVideo();
			
			var mediaFile:VASTMediaFile = new VASTMediaFile();
			vastAd.inlineAd.video.mediaFiles.push(mediaFile);
			mediaFile.url = TestConstants.REMOTE_PROGRESSIVE_VIDEO;
			mediaFile.delivery = VASTMediaFile.DELIVERY_PROGRESSIVE;
			mediaFile.type = "video/x-flv";

			// Should get the VideoElement with the supported MIME type back.			
			var mediaElements:Vector.<MediaElement> = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 1);
			
			assertTrue(createdCount == 1);
			
			function onElementCreate(event:MediaFactoryEvent):void
			{
				createdCount++;
			}
		}
		
		public function testCreateMediaElementsWithImpressionProxy():void
		{
			var generator:VASTMediaGenerator = new VASTMediaGenerator();
			
			var document:VASTDocument = new VASTDocument();
			var vastAd:VASTAd = new VASTAd("myad1");
			document.addAd(vastAd);
			vastAd.inlineAd = new VASTInlineAd();
			vastAd.inlineAd.video = new VASTVideo();
			var mediaFile:VASTMediaFile = new VASTMediaFile();
			vastAd.inlineAd.video.mediaFiles.push(mediaFile);
			mediaFile.url = TestConstants.REMOTE_PROGRESSIVE_VIDEO;
			mediaFile.delivery = VASTMediaFile.DELIVERY_PROGRESSIVE;
			mediaFile.type = "video/x-flv";
			
			// Adding impressions should result in our VideoElement being
			// wrapped in a proxy.
			vastAd.inlineAd.addImpression(new VASTUrl("http://example.com/impression1"));
			vastAd.inlineAd.addImpression(new VASTUrl("http://example.com/impression2"));
			
			var mediaElements:Vector.<MediaElement> = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 1);
			
			var mediaElement:MediaElement = mediaElements[0];
			var impressionProxy:VASTImpressionProxyElement = mediaElement as VASTImpressionProxyElement;
			assertTrue(impressionProxy != null);
			var resource:URLResource = impressionProxy.resource as URLResource;
			assertTrue(resource != null);
			assertTrue(resource.url != null);
			assertTrue(resource.url == TestConstants.REMOTE_PROGRESSIVE_VIDEO);
			assertTrue(impressionProxy.proxiedElement is VideoElement);
		}
		
		public function testCreateMediaElementsWithTrackingProxy():void
		{
			var generator:VASTMediaGenerator = new VASTMediaGenerator();
			
			var document:VASTDocument = new VASTDocument();
			var vastAd:VASTAd = new VASTAd("myad1");
			document.addAd(vastAd);
			vastAd.inlineAd = new VASTInlineAd();
			vastAd.inlineAd.video = new VASTVideo();
			var mediaFile:VASTMediaFile = new VASTMediaFile();
			vastAd.inlineAd.video.mediaFiles.push(mediaFile);
			mediaFile.url = TestConstants.REMOTE_PROGRESSIVE_VIDEO;
			mediaFile.delivery = VASTMediaFile.DELIVERY_PROGRESSIVE;
			mediaFile.type = "video/x-flv";
			
			// Adding tracking events should result in our VideoElement being
			// wrapped in a proxy.
			var trackingEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.START);
			trackingEvent.urls.push(new VASTUrl("http://example.com/start"));
			vastAd.inlineAd.addTrackingEvent(trackingEvent);
			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.PAUSE);
			trackingEvent.urls.push(new VASTUrl("http://example.com"));
			vastAd.inlineAd.addTrackingEvent(trackingEvent);
			
			var mediaElements:Vector.<MediaElement> = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 1);
			
			var mediaElement:MediaElement = mediaElements[0];
			var trackingProxy:VASTTrackingProxyElement = mediaElement as VASTTrackingProxyElement;
			assertTrue(trackingProxy != null);
			var resource:URLResource = trackingProxy.resource as URLResource;
			assertTrue(resource != null);
			assertTrue(resource.url != null);
			assertTrue(resource.url == TestConstants.REMOTE_PROGRESSIVE_VIDEO);
			assertTrue(trackingProxy.proxiedElement is VideoElement);
		}
		
		public function testCreateMediaElementsWithProxyChain():void
		{
			var generator:VASTMediaGenerator = new VASTMediaGenerator();
			
			var document:VASTDocument = new VASTDocument();
			var vastAd:VASTAd = new VASTAd("myad1");
			document.addAd(vastAd);
			vastAd.inlineAd = new VASTInlineAd();
			vastAd.inlineAd.video = new VASTVideo();
			var mediaFile:VASTMediaFile = new VASTMediaFile();
			vastAd.inlineAd.video.mediaFiles.push(mediaFile);
			mediaFile.url = TestConstants.REMOTE_PROGRESSIVE_VIDEO;
			mediaFile.delivery = VASTMediaFile.DELIVERY_PROGRESSIVE;
			mediaFile.type = "video/x-flv";
			
			// Adding impressions and tracking events should result in our
			// VideoElement being wrapped in two proxies.
			vastAd.inlineAd.addImpression(new VASTUrl("http://example.com/impression1"));
			vastAd.inlineAd.addImpression(new VASTUrl("http://example.com/impression2"));
			var trackingEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.START);
			trackingEvent.urls.push(new VASTUrl("http://example.com/start"));
			vastAd.inlineAd.addTrackingEvent(trackingEvent);
			trackingEvent = new VASTTrackingEvent(VASTTrackingEventType.PAUSE);
			trackingEvent.urls.push(new VASTUrl("http://example.com"));
			vastAd.inlineAd.addTrackingEvent(trackingEvent);
			
			var mediaElements:Vector.<MediaElement> = generator.createMediaElements(document);
			assertTrue(mediaElements.length == 1);
			
			var mediaElement:MediaElement = mediaElements[0];
			var trackingProxy:VASTTrackingProxyElement = mediaElement as VASTTrackingProxyElement;
			assertTrue(trackingProxy != null);
			var resource:URLResource = trackingProxy.resource as URLResource;
			assertTrue(resource != null);
			assertTrue(resource.url != null);
			assertTrue(resource.url == TestConstants.REMOTE_PROGRESSIVE_VIDEO);

			var impressionProxy:VASTImpressionProxyElement = trackingProxy.proxiedElement as VASTImpressionProxyElement;
			assertTrue(impressionProxy != null);
			resource = impressionProxy.resource as URLResource;
			assertTrue(resource != null);
			assertTrue(resource.url != null);
			assertTrue(resource.url == TestConstants.REMOTE_PROGRESSIVE_VIDEO);
			assertTrue(impressionProxy.proxiedElement is VideoElement);
		}
	}
}