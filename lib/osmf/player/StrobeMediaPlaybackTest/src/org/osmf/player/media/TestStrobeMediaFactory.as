/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.player.media
{
	import mx.utils.object_proxy;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.*;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.player.configuration.PlayerConfiguration;

	public class TestStrobeMediaFactory
	{
		[Before]
		public function setUp():void
		{
			var cp:ChromeProvider = ChromeProvider.getInstance();
			if (cp.loaded == false)
			{
				cp.load(null);
			}
		}
		
		[Test]
		public function testPlaylist():void
		{
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var strobeMediaFactory:StrobeMediaFactory = new StrobeMediaFactory(configuration);
			var canHandleM3U:Boolean = false;
			var resource:MediaResourceBase = new StreamingURLResource("http://mysite.com/myplaylist.m3u");
			for (var b:int = 0; b < strobeMediaFactory.numItems; b++)
			{
				var mediaFactoryItem:MediaFactoryItem = strobeMediaFactory.getItemAt(b);
				if (mediaFactoryItem.canHandleResourceFunction(resource))
				{
					canHandleM3U = true;
				}
			}
			assertTrue(canHandleM3U);
		}
		
		[Test(async, timeout="2000")]
		public function testEnableOptimization():void
		{
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var strobeMediaFactory:MockStrobeMediaFactory = new MockStrobeMediaFactory(configuration);
			var canHandleM3U:Boolean = false;
			var resource:MediaResourceBase = new StreamingURLResource("http://mysite.com/myplaylist.flv");
			var mediaElement:MediaElement = strobeMediaFactory.createMediaElement(resource);
			
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			mediaPlayer.media = mediaElement;
			mediaPlayer.play();
			
			Async.handleEvent(this, mediaPlayer,
				MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, 
				onStateChange, 1000, this);
			function onStateChange(event:MediaPlayerStateChangeEvent, test:*):void
			{
				if (mediaPlayer.state == MediaPlayerState.PLAYING)
				{
					assertEquals(0.1, mediaPlayer.bufferTime);
				}
			}
			assertEquals(1, strobeMediaFactory.rtmpDynamicStreamingNetLoaderAdapterCount);
			assertEquals(1, strobeMediaFactory.playbackOptimizationManagerCount);
		}
		
		[Test(async, timeout="2000")]
		public function testDisableOptimization():void
		{
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			configuration.optimizeInitialIndex = false;
			configuration.optimizeBuffering = false;
			var strobeMediaFactory:MockStrobeMediaFactory = new MockStrobeMediaFactory(configuration);
			var resource:MediaResourceBase = new StreamingURLResource("http://mysite.com/myplaylist.flv");
			var mediaElement:MediaElement = strobeMediaFactory.createMediaElement(resource);
			
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			mediaPlayer.media = mediaElement;
			mediaPlayer.play();
			
			assertEquals(0, strobeMediaFactory.rtmpDynamicStreamingNetLoaderAdapterCount);
			assertEquals(0, strobeMediaFactory.playbackOptimizationManagerCount);
		}
		
		CONFIG::FLASH_10_1
		{
			
		//TO FIX: 
		[Ignore]
		[Test(async, timeout="5000")]
		public function testHTTPNetStream():void
		{
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var strobeMediaFactory:MockStrobeMediaFactory = new MockStrobeMediaFactory(configuration);
			var canHandleM3U:Boolean = false;
			var resource:MediaResourceBase = new URLResource("http://example.com/movie/");
			resource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA, new Metadata());
			var mediaElement:MediaElement = strobeMediaFactory.createMediaElement(resource);
			
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			mediaPlayer.autoPlay = false;
			mediaPlayer.media = mediaElement;
	
			
			Async.handleEvent(this, mediaPlayer,
				MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, 
				onStateChange, 4000, this);
			function onStateChange(event:MediaPlayerStateChangeEvent, test:*):void
			{
				if (mediaPlayer.state == MediaPlayerState.PLAYING)
				{
					assertEquals(0.1, mediaPlayer.bufferTime);
				}
			}
			mediaPlayer.play();
		}		
		}
	}
}