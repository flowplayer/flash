/* * This file is part of Flowplayer, http://flowplayer.org * * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy * Copyright (c) 2008-2011 Flowplayer Oy * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.cluster {import flash.events.IOErrorEvent;import flash.events.NetStatusEvent;import flash.net.NetConnection;import flash.net.NetStream;import flash.net.Responder;import flash.utils.*;import org.flowplayer.controller.ClipURLResolver;import org.flowplayer.controller.ConnectionProvider;import org.flowplayer.controller.NetConnectionClient;import org.flowplayer.controller.NetStreamClient;import org.flowplayer.controller.NetStreamControllingStreamProvider;import org.flowplayer.controller.StreamProvider;import org.flowplayer.model.Clip;import org.flowplayer.model.ClipError;import org.flowplayer.model.Plugin;import org.flowplayer.model.PluginEventType;import org.flowplayer.model.PluginModel;import org.flowplayer.util.Log;import org.flowplayer.util.PropertyBinder;import org.flowplayer.util.URLUtil;import org.flowplayer.view.Flowplayer;/**     * A RTMP stream provider with fallback and clustering support. Supports following:     * <ul>     * <li>Starting in the middle of the clip's timeline using the clip.start property.</li>     * <li>Stopping before the clip file ends using the clip.duration property.</li>     * <li>Ability to combine a group of clips into one gapless stream.</li>     * <li>Ability to fallback to a list of servers in a cluster server farm.</li>     * <li>Ability to recognise, store and leave out any failed servers for a given time.</li>     * <li>Ability to randomly connect to a server in the servers list mimicking a round robin connection.</li>     * <li>Works with a traditional load balancing appliance by feeding its host at the top of the list, and direct connections to the servers happen on fallback.</li>     * </ul>     * <p>     * Stream group is configured in a clip like this:     * <code>     * { streams: [ { url: 'metacafe', duration: 20 }, { url: 'honda_accord', start: 10, duration: 20 } ] }     * </code>     * The group is played back seamlessly as one gapless stream. The individual streams in a group can     * be cut out from a larger file using the 'start' and 'duration' properties as shown in the example above.     *     * <p>     * To enable server fallback a hosts config property is required in the plugins config like this:     *     * hosts: [     *	       'rtmp://server1.host.com/myapp',     *	       'rtmp://server2.host.com/myapp',     *	       'rtmp://server3.host.com/myapp',     *	      ]     *     * <p>     * To enable the fallback feature to store (client side) failed servers to prevent reattempting those connections the failureExpiry config property is required like so:     * failureExpiry: 3000,     *     * <p> This tells the feature to wait for 3000 milliseconds before allowing connection attempts again.     *     * <p>     * To enable round robin connections the loadBalanceServers config property requires to be enabled like so:     *     * loadBalanceServers: true     *     * <p>     * Advanced configurations for the fallback feature can be enabled like so:     *     * connectTimeout: 5000,     * connectCount: 3     * encoding: 0     *     * <p> connectTimeout is the time in milliseconds before each reconnection attempt.     * connectCount is the ammount of times connection reattmps will occur before giving up.     * encoding is the AMF encoding version either 0 or 3 for AMF3.     *     * <p> Two custom events a fired during connection attempts and fallback, these are:     *     * <ul>     * <li>RTMPEventType.RECONNECTED - onReconnect</li>     * <li>RTMPEventType.FAILED - onFailed</li>     * </ul>     *     * @author danielr     */    public class ClusterConnectionProvider implements ConnectionProvider, ClipURLResolver, Plugin {        private var _config:ClusterConfig;        private var log:Log = new Log(this);        protected var _rtmpCluster:RTMPCluster;        private var _connection:NetConnection;        private var _netStream:NetStream;        private var _provider:StreamProvider;        private var _successListener:Function;        private var _failureListener:Function;        private var _connectionClient:Object;        private var _objectEncoding:uint;        private var _clip:Clip;        private var _connectionArgs:Array;        private var _isComplete:Boolean = false;        private var _model:PluginModel;        private var _resolving:Boolean;        private var _player:Flowplayer;        private var _onConnectionStatusCallback:Function;        public function onConfig(model:PluginModel):void {            log.debug("onConfig");            _model = model;            _config = new PropertyBinder(new ClusterConfig(), null).copyProperties(model.config) as ClusterConfig;            _rtmpCluster = new RTMPCluster(_config);            _rtmpCluster.onFailed(onFailed);        }        public function getDefaultConfig():Object {            return null;        }        public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding:uint, connectionArgs:Array):void {            log.debug("connect()");            _resolving = false;            _objectEncoding = objectEncoding;            _clip = clip;            _connectionArgs = connectionArgs;            _successListener = successListener;            _provider = provider as NetStreamControllingStreamProvider;            _connection = new NetConnection();            _connection.proxyType = "best";            _connection.objectEncoding = objectEncoding;            _connection.client = _connectionClient || new NetConnectionClient();            log.debug("connect() using connection client " + _connection.client);            _connection.addEventListener(NetStatusEvent.NET_STATUS, connectionProviderConnectionStatus);            _connection.addEventListener(IOErrorEvent.IO_ERROR, _netIOError);            var host:String = getNextNetConnectionUrl(clip);            log.debug("connecting to " + host);            if (connectionArgs.length > 0)            {                _connection.connect(host, connectionArgs);            } else if (_config.connectionArgs) {                _connection.connect(host, _config.connectionArgs);            } else {                _connection.connect(host);            }            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onConnect", _rtmpCluster.currentHost, _rtmpCluster.currentHostIndex);            if (isRtmpUrl(host)) {                _rtmpCluster.onReconnected(onRTMPReconnect);                _rtmpCluster.start();            }        }        private function _netIOError(event:IOErrorEvent):void        {            log.error(event.text);        }        protected function getNextNetConnectionUrl(clip:Clip):String {            var host:String = _rtmpCluster.nextHost;            if (isRtmpUrl(host)) return host;            return null;        }        private function connectionProviderConnectionStatus(event:NetStatusEvent):void {            if (_onConnectionStatusCallback != null) {                _onConnectionStatusCallback(event, _connection);            }            if (event.info.code == "NetConnection.Connect.Success" && _successListener != null) {                log.debug("_onConnectionStatus, NetConnection.Connect.Success, calling clusterComplete()");                clusterComplete();            } else if (["NetConnection.Connect.Failed", "NetConnection.Connect.Rejected", "NetConnection.Connect.AppShutdown", "NetConnection.Connect.InvalidApp"].indexOf(event.info.code) >= 0) {                log.info("Couldnt connect to " + _connection.uri);            }        }        public function set connectionClient(client:Object):void {            if (_connection) {                _connection.client = client;            }            _connectionClient = client;        }        public function set onFailure(listener:Function):void {            _failureListener = listener;        }        protected function get connection():NetConnection {            return _connection;        }        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {            return true;        }        protected function get provider():StreamProvider {            return _provider;        }        protected function get failureListener():Function {            return _failureListener;        }        protected function get successListener():Function {            return _successListener;        }        /**         * Fallback feature method called by the reconnection attempt timer         */        protected function onRTMPReconnect():void        {            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onConnectFailed", _rtmpCluster.currentHost, _rtmpCluster.currentHostIndex);            _rtmpCluster.setFailedServer(_rtmpCluster.currentHost);            _connection.close();            _rtmpCluster.stop();            //#427 run host checks here to check for null hosts on rtmp.            if (!_rtmpCluster.hasMoreHosts()) {                _rtmpCluster.stop();                onFailed();                return;            }            connect(_provider, _clip, _successListener, _objectEncoding, _connectionArgs);            log.info("RTMP Connection Failed Attempting Reconnection");        }        protected function onHTTPReconnect():void        {            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onConnectFailed", _rtmpCluster.currentHost, _rtmpCluster.currentHostIndex);            _rtmpCluster.setFailedServer(_clip.getResolvedUrl(this));            _rtmpCluster.stop();            log.info("HTTP Connection Attempting Reconnection");            resolveURL(true);        }        protected function onFailed():void        {            log.info("Connections failed");            //#601 dispatch resolver failure correctly.            _failureListener(_clip.completeUrl);            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onFailed");        }        protected function resolveURL(useNextHost:Boolean):void        {            //fix for #377, run host checks and increment indexes here to trigger reconnections of the next host or else recurssion occurs or last host is null.            if (!_rtmpCluster.hasMoreHosts()) {                _rtmpCluster.stop();                onFailed();                return;            }            log.debug("resolveURL, useNextHost " + useNextHost);            // store the resolvedUrl already now, to make sure the resolved URL is there when onStart()            // is dispatched by the provider            var currentUrl:String = _clip.getPreviousResolvedUrl(this);            var nextHost:String = useNextHost ? _rtmpCluster.nextHost : _rtmpCluster.currentHost;            var url:String = URLUtil.completeURL(nextHost, URLUtil.baseUrlAndRest(currentUrl)[1]);            _clip.setResolvedUrl(this, url);            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onConnect", _rtmpCluster.currentHost, _rtmpCluster.currentHostIndex);            //#15 add cache busting to the file being checked for availability to play back correctly once resolving has completed.            _netStream.play(_clip.getResolvedUrl(this) + "?" + Math.random());            _rtmpCluster.start();        }        private function _onNetStatus(event:NetStatusEvent):void {            if (event.info.code == "NetStream.Play.Start") {                log.debug("_onNetStatus: NetStream.Play.Start, calling clusterComplete()");                clusterComplete();            }  else if (event.info.code == "NetStream.Play.StreamNotFound" ||                        event.info.code == "NetConnection.Connect.Rejected" ||                        event.info.code == "NetConnection.Connect.Failed") {                onHTTPReconnect();            }        }        protected function clusterComplete():void        {            _isComplete = true;            if (_netStream) {                _netStream.close();            }            _rtmpCluster.stop();            if (_resolving) {                log.debug("clusterComplete(), resolving? " + _resolving);                var currentUrl:String = _clip.getPreviousResolvedUrl(this);                _clip.setResolvedUrl(this, URLUtil.completeURL(_rtmpCluster.currentHost, URLUtil.baseUrlAndRest(currentUrl)[1]));                _successListener(_clip);            } else {				getServerDuration();                log.debug("calling success listener");                _successListener(_connection);            }        }        private function lookupRtmpPlugin(providers:Dictionary):PluginModel {            for each (var obj:Object in providers) {                var model:PluginModel = obj as PluginModel;                log.debug(model.name);                if (model.name == "rtmp") {                    return model;                }                if (["http", "httpInstream"].indexOf(model.name) < 0 && model.pluginObject is StreamProvider) {                    return model;                }            }            return null;        }        private function getServerDuration():void {            log.debug("getServerDuration()");            var model:PluginModel = lookupRtmpPlugin(_player.pluginRegistry.providers);            if (! model) return;            log.debug("found RTMP plugin " + model + ", looking up durationFunc");            if (model.config && model.config.durationFunc) {                log.debug("getServerDuration(), calling durationFunc '" + model.config.durationFunc + "'");                _connection.call(model.config.durationFunc, new Responder(onDurationResult), _clip.url);            }		}		private function onDurationResult(info:Object):void {            log.debug("onDurationResult()");			_clip.duration = info as Number;		}        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {            log.debug("resolve()");            _resolving = true;            _clip = clip;            _successListener = successListener;            _provider = provider;            if (_provider.netStream) {                _provider.netStream.close();            }            _connection = new NetConnection();            _connection.addEventListener(NetStatusEvent.NET_STATUS, _onConnectionStatus);            _connection.connect(getNextNetConnectionUrl(_clip));        }        private function _onConnectionStatus(event:NetStatusEvent):void {            log.debug("onConnectionStatus: " + event.info.code);            if (event.info.code == "NetConnection.Connect.Success") {                doResolve(false);            } else if (["NetConnection.Connect.Failed", "NetConnection.Connect.Rejected", "NetConnection.Connect.AppShutdown", "NetConnection.Connect.InvalidApp"].indexOf(event.info.code) >= 0) {                _failureListener("Failed to connect " + event.info.code);            }        }        private function doResolve(useNextHost:Boolean):void {            _netStream = new NetStream(_connection);            _netStream.client = new NetStreamClient(_clip, _player.config, _provider.streamCallbacks);            _netStream.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);            _rtmpCluster.onReconnected(onHTTPReconnect);            _rtmpCluster.start();            resolveURL(useNextHost);        }        public static function isRtmpUrl(url:String):Boolean {            if (! url) return false;            return url.toLowerCase().indexOf("rtmp") == 0;        }        [External]        public function set loadBalancing(enabled:Boolean):void {            log.debug("setting loadBalanceServers to " + enabled);            _config.loadBalance = enabled;        }        public function onLoad(player:Flowplayer):void {            _player = player;            _model.dispatchOnLoad();        }        public function set onConnectionStatus(value:Function):void {            _onConnectionStatusCallback = value;        }    }}