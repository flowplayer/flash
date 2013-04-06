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
package org.osmf.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.ListEvent;
	import mx.events.MenuEvent;
	import mx.events.SliderEvent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.examples.AllExamples;
	import org.osmf.examples.Category;
	import org.osmf.examples.Example;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.metadata.MetadataWatcher;
	import org.osmf.utils.Version;
	
	public class MainWindow extends MainWindowLayout
	{
		// Overrides
		//
				
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			
			// Set up our MediaPlayer.
			//
			
			mediaPlayer = new MediaPlayer();
			mediaPlayer.autoPlay = true;
			mediaPlayer.autoRewind = true;
			
			// Set up our list of examples.
			//
			
			examples = AllExamples.examples;
			exampleTree.labelField = "name";
			exampleTree.dataTipField = "name";
			exampleTree.showDataTips = true;
			exampleTree.dataProvider = examples;
			exampleTree.validateNow();
			exampleTree.expandChildrenOf(examples[0], true);
			
			// Add UI event handlers.
			//

			exampleTree.addEventListener(ListEvent.CHANGE, onExampleTreeSelect);
			
			buttonPlay.addEventListener(MouseEvent.CLICK, onPlayClick);
			buttonPause.addEventListener(MouseEvent.CLICK, onPauseClick);
			
			panControl.addEventListener(SliderEvent.CHANGE, onPan);
			volumeSlider.addEventListener(SliderEvent.CHANGE, onVolume);
			muteToggle.addEventListener(MouseEvent.CLICK, onToggleMuteClick);
			
			seekBar.addEventListener(SliderEvent.CHANGE, onSeek);
			seekBar.addEventListener(SliderEvent.THUMB_DRAG, onSeek);
			
			scaleModeButton.dataProvider = new ArrayCollection([ScaleMode.NONE, ScaleMode.LETTERBOX, ScaleMode.STRETCH, ScaleMode.ZOOM]);
			scaleModeButton.addEventListener(MenuEvent.ITEM_CLICK, onScaleModeSelect);
			
			playOptions.addEventListener(Event.CHANGE, onPlayOptions);

			// Add MediaPlayer event handlers.
			//
			
			mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE, onCapabilityChange);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE, onCapabilityChange);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE, onCapabilityChange);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onCapabilityChange);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, onCapabilityChange);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE, onCapabilityChange);
			mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);

			mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			mediaPlayer.addEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
			mediaPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			mediaPlayer.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, onBufferTimeChange);
			mediaPlayer.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
			mediaPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
			mediaPlayer.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);

			// Set up the container.
			//
			
			mediaContainerUIComponent.container = new MediaContainer();
			
			// Sync the UI to the current (empty) state.
			//
			
			updateControls();

			version.text = "OSMF Version: " + Version.version;
		}
					
		// UI Event Handlers
		//
		
		private function onPlayOptions(event:Event):void
		{
			mediaPlayer.autoPlay = playOptions.dataProvider[0].autoPlay.@toggled == "true";
			mediaPlayer.autoRewind = playOptions.dataProvider[0].autoRewind.@toggled == "true";
			mediaPlayer.loop = playOptions.dataProvider[0].loop.@toggled == "true";
		}
		
		private function onPan(event:SliderEvent):void
		{
			mediaPlayer.audioPan = event.value;
		}
				
		private function onVolume(event:SliderEvent):void
		{
			mediaPlayer.volume = event.value;
		}

		private function onPlayClick(event:MouseEvent):void
		{
			mediaPlayer.play();
		}
		
		private function onPauseClick(event:MouseEvent):void
		{
			mediaPlayer.pause();
		}
		
		private function onToggleMuteClick(event:MouseEvent):void
		{
			mediaPlayer.muted = muteToggle.selected;
		}
		
		private function onSeek(event:SliderEvent):void
		{
			if (mediaPlayer.canSeek)
			{
				mediaPlayer.seek(event.value);
			}	
		}
		
		private function onScaleModeSelect(event:MenuEvent):void
		{
			setScaleMode(event.item.toString());
		}
		
		private function setScaleMode(scaleMode:String):void
		{
			scaleModeButton.label = scaleMode;

			if (mediaPlayer.media != null)
			{
				var layoutMetadata:LayoutMetadata = mediaPlayer.media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
				layoutMetadata.scaleMode = scaleMode;
			}
		}
		
		private function setMediaElement(value:MediaElement):void
		{
			if (mediaPlayer.media != null)
			{
				mediaContainerUIComponent.container.removeMediaElement(mediaPlayer.media);
				recommendationsWatcher.unwatch();
			}
			
			if (value != null)
			{
				// If there's no explicit layout metadata, center the content. 
				var layoutMetadata:LayoutMetadata = value.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
				if (layoutMetadata == null)
				{
					layoutMetadata = new LayoutMetadata();
					layoutMetadata.scaleMode = scaleMode;
					layoutMetadata.percentHeight = layoutMetadata.percentWidth = 100;
					layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
					layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
					value.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);
				}
				mediaContainerUIComponent.container.addMediaElement(value);
				
				recommendationsWatcher = new MetadataWatcher(value.metadata, "recommendations", "open", onRecomendationsOpenChange);
				recommendationsWatcher.watch(false);
			}
				
			mediaPlayer.media = value;
		}

		private function onExampleTreeSelect(event:ListEvent = null):void
		{
			if (example != null)
			{
				example.dispose();
			}

			errorIDBox.visible = errorMessageBox.visible = errorDetailBox.visible = false;
			errorID.text = errorMessage.text = errorDetail.text = "";
			duration.text = "";
			
			if (exampleTree.selectedItem != null &&
				exampleTree.selectedItem is Example)
			{
				example = exampleTree.selectedItem as Example;
				setMediaElement(example.mediaElement);
				exampleDescription.text = example.description;
				
				disableScaleMode = false;
				scaleModeButton.label = scaleMode;
				if (example.scaleModeOverride != null)
				{
					if (example.scaleModeOverride == "disable")
					{
						disableScaleMode = true;
					}
					else
					{
						setScaleMode(example.scaleModeOverride);
					}
				}
			}
			else
			{
				setMediaElement(null);
				exampleDescription.text = "";
				disableScaleMode = false;
			}
			
			updateControls();
		}

		// MediaPlayer Event Handlers
		//
		
		private function onStateChange(event:MediaPlayerStateChangeEvent):void
		{
			stateControls.visible = true;
			playerState.text = event.state;
			
			updateControls();
		}
		
		private function onCapabilityChange(event:MediaPlayerCapabilityChangeEvent):void
		{
			updateControls();
		}

		private function onMediaError(event:MediaErrorEvent):void
		{
			errorIDBox.visible = errorMessageBox.visible = errorDetailBox.visible = true;
			
			errorID.text = "" + event.error.errorID;
			errorMessage.text = event.error.message;
			errorDetail.text = event.error.detail;
			
			updateControls();
		}
		
		private function onDurationChange(event:TimeEvent):void
		{
			seekBar.maximum = event.time;
			duration.text = "" + Math.round(event.time);
		}

		private function onCurrentTimeChange(event:TimeEvent):void
		{
			if (mediaPlayer.state != MediaPlayerState.BUFFERING)
			{
				position.text = "" + Math.round(event.time);
	
				seekBar.value = 	mediaPlayer.temporal
								? 	mediaPlayer.currentTime
								:	0;
				
				bufferLength.text = mediaPlayer.canBuffer
								? 	mediaPlayer.bufferLength.toFixed(1)
								: "";
			}
		}
		
		private function onMutedChange(event:AudioEvent):void
		{
			muteToggle.selected = event.muted;
		}

		private function onBufferingChange(event:BufferEvent):void
		{
			buffering.text = event.buffering ? "true" : "false";
		}

		private function onBufferTimeChange(event:BufferEvent):void
		{
			bufferTime.text = mediaPlayer.bufferTime.toFixed(1);
		}
		
		private function onBytesTotalChange(event:LoadEvent):void
		{
			bytesTotal.text = event.bytes.toString();
		}
		
		private function onBytesLoadedChange(event:LoadEvent):void
		{
			bytesLoaded.text = event.bytes.toString();
		}
		
		private function onDisplayObjectChange(event:DisplayObjectEvent):void
		{
			updateControls();
		}
		
		private function updateControls():void
		{
			buttonPlay.visible 			= mediaPlayer.canPlay;
			buttonPause.visible 		= mediaPlayer.canPlay && mediaPlayer.canPause;
			audioTraitControls.visible 	= mediaPlayer.hasAudio;
			timeTraitControls.visible	= mediaPlayer.temporal;
			bufferTraitControls.visible	= mediaPlayer.canBuffer;
			loadTraitControls.visible	= mediaPlayer.canLoad;
			seekBar.enabled 			= mediaPlayer.canSeek;
			scaleModeBox.visible		= mediaPlayer.displayObject != null && !disableScaleMode;
			
			if (mediaPlayer.temporal)
			{
				seekBar.maximum = mediaPlayer.duration;
				duration.text = "" + Math.round(mediaPlayer.duration);
			}
			else
			{
				seekBar.maximum = 0;
				duration.text = "0";
			}
			
			if (mediaPlayer.canLoad)
			{
				bytesTotal.text = "" + mediaPlayer.bytesTotal;
			}
			else
			{
				bytesTotal.text = "";
			}
			
			if (mediaPlayer.canBuffer)
			{
				bufferTime.text = mediaPlayer.bufferTime.toFixed(1);
				bufferLength.text = mediaPlayer.bufferLength.toFixed(1);
			}
			else
			{
				bufferTime.text = "";
				bufferLength.text = "";
			}
			
			if (mediaPlayer.canLoad == false)
			{
				bytesTotal.text = "";
				bytesLoaded.text = "";
			}
			
			if (mediaPlayer.hasAudio)
			{
				muteToggle.selected = mediaPlayer.muted;
				volumeSlider.value = mediaPlayer.volume;
				panControl.value = mediaPlayer.audioPan;
			}
		}
		
		private function onRecomendationsOpenChange(value:String):void
		{
			for each (var category:Category in examples)
			{
				for each (var example:Example in category)
				{
					if (example.name == value)
					{
						exampleTree.selectedItem = example;
						onExampleTreeSelect();
						return;
					}		
				}
			}
		}
		
		private var mediaPlayer:MediaPlayer;
		private var examples:ArrayCollection;
		private var example:Example;
		private var recommendationsWatcher:MetadataWatcher;
		private var scaleMode:String = ScaleMode.NONE;
		private var disableScaleMode:Boolean = false;
	}
}
