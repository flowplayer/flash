/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.slowmotion {
    import flash.net.NetStream;
    import flash.utils.Dictionary;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.Loader;

    import org.flowplayer.controller.TimeProvider;
    import org.flowplayer.layout.LayoutEvent;

	import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;
	import org.flowplayer.util.PropertyBinder;

	import org.flowplayer.ui.containers.WidgetContainer;
	import org.flowplayer.ui.containers.WidgetContainerEvent;

	import org.flowplayer.ui.controllers.GenericButtonController;

	import fp.*;

    public class AbstractSlowMotion implements TimeProvider {
        protected var log:Log = new Log(this);
        private var _provider:StreamProvider;
        private var _currentInfo:SlowMotionInfo;
        private var _model:PluginModel;
        private var _playlist:Playlist;
        private var _providerName:String;

        public function AbstractSlowMotion(model:PluginModel, playlist:Playlist, provider:StreamProvider, providerName:String) {
            _model = model;
            _playlist = playlist;
            _provider = provider;
            _providerName = providerName;

            playlist.onStart(_onStart, slowMotionClipFilter);
            reset();
        }

        protected function slowMotionClipFilter(clip:Clip):Boolean { return clip.provider == _providerName; };

        public function getTimeProvider():TimeProvider {
            return null;
        }

        public final function normal():void {
            normalSpeed();
        }

        protected function normalSpeed():void {
            // should be overridden in subclasses
        }

        public final function trickPlay(multiplier:Number, forward:Boolean):void {
            trickSpeed(multiplier, forward);
        }

        protected function trickSpeed(multiplier:Number, forward:Boolean):void {
            // should be overridden in subclasses
        }

        protected function get netStream():NetStream {
            return _provider.netStream;
        }

        protected function get provider():StreamProvider {
            return _provider;
        }

        protected function get time():Number {
            return getTime(netStream);
        }

        public function getInfo(event:NetStatusEvent):SlowMotionInfo {
            // should be overridden in subclasses
            return null;
        }

        public function getTime(netStream:NetStream):Number {
            var time:Number = _provider.netStream.time;
            if (! _currentInfo) return time;
            if (_currentInfo.isTrickPlay) {
                return _currentInfo.adjustedTime(time);
            }

            return time;
        }

        public function get info():SlowMotionInfo {
            return _currentInfo;
        }

		private function reset():void {
            log.debug("reset()");
			_currentInfo = new SlowMotionInfo(_playlist.current, false, true, 0, 1);
		}

        private function _onStart(event:ClipEvent):void {
            onStart(event);
            log.debug("AbstractSlowMotion._onStart(), netStream: " + netStream);
//			reset(event);
            netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);

            if (_currentInfo && _currentInfo.isTrickPlay) {
                // previous clip was ended in trickPlay. start this one in trickPlay too
                log.debug("AbstractSlowMotion._onStart(), starting trick play");
                trickSpeed(_currentInfo.speedMultiplier, _currentInfo.forwardDirection);
            }
        }

        /**
         * Called at the beginning of handling the onStart event.
         * @param event
         */
        protected function onStart(event:ClipEvent):void {
            // can be overridden in subclasses
        }

        private function onNetStatus(event:NetStatusEvent):void {
            logNetStatus(event);

            var info:SlowMotionInfo = getInfo(event);

            if (info) {
                if (info.equals(_currentInfo)) {
//                    log.debug("onNetStatus(), status did not change, will not dispatch 'onTrickPlay'");
                    return;
                }
                _currentInfo = info;
                log.info("dispatching PluginEvent 'onTrickPlay', trickPlay == " + info.isTrickPlay);
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onTrickPlay", _currentInfo);

            }
        }

        private function logNetStatus(event:NetStatusEvent):void {
            log.debug("onNetStatus(): ");
            for (var propName:String in event.info) {
                log.debug("  " + propName + " = " + event.info[propName]);
            }
        }

        protected function get playlist():Playlist {
            return _playlist;
        }

        protected function isTrickPlay():Boolean {
            return _currentInfo && _currentInfo.isTrickPlay;
        }
    }
}