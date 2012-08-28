/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.securestreaming {
    import com.adobe.crypto.MD5;
import flash.events.NetStatusEvent;
    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    public class SecureHttpUrlResolver implements ClipURLResolver {
        private var log:Log = new Log(this);
        private var _config:Config;
        private var _player:Flowplayer;
        private var _failureListener:Function;
        private var _mainResolver:ClipURLResolver;

        public function SecureHttpUrlResolver(mainResolver:ClipURLResolver, player:Flowplayer, config:Config, failureListener:Function) {
            _mainResolver = mainResolver;
            _player = player;
            _config = config;
            _failureListener = failureListener;
        }


        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            if (_config.timestamp) {
                doResolve(buildClipUrl(_config.timestamp, clip), clip, successListener);
            } else {
                loadTimestampAndResolve(clip, successListener);
            }
        }

        private function loadTimestampAndResolve(clip:Clip, successListener:Function):void {
            log.debug("resolve, will load timestamp from url " + _config.timestampUrl);
            var loader:ResourceLoader = _player.createLoader();
            loader.load(_config.timestampUrl, function(loader:ResourceLoader):void {
                var url:String = buildClipUrl(stripLinebreaks(String(loader.getContent())), clip);
                doResolve(url, clip, successListener);
            }, true);
        }

        private function doResolve(url:String, clip:Clip, successListener:Function):void {
            clip.setResolvedUrl(_mainResolver, url);
            log.debug("resolved url " + clip.completeUrl);
            if (! url) {
                if (_failureListener != null) {
                    _failureListener();
                }
                return;
            }
            successListener(clip);
        }

        private function stripLinebreaks(line:String):String {
            if (! line) return null;
            var tmp:Array = line.split("\n");
            line = tmp.join("");
            tmp = line.split("\r");
            line = tmp.join("");
            return line;
        }

        private function buildClipUrl(timestamp:String, clip:Clip):String {
            if (! timestamp) return null;

            log.debug("main resolver is " + _mainResolver);
            if (URLUtil.isCompleteURLWithProtocol(clip.getPreviousResolvedUrl(_mainResolver))) {
                var parts:Array = URLUtil.baseUrlAndRest(clip.url);
                return URLUtil.appendToPath(URLUtil.appendToPath(parts[0], generateProtection(timestamp, parts[1])), parts[1]);
            }
            return URLUtil.appendToPath(generateProtection(timestamp, clip.getPreviousResolvedUrl(_mainResolver)), clip.url);
        }

        private function generateProtection(timestamp:String, file:String):String {
            var secret:String = _config.token;
           // log.debug("secret token is " + secret + ", filename is " + "/" + file);
            //log.debug(secret + "/" + file + timestamp);
            return MD5.hash(secret + "/" + file + timestamp) + "/" + timestamp ;
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }
    }
}