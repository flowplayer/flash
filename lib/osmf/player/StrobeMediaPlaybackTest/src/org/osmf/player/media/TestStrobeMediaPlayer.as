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
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.DynamicStreamTrait;

	public class TestStrobeMediaPlayer extends Sprite
	{
//		[Test]
//		public function testDTB():void
//		{
//			var strobeMediaPlayer:StrobeMediaPlayer = new StrobeMediaPlayer();
//			var mediaElement:MockMediaElement = new MockMediaElement();
//			
//			var bufferTrait:BufferTrait = new BufferTrait();
//			mediaElement.addSomeTrait(bufferTrait);
//			
//			strobeMediaPlayer.media = mediaElement;
//			
//			assertEquals(1, strobeMediaPlayer.bufferTime);
//			
//			mediaElement.makeTheBufferFull();
//			
//			assertEquals(10, strobeMediaPlayer.bufferTime);
//		}
//		
//		[Test]
//		public function testDisableDTB():void
//		{
//			var strobeMediaPlayer:StrobeMediaPlayer = new StrobeMediaPlayer();
//			strobeMediaPlayer.bufferManagerConfiguration.expandedBufferTime = 0;
//			
//			var mediaElement:MockMediaElement = new MockMediaElement();
//				
//			var bufferTrait:BufferTrait = new BufferTrait();
//			mediaElement.addSomeTrait(bufferTrait);
//			
//			strobeMediaPlayer.media = mediaElement;
//			
//			assertEquals(1, bufferTrait.bufferTime);
//		}
//		
//		[Test]
//		public function testKeepOSMFDefaults():void
//		{
//			var strobeMediaPlayer:StrobeMediaPlayer = new StrobeMediaPlayer();
//			var mediaElement:MockMediaElement = new MockMediaElement();
//			strobeMediaPlayer.bufferManagerConfiguration.initialBufferTime = 0;
//			strobeMediaPlayer.bufferManagerConfiguration.expandedBufferTime = 0;
//			var bufferTrait:BufferTrait = new BufferTrait();
//			mediaElement.addSomeTrait(bufferTrait);
//			
//			strobeMediaPlayer.media = mediaElement;
//			
//			assertEquals(0, strobeMediaPlayer.bufferTime);
//			
//			mediaElement.makeTheBufferFull();
//			
//			assertEquals(0, strobeMediaPlayer.bufferTime);
//		}
		
		[Test]
		public function testFullScreenSourceRectHD():void
		{
			var strobeMediaPlayer:StrobeMediaPlayer = new StrobeMediaPlayer();
			var mediaElement:MockMediaElement = new MockMediaElement();
			strobeMediaPlayer.media = mediaElement;
			
			var displayObjectTrait:DisplayObjectTrait = new DisplayObjectTrait(this, 1920, 1080);
			mediaElement.addSomeTrait(displayObjectTrait);
			var rect:Rectangle = strobeMediaPlayer.getFullScreenSourceRect(1920, 1080);
			assertEquals(1920, rect.width);
			assertEquals(1080, rect.height);
		}		
		
		[Test]
		public function testFullScreenSourceRectSD():void
		{
			var strobeMediaPlayer:StrobeMediaPlayer = new StrobeMediaPlayer();
			var mediaElement:MockMediaElement = new MockMediaElement();
			strobeMediaPlayer.media = mediaElement;
			
			var displayObjectTrait:DisplayObjectTrait = new DisplayObjectTrait(this, 320, 280);
			mediaElement.addSomeTrait(displayObjectTrait);
			var rect:Rectangle = strobeMediaPlayer.getFullScreenSourceRect(1920, 1080);
			assertNull(rect);
		}
		
		[Test]
		public function testFullScreenSourceRectDynamicStreaming():void
		{
			var strobeMediaPlayer:StrobeMediaPlayer = new StrobeMediaPlayer();
			var mediaElement:MockMediaElement = new MockMediaElement();
			strobeMediaPlayer.media = mediaElement;
			
			var displayObjectTrait:DisplayObjectTrait = new DisplayObjectTrait(this, 320, 280);
			mediaElement.addSomeTrait(displayObjectTrait);
		
			var dsr:DynamicStreamingResource = new DynamicStreamingResource("http://somehost.com");
			var dsi:DynamicStreamingItem = new DynamicStreamingItem("streamname", 1024, 1920, 1080);
			dsr.streamItems[0] = dsi;
			var dst:DynamicStreamTrait = new DynamicStreamTrait(true, 0, 1);
			
			mediaElement.resource = dsr;
			mediaElement.addSomeTrait(dst);
			var rect:Rectangle = strobeMediaPlayer.getFullScreenSourceRect(1920, 1080);
			assertEquals(1920, rect.width);
			assertEquals(1080, rect.height);
		}
		
		[Test]
		public function testChangeMediaSizeOnDynamicStreaming():void
		{
			var strobeMediaPlayer:StrobeMediaPlayer = new StrobeMediaPlayer();
			var mediaElement:MockMediaElement = new MockMediaElement();
			
			var displayObjectTrait:DisplayObjectTrait = new DisplayObjectTrait(this, 320, 280);
			
			
			var dsr:DynamicStreamingResource = new DynamicStreamingResource("http://somehost.com");
			var dsi0:DynamicStreamingItem = new DynamicStreamingItem("streamname0", 640, 320, 280);
			var dsi1:DynamicStreamingItem = new DynamicStreamingItem("streamname1", 1024, 1920, 1080);
			dsr.streamItems[0] = dsi0;
			dsr.streamItems[1] = dsi1;
			var dst:DynamicStreamTrait = new DynamicStreamTrait(true, 0, dsr.streamItems.length);			
			mediaElement.resource = dsr;
			mediaElement.addSomeTrait(dst);
			mediaElement.addSomeTrait(displayObjectTrait);
			strobeMediaPlayer.media = mediaElement;
			
			var rect:Rectangle = strobeMediaPlayer.getFullScreenSourceRect(1920, 1080);
			assertEquals(1920, rect.width);
			assertEquals(1080, rect.height);
		}
		
		
		[Test]
		public function testChangeFromDynamicStreamingToNormal():void
		{
			var strobeMediaPlayer:StrobeMediaPlayer = new StrobeMediaPlayer();
			var mediaElement:MockMediaElement = new MockMediaElement();
			
			var displayObjectTrait:DisplayObjectTrait = new DisplayObjectTrait(this, 320, 280);
			
			
			var dsr:DynamicStreamingResource = new DynamicStreamingResource("http://somehost.com");
			var dsi0:DynamicStreamingItem = new DynamicStreamingItem("streamname0", 640, 320, 280);
			var dsi1:DynamicStreamingItem = new DynamicStreamingItem("streamname1", 1024, 1920, 1080);
			dsr.streamItems[0] = dsi0;
			dsr.streamItems[1] = dsi1;
			var dst:DynamicStreamTrait = new DynamicStreamTrait(true, 0, 1);			
			mediaElement.resource = dsr;
			mediaElement.addSomeTrait(dst);
			
			strobeMediaPlayer.media = mediaElement;			
			var rect:Rectangle = strobeMediaPlayer.getFullScreenSourceRect(1920, 1080);
			assertEquals(1920, rect.width);
			assertEquals(1080, rect.height);
			
			mediaElement.removeSomeTrait(dst.traitType);
			
			mediaElement.addSomeTrait(displayObjectTrait);
			assertNull(strobeMediaPlayer.getFullScreenSourceRect(1920, 1080));
		}
	}
}

import org.osmf.events.BufferEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.MediaTraitBase;
import org.osmf.traits.MediaTraitType;

class MockMediaElement extends MediaElement
{
	public function addSomeTrait(trait:MediaTraitBase):void
	{
		addTrait(trait.traitType, trait);
	}
	
	public function removeSomeTrait(traitType:String):void
	{
		removeTrait(traitType);
	}
	
	public function makeTheBufferFull(value:Number = NaN):void
	{
		var bufferTrait:BufferTrait = (getTrait(MediaTraitType.BUFFER) as BufferTrait);
		if (!isNaN(value))
		{
			bufferTrait.bufferTime = value;
		}
		bufferTrait.dispatchEvent(new BufferEvent(BufferEvent.BUFFERING_CHANGE, false, false, false));		
	}
	
}