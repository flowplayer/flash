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
package
{
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.effects.Effect;
	import mx.effects.Fade;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.traits.TraitEventDispatcher;
	
	public class MediaElementEffect
	{
		private var complete:Timer;
		private var timeTrait:TimeTrait;
		private var _duration:Number;
		private var mediaElement:MediaElement;
		private var _padding:Number;
		private var playTrait:PlayTrait;
		protected var effect:Effect;
		
		public function MediaElementEffect(padding:Number, element:MediaElement)
		{	
			mediaElement = element;
			_padding = padding;
			//Complete timer (give it a default duration until the video gets its real duration
			complete = new Timer(50, 1);
				
			if (mediaTimeTrait)
			{
				_duration =  mediaTimeTrait.duration - _padding;
			}
						
			var ted:TraitEventDispatcher = new TraitEventDispatcher();
						
			ted.addEventListener(TimeEvent.DURATION_CHANGE, onDuration);
			ted.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
			ted.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);
			ted.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayState);
			ted.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadState);
			
			ted.media = element;
			
			complete.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}
		
		public function get padding():Number
		{
			return _padding;
		}
			
		protected function resetTimer():void
		{				
			complete.reset();
			
			//Treat NaN as 0, for currentTime.			
			var currTime:Number = isNaN(mediaTimeTrait.currentTime) ? 0 : mediaTimeTrait.currentTime;
			
			if (!isNaN(mediaTimeTrait.duration) && 
				(currTime < (mediaTimeTrait.duration - padding)))
			{				
				complete.delay =  (mediaTimeTrait.duration - currTime - padding)*1000;
				complete.repeatCount = 1;
				complete.start();
			}			
		}
		
		protected function get mediaPlayTrait():PlayTrait
		{
			return (mediaElement.getTrait(MediaTraitType.PLAY) as PlayTrait);
		}
				
		protected function get mediaTimeTrait():TimeTrait
		{
			return (mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait);
		}
				
		protected function get mediaSeekTrait():SeekTrait
		{
			return (mediaElement.getTrait(MediaTraitType.SEEK) as SeekTrait);
		}
		
		protected function get mediaDisplayObjectTrait():DisplayObjectTrait
		{
			return (mediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait);
		}
				
		protected function doTransition(reversed:Boolean, startFrom:Number = 0):void
		{			
			var display:DisplayObject;			
			if(effect)
			{
				effect.stop();
			}			
			if (mediaDisplayObjectTrait)
			{
				display = mediaDisplayObjectTrait.displayObject;
			}			
			if (display)
			{		
				var fade:Fade =  new Fade(display);
				effect = fade;
				fade.duration = padding*1000; 
				fade.alphaFrom = 0;
				fade.alphaTo = 1;
				fade.play([display], reversed);
			}			
		}
		
		/**
		 * Setup the ending timer.
		 */ 
		private function onDuration(value:TimeEvent):void
		{
			_duration =  mediaTimeTrait.duration - _padding;	
			if (mediaPlayTrait.playState == PlayState.PLAYING)
			{
				resetTimer();
			}
		}
		
		private function onLoadState(event:LoadEvent):void
		{
			if (event.loadState == LoadState.READY)
			{
				startTransition();
			}
		}
		
		private function startTransition():void
		{			
			if (mediaTimeTrait.currentTime == 0 ||
				isNaN(mediaTimeTrait.currentTime))
			{
				doTransition(false, 0);
			}
		}
				
		private function onDisplayObjectChange(event:DisplayObjectEvent):void
		{
			startTransition();
		}
		
		/**
		 * Fire the exit transition.
		 */ 
		private function onComplete(event:TimerEvent):void
		{				
			complete.stop();
			doTransition(true);
		}
		
		private function onPlayState(value:PlayEvent):void
		{
			if (value.playState == PlayState.PLAYING)
			{				
				resetTimer();
				if (mediaTimeTrait.currentTime == 0 ||
					isNaN(mediaTimeTrait.currentTime))
				{					
					doTransition(false, 0);
				}
			}
			else 
			{					
				complete.stop();
			}
		}
		
		private function onSeekingChange(value:SeekEvent):void
		{
			resetTimer();
		}	
		
				
	}
}