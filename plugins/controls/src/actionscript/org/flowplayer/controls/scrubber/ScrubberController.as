/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.scrubber {

    import flash.events.Event;
    import flash.events.TimerEvent;

    import org.flowplayer.controls.SkinClasses;
    import org.flowplayer.controls.controllers.AbstractTimedWidgetController;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Status;
    import org.flowplayer.ui.buttons.WidgetDecorator;
    import org.flowplayer.util.TimeUtil;

    public class ScrubberController extends AbstractTimedWidgetController {
        private var _enableOnStart:Boolean;

		public function ScrubberController() {
			super();
		}
	
		override public function get name():String {
			return "scrubber";
		}
	
		override public function get defaults():Object {
			return {
				tooltipEnabled: true,
				visible: true,
				enabled: true
			};
		}
	
		override protected function createWidget():void {
			log.debug("Creating scrubber with ", _config)
			_widget = new ScrubberSlider(_config as ScrubberConfig, _player, _controlbar);
            //#443 disabling tabbing for accessibility options
            setInaccessible(_widget);
//            enableScrubber(true);
        }

		override protected function createDecorator():void {
			_decoratedView = new WidgetDecorator(SkinClasses.getDisplayObject("fp.ScrubberTopEdge"),
										 	 	 SkinClasses.getDisplayObject("fp.ScrubberRightEdge"),
												 SkinClasses.getDisplayObject("fp.ScrubberBottomEdge"),
												 SkinClasses.getDisplayObject("fp.ScrubberLeftEdge"), true).init(_widget);
		}

		override protected function onTimeUpdate(event:TimerEvent):void {
            var status:Status = getPlayerStatus();
            if (! status) return;

            var duration:Number = status.clip ? status.clip.duration : 0;
			var scrubber:ScrubberSlider = (_widget as ScrubberSlider);
			if (duration > 0) {
				scrubber.value = (status.time / duration) * 100;
				scrubber.setBufferRange(status.bufferStart / duration, status.bufferEnd / duration);
				scrubber.allowRandomSeek = status.allowRandomSeek;
			} else {
				scrubber.value = 0;
				scrubber.setBufferRange(0, 0);
				scrubber.allowRandomSeek = false;
			}
			if (status.clip) {
				scrubber.tooltipTextFunc = function(percentage:Number):String {
					if (duration == 0) return null;
					if (percentage < 0) {
						percentage = 0;
					}
					if (percentage > 100) {
						percentage = 100;
					}
					return TimeUtil.formatSeconds(percentage / 100 * duration);
				};
			}
        }

		override protected function onPlayStarted(event:ClipEvent):void {
			super.onPlayStarted(event);
            log.info("received " + event + ", time " + _player.status.time);
			if (_player.status.time < 0.5) {
                if (_enableOnStart) {
                    enableScrubber(true);
                    _enableOnStart = false;
                }
			}
		}

		
		override protected function onPlayPaused(event:ClipEvent):void {
			super.onPlayPaused(event);
            log.info("received " + event + ", time " + _player.status.time);
			var clip:Clip = event.target as Clip;
			log.info("clip.seekableOnBegin: " + clip.seekableOnBegin);
			if (_player.status.time == 0 && ! clip.seekableOnBegin) {
                if (_widget.enabled) {
                    enableScrubber(false);
                    _enableOnStart = true;
                }
            }
        }

        override protected function onPlayResumed(event:ClipEvent):void {
			super.onPlayResumed(event);

            //#42 when returning and resuming from an instream clip, restart the time update timer.
            if (!_timeUpdateTimer.running) _timeUpdateTimer.start();

            log.info("received " + event + ", time " + _player.status.time);
			if (_player.status.time < 0.5) {
                if (_enableOnStart) {
                    enableScrubber(true);
                    _enableOnStart = false;
                }
			}
        }

		private function enableScrubber(enabled:Boolean):void {
            log.debug("enableScrubber() setting scrubber enabled " + enabled);
            if (!_widget) return;

			_widget.enabled = enabled;

		//	log.error("Enabling scrubber :", enabled);

			if (enabled) {
				_widget.addEventListener(ScrubberSlider.DRAG_EVENT, onScrubbed);
			} else {
				_widget.removeEventListener(ScrubberSlider.DRAG_EVENT, onScrubbed);
			}
		}
		

		private function onScrubbed(event:Event):void {
            log.debug("onScrubbed() " + ScrubberSlider(event.target).value);
			_player.seekRelative(ScrubberSlider(event.target).value);
		}


	}
}

