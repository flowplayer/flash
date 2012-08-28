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
 **********************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.asserts.*;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;
	import org.osmf.player.chrome.AssetsProvider;

	public class TestTimeViewWidget extends Sprite
	{
		[BeforeClass]
		public static function setup():void
		{
			assetProvider = new AssetsProvider();
			assetProvider.load();
		}
		[Test]
		public function testVisibilityOnRequiredTraits():void
		{
			var media:MockMediaElement = new MockMediaElement();			
			
			var timeViewWidget:TimeViewWidget = new TimeViewWidget();
			timeViewWidget.configure(<default/>, assetProvider.assetsManager);
			timeViewWidget.media = media;
			assertFalse(timeViewWidget.layoutMetadata.includeInLayout);
			var timeTrait:MockTimeTrait = new MockTimeTrait(1000);	
			media.addTrait2(MediaTraitType.TIME, timeTrait);
			assertTrue(timeViewWidget.layoutMetadata.includeInLayout);		
			media.removeTrait2(MediaTraitType.TIME);
			assertFalse(timeViewWidget.layoutMetadata.includeInLayout);	
		} 
		
		[Test]
		public function testUpdateValuesUsingAutoSize():void
		{
			var media:MockMediaElement = new MockMediaElement();			
			var timeViewWidget:TimeViewWidget = new TimeViewWidget();
			timeViewWidget.configure(<default/>, assetProvider.assetsManager);
			timeViewWidget.media = media;
			assertEquals(" 0:00 / 0:00 ", timeViewWidget.text);
			timeViewWidget.updateValues(100, 1000, false);
			assertEquals(" 01:40 / 16:40 ", timeViewWidget.text);			
			timeViewWidget.updateValues(10000, 100000, false);
			assertEquals("  2:46:40 / 27:46:40 ", timeViewWidget.text);
		}
		
		[Test]
		public function testUpdateValuesForLive():void
		{
			var media:MockMediaElement = new MockMediaElement();			
			var timeViewWidget:TimeViewWidget = new TimeViewWidget();
			timeViewWidget.configure(<default/>, assetProvider.assetsManager);
			timeViewWidget.media = media;
			
			assertEquals(" 0:00 / 0:00 ", timeViewWidget.text);
			timeViewWidget.updateValues(100, 0, true);
			assertEquals("Live   ", timeViewWidget.text);
			timeViewWidget.updateValues(10000, NaN, true);
			assertEquals("Live   ", timeViewWidget.text);
		}
		
	
		
		[Test]
		public function testSeek():void
		{
			var media:MockMediaElement = new MockMediaElement();			
			var timeViewWidget:TimeViewWidget = new TimeViewWidget();
			timeViewWidget.configure(<default/>, assetProvider.assetsManager);
			timeViewWidget.media = media;
			var timeTrait:MockTimeTrait = new MockTimeTrait(1000);			
			var seekTrait:SeekTrait = new SeekTrait(timeTrait);
			media.addTrait2(MediaTraitType.TIME, timeTrait);
			media.addTrait2(MediaTraitType.SEEK, seekTrait);
			assertEquals(" 0:00 / 0:00 ", timeViewWidget.text);
			assertTrue(timeViewWidget.getBounds(this).width < 32);
			seekTrait.seek(100);
			assertEquals(" 01:40 / 16:40 ", timeViewWidget.text);
			timeTrait.setDuration2(100000);
			seekTrait.seek(10000);
			assertEquals("  2:46:40 / 27:46:40 ", timeViewWidget.text);
		}
		
		[Test]
		public function testRemoveSeekTrait():void
		{
			var media:MockMediaElement = new MockMediaElement();			
			var timeViewWidget:TimeViewWidget = new TimeViewWidget();
			timeViewWidget.configure(<default/>, assetProvider.assetsManager);
			timeViewWidget.media = media;
			var timeTrait:MockTimeTrait = new MockTimeTrait(1000);			
			var seekTrait:SeekTrait = new SeekTrait(timeTrait);
			media.addTrait2(MediaTraitType.TIME, timeTrait);
			media.addTrait2(MediaTraitType.SEEK, seekTrait);
			assertEquals(" 0:00 / 0:00 ", timeViewWidget.text);
			assertTrue(timeViewWidget.getBounds(this).width < 32);
			media.removeTrait2(MediaTraitType.SEEK);
			seekTrait.seek(100);
			assertEquals(" 0:00 / 0:00 ", timeViewWidget.text);
		}
		
		[Test] [Ignore]
		public function testLiveMetadata():void
		{
			var media:MockMediaElement = new MockMediaElement();			
			var timeViewWidget:TimeViewWidget = new TimeViewWidget();
			timeViewWidget.configure(<default/>, assetProvider.assetsManager);
		
			var timeTrait:MockTimeTrait = new MockTimeTrait();			
			media.addTrait2(MediaTraitType.TIME, timeTrait);
			timeViewWidget.media = media;
			
			timeTrait.setDuration2(100000);
			timeTrait.setCurrentTime2(10000);
			timeViewWidget.updateNow();
			assertTrue(timeViewWidget.getBounds(this).width > 50 && timeViewWidget.getBounds(this).width < 55);
				
			timeTrait.setDuration2(100000);
			timeTrait.setCurrentTime2(10000);
			media.addTrait2(MediaTraitType.TIME, timeTrait);	
		}
		
		private static var assetProvider:AssetsProvider;
	}
}

import org.osmf.events.BufferEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.MediaTraitBase;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TimeTrait;

class MockTimeTrait extends TimeTrait
{
	public function MockTimeTrait(duration:Number=NaN)
	{
		super(duration);
	}
	public function setCurrentTime2(value:Number):void
	{
		super.setCurrentTime(value);
	}
	
	public function setDuration2(value:Number):void
	{
		super.setDuration(value);
	}
	
}
class MockMediaElement extends MediaElement
{	
	public function startBuffering():void
	{
		(getTrait(MediaTraitType.BUFFER) as BufferTrait).dispatchEvent(new BufferEvent(BufferEvent.BUFFERING_CHANGE, false, false, true));		
	}
	
	public function makeTheBufferFull():void
	{
		(getTrait(MediaTraitType.BUFFER) as BufferTrait).dispatchEvent(new BufferEvent(BufferEvent.BUFFERING_CHANGE, false, false, false));		
	}
	
	public function addTrait2(type:String, instance:MediaTraitBase):void
	{
		super.addTrait(type, instance);
	}
	
	public function removeTrait2(type:String):void
	{
		super.removeTrait(type);
	}
}