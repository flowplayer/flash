/*****************************************************
*  
*  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.AlternativeAudioEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamingItem;
	
	/**
	 * Plays a video with alternate audio streams.
	 **/
	[SWF(backgroundColor="0xdedede", width=640, height=480)]
	public class HelloWorld8 extends Sprite
	{
		/**
		 * Default constructor.
		 */
		public function HelloWorld8()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
 			
 			// Create the container class that displays the media.
 			var container:MediaContainer = new MediaContainer();
			container.x = 0;
			container.y = 0;
			container.width = stage.stageWidth;
			container.height = stage.stageHeight;
			addChild(container);
			
			// Create some layout metadata from the MediaElement.  This will cause
			// it to be centered in the container, with no scaling of content.
			var layoutMetadata:LayoutMetadata = new LayoutMetadata();
			layoutMetadata.layoutMode = LayoutMode.NONE;
			layoutMetadata.scaleMode = ScaleMode.LETTERBOX;
			layoutMetadata.percentHeight = 100;
			layoutMetadata.percentWidth = 100;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;

			// create media element
			var mediaFactory:MediaFactory = new DefaultMediaFactory();
			var mediaElement:MediaElement = mediaFactory.createMediaElement(new URLResource(F4M_VOD));
			mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);
			container.addMediaElement(mediaElement);
			
			// create media player
			_player = new MediaPlayer();
			
			_player.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			_player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onPlayerStateChange);
			_player.addEventListener(AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE, onAlternateAudioSwitchingChange);
			_player.addEventListener(AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE, onNumAlternativeAudioStreamsChange);

			_player.media = mediaElement;
			_player.loop = false;
			_player.autoPlay = false;
			_player.bufferTime = 4 ;
		}
		
		/**
		 * Error event handler.
		 */
		private function onMediaError(event:MediaErrorEvent):void
		{
			trace("[Error]", event.toString());	
		}

		/**
		 * @private
		 * 
		 * Event handler called when the total number of associated alternative streams changes.
		 */
		private function onNumAlternativeAudioStreamsChange(event:AlternativeAudioEvent):void
		{
			if (_player.hasAlternativeAudio)
			{
				trace("Number of alternative audio streams = ", _player.numAlternativeAudioStreams);
			}
		}
		
		/**
		 * @private
		 * 
		 * Event handler called when an alternative audio stream switch is in progress or has been completed.
		 */
		private function onAlternateAudioSwitchingChange(event:AlternativeAudioEvent):void
		{
			if (event.switching)
			{
				trace("Alternative audio stream switch in progress");
			}
			else
			{
				trace("Alternate audio stream switch completed");
				trace("Current alternate audio index is [" + _player.currentAlternativeAudioStreamIndex + "].");
			}
		}

		/**
		 * Event handler for player state change event. 
		 */ 		
		private function onPlayerStateChange(event:MediaPlayerStateChangeEvent):void
		{
			switch (event.state)
			{
				case MediaPlayerState.READY:
					if (!_playbackInitiated)
					{
						_playbackInitiated = true;
						
						trace("Alternative languages", _player.hasAlternativeAudio ? "available" : " not available" );
						if (_player.hasAlternativeAudio)
						{
							for (var index:int = 0; index < _player.numAlternativeAudioStreams; index++)
							{
								var item:StreamingItem = _player.getAlternativeAudioItemAt(index);
								trace("[LBA] [", item.info.language, "]", item.info.label);
							}
							
							// we'll just select the first available alternate language
							_player.switchAlternativeAudioIndex(0);
						}	
						if (_player.canPlay)
						{
							_player.play();
						}
					}
					break;
				case MediaPlayerState.PLAYING:
					break;
			}
		}
		
		/// Internal
		private var _player:MediaPlayer = null;
		private var _playbackInitiated:Boolean = false;

		private static const F4M_VOD:String = "http://10.131.237.107/vod/hs/vod_2alt/ex.f4m";
	}
}
