/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.akamai {
    import flash.events.NetStatusEvent;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    public class AkamaiResolver implements ClipURLResolver, Plugin {

        private var log:Log = new Log(this);
        private var _parseResults:Object;
        private var _player:Flowplayer;
        private var _model:PluginModel;
        private var _failureListener:Function;
        private var _clip:Clip;
        private var _smilResolver:AkamaiSmilResolver;

        public function AkamaiResolver() {
            _smilResolver = new AkamaiSmilResolver(this);
        }


        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            _clip = clip;
            _parseResults = URLUtil.parseURL(_clip.completeUrl);
            log.debug("resolve(), inspecting what to do with URL " + _clip.completeUrl);

            if (_parseResults.isRTMP) {
                findAkamaiIP("http://" + _parseResults.serverName, successListener);
            } else {
                log.debug("resolve(): This is not a RTMP url, assuming it points to a Akamai BOSS smil file");
                _smilResolver.resolve(provider, clip, successListener);
            }

        }

        public function findAkamaiIP(akamaiAppURL:String, successListener:Function):void{
            log.debug("findAkamaiIP(), requesting " + akamaiAppURL + "/fcs/ident " + _player);

            var loader:ResourceLoader = _player.createLoader();
            loader.load(akamaiAppURL + "/fcs/ident/", function(loader:ResourceLoader):void {
                log.debug("Ident file received " + loader.getContent());
                updateClip(String(loader.getContent()));
                successListener(_clip);
            }, true);
        }

        private function updateClip(identFile:String):void {
            log.debug("parsing Ident file " + identFile);
            var ident:XML = new XML(identFile);
            var ip:String = ident.ip.toString();

            var url:String = _parseResults.protocol + "/" + ip;
            if (_parseResults.portNumber) {
                url += ":" + _parseResults.portNumber;
            }
            url += "/" + getAkamaiAppName(_clip.completeUrl);

            log.debug("netConnectionUrl is " + url);
            _clip.setCustomProperty("netConnectionUrl", url);
            _clip.setResolvedUrl(this, getAkamaiStreamName(_clip.completeUrl));
            _clip.url = null;
            _clip.baseUrl = null;
            log.debug("stream name is " + _clip.url);
        }

        public function onLoad(player:Flowplayer):void {
            _player = player;
            _model.dispatchOnLoad();
        }

        public function getDefaultConfig():Object {
            return null;
        }

        public function onConfig(model:PluginModel):void {
            _model = model;
        }

        private function getAkamaiAppName(p:String):String
        {
            var result:String;
            //first check if a vhost is being passed in
            if (p.indexOf("_fcs_vhost") != -1) {
                result = p.slice(p.indexOf("/", 10)+1, p.indexOf("/", p.indexOf("/", 10)+1))+"?_fcs_vhost="+p.slice(p.indexOf("_fcs_vhost")+11, p.length);
            } else {
                result =  p.slice(p.indexOf("/", 10)+1, p.indexOf("/", p.indexOf("/", 10)+1))+"?_fcs_vhost="+ URLUtil.parseURL(p).serverName;
            }
            if (p.indexOf("?") != -1) {
                result += "&"+p.slice(p.indexOf("?")+1, p.length);
            }
            return result;
        }

        private function getAkamaiStreamName(p:String):String
        {
            var tempApp:String=p.slice( p.indexOf("/",10) + 1, p.indexOf("/", p.indexOf("/",10) + 1));
            tempApp = p.indexOf("_fcs_vhost") != -1 ?
                      p.slice(p.indexOf(tempApp)+tempApp.length+1, p.indexOf("_fcs_vhost")-1)
                        : p.slice(p.indexOf(tempApp)+tempApp.length+1, p.length);
            return URLUtil.stripFileExtension(tempApp);
        }

        public function set onFailure(listener:Function):void {
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }
    }
}