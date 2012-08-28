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
    import flash.events.NetStatusEvent;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.ConnectionProvider;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.DomainUtil;
    import org.flowplayer.util.DomainUtil;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    public class SecureStreaming implements ClipURLResolver, ConnectionProvider, Plugin {
        private const log:Log = new Log(this);
        private var _httpResolver:SecureHttpUrlResolver;
        private var _connectionProvider:ConnectionProvider;
        private var _model:PluginModel;
        private var _config:Config;
        private var _player:Flowplayer;
        private var _failureListener:Function;
        private var _connectionClient:Object;

        /*
         * URL resolving is used for HTTP
         */
        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            _httpResolver.resolve(provider, clip, successListener);
        }

        /*
         * Connection establishment is used for Wowza
         */
        public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding: uint, connectionArgs:Array):void {
            _connectionProvider.connect(provider, clip, successListener, objectEncoding, connectionArgs);
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
            if (_httpResolver) {
                _httpResolver.onFailure = listener;
            }
            if (_connectionProvider) {
                _connectionProvider.onFailure = listener;
            }
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config()).copyProperties(model.config) as Config;
        }

        public function onLoad(player:Flowplayer):void {
            if (! isIn(_config.domains)) {
                _model.dispatchError(PluginError.ERROR);
                return;
            }
            _player = player;
            _httpResolver = new SecureHttpUrlResolver(this, player, _config, _failureListener);

            var cluster:ConnectionProvider = lookupClusterPlugin(_config.clusterPlugin || "cluster", player);
            _connectionProvider = cluster ?  new ClusterDelegatingSecureRTMPConnectionProvider(_config, cluster) : new SecureRTMPConnectionProvider(_config.token);

            _connectionProvider.connectionClient = _connectionClient;
            _model.dispatchOnLoad();
        }


        private static function isIn(acceptedDomains:Array):Boolean {
//            log.debug("acceptedDomains", acceptedDomains);
            if (! acceptedDomains || acceptedDomains.length == 0) return true;

            return checkDomain(URLUtil.pageUrl, acceptedDomains);
        }

        private static function checkDomain(url:String, acceptedDomains:Array):Boolean {
            var domain:String = DomainUtil.parseDomain(url, true);
//            log.debug("domain is '" + domain + "'");
            return acceptedDomains.indexOf(domain) >= 0;
        }

        public function getDefaultConfig():Object {
            return null;
        }

        public static function isRtmpUrl(url:String):Boolean {
            return url && url.toLowerCase().indexOf("rtmp") == 0;
        }

        public function set connectionClient(client:Object):void {
            _connectionClient = client;
            if (_connectionProvider) {
                _connectionProvider.connectionClient = client;
            }
        }

        private function lookupClusterPlugin(clusterPluginName:String, player:Flowplayer):ConnectionProvider {
            log.debug("looking up cluster plugin with name '" + clusterPluginName + "'");
            var cluster:PluginModel = PluginModel(player.pluginRegistry.getPlugin(clusterPluginName));
            if (cluster) {
                var plugin:ConnectionProvider = cluster.pluginObject as ConnectionProvider;
                log.debug("found cluster plugin " + plugin);
                return plugin;
            } else {
                log.debug("cluster plugin not found in configuration");
            }
            return null;
        }

    }
}