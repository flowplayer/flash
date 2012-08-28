/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Richard Mueller  richard@3232design.com, Anssi Piirainen api@iki.fi
 * Copyright (c) 2009-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.analytics {
    import com.google.analytics.GATracker;
    import com.google.analytics.AnalyticsTracker;
    import com.google.analytics.debug.DebugConfiguration;

    import flash.display.Sprite;
    import flash.external.ExternalInterface;

    import flash.ui.Keyboard;

import flash.utils.getTimer;

import org.flowplayer.model.*;

    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    public class GoogleTracker extends Sprite implements Plugin {
        private var log:Log = new Log(this);
        private var _model:PluginModel;
        private var _player:Flowplayer;
        private var _config:Config;
        private var _tracker:AnalyticsTracker;
        private var _startTimeMillis:int;
        private var _viewDurationMillis:int = 0;

        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = Config(new PropertyBinder(new Config()).copyProperties(model.config));
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;
            var events:Events = _config.events;
            var playlist:Playlist = _player.playlist;
            createClipEventTracker(playlist.onStart, events.start, true);
            createClipEventTracker(playlist.onStop, events.stop, true);
            createClipEventTracker(playlist.onFinish, events.finish, true);
            createClipEventTracker(playlist.onPause, events.pause, events.trackPause);
            createClipEventTracker(playlist.onResume, events.resume, events.trackResume);
            createClipEventTracker(playlist.onSeek, events.seek, events.trackSeek);

            createPlayerEventTracker(_player.onMute, events.mute, events.trackMute);
            createPlayerEventTracker(_player.onUnmute, events.unmute, events.trackUnmute);
            createPlayerEventTracker(_player.onFullscreen, events.fullscreen, events.trackFullscreen);
            createPlayerEventTracker(_player.onFullscreenExit, events.fullscreenExit, events.trackFullscreenExit);

            // track unload if the clip is playing or paused. If it's stopped or finished, the Stop event has already
            // been tracked or the playback has not started at all.
            createPlayerEventTracker(_player.onUnload, events.unload, true, function():Boolean { return _player.isPlaying() ||  _player.isPaused() });

            // bind listeners for tracking the total view time
            playlist.onStart(startTimeTracking, null, true);
            playlist.onResume(startTimeTracking, null, true);

            playlist.onStop(stopTimeTracking, null, true);
            playlist.onPause(stopTimeTracking, null, true);
            playlist.onFinish(stopTimeTracking, null, true);

            _model.dispatchOnLoad();
        }

        private function startTimeTracking(event:ClipEvent):void {
            _startTimeMillis = getTimer();
            log.debug("startTimeTracking(), started at " + _startTimeMillis + ", total view time " + _viewDurationMillis + " milliseconds");
        }

        private function stopTimeTracking(event:ClipEvent = null):void {
            _viewDurationMillis += getTimer() - _startTimeMillis;
            log.debug("stopTimeTracking(), total view time " + _viewDurationMillis + " milliseconds");
        }

        private function createClipEventTracker(eventBinder:Function, eventName:String, doTrack:Boolean):void {
            if (! doTrack) return;
            eventBinder(
                    function(event:ClipEvent):void {
                        doTrackEvent(eventName, isStopping(event), event);
                    },
                    function(clip:Clip):Boolean {
                        return _config.clipTypes.indexOf(clip.typeStr) >= 0;
                    });
        }

        private function createPlayerEventTracker(eventBinder:Function, eventName:String, doTrack:Boolean, extraCheck:Function = null):void {
            if (!doTrack) return;
            eventBinder(
                    function(event:PlayerEvent):void {
                        if (extraCheck != null) {
                            if (! extraCheck()) {
                                // extra check returns false --> don't track
                                return;
                            }
                        }
                        doTrackEvent(eventName, true);
                    });
        }

        public function getCategory():String {
            var clipCategory:String = String(_player.playlist.current.getCustomProperty("eventCategory"));
            if (clipCategory) return clipCategory;

            var pageUrl:String = URLUtil.pageUrl;
            if (pageUrl) return pageUrl;

            _model.dispatchError(PluginError.ERROR, "Unable to get page URL to be used as google analytics event gategory. Specify this in the analytics plugin config.");
            return "Unknown";
        }

        private function instantiateTracker():void {
            try {
                var _confdebug:DebugConfiguration = new DebugConfiguration();
                _confdebug.minimizedOnStart = true;

                if (! _config.accountId) {
                    _model.dispatchError(PluginError.ERROR, "Google Analytics account ID not specified. Look it up in your Analytics account, the format is 'UA-XXXXXX-N'");
                    return;
                }

                log.debug("Creating tracker in AS3 mode using " + _config.accountId + ", debug ? " + _config.debug);
                _tracker = new GATracker(this, _config.accountId, "AS3", _config.debug);
                _tracker.debug.showHideKey = Keyboard.F6; // use the F6 key to toggle visual debug display

            } catch(e:Error) {
                _model.dispatchError(PluginError.ERROR, "Unable to create tracker: " + e);
            }
        }

        private function doTrackEvent(eventName:String, trackViewDuration:Boolean = false, event:ClipEvent = null):void {
            if (_tracker == null) {
                instantiateTracker();
            }
            var clip:Clip = Clip(event ? event.target : _player.currentClip);

            try {
                var time:int = trackViewDuration ? (_viewDurationMillis / 1000) : int(_player.status ? _player.status.time : 0);

                log.debug("Tracking " + eventName + "[" + (clip.completeUrl + (clip.isInStream ? ": instream" : "")) + "] : " + time + " on page " + getCategory());
                if (_tracker.isReady()) {
                    _tracker.trackEvent(getCategory(), eventName, clip.completeUrl + (clip.isInStream ? ": instream" : ""), time);
                }
            } catch (e:Error) {
                log.error("Got error while tracking event " + eventName);
            }
        }

        private function isStopping(event:ClipEvent):Boolean {
            if (event.eventType == ClipEventType.STOP) return true;
            if (event.eventType == ClipEventType.FINISH) return true;
            return false;
        }

        [External]
        public function trackEvent(eventName:String):void {
            doTrackEvent(eventName);
        }

        [External]
        public function setEventName(oldName:String, newName:Object):void {
            var newProp:Object = {};
            newProp[oldName] = newName == "false" ? null : newName;
            log.debug("setEventName()", newProp);
            new PropertyBinder(_config.events).copyProperties(newProp, true);
        }

        [External(convert="true")]
        public function get config():Config {
            return _config;
        }

        public function getDefaultConfig():Object {
            return null;
        }

    }
}
