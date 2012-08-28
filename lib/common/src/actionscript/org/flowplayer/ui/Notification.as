/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.ui {
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    /**
     * Base class for notifications that are shown in the Panel. Supports hiding after a specified delay.
     *
     * Provides factory methods for creating text field based notifications and display object notifications.
     * Display object notifications can be used to show a display object in the player's panel.
     */
    public class Notification extends StyleableSprite {
        protected var _player:Flowplayer;

        private var _hideTimer:Timer;

        public function Notification(player:Flowplayer) {
            _player = player;
            addClickListener();
        }

        public static function createTextNotification(player:Flowplayer, message:String):Notification {
            return new TextNotification(player, message);
        }

        public static function createDisplayObjectNotification(player:Flowplayer, view:DisplayObject):Notification {
            return new DisplayObjectNotification(player, view);
        }

        private function addClickListener():void {
            addEventListener(MouseEvent.CLICK, createClickListener(_player, this));
        }

        private function createClickListener(player:Flowplayer, disp:DisplayObject):Function {
            return function(event:MouseEvent):void {
                log.debug("hiding Notification");
                player.animationEngine.cancel(disp);
                if (_hideTimer && _hideTimer.running) {
                    _hideTimer.stop();
                }
                player.animationEngine.fadeOut(disp, 500, function():void {
                    disp.parent.removeChild(disp);
                });
            };
        }

        /**
         * Shows the notification.
         * @param displayProperties if null, shows up using defaults
         * @return
         */
        public function show(displayProperties:Object = null):Notification {
            log.debug("show(), width: " + this.width);
            this.alpha = 0;
            // set zIndex to a large value so that it displays on top of everything else
            _player.addToPanel(this, displayProperties || { left: '50pct', top: '50pct', zIndex: 1000 });
            _player.animationEngine.fadeIn(this);
            return this;
        }

        public function autoHide(hideDelay:int = 5000, onHiddenCallback:Function = null):Notification {
            createHideTimer(hideDelay, onHiddenCallback);
            return this;
        }

        private function createHideTimer(delay:int, onHiddenCallback:Function = null):void {
            _hideTimer = new Timer(delay, 1);
            _hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, createTimerCompleteListener(_player, this, onHiddenCallback));
            _hideTimer.start();
        }

        private function createTimerCompleteListener(player:Flowplayer, disp:DisplayObject, onHiddenCallback:Function):Function {
            return function(event:TimerEvent):void {
                log.debug("hiding Notification");
                player.animationEngine.fadeOut(disp, 800,
                        function():void {
                            disp.parent.removeChild(disp);
                            if (onHiddenCallback != null) {
                                onHiddenCallback();
                            }
                        });
            };
        }
    }
}
