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
package org.osmf.media
{
	import flexunit.framework.Assert;
	
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.net.MulticastResource;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;

	public class TestDefaultMediaFactory
	{
		[Test]
		public function testCreateMediaElementF4M():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			Assert.assertTrue(factory.createMediaElement(new URLResource("http://www.example.com/f4m.f4m")) is F4MElement);
		}
		
		[Test]
		public function testCreateMediaElementImage():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();	
			Assert.assertTrue(factory.createMediaElement(new URLResource("http://www.example.com/image.jpg")) is ImageElement);
		}
		
		[Test]
		public function testCreateMediaElementSWF():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			Assert.assertTrue(factory.createMediaElement(new URLResource("http://www.example.com/swf.swf")) is SWFElement);
		}
		
		[Test]
		public function testCreateMediaElementVideo():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			Assert.assertTrue(factory.createMediaElement(new URLResource("rtmp://www.example.com/video")) is VideoElement);
		}
		
		[Test]
		public function testCreateMediaElementVideoFlv():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			Assert.assertTrue(factory.createMediaElement(new URLResource("http://www.example.com/video.flv")) is VideoElement);
		}
		
		[Test]
		public function testCreateMediaElementAudio():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			Assert.assertTrue(factory.createMediaElement(new URLResource("http://www.example.com/audio.mp3")) is AudioElement);
		}
		
		[Test]
		public function testCreateMediaElementDVR():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			Assert.assertTrue(factory.createMediaElement(new StreamingURLResource("rtmp://www.example.com/video", StreamType.DVR)) is VideoElement);
		}
		
		[Test]
		public function testCreateMediaElementMediaResourceBase():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			Assert.assertTrue(factory.createMediaElement(new MediaResourceBase()) == null);
		}
		
		[Test]
		public function testCreateMediaElementRtmp():void
		{
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			var resource:URLResource = new URLResource("rtmp://www.example.com/audio");
			resource.mediaType = MediaType.AUDIO;
			Assert.assertTrue(factory.createMediaElement(resource) is AudioElement);
			
			Assert.assertTrue(factory.getItemById("org.osmf.elements.video").mediaElementCreationFunction.call(new URLResource("http://www.example.com/video.flv")) is VideoElement);
			Assert.assertTrue(factory.getItemById("org.osmf.elements.audio.streaming").mediaElementCreationFunction.call(new URLResource("rtmp://www.example.com/audio")) is AudioElement);
		}
		
		CONFIG::FLASH_10_1
		{
			[Test]
			public function testFM964():void
			{
				var factory:DefaultMediaFactory = new DefaultMediaFactory();
				var resource:MulticastResource = new MulticastResource("rtmfp://weiz-xp1/multicast", StreamType.LIVE);
				resource.groupspec = "G:010121055e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8010c170e6f72672e6f736d662e6e65742e6d756c746963617374210e61b67506b6a5f02187ca24fe590388778040fa3a9c23589c58baadd097c12657011b00070ae00000fe814b";
				resource.streamName = "fusionstream1";
				
				Assert.assertTrue(factory.getItemById("org.osmf.elements.video.rtmfp.multicast") != null);		
				Assert.assertTrue(factory.createMediaElement(resource) is VideoElement);		
			}
		}
	}
}