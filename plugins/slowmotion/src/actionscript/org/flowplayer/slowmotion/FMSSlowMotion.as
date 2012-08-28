/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.slowmotion {
    import flash.events.NetStatusEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import flash.utils.clearInterval;
    import flash.utils.setInterval;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.TimeProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginModel;

    public class FMSSlowMotion extends AbstractSlowMotion {
        private static var FASTPLAY_STEP_INTERVAL:int = 100;  // == 10 FPS
        private var _stepTimer:Timer;
        private var _frameStep:Number;
        private var _clipFPS:int;
        private var _info:SlowMotionInfo;
        private var _playlist:Playlist;
        private var _maxPauseBuffer:Number;
        private var _isPaused:Boolean;

        public function FMSSlowMotion(model:PluginModel, playlist:Playlist, provider:StreamProvider, providerName:String) {
            super(model, playlist, provider, providerName);
            _playlist = playlist;

            playlist.onPause(onPause, slowMotionClipFilter);
            playlist.onResume(onResume, slowMotionClipFilter);

            playlist.onBeforeStop(onFinish, slowMotionClipFilter);
            playlist.onBeforeFinish(onFinish, slowMotionClipFilter);
        }

        private function onFinish(clip:ClipEvent):void {
            if (_info && _info.isTrickPlay) {
                log.debug("stopping step timer");
                _stepTimer.stop();
            }
        }

        private function onPause(event:ClipEvent):void {
            if (! _stepTimer) return;
            _stepTimer.stop();
        }

        private function onResume(event:ClipEvent):void {
            log.debug("onResume()");
            if (! _stepTimer) return;
            if (_info.isTrickPlay) {
                log.debug("onResume(), resuming trick play");
                netStream.pause();
                _stepTimer.start();
            }
        }

        private function stopTimer():void {
            if (_stepTimer) {
                _stepTimer.stop();
                _stepTimer.removeEventListener(TimerEvent.TIMER, onStepTimer);
                _stepTimer = null;
            }
        }

        private function startTimer(interval:int):void {
            stopTimer();
            _stepTimer = new Timer(interval);
            _stepTimer.addEventListener(TimerEvent.TIMER, onStepTimer);
            _stepTimer.start();
            log.debug("timer started with interval " + interval);
        }

        override protected function onStart(event:ClipEvent):void {
            log.debug("onStart");
            var clip:Clip = Clip(event.target);
            _clipFPS = clip.metaData ? clip.metaData.framerate : 0;
            log.debug("frameRate from metadata == " + _clipFPS);
            netStream.inBufferSeek = true;

            netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        }

        override protected function normalSpeed():void {
            log.info("normalSpeed()");
            stopTimer();
            if (netStream) {
                netStream.maxPauseBufferTime = _maxPauseBuffer;
                netStream.resume();
                _isPaused = false;
            }
            _info = SlowMotionInfo.createForNormalSpeed(_playlist.current);
        }

        override protected function trickSpeed(multiplier:Number, forward:Boolean):void {
            log.info("trickSpeed() multiplier == " + multiplier + ", " + (forward ? "forward" : "backward"));

            if (!_isPaused) {
                _isPaused = true;
                netStream.pause();
            }

            //#598 fill a large pause buffer length
            _maxPauseBuffer = netStream.maxPauseBufferTime;
            netStream.maxPauseBufferTime = 3600;

            if (netStream.currentFPS > 0 && netStream.currentFPS > _clipFPS) {
                _clipFPS = netStream.currentFPS;
            }
            log.debug("current FPS = " + netStream.currentFPS + ", stored value " + _clipFPS);

            if (multiplier < 1) {
                startSlowMotion(multiplier, forward);
            } else {
                startFastPlay(multiplier, forward);
            }
            _info = new SlowMotionInfo(_playlist.current, true, forward, 0, multiplier);
        }

        private function startFastPlay(multiplier:Number, forward:Boolean):void {
            var targetFps:int = _clipFPS * multiplier;

            _frameStep = Math.round(targetFps / (1000 / FASTPLAY_STEP_INTERVAL));
            _frameStep = forward ? _frameStep : - _frameStep;

            log.debug("startFastPlay(), frame step is " + _frameStep + ", " + (forward ? "forward" : "backward"));
            startTimer(FASTPLAY_STEP_INTERVAL);
        }

        private function startSlowMotion(multiplier:Number, forward:Boolean):void {
            startTimer(1000 / (_clipFPS * multiplier));
            _frameStep = forward ? 1 : -1;
            log.debug("startSlowMotion(), frame step is " + _frameStep);
        }

        private function onStepTimer(event:TimerEvent):void {
            if (! netStream) return;

            //#598 if the stepping is too close to the buffer slow it down for it to catch up.
            if (netStream.bufferLength < 0.1 || netStream.backBufferLength < 0.1)
			{
               log.debug("Stepping too close to the buffer stepping 1 frame");
               netStream.step(1);
               return;
			}

            netStream.step(_frameStep);
        }

        override public function getInfo(event:NetStatusEvent):SlowMotionInfo {
            return _info;
        }

        /**
         * #598 Return to normal playback if stepping FMS servers fail due to passing the buffer regions.
         * @param event
         */
        private function onNetStatus(event:NetStatusEvent):void
        {
            switch (event.info.code) {
                case "NetStream.InvalidArg":
                    log.error("Problem stepping frames possibly outside the buffer, setting to normal speed");
                    normalSpeed();
                break;
            }
        }
    }
}
