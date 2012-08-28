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
	import __AS3__.vec.Vector;
	
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	
	import org.osmf.elements.ParallelElement;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.DynamicBufferTrait;
	import org.osmf.utils.DynamicDynamicStreamTrait;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.DynamicPlayTrait;
	import org.osmf.utils.DynamicSeekTrait;
	import org.osmf.utils.DynamicTimeTrait;
	import org.osmf.utils.NetFactory;
	
	public class TestMediaPlayer
	{
		// Overrides
		//
		
		[Before]
		public function setUp():void
		{
			mediaPlayer = new MediaPlayer();
			mediaPlayer.autoPlay = false;
			mediaPlayer.autoRewind = false;
			eventDispatcher = new EventDispatcher();
			events = new Vector.<Event>();
		}
		
		[After]
		public function tearDown():void
		{
			mediaPlayer = null;
			eventDispatcher = null;
		}
		
		[Test]
		public function testDisplayObjectEventGeneration():void
		{
			
			var media:DynamicMediaElement = new DynamicMediaElement();
			mediaPlayer.media = media;
			mediaPlayer.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, eventCatcher);
			mediaPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, eventCatcher);
						
			Assert.assertTrue(isNaN(mediaPlayer.mediaHeight));
			Assert.assertTrue(isNaN(mediaPlayer.mediaWidth));
			Assert.assertEquals(null, mediaPlayer.displayObject);
			var display:Sprite = new Sprite();
			var doTrait:DisplayObjectTrait = new DisplayObjectTrait(display, 150, 200);
						
			media.doAddTrait(MediaTraitType.DISPLAY_OBJECT, doTrait);
								
			Assert.assertEquals(2, events.length);		
			Assert.assertTrue(events[0] is DisplayObjectEvent);		
			Assert.assertTrue(events[1] is DisplayObjectEvent);
			Assert.assertEquals(events[0].type, DisplayObjectEvent.DISPLAY_OBJECT_CHANGE);		
			Assert.assertEquals(events[1].type, DisplayObjectEvent.MEDIA_SIZE_CHANGE);
			
			Assert.assertEquals(DisplayObjectEvent(events[0]).newDisplayObject, doTrait.displayObject );
			Assert.assertEquals(DisplayObjectEvent(events[1]).newHeight, doTrait.mediaHeight );
			Assert.assertEquals(DisplayObjectEvent(events[1]).newWidth, doTrait.mediaWidth );
			
			media.doRemoveTrait(MediaTraitType.DISPLAY_OBJECT);
			
			Assert.assertEquals(4, events.length);	
			Assert.assertTrue(events[2] is DisplayObjectEvent);		
			Assert.assertTrue(events[3] is DisplayObjectEvent);
			Assert.assertEquals(events[2].type, DisplayObjectEvent.DISPLAY_OBJECT_CHANGE);		
			Assert.assertEquals(events[3].type, DisplayObjectEvent.MEDIA_SIZE_CHANGE);
		}
		
		[Test]
		public function testBufferEventGeneration():void
		{			
			var media:DynamicMediaElement = new DynamicMediaElement();
			mediaPlayer.media = media;
			mediaPlayer.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, eventCatcher);
			mediaPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, eventCatcher);
					
			Assert.assertFalse(mediaPlayer.buffering);
			Assert.assertEquals(0, mediaPlayer.bufferTime);
			Assert.assertEquals(0, mediaPlayer.bufferLength);
			
			var bufferTrait:DynamicBufferTrait = new DynamicBufferTrait();
			bufferTrait.bufferTime = 25;
			bufferTrait.bufferLength = 15;
			bufferTrait.buffering = true;
			
			media.doAddTrait(MediaTraitType.BUFFER, bufferTrait);
			
			Assert.assertEquals(2, events.length);	
			Assert.assertTrue(events[0] is BufferEvent);	
			Assert.assertTrue(events[1] is BufferEvent);		
						
			Assert.assertEquals(BufferEvent(events[0]).bufferTime, bufferTrait.bufferTime, mediaPlayer.bufferTime);
			Assert.assertEquals(BufferEvent(events[0]).type, BufferEvent.BUFFER_TIME_CHANGE);
			Assert.assertEquals(bufferTrait.bufferLength, mediaPlayer.bufferLength);
			Assert.assertEquals(BufferEvent(events[1]).type, BufferEvent.BUFFERING_CHANGE);
			Assert.assertEquals(BufferEvent(events[1]).buffering, bufferTrait.buffering, mediaPlayer.buffering);
			
			media.doRemoveTrait(MediaTraitType.BUFFER);
			
			// Should get a buffer time change, back to the default of 0.
			
			Assert.assertEquals(4, events.length);	
			Assert.assertTrue(events[2] is BufferEvent);	
			Assert.assertEquals(events[2].type, BufferEvent.BUFFER_TIME_CHANGE);			
			Assert.assertTrue(events[3] is BufferEvent);	
			Assert.assertEquals(events[3].type, BufferEvent.BUFFERING_CHANGE);			
		}
		
		[Test]
		public function testDynamicStreamEventGeneration():void
		{			
			var media:DynamicMediaElement = new DynamicMediaElement();
			mediaPlayer.media = media;
			mediaPlayer.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, eventCatcher);
			mediaPlayer.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, eventCatcher);
			mediaPlayer.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, eventCatcher);
						
			mediaPlayer.maxAllowedDynamicStreamIndex = 8;
			
			Assert.assertFalse(mediaPlayer.dynamicStreamSwitching);
			Assert.assertEquals(0, mediaPlayer.numDynamicStreams);
			Assert.assertEquals(8, mediaPlayer.maxAllowedDynamicStreamIndex);
			
			var dynamicTrait:DynamicDynamicStreamTrait = new DynamicDynamicStreamTrait(true, 5, 20);
			dynamicTrait.currentIndex = 5;
			dynamicTrait.maxAllowedIndex = 10;
			dynamicTrait.autoSwitch = true;
						
			media.doAddTrait(MediaTraitType.DYNAMIC_STREAM, dynamicTrait);
			
			Assert.assertFalse(dynamicTrait.switching);					
			Assert.assertEquals(8, mediaPlayer.maxAllowedDynamicStreamIndex, dynamicTrait.maxAllowedIndex);
			
			Assert.assertEquals(1, events.length);	
			Assert.assertTrue(events[0] is DynamicStreamEvent);	
			Assert.assertTrue(dynamicTrait.autoSwitch);
			Assert.assertTrue(mediaPlayer.autoDynamicStreamSwitch);
			Assert.assertEquals(dynamicTrait.numDynamicStreams, 20, mediaPlayer.numDynamicStreams);	
			Assert.assertEquals(events[0].type, DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE);
			
			mediaPlayer.autoDynamicStreamSwitch = true;
			
			media.doRemoveTrait(MediaTraitType.DYNAMIC_STREAM);
			
			Assert.assertTrue(mediaPlayer.autoDynamicStreamSwitch);
			
			dynamicTrait.autoSwitch = false;
			
			Assert.assertEquals(2, events.length);	
			Assert.assertTrue(events[1] is DynamicStreamEvent);
			Assert.assertEquals(events[1].type, DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE);
			
			media.doAddTrait(MediaTraitType.DYNAMIC_STREAM, dynamicTrait);
			
			// Should make it true.
			
			Assert.assertTrue(dynamicTrait.autoSwitch);
			
			Assert.assertEquals(4, events.length);	
			Assert.assertTrue(events[2] is DynamicStreamEvent);
			Assert.assertEquals(events[2].type, DynamicStreamEvent.AUTO_SWITCH_CHANGE);
			Assert.assertTrue(events[3] is DynamicStreamEvent);
			Assert.assertEquals(events[3].type, DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE);
			
		}
		
		[Test]
		public function testAudioEventGeneration():void
		{			
			var media:DynamicMediaElement = new DynamicMediaElement();
			mediaPlayer.media = media;
			mediaPlayer.addEventListener(AudioEvent.MUTED_CHANGE, eventCatcher);
			mediaPlayer.addEventListener(AudioEvent.PAN_CHANGE, eventCatcher);
			mediaPlayer.addEventListener(AudioEvent.VOLUME_CHANGE, eventCatcher);
						
			Assert.assertEquals(1, mediaPlayer.volume);
			Assert.assertEquals(0, mediaPlayer.audioPan);
			Assert.assertFalse(mediaPlayer.muted);
			
			var audioTrait:AudioTrait = new AudioTrait();
			audioTrait.volume = .5;
			audioTrait.pan = 1;
			audioTrait.muted = true;
					
			media.doAddTrait(MediaTraitType.AUDIO, audioTrait);
			
			Assert.assertEquals(.5, mediaPlayer.volume, audioTrait.volume);
			Assert.assertEquals(1, mediaPlayer.audioPan, audioTrait.pan);
			Assert.assertEquals(true, mediaPlayer.muted, audioTrait.muted);
			
			Assert.assertEquals(3, events.length);	
			Assert.assertTrue(events[0] is AudioEvent);	
			Assert.assertTrue(events[1] is AudioEvent);
			Assert.assertTrue(events[2] is AudioEvent);
			
			Assert.assertTrue(events[0].type, AudioEvent.VOLUME_CHANGE);	
			Assert.assertTrue(events[1].type, AudioEvent.MUTED_CHANGE);
			Assert.assertTrue(events[2].type, AudioEvent.PAN_CHANGE);
			
			Assert.assertEquals(AudioEvent(events[0]).volume,  mediaPlayer.volume);
			Assert.assertEquals(AudioEvent(events[0]).pan,  mediaPlayer.audioPan);
			Assert.assertEquals(AudioEvent(events[0]).muted,  mediaPlayer.muted);			
			
			// No event generation from removal.
			media.doRemoveTrait(MediaTraitType.AUDIO);
			
			Assert.assertEquals(6, events.length);
			
			Assert.assertTrue(events[3].type, AudioEvent.VOLUME_CHANGE);	
			Assert.assertTrue(events[4].type, AudioEvent.MUTED_CHANGE);
			Assert.assertTrue(events[5].type, AudioEvent.PAN_CHANGE);
			
			Assert.assertEquals(AudioEvent(events[3]).volume,  mediaPlayer.volume);
			Assert.assertEquals(AudioEvent(events[3]).pan,  mediaPlayer.audioPan);
			Assert.assertEquals(AudioEvent(events[3]).muted,  mediaPlayer.muted);			
			
		}
		
		[Test]
		public function testTimeEventGeneration():void
		{	
			var media:DynamicMediaElement = new DynamicMediaElement();
			mediaPlayer.media = media;
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, eventCatcher);
			mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, eventCatcher);
			
			Assert.assertEquals(1, mediaPlayer.volume);
			Assert.assertEquals(0, mediaPlayer.audioPan);
			Assert.assertFalse(mediaPlayer.muted);
			
			var timeTrait:TimeTrait = new TimeTrait(20);
						
			media.doAddTrait(MediaTraitType.TIME, timeTrait);
			
			Assert.assertEquals(20, mediaPlayer.duration, timeTrait.duration);
			
			Assert.assertEquals(2, events.length);	
			Assert.assertTrue(events[0] is TimeEvent);	
			Assert.assertTrue(events[1] is TimeEvent);	
			
			Assert.assertTrue(events[0].type, TimeEvent.CURRENT_TIME_CHANGE);	
			Assert.assertTrue(events[1].type, TimeEvent.DURATION_CHANGE);	
			Assert.assertEquals(TimeEvent(events[0]).time,  mediaPlayer.currentTime);		
			Assert.assertEquals(TimeEvent(events[1]).time,  mediaPlayer.duration);		
			
			// Removal Events
			
			media.doRemoveTrait(MediaTraitType.TIME);
			
			Assert.assertEquals(4, events.length);	
			Assert.assertTrue(events[2] is TimeEvent);	
			Assert.assertTrue(events[3] is TimeEvent);	
			
			Assert.assertTrue(events[2].type, TimeEvent.CURRENT_TIME_CHANGE);	
			Assert.assertTrue(events[3].type, TimeEvent.DURATION_CHANGE);	
			Assert.assertEquals(TimeEvent(events[2]).time,  mediaPlayer.currentTime);		
			Assert.assertEquals(TimeEvent(events[3]).time,  mediaPlayer.duration);		
		}
			
		[Test]
		public function testPlayEventGeneration():void
		{
			var media:DynamicMediaElement = new DynamicMediaElement();
			mediaPlayer.media = media;
			mediaPlayer.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, eventCatcher);
			mediaPlayer.addEventListener(PlayEvent.PLAY_STATE_CHANGE, eventCatcher);
						
			var playTrait:DynamicPlayTrait = new DynamicPlayTrait();
			
			playTrait.canPause = true;
			
			Assert.assertFalse(mediaPlayer.playing);
			
			media.doAddTrait(MediaTraitType.PLAY, playTrait);
			
			Assert.assertEquals(1, events.length);
			Assert.assertTrue(events[0] is PlayEvent);	
			Assert.assertEquals(events[0].type, PlayEvent.CAN_PAUSE_CHANGE);
			
			media.doRemoveTrait(MediaTraitType.PLAY);
			
			Assert.assertEquals(2, events.length);
			Assert.assertTrue(events[1] is PlayEvent);	
			Assert.assertEquals(events[1].type, PlayEvent.CAN_PAUSE_CHANGE);
			
			Assert.assertFalse(mediaPlayer.canPause);
			Assert.assertFalse(mediaPlayer.canPlay);
			
			playTrait.canPause = false;
			playTrait.play();
			
			media.doAddTrait(MediaTraitType.PLAY, playTrait);
			
			Assert.assertEquals(3, events.length);
			Assert.assertTrue(events[2] is PlayEvent);	
			Assert.assertEquals(events[2].type, PlayEvent.PLAY_STATE_CHANGE);
			
			Assert.assertTrue(mediaPlayer.playing);	
		}
		
		// Fixes #FM-612, tests that a composition is stopped when a fatal error
		// is raised from one element.
		[Test]
		public function testMediaPlaybackErrorCompositions():void
		{
			var parallel:ParallelElement = new ParallelElement();
			var media1:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.PLAY], null, null, true);
			var media2:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.PLAY], null, null, true);
			
			var dynamicTime1:DynamicTimeTrait = new DynamicTimeTrait();
			dynamicTime1.duration = 30;
			var dynamicTime2:DynamicTimeTrait = new DynamicTimeTrait();
			dynamicTime2.duration = 30;
			
			var seekTrait1:DynamicSeekTrait = new DynamicSeekTrait(dynamicTime1);
			var seekTrait2:DynamicSeekTrait = new DynamicSeekTrait(dynamicTime2);
			seekTrait1.autoCompleteSeek = true;
			seekTrait2.autoCompleteSeek = true;
			
			media1.doAddTrait(MediaTraitType.TIME, dynamicTime1);
			media2.doAddTrait(MediaTraitType.TIME, dynamicTime2);
			media1.doAddTrait(MediaTraitType.SEEK, seekTrait1);
			media2.doAddTrait(MediaTraitType.SEEK, seekTrait2);
					
			parallel.addChild(media1);
			parallel.addChild(media2);
						
			mediaPlayer.media = parallel;
			mediaPlayer.play();
			
			Assert.assertTrue(mediaPlayer.playing);
			
			media1.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(2, "sample media error")));
			
			Assert.assertEquals(PlayState.STOPPED, (media2.getTrait(MediaTraitType.PLAY) as PlayTrait).playState);
						
		}		
		
		// Protected
		//
		
		protected function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			// Subclasses can override to specify the MediaElement subclass
			// to use with the MediaPlayer.
			var mediaElement:MediaElement = new MediaElement();
			mediaElement.resource = resource;
			return mediaElement; 
		}
		
		protected function get hasLoadTrait():Boolean
		{
			// Subclasses can override to specify that the MediaElement starts
			// with the LoadTrait.
			return false;
		}
		
		protected function get resourceForMediaElement():MediaResourceBase
		{
			// Subclasses can override to specify a resource that the
			// MediaElement can work with.
			return new URLResource("http://www.example.com");
		}

		protected function get invalidResourceForMediaElement():MediaResourceBase
		{
			// Subclasses can override to specify a resource that the
			// MediaElement should Assert.fail to load.
			return new URLResource("http://www.example.com/Assert.fail");
		}

		protected function get existentTraitTypesOnInitialization():Array
		{
			// Subclasses can override to specify the trait types which are
			// expected upon initialization of the MediaElement
			return [];
		}

		protected function get existentTraitTypesAfterLoad():Array
		{
			// Subclasses can override to specify the trait types which are
			// expected after a load of the MediaElement.  Ignored if the
			// MediaElement lacks the ILoadable trait.
			return [];
		}
		
		protected function get expectedMediaWidthOnInitialization():Number
		{
			// Subclasses can override to specify the expected mediaWidth of the
			// MediaElement upon initialization.
			return 0;
		}

		protected function get expectedMediaHeightOnInitialization():Number
		{
			// Subclasses can override to specify the expected mediaHeight of the
			// MediaElement upon initialization.
			return 0;
		}

		protected function get expectedMediaWidthAfterLoad():Number
		{
			// Subclasses can override to specify the expected mediaWidth of the
			// MediaElement after it has been loaded.
			return 0;
		}

		protected function get expectedMediaHeightAfterLoad():Number
		{
			// Subclasses can override to specify the expected mediaHeight of the
			// MediaElement after it has been loaded.
			return 0;
		}
		
		protected function get expectedBytesLoadedOnInitialization():Number
		{
			// Subclasses can override to specify the expected bytesLoaded of the
			// MediaElement upon initialization.
			return 0;
		}

		protected function get expectedBytesTotalOnInitialization():Number
		{
			// Subclasses can override to specify the expected bytesTotal of the
			// MediaElement upon initialization.
			return 0;
		}

		protected function get expectedBytesLoadedAfterLoad():Number
		{
			// Subclasses can override to specify the expected bytesLoaded of the
			// MediaElement after it has been loaded.
			return 0;
		}

		protected function get expectedBytesTotalAfterLoad():Number
		{
			// Subclasses can override to specify the expected bytesTotal of the
			// MediaElement after it has been loaded.
			return 0;
		}

		protected function get dynamicStreamResource():MediaResourceBase
		{
			// Subclasses can override to specify a media resource that is
			// a dynamic stream.
			return null;
		}
		
		protected function get expectedMaxAllowedDynamicStreamIndex():int
		{
			// Subclasses can override to specify the expected max allowed dynamic
			// stream index.
			return -1;
		}
		
		protected function getExpectedBitrateForDynamicStreamIndex(index:int):Number
		{
			// Subclasses can override to specify the expected bitrates for each
			// dynamic stream index.
			return -1;
		}
		
		protected function get supportsSubclips():Boolean
		{
			// Subclasses can override to indicate that they are capable of
			// playing subclips.
			return false;
		}
		
		protected function get expectedSubclipDuration():Number
		{
			// Subclasses can override to specify the expected duration of
			// the subclip.  Ignored unless supportsSubclips returns true.
			return 0;
		}
		
		// Internals
		//
		
		private function traitExists(traitType:String):Boolean
		{
			var traitTypes:Array = existentTraitTypesAfterLoad;
			for each (var type:String in traitTypes)
			{
				if (type == traitType)
				{
					return true;
				}
			}
			
			return false;
		}
		
		private function eventCatcher(event:Event):void
		{
			events.push(event);
		}
		
		private var mediaPlayer:MediaPlayer;
		private var eventDispatcher:EventDispatcher;
		private var events:Vector.<Event>;
	}
}