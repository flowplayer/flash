/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.controllers {
    
	import org.flowplayer.model.Status;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.view.Flowplayer;
	
	import org.flowplayer.ui.buttons.ConfigurableWidget;
	import org.flowplayer.ui.controllers.AbstractWidgetController;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.DisplayObjectContainer;

	public class AbstractTimedWidgetController extends AbstractWidgetController {

		protected var _timeUpdateTimer:Timer;
		
		public function AbstractTimedWidgetController() {
			super();
		}
		
		override public function init(player:Flowplayer, controlbar:DisplayObjectContainer, defaultConfig:Object):ConfigurableWidget {
			super.init(player, controlbar, defaultConfig);
			createUpdateTimer();
			
			return _widget;
		}
		
		protected function createUpdateTimer():void {
			_timeUpdateTimer = new Timer(100);
			_timeUpdateTimer.addEventListener(TimerEvent.TIMER, onTimeUpdate);
		}

		protected function startUpdateTimer():void {
			_timeUpdateTimer.start();
			onTimeUpdate(null);
		}

		protected function stopUpdateTimer():void {
			_timeUpdateTimer.stop();
			onTimeUpdate(null);
		}

		protected function getPlayerStatus():Status {
            try {
                return _player.status;
            } catch (e:Error) {
                log.error("error querying player status, will stop query timer, error message: " + e.message);
                stopUpdateTimer();
                throw e;
            }
            return null;
       	}
	
		override protected function onPlayStarted(event:ClipEvent):void {
			super.onPlayStarted(event);
			startUpdateTimer();
		}

		override protected function onPlayStopped(event:ClipEvent):void {
			super.onPlayStopped(event);
			stopUpdateTimer();
		}

		// override this when you need to get updated
		protected function onTimeUpdate(event:TimerEvent):void {
			
		}
		
	}
}

