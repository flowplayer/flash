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
    import flash.display.Stage;
    import flash.display.StageDisplayState;
    import flash.events.Event;
    import flash.events.FullScreenEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.util.Assert;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    /**
     * @author api
     */
    public class AutoHide {

        private var log:Log = new Log(this);
        private var _disp:DisplayObject;
        private var _hideTimer:Timer;
        private var _mouseOutTimer:Timer;
        private var _stage:Stage;
        private var _playList:Playlist;
        private var _config:AutoHideConfig;
        private var _player:Flowplayer;
        private var _originalPos:Object;
        private var _mouseOver:Boolean = false;
        private var _model:DisplayPluginModel;
        private var _hideListener:Function;
        private var _showListener:Function;

        public function AutoHide(model:DisplayPluginModel, config:AutoHideConfig, player:Flowplayer, stage:Stage, displayObject:DisplayObject) {
            //            Assert.notNull(model, "model cannot be null");
            Assert.notNull(config, "config cannot be null");
            Assert.notNull(player, "player cannot be null");
            Assert.notNull(stage, "stage cannot be null");
            Assert.notNull(displayObject, "displayObject cannot be null");
            _model = model;
            _config = config;
            _playList = player.playlist;
            _player = player;
            _stage = stage;
            _disp = displayObject;

            updateDisplayProperties();


            if (_config.state != "fullscreen" && config.enabled) {
                startTimerAndInitializeListeners();
            }
            _stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
        }

        /**
         * #624 Update the original display properties if these have changed.
         */
        public function updateDisplayProperties():void
        {
            _originalPos = getDisplayProperties();
        }

        /**
         * Adds a hide listener function.
         * @param hideListener the listener callback function. If this returns false the hiding is prevented.
         */
        public function onHide(hideListener:Function):void {
            _hideListener = hideListener;
        }

        /**
         * Adds a show lisenerer function.
         * @param showListener the listener callback function. If this returns false showing is prevented.
         */
        public function onShow(showListener:Function):void {
            _showListener = showListener;
        }

        /**
         * Stops the timed autohiding leaving the display object either visible or hidden.
         * @param leaveVisible
         */
        public function stop(leaveVisible:Boolean = true):void {
            log.debug("stop(), leaveVisible? " + leaveVisible);
            if (leaveVisible) {
                doShow();
            }
            if (! leaveVisible) {
                hide(null, true);
            }
            stopHideTimer();
            stopMouseOutTimer();
            _stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
            _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            _stage.removeEventListener(Event.RESIZE, onStageResize);
            _stage.removeEventListener(Event.MOUSE_LEAVE, startMouseOutTimer);
            _disp.removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
            _disp.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
        }

        /**
         * Brings the display object visible and starts the autohiding timer.
         */
        public function start():void {
            doShow();
            log.debug("start(), autoHide is " + _config.state);
            if (_config.state == 'fullscreen') {

                fullscreenStart();
                return;
            }
            if (_config.state == "always") {
                startTimerAndInitializeListeners();
                return;
            }
        }

        /**
         * Cancel the current animation that has been started by this autohide (if any).
         */
        public function cancelAnimation():void {
            log.debug("cancelAnimation");
            _player.animationEngine.cancel(_disp);
        }

        /**
         * Brings the display object visible. If an animation is in progress, it's canceled.
         */
        public function show():void {
            cancelAnimation();
            doShow();
        }

        /**
         * Hides the display object.
         * @param event
         * @param ignoreMouseOver
         */
        public function hide(event:TimerEvent = null, ignoreMouseOver:Boolean = false):void {
            if (! isShowing())
            {
                if (_hideTimer) {
                    _hideTimer.stop();
                }
                return;
            }

            log.warn("HIDING ? " + (ignoreMouseOver ? 'true ' : 'false ') + (_mouseOver ? 'true ' : 'false '))
            if (! ignoreMouseOver && _mouseOver) return;

            log.debug("dispatching onBeforeHidden");
            if (_model && ! _model.dispatchBeforeEvent(PluginEventType.PLUGIN_EVENT, "onBeforeHidden")) {
                log.debug("hide() onHidden event was prevented, not hiding");
                return;
            }

            if (_hideListener != null && ! _hideListener()) {
                log.debug("hideListener callback function prevented hiding");
                return;
            }

            log.debug("animating to hidden position");

            //#426 use fadeIn/fadeOut for fade mode to improve animation engine performance as only alpha is required.
            if (useFadeOut)
                _player.animationEngine.fadeOut(_disp, _config.hideDuration, onHidden);
            else
                _player.animationEngine.animate(_disp, hiddenPos, _config.hideDuration, onHidden);

            if (_hideTimer) {
                _hideTimer.stop();
            }
        }

        private function getDisplayProperties():Object {
            if (_model && _model.getDisplayObject() == _disp) {
                return DisplayProperties(_player.pluginRegistry.getPlugin(_model.name)).clone() as DisplayProperties;
            } else {
                return { top: _disp.y, left: _disp.x, width: _disp.width, height: _disp.height, alpha: _disp.alpha };
            }
        }

        private function clone(obj:Object):Object {
            if (obj is DisplayProperties) {
                return obj.clone() as DisplayProperties;
            } else {
                var clone:Object = {};
                for (var prop:String in obj) {
                    clone[prop] = obj[prop];
                }
                return clone;
            }
        }

        private function get showingPos():Object {
            //#426 only set these for the move style.
            var showingProps:Object = getDisplayProperties();
            if (_originalPos is DisplayProperties) {
                if (_originalPos.position.top.hasValue()) {
                    log.debug("restoring to top " + _originalPos.position.top);
                    showingProps.top = _originalPos.position.top;
                }
                if (_originalPos.position.bottom.hasValue()) {
                    log.debug("restoring to bottom " + _originalPos.position.bottom);
                    showingProps.bottom = _originalPos.position.bottom;
                }
            } else {
                log.debug("restoring to y " + _originalPos.y);
                showingProps.y = _originalPos.y;
            }
            showingProps.alpha = _originalPos.alpha;
            log.debug("showing alpha " + showingProps.alpha);
            return showingProps;
        }

        private function get hiddenPos():Object {
            //#426 only set these for the move style.
            var hiddenPos:Object = getDisplayProperties();
            hiddenPos.top = getHiddenPosition();
            return hiddenPos;
        }

        private function onFullScreen(event:FullScreenEvent):void {
            if (event.fullScreen) {
                startTimerAndInitializeListeners();
                show();
            } else {
                if (_config.state != 'always') {
                    stop();
                }
                _disp.alpha = 0;
                cancelAnimation();
                show();
            }
        }

        private function fullscreenStart():void {
            if (isInFullscreen()) {
                startTimerAndInitializeListeners();
            } else {
                stopHideTimer();
                stopMouseOutTimer();
                _stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
            }
        }

        private function startTimerAndInitializeListeners():void {
            startHideTimer();
            _stage.addEventListener(Event.MOUSE_LEAVE, startMouseOutTimer);
            _stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
            _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            _stage.addEventListener(Event.RESIZE, onStageResize);
            _disp.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
            _disp.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
        }

        private function onMouseOver(event:MouseEvent):void {
            //log.warn("MOUSE OVER");
            _mouseOver = true;
        }

        private function onMouseOut(event:MouseEvent):void {
            //log.warn("MOUSE OUT");
            _mouseOver = false;
        }


        private function mouseLeave(event:Event = null):void {
            _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

            stopHideTimer();
            stopMouseOutTimer();
            cancelAnimation();

            hide();
            //stop();
        }


        private function startMouseOutTimer(event:Event = null):void {
            log.debug("startMouseOutTimer(), delay is " + _config.mouseOutDelay);
            if (_config.mouseOutDelay == 0) {
                mouseLeave();
                return;
            }
            if (! _mouseOutTimer) {
                _mouseOutTimer = new Timer(_config.mouseOutDelay);
            }
            // check if hideDelay has changed
            else if (_config.mouseOutDelay != _mouseOutTimer.delay) {
                log.debug("startMouseOutTimer(), using new delay " + _config.mouseOutDelay);
                _mouseOutTimer.stop();
                _mouseOutTimer = new Timer(_config.mouseOutDelay);
            }

            _mouseOutTimer.addEventListener(TimerEvent.TIMER, mouseLeave);
            _mouseOutTimer.start();
        }

        private function stopMouseOutTimer():void {
            if (! _mouseOutTimer) return;
            _mouseOutTimer.stop();
            _mouseOutTimer = null;
        }


        private function onMouseMove(event:MouseEvent):void {
            //#405 move showing check to the beginning to prevent multiple event bubbling / system performance and frame dropping issues.
            if (isShowing() && _hideTimer) {
                //                log.debug("onMouseMove(): already showing");
                _hideTimer.stop();
                _hideTimer.start();
                return;
            }

            _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            cancelAnimation();
            doShow();

        }

        private function isShowing():Boolean {
            return _disp.alpha > 0 && _disp.y < getHiddenPosition();
        }

        private function onStageResize(event:Event):void {
            if (! _hideTimer) return;
            _hideTimer.stop();
            _hideTimer.start();
        }

        private function startHideTimer():void {
            //            log.info("startHideTimer(), delay is " + _config.hideDelay);
            if (_config.hideDelay == 0) {
                hide();
                return;
            }
            if (! _hideTimer) {
                _hideTimer = new Timer(_config.hideDelay);
            }
            // check if hideDelay has changed
            else if (_config.hideDelay != _hideTimer.delay) {
                //                log.info("startHideTimer(), using new delay " + _config.hideDelay);
                _hideTimer.stop();
                _hideTimer = new Timer(_config.hideDelay);
            }

            _hideTimer.addEventListener(TimerEvent.TIMER, hide);
            _hideTimer.start();
        }

        private function stopHideTimer():void {
            if (! _hideTimer) return;
            _hideTimer.stop();
            _hideTimer = null;
        }

        private function isInFullscreen():Boolean {
            return _stage.displayState == StageDisplayState.FULL_SCREEN;
        }

        private function onHidden():void {
            log.debug("onHidden()");
            dispatchEvent("onHidden");
        }

        private function doShow():void {
            if (_config.state == "never") {
                return;
            }

            var showPos:Object = showingPos;
            if (showPos.display == "none") {
                log.debug("display is 'none', will not show this!");
                return;
            }

            if (_model && ! _model.dispatchBeforeEvent(PluginEventType.PLUGIN_EVENT, "onBeforeShowed")) {
                log.debug("doShow() onShowed event was prevented, not showing");
                return;
            }

            if (_showListener != null && ! _showListener()) {
                log.debug("showListener returned false, will not show");
                return;
            }

            //#426 use fadeIn/fadeOut for fade mode to improve animation engine performance as only alpha is required.
            if (useFadeOut)
                _player.animationEngine.fadeTo(_disp, showingPos.alpha, 400, onShowed);
            else
                _player.animationEngine.animate(_disp, showingPos, 400, onShowed);
        }


        private function dispatchEvent(string:String):void {
            if (! _model) return;
            _model.dispatch(PluginEventType.PLUGIN_EVENT, string);
        }

        private function onShowed():void {
            dispatchEvent("onShowed");
            _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

            if (_config.state == "fullscreen") {
                fullscreenStart();
            }
            if (_config.state == "always") {
                startTimerAndInitializeListeners();
            }
        }

        private function get useFadeOut():Boolean {
            if (_config.hideStyle == "fade") return true;
            // always use fading when using accelerated fullscreen
            return isInFullscreen() && _stage.hasOwnProperty("fullScreenSourceRect") && _stage.fullScreenSourceRect != null;
        }

        private function getHiddenPosition():Object {
            if (_stage.displayState == StageDisplayState.FULL_SCREEN && _stage.hasOwnProperty("fullScreenSourceRect")) {
                var rect:Rectangle = _stage.fullScreenSourceRect;
                if (rect) {
                    return rect.height;
                }
            }
            return _stage.stageHeight;
        }
    }
}
