/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.time {
   
	import org.flowplayer.ui.buttons.WidgetDecorator;

	import org.flowplayer.controls.controllers.AbstractTimedWidgetController;
	import org.flowplayer.controls.Controlbar;
	import org.flowplayer.controls.SkinClasses;
	
	import org.flowplayer.view.Flowplayer;
	
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Status;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.TimerEvent;
	import flash.events.Event;

	public class TimeViewController extends AbstractTimedWidgetController {
				
		protected var _durationReached:Boolean = false;

		public function TimeViewController() {
			super();
		}
		
		override public function get name():String {
			return "time";
		}
		
		override public function get defaults():Object {
			return {
				visible: true
			};
		}
	
		override protected function createWidget():void {			
			_widget = new TimeView(_config as TimeViewConfig, _player);
            //#443 disabling tabbing for accessibility options
            setInaccessible(_widget);
			_widget.addEventListener(TimeView.EVENT_REARRANGE, function(event:Event):void {
				(_controlbar as Controlbar).configure((_controlbar as Controlbar).config);
			});
        }

		override protected function createDecorator():void {
			_decoratedView = new WidgetDecorator(SkinClasses.getDisplayObject("fp.TimeTopEdge"),
												 SkinClasses.getDisplayObject("fp.TimeRightEdge"),
												 SkinClasses.getDisplayObject("fp.TimeBottomEdge"),
												 SkinClasses.getDisplayObject("fp.TimeLeftEdge")).init(_widget);
		}


		override protected function onTimeUpdate(event:TimerEvent):void {
			var status:Status = getPlayerStatus();
			if (! status) return;
			
			var duration:Number = status.clip ? status.clip.duration : 0;

			(_widget as TimeView).duration = status.clip.live && duration == 0 ? -1 : duration;
			(_widget as TimeView).time = _durationReached ? duration : status.time;
		}

		override protected function addPlayerListeners():void {
			super.addPlayerListeners();
			_player.playlist.onSeek(function(event:ClipEvent):void { onTimeUpdate(null); });
            //#145 there is no seek complete event use the metadata change to update the time when seeking when paused with rtmp.
            _player.playlist.onMetaDataChange(function(event:ClipEvent):void { onTimeUpdate(null); });
			_player.playlist.onBeforeFinish(durationReached);
		}

		protected function durationReached(event:ClipEvent):void {
			_durationReached = true;
		}

        // cannot push this to the superclass because it prevents the buffer bar moving in paused state
        override protected function onPlayPaused(event:ClipEvent):void {
            super.onPlayPaused(event);
            stopUpdateTimer();
        }

        override protected function onPlayResumed(event:ClipEvent):void {
            super.onPlayResumed(event);
            startUpdateTimer();
            _durationReached = false;
        }

		override protected function onPlayStarted(event:ClipEvent):void {
			super.onPlayStarted(event);
			_durationReached = false;
		}
	}
}

