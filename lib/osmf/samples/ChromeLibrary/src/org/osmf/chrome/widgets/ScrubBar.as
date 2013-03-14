/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.chrome.assets.FontAsset;
	import org.osmf.chrome.events.ScrubberEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	public class ScrubBar extends Widget
	{
		public function ScrubBar()
		{
			currentTime = new TextField();
			addChild(currentTime);
			
			remainingTime = new TextField();
			addChild(remainingTime);
			
			scrubBarClickArea = new Sprite();
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_DOWN, onTrackMouseDown);
			addChild(scrubBarClickArea);
			
			super();
		}
		
		// Overrides
		//

		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			if (lastWidth != availableWidth || lastHeight != availableHeight)
			{
				lastWidth = availableWidth;
				lastHeight = availableHeight;
				
				currentTime.height
					= remainingTime.height
					= timeFieldsHeight;
					
				currentTime.width
					= remainingTime.width
					= timeFieldsWidth;
					
				remainingTime.x = availableWidth - timeFieldsWidth;
				
				var scrubBarWidth:Number = Math.max(10, availableWidth - ((timeFieldsWidth + timeFieldSpacing) * 2));
				 
				scrubBarTrack.x = Math.round(timeFieldsWidth + timeFieldSpacing);
				scrubBarTrack.y = Math.round((timeFieldsHeight - scrubBarTrack.height) / 2) 
				scrubBarTrack.width = scrubBarWidth;
				
				scrubberStart = scrubBarTrack.x - Math.round(scrubber.width / 2);
				scrubberEnd = scrubberStart + scrubBarWidth;
				
				scrubber.range = scrubBarWidth;
				scrubber.y = scrubBarTrack.y;
				scrubber.origin = scrubberStart;
				
				scrubBarClickArea.x = scrubBarTrack.x;
				scrubBarClickArea.y = scrubBarTrack.y;
				scrubBarClickArea.graphics.clear();
				scrubBarClickArea.graphics.beginFill(0xFFFFFF, 0);
				scrubBarClickArea.graphics.drawRect(0, 0, scrubBarWidth, scrubber.height);
				scrubBarClickArea.graphics.endFill();
				
				onTimerTick();
			}
		}		
		
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			timeFieldsWidth = Number(xml.@timeFieldsWidth || 52);
			timeFieldsHeight = Number(xml.@timeFieldsHeight || 20);
			timeFieldSpacing = Number(xml.@timeFieldSpacing || 10);
			
			var fontId:String = xml.@font || "defaultFont";
			var fontAsset:FontAsset = assetManager.getAsset(fontId) as FontAsset;
			
			currentTime.defaultTextFormat = fontAsset.format;
			currentTime.selectable = false;
			currentTime.embedFonts = true;
			currentTime.alpha = 0.4;
			
			var format:TextFormat = fontAsset.format;
			format.align = TextFormatAlign.RIGHT;
			remainingTime.defaultTextFormat = format; 
			remainingTime.selectable = false;
			remainingTime.embedFonts = true;
			remainingTime.alpha = 0.4;
			
			scrubBarTrack = assetManager.getDisplayObject(xml.@track) || new Sprite();
			addChild(scrubBarTrack);
			
			scrubber
				= new Scrubber
					( assetManager.getDisplayObject(xml.@scrubberUp) || new Sprite()
					, assetManager.getDisplayObject(xml.@scrubberDown) || new Sprite()
					, assetManager.getDisplayObject(xml.@scrubberDisabled) || new Sprite()
					);
					
			scrubber.enabled = false;
			scrubber.addEventListener(ScrubberEvent.SCRUB_START, onScrubberStart);
			scrubber.addEventListener(ScrubberEvent.SCRUB_UPDATE, onScrubberUpdate);
			scrubber.addEventListener(ScrubberEvent.SCRUB_END, onScrubberEnd);
			addChild(scrubber);
			
			currentPositionTimer = new Timer(CURRENT_POSITION_UPDATE_INTERVAL);
			currentPositionTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
			
			measure();
			
			updateState();
		}
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(media:MediaElement):void
		{
			updateState();
		}
		
		override protected function processRequiredTraitsUnavailable(media:MediaElement):void
		{
			updateState();
		}
		
		override protected function onMediaElementTraitAdd(event:MediaElementEvent):void
		{
			updateState();
		}
		
		override protected function onMediaElementTraitRemove(event:MediaElementEvent):void
		{
			updateState();
		}
		
		// Internals
		//
		
		private function updateState():void
		{
			visible = media != null;
			scrubber.enabled = media ? media.hasTrait(MediaTraitType.SEEK) : false;
			updateTimerState();
		}
		
		private function updateTimerState():void
		{
			var temporal:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
			if (temporal == null)
			{
				currentPositionTimer.stop();
				
				resetUI();
			}
			else
			{
				currentPositionTimer.start();
			}
		}
		
		private function onTimerTick(event:Event = null):void
		{
			var temporal:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
			if (temporal != null)
			{
				var duration:Number = temporal.duration;
				var position:Number = isNaN(seekToTime) ? temporal.currentTime : seekToTime;
			
				currentTime.text
					= prettyPrintSeconds(position);
					
				remainingTime.text
					= "-" 
					+ prettyPrintSeconds(Math.max(0, duration - position));
				
				var scrubberX:Number
						= 	scrubberStart
						+ 	(	(scrubberEnd - scrubberStart)
								* position
							)
							/ duration
						||	scrubberStart; // defaul value if calc. returns NaN.
							
				scrubber.x = Math.min(scrubberEnd, Math.max(scrubberStart, scrubberX));
			}
			else
			{
				resetUI();
			}
		}
		
		private function prettyPrintSeconds(seconds:Number):String
		{
			seconds = Math.floor(isNaN(seconds) ? 0 : Math.max(0, seconds));
			return Math.floor(seconds / 3600) 
				 + ":"
				 + (seconds % 3600 < 600 ? "0" : "")
				 + Math.floor(seconds % 3600 / 60)
				 + ":"
				 + (seconds % 60 < 10 ? "0" : "") + seconds % 60;
		}
		
		private function onScrubberStart(event:ScrubberEvent):void
		{
			var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if (playable)
			{
				preScrubPlayState = playable.playState;
				if (playable.canPause && playable.playState != PlayState.PAUSED)
				{
					playable.pause();
				}
			}
		}
		
		private function onScrubberUpdate(event:ScrubberEvent = null):void
		{
			var temporal:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
			var seekable:SeekTrait = media ? media.getTrait(MediaTraitType.SEEK) as SeekTrait : null;
			if (temporal && seekable)
			{
				var time:Number
					= (temporal.duration * (scrubber.x - scrubberStart))
					/ scrubber.range;
				
				if (seekable.canSeekTo(time))
				{
					seekable.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange)
					seekToTime = time;
					seekable.seek(time);
				}
			}
		}
		
		private function onSeekingChange(event:SeekEvent):void
		{
			var seekable:SeekTrait = event.target as SeekTrait;
			if (event.seeking == false)
			{
				seekable.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
				seekToTime = NaN;
				onTimerTick();
			}
		}
		
		private function onScrubberEnd(event:ScrubberEvent):void
		{
			onScrubberUpdate();
			
			if (preScrubPlayState)
			{
				var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playable)
				{
					if (playable.playState != preScrubPlayState)
					{
						switch (preScrubPlayState)
						{
							case PlayState.STOPPED:
								playable.stop();
								break;
							case PlayState.PLAYING:
								playable.play();
								break;
						}
					}
				}
			}
		}
		
		private function onTrackMouseDown(evenet:MouseEvent):void
		{
			scrubber.start();
		}
		
		private function resetUI():void
		{
			currentTime.text = "0:00:00";
			remainingTime.text = "-0:00:00";
			scrubber.x = scrubberStart;
		}
		
		private var scrubber:Scrubber;
		private var scrubBarClickArea:Sprite;
		
		private var scrubberStart:Number;
		private var scrubberEnd:Number;
		
		private var timeFieldsWidth:Number;
		private var timeFieldsHeight:Number;
		private var timeFieldSpacing:Number;
		
		private var currentTime:TextField;
		private var remainingTime:TextField;
		
		private var currentPositionTimer:Timer;
		
		private var scrubBarTrack:DisplayObject;
		
		private var preScrubPlayState:String;
		
		private var lastWidth:Number;
		private var lastHeight:Number;
		
		private var seekToTime:Number;
		
		/* static */
		private static const CURRENT_POSITION_UPDATE_INTERVAL:int = 100;
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.TIME;
	}
}