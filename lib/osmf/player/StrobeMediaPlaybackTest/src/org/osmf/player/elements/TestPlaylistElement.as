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

package org.osmf.player.elements
{
	import org.flexunit.asserts.*;
	import org.osmf.elements.AudioElement;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.elements.playlistClasses.MockPlaylistFactory;
	import org.osmf.player.elements.playlistClasses.MockPlaylistLoader;
	import org.osmf.player.elements.playlistClasses.PlaylistMetadata;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.utils.DynamicLoadTrait;
	import org.osmf.utils.DynamicLoader;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.DynamicPlayTrait;
	import org.osmf.utils.DynamicSeekTrait;
	import org.osmf.utils.DynamicTimeTrait;

	public class TestPlaylistElement
	{		
		[Before]
		public function setUp():void
		{
			var factory:MockPlaylistFactory = new MockPlaylistFactory();
			
			factory.addMediaContstructor
				( "element1"
				, function(resource:MediaResourceBase):MediaElement
					{
						return element1;	
					}
				);
			
			factory.addMediaContstructor
				( "element2"
				, function(resource:MediaResourceBase):MediaElement
					{
						return element2;	
					}
				);
			
			factory.addMediaContstructor
				( "element3-null"
				, function(resource:MediaResourceBase):MediaElement
					{
						return null;	
					}
				);	
				
			
			var loader:MockPlaylistLoader = new MockPlaylistLoader(factory);
			loader.playlistContent 
				= "#Playlist\n"
				+ "\n"
				+ "element1\n"
				+ "element2\n"
				;
			
			element = new PlaylistElement(loader);
			element.resource = new StreamingURLResource("somefile.m3u");
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testConstruction():void
		{
			assertNotNull(element);
		}
		
		[Test]
		public function testLoad():void
		{
			var player:MediaPlayer = new MediaPlayer();
			
			assertTrue(element.hasTrait(MediaTraitType.LOAD));
			assertFalse(element.hasTrait(MediaTraitType.AUDIO));
			assertFalse(element.hasTrait(MediaTraitType.PLAY));
			assertFalse(element.hasTrait(MediaTraitType.TIME));
			
			player.media = element;
			
			var audioTrait:AudioTrait = new AudioTrait();
			element1.doAddTrait(MediaTraitType.AUDIO, audioTrait);
			assertTrue(element.hasTrait(MediaTraitType.AUDIO));
			element1.doRemoveTrait(MediaTraitType.AUDIO);
			assertFalse(element.hasTrait(MediaTraitType.AUDIO));
			
			var playTrait:DynamicPlayTrait = new DynamicPlayTrait();
			element1.doAddTrait(MediaTraitType.PLAY, playTrait);
			assertTrue(element.hasTrait(MediaTraitType.PLAY));
			
			var timeTrait:DynamicTimeTrait = new DynamicTimeTrait();
			timeTrait.currentTime = 0;
			timeTrait.duration = 100;
			element1.doAddTrait(MediaTraitType.TIME, timeTrait);
			assertTrue(element.hasTrait(MediaTraitType.TIME));
			
			// Jump to the next element by signaling complete on the time trait:
			timeTrait.currentTime = timeTrait.duration;
			
			// This should result in all traits to report null again:
			assertFalse(element.hasTrait(MediaTraitType.AUDIO));
			assertTrue(element.hasTrait(MediaTraitType.PLAY));
			assertFalse(element.hasTrait(MediaTraitType.TIME));
			
			// Let's jump back to the first element:
			var playlistMetadata:Metadata = element.getMetadata(PlaylistMetadata.NAMESPACE);
			playlistMetadata.addValue("gotoPrevious", true);
			
			// This should result in element1's traits being reflected:
			assertTrue(element.hasTrait(MediaTraitType.PLAY));
			assertTrue(element.hasTrait(MediaTraitType.TIME));
			
			// Reinstate the audio trait, add it to the next element too:
			element1.doAddTrait(MediaTraitType.AUDIO, audioTrait);
			var eAudioTrait:AudioTrait = element.getTrait(MediaTraitType.AUDIO) as AudioTrait;
			eAudioTrait.volume = 0.1;
			eAudioTrait.muted = true;
			eAudioTrait.pan = 0.5;
			assertEquals(eAudioTrait.volume, audioTrait.volume, 0.1);
			assertEquals(eAudioTrait.muted, audioTrait.muted, true);
			assertEquals(eAudioTrait.pan, audioTrait.pan, 0.5);
			
			var ePlayTrait:PlayTrait = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
			ePlayTrait.play();
			
			// Give the second element an audio trait, play trait, etc:
			var audioTrait2:AudioTrait = new AudioTrait();
			element2.doAddTrait(MediaTraitType.AUDIO, audioTrait2);
			var playTrait2:DynamicPlayTrait = new DynamicPlayTrait();
			element2.doAddTrait(MediaTraitType.PLAY, playTrait2);
			var timeTrait2:DynamicTimeTrait = new DynamicTimeTrait();
			element2.doAddTrait(MediaTraitType.TIME, timeTrait2);
			var seekTrait:DynamicSeekTrait = new DynamicSeekTrait(timeTrait2);
			seekTrait.seekInstantly = true;
			element2.doAddTrait(MediaTraitType.SEEK, seekTrait);
			
			
			// Goto the next element again, this time by setting the metadata:
			playlistMetadata.addValue("gotoNext", true);
			
			// Next, check if all trait settings got propagated to the next child
			// correctly:
			assertEquals(eAudioTrait.volume, audioTrait2.volume, 0.1);
			assertEquals(eAudioTrait.muted, audioTrait2.muted, true);
			assertEquals(eAudioTrait.pan, audioTrait2.pan, 0.5);
			assertEquals(ePlayTrait.playState, playTrait2.playState, PlayState.PLAYING);
			
			// Time is expected to be NaN right now:
			assertTrue(isNaN(timeTrait2.currentTime));
			timeTrait2.duration = 200;
			timeTrait2.currentTime = 100;
			
			// Goto the first element:
			playlistMetadata.addValue("gotoPrevious", true);
			
			// This is not instant anymore since we stop the video after .5 secs now, 
			// as a workarround for ST-134
			
			// Play should be stopped:
			///assertEquals(PlayState.STOPPED, playTrait2.playState);
			// Current time should now be 0:
			///assertEquals(0, timeTrait2.currentTime);
		}
		
		[Test]
		public function testErrorElementInList():void
		{
			var factory:MockPlaylistFactory = new MockPlaylistFactory();
			
			factory.addMediaContstructor
				( "null"
					, function(resource:MediaResourceBase):MediaElement
					{
						return null;	
					}
				);	
			
			
			var loader:MockPlaylistLoader = new MockPlaylistLoader(factory);
			loader.playlistContent 
				= "#Playlist\n"
				+ "\n"
				+ "null"
				;
			
			element = new PlaylistElement(loader);
			element.resource = new StreamingURLResource("somefile.m3u");
			
			var player:MediaPlayer = new MediaPlayer(element);
		}
		
		// Internals
		//
		
		private var element:PlaylistElement;
		
		private static const element1:DynamicMediaElement = new DynamicMediaElement();
		private static const element2:DynamicMediaElement = new DynamicMediaElement();
	}
}