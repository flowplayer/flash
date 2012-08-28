/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.scrubber {
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.*;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controls.buttons.AbstractSlider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.ClipEventType;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginEvent;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.Status;
    import org.flowplayer.util.GraphicsUtil;
    import org.flowplayer.view.Flowplayer;

    /**
	 * @author api
	 */
	public class ScrubberSlider extends AbstractSlider {
		
		public static const DRAG_EVENT:String = AbstractSlider.DRAG_EVENT;
		
		protected static const DRAG_THRESHOLD:int = 10;
		
		private var _bufferEnd:Number;
		private var _bufferBar:Sprite;
		private var _allowRandomSeek:Boolean;
		private var _seekInProgress:Boolean;
		private var _progressBar:Sprite;
		private var _bufferStart:Number;
		private var _enabled:Boolean = true;
        private var _startDetectTimer:Timer;
        private var _trickPlayTrackTimer:Timer;
        private var _slowMotionInfo:Object;
		private var _currentClip:Clip;
        private var _isSeekPaused:Boolean;
        private var _isRtmp:Boolean;

        public function ScrubberSlider(config:ScrubberConfig, player:Flowplayer, controlbar:DisplayObject) {
            super(config, player, controlbar);
            lookupPluginAndBindEvent(_player, "slowmotion", onSlowMotionEvent);
            lookupPluginAndBindEvent(_player, "audio", onAudioEvent);
            createBars();
            addPlaylistListeners(_player.playlist);
        }

        private function lookupPluginAndBindEvent(player:Flowplayer, pluginName:String, eventHandler:Function):void {
            var plugin:PluginModel = player.pluginRegistry.getPlugin(pluginName) as PluginModel;
            if (plugin) {
                log.debug("found plugin " +plugin);
                plugin.onPluginEvent(eventHandler);
            }
        }

        public function addPlaylistListeners(playlist:Playlist):void {

            playlist.onBeforeBegin(function(event:ClipEvent):void {
                _currentClip = event.target as Clip;
                detectProvider();
            });

            playlist.onBegin(function(event:ClipEvent):void {
                _currentClip = event.target as Clip;
            });
            playlist.onResume(function(event:ClipEvent):void {
                _currentClip = event.target as Clip;
            });

            // onBegin instead of onStart: http://code.google.com/p/flowplayer-core/issues/detail?id=190
            playlist.onBegin(start);

            //#404 stop/start dragger animation when switching to update correctly.
            playlist.onSwitch(resume);

            playlist.onResume(resume);

            playlist.onPause(stop);

            // possible fix for #175 danielr
            //calls animationEngine.pause and animationEngine.resume during rebuffering
            playlist.onBufferEmpty(bufferEmpty);
            playlist.onBufferFull(bufferFull);

            playlist.onStop(stopAndRewind);
            playlist.onFinish(stopAndRewind);
            
            playlist.onBeforeSeek(onBeforeSeek);
            playlist.onSeek(onSeek);
        }

        private function detectProvider():void {
            if (! _currentClip.provider) return;
            var model:PluginModel = PluginModel(_player.pluginRegistry.getPlugin(_currentClip.provider));
            if (! model) return;
            var plugin:StreamProvider = StreamProvider(model.pluginObject);
            _isRtmp = plugin.type == "rtmp";
        }

        private function onSlowMotionEvent(event:PluginEvent):void {
            log.debug("onSlowMotionEvent()");
            _slowMotionInfo = event.info2;
            stop(null);

            if (! isTrickPlay) {
                stopTrickPlayTracking();
                doStart(_slowMotionInfo["clip"], adjustedTime(_player.status.time));

            } else {
                startTrickPlayTracking();
            }
        }

        private function onAudioEvent(event:PluginEvent):void {
            log.debug("onAudioEvent()");
            stop(null);
            doStart(_player.playlist.current);

        }

        private function stopTrickPlayTracking():void {
            log.debug("stopTrickPlayTracking()");
            if (_trickPlayTrackTimer) {
                _trickPlayTrackTimer.stop();
            }
        }

        private function startTrickPlayTracking():void {
            log.debug("startTrickPlayTracking()");
            if (_trickPlayTrackTimer) {
                _trickPlayTrackTimer.stop();
            }
            _trickPlayTrackTimer = new Timer(200);
            _trickPlayTrackTimer.addEventListener(TimerEvent.TIMER, onTrickPlayProgress);
            _trickPlayTrackTimer.start();
        }

        private function onTrickPlayProgress(event:TimerEvent):void {
            updateDraggerPos(_player.status.time, _slowMotionInfo["clip"] as Clip);
        }

		protected override function onResize():void {
			super.onResize();

			doDrawBufferBar(0, 0);
			drawProgressBar(0, 0);

			if ( _currentClip )
			{
				stop(null);
				updateDraggerPos(_player.status.time, _currentClip);
				doStart(_currentClip, _player.status.time);
			}

        }

        private function updateDraggerPos(time:Number, clip:Clip):void {
            //#390 regression issue with updating with maxDrag inside a buffer use full scrubbar dimensions as boundary is contained elsewhere.
            //using bitwise operation here instead of Math.min.
            var bounds:int = (width - _dragger.width);
            var pos:int = (time / clip.duration) * bounds;
            _dragger.x =  pos > bounds ? bounds :pos;
        }

        private function onBeforeSeek(event:ClipEvent):void {
            log.debug("onBeforeSeek()");

            if (event.isDefaultPrevented() ) {
				log.debug("Default prevented ");
                if (_isSeekPaused) {
                    enableDragging(false);
                }
                stop(null);
                updateDraggerPos(_player.status.time, event.target as Clip);
                doStart(event.target as Clip, _player.status.time);
                return;
			}

            if (! isDragging) {
                updateDraggerPos(event.info as Number, event.target as Clip);
            }
            _seekInProgress = true;
            stop(null);
        }

        private function onSeek(event:ClipEvent):void {
            log.debug("onSeek(), isPlaying: " + _player.isPlaying() + ", seek target time is " + event.info);
            if (event.info == null) return;

            _seekInProgress = false;
            stop();
			drawBufferBar();
			
            if (! _player.isPlaying()) return;
			
			_currentClip = (event.target as Clip);
            doStart(_currentClip, event.info as Number);
        }

        private function start(event:ClipEvent):void {
			_currentClip = (event.target as Clip);
            log.debug("start() " + _currentClip);
            if (_currentClip.duration == 0 && _currentClip.type == ClipType.IMAGE) return;
            enableDragging(true);
            doStart(_currentClip);
        }

        private function resume(event:ClipEvent):void {
            log.debug("resume() " + event.target);
			_currentClip = (event.target as Clip);
			stop(null);
            doStart(_currentClip);
        }

        private function doStart(clip:Clip, startTime:Number = 0):void {
            log.debug("doStart() " + clip);
            if (isTrickPlay) {
                log.debug("doStart(), trickplay in progress, returning");
                return;
            }

            if (_seekInProgress) {
                log.debug("doStart(), seek in progress, returning");
                return;
            }

            if (! _player.isPlaying()) {
                log.debug("doStart(), not playing, returning");
                return;
            }
            if (_startDetectTimer && _startDetectTimer.running) {
                log.debug("doStart(), not playing, returning");
                return;
            }
            if (animationEngine.hasAnimationRunning(_dragger)) {
                log.debug("doStart(), animation already running, returning");
                return;
            }

            var status:Status = _player.status;
            var time:Number = startTime > 0 ? startTime : status.time;

            _startDetectTimer = new Timer(200);
            _startDetectTimer.addEventListener(TimerEvent.TIMER,
                    function(event:TimerEvent):void {
                        var currentTime:Number = _player.status.time;
                        log.debug("on startDetectTimer() currentTime " + currentTime + ", time " + time);

                        if (Math.abs(currentTime - time) > 0.2) {
                            _startDetectTimer.stop();
                            var endPos:Number = width - _dragger.width;
							log.debug("animation duration is " + clip.duration + " - "+ time + " * 1000");
							// var duration:Number = (clip.duration - time) * 1000;  
                            var duration:Number = (clip.duration - currentTime) * 1000;

                            updateDraggerPos(currentTime, clip);
                            log.debug("doStart(), starting an animation to x pos " + endPos + ", the duration is " + duration + ", current pos is " + _dragger.x + ", time is "+ currentTime);

                            animationEngine.animateProperty(_dragger, "x", endPos, duration, null,
                                    function():void {
                                        drawProgressBar(_bufferStart * width);
                                    },
                                    function(t:Number, b:Number, c:Number, d:Number):Number {
                                        return c * t / d + b;
                                    });
                        } else {
                            log.debug("not started yet, currentTime " + currentTime + ", time " + time);
                        }
                    });
            log.debug("doStart(), starting timer");
            _startDetectTimer.start();
        }

        private function adjustedTime(time:Number):Number {
            if (! _slowMotionInfo) return time;
            if (_slowMotionInfo) {
                log.debug("adjustedTime: " + _slowMotionInfo["adjustedTime"](time));
                return _slowMotionInfo["adjustedTime"](time);
            }
            return time;
        }

        private function get isTrickPlay():Boolean {
            return _slowMotionInfo && _slowMotionInfo["isTrickPlay"]; 
        }

        private function stop(event:ClipEvent = null):void {
            log.debug("stop()");
            if (_startDetectTimer) {
                _startDetectTimer.stop();
            }
            animationEngine.cancel(_dragger);
        }
        
        private function bufferEmpty(event:ClipEvent):void {
            log.debug("bufferEmpty()");
            animationEngine.pause(_dragger);
        }
        
        private function bufferFull(event:ClipEvent):void {
            log.debug("bufferFull()");
            animationEngine.resume(_dragger);
        }

        private function stopAndRewind(event:ClipEvent):void {
            var clip:Clip = event.target as Clip;
            log.debug("stopAndRewind() " + clip);

            stop(event);
            if (clip.isMidroll) {
                log.debug("midroll stopped, not rewinding to beginning");
                return;
            }
            _dragger.x = 0;
            clearBar(_progressBar);
        }

		override protected function get dispatchOnDrag():Boolean {
			return false;
		}

		override protected function getClickTargets(enabled:Boolean):Array {
			_enabled = enabled;
			var targets:Array = [_bufferBar, _progressBar];
			if (! enabled || _allowRandomSeek) {
				targets.push(this);
			}
			return targets;
		}
		
		override protected function isToolTipEnabled():Boolean {			
			return _config.draggerButtonConfig.tooltipEnabled;
		}

		private function doDrawBufferBar(leftEdge:Number, rightEdge:Number):void {
			drawBar(_bufferBar, (_config as ScrubberConfig).bufferColor, (_config as ScrubberConfig).bufferAlpha, (_config as ScrubberConfig).bufferGradient, leftEdge, rightEdge);
		}
		
		private function drawProgressBar(leftEdge:Number, rightEdge:Number = 0):void {
            if (_isRtmp) {
                clearBar(_progressBar);
                return;
            }
			drawBar(_progressBar, _config.color, _config.alpha, _config.gradient, leftEdge || 0, rightEdge || _dragger.x + _dragger.width - 2);
		}

		

		private function createBars():void {
			_progressBar = new Sprite();
			addChild(_progressBar);
			
			_bufferBar = new Sprite();
			addChild(_bufferBar);
			swapChildren(_dragger, _bufferBar);
		}


		public function set allowRandomSeek(value:Boolean):void {
			//log.error("set allowRandomSeek", value);
			_allowRandomSeek = value;
			if (_enabled) {
				if (value) {
					addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				} else {
					removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				buttonMode = _allowRandomSeek;
			}
		}

		override protected function get maxDrag():Number {
			if (_allowRandomSeek) return width - _dragger.width;
			//log.debug("maxDrag = "+ _bufferEnd + " * ("+ width + " - "+ _dragger.width +")  = "+ (_bufferEnd * (width - _dragger.width)));
			return _bufferEnd * (width - _dragger.width);
		}

		public function setBufferRange(start:Number, end:Number):void {
			_bufferStart = start;
			_bufferEnd = Math.min(end, 1);
			drawBufferBar();
		}
		
		override protected function canDragTo(xPos:Number):Boolean {
			//log.error("canDragTo ", _allowRandomSeek);
			if (_allowRandomSeek) return true;			
			return (xPos < _bufferBar.x + _bufferBar.width + DRAG_THRESHOLD ) && (xPos > 0 - DRAG_THRESHOLD);
		}

        override protected function onMouseDown(event:MouseEvent):void {
            log.debug("onMouseDown()");
            if (_player.isPlaying()) {
                _player.pause(true);
                _isSeekPaused = true;
            }
        }

		override protected function onMouseUp(event:MouseEvent):void {
            log.debug("onMouseUp()");

            //#403 prevent drag correctly for http streams
            if (! canDragTo(mouseX)) {
                doStart(_currentClip);
                if (_isSeekPaused) {
                    _player.resume(true);
                    _isSeekPaused = false;
                    return;
                }
                return;
            }

            if (_isSeekPaused) {
                _player.resume(true);
                seekToScrubberValue(false);
                _isSeekPaused = false;
                return;
            }
            if (_player.isPaused()) {
                _currentClip.dispatchEvent(new ClipEvent(ClipEventType.SEEK, value));
            }
        }

        //#321 set an maximum end seek limit or else playback completion may fail
        //#403 Setting limit back to full range.
        private function endSeekLimit(value:Number):Number {
            return Math.min(value, 100);
        }

        private function seekToScrubberValue(silent:Boolean):void {
            log.debug("seekToScrubberValue(), silent == " + silent);
            var value:Number = endSeekLimit(valueFromScrubberPos);

            if (silent && ! _currentClip.dispatchBeforeEvent(new ClipEvent(ClipEventType.SEEK, value))) {
                return;
            }
            _player.seekRelative(value , silent);
        }

		override protected function onDispatchDrag():void {
			drawBufferBar();
			_seekInProgress = true;
		}

        override protected function drawSlider():void {
            drawBufferBar();
            doDrawBufferBar(0, 0);
        }

        private function drawBufferBar():void {
            if (_dragger.x + _dragger.width / 2 > _bufferStart * width) {
                doDrawBufferBar(_bufferStart * width, _bufferEnd * width);
            } else {
                clearBar(_bufferBar);
            }
        }

        private function clearBar(bar:Sprite):void {
            bar.graphics.clear();
            GraphicsUtil.removeGradient(bar);
        }

		override public function configure(config:Object):void {
			super.configure(config);
			drawBar(_progressBar, _config.color, _config.alpha, _config.gradient, _progressBar.x, _progressBar.width);
			drawBar(_bufferBar, (_config as ScrubberConfig).bufferColor, (_config as ScrubberConfig).bufferAlpha, (_config as ScrubberConfig).bufferGradient, _bufferBar.x, _bufferBar.width);
		}

        override protected function onDragging():void {
            log.debug("onDragging()");
            stop(null);
            drawProgressBar(_bufferStart * width);

            //#403 prevent drag for http streams
            if (! canDragTo(mouseX)/* && _dragger.x > 0*/) {
                return;
            }

            if (mouseDown) {
                seekToScrubberValue(true);
            }
        }
	}
}
