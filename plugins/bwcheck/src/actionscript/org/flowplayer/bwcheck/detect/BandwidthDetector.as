/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

    package org.flowplayer.bwcheck.detect {
    import flash.events.EventDispatcher;
    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;

    import flash.utils.setTimeout;

    import org.flowplayer.bwcheck.config.Config;
    import org.flowplayer.bwcheck.net.NullNetConnectionClient;

    import org.flowplayer.cluster.RTMPCluster;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;

    /**
     * @author danielr
     */
    public class BandwidthDetector extends EventDispatcher {
    private var log:Log = new Log(this);

    // --------- These references are needed here, so that the classes get compiled in!
    private var wowzaImpl:BandwidthDetectorWowza;
    private var httpImpl:BandwidthDetectorHttp;
    private var fmsImpl:BandwidthDetectorOldfms;
    private var fms35Impl:BandwidthDetectorFms;
    private var red5Impl:BandwidthDetectorRed5;
    // ---------

    private var _strategy:AbstractDetectionStrategy;
    private var _connection:NetConnection;
    protected var _rtmpCluster:RTMPCluster;
    private var _config:Config;
    private var _model:PluginModel;
    private var _host:String;
    private var _playlist:Playlist;

    public function BandwidthDetector(model:PluginModel, config:Config, playlist:Playlist) {
        _model = model;
        _config = config;
        _playlist = playlist;

        var bandwidthDetectionCls:Class = FactoryMethodUtil.getFactoryMethod("org.flowplayer.bwcheck.detect.BandwidthDetector", _config.serverType);
        _strategy = new bandwidthDetectionCls();

        if (_strategy == null) _strategy = new BandwidthDetectorHttp();

        if (_config.hosts.length > 0 || config.netConnectionUrl) {
            log.debug("Using netConnectionUrls configured for the plugin");
            createCluster();
        }
    }

    private function createCluster():void {
        _rtmpCluster = new RTMPCluster(_config);
        _rtmpCluster.onFailed(onClusterFailed);
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        if (type == BandwidthDetectEvent.CLUSTER_FAILED) {
            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        } else {
            _strategy.addEventListener(type, listener);
        }
    }

    public function detect(host:String = null):void {
        log.debug("detect()");
        if (_rtmpCluster) {
            _host = _rtmpCluster.nextHost;
        } else {
            _host = _playlist.current.getCustomProperty("netConnectionUrl") as String;
            log.debug("detect(), using clip's netConnectionUrl: " + _host);
            _config.hosts = [_host];
            createCluster();
        }

        if (!_host) {
            log.error("no live hosts to connect to");
            dispatchClusterFailed();
            return;
        }
        _rtmpCluster.onReconnected(onRTMPReconnect);
        _rtmpCluster.start();

        _connection = new NetConnection();
        _connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
        _connection.client = new NullNetConnectionClient();
        _strategy.connection = _connection;

        log.debug("detect(), connecting to " + _host + ", using strategy " + _strategy);
        _strategy.connect(_host);
    }

    private function onConnectionStatus(event:NetStatusEvent):void {
        switch (event.info.code) {
            case "NetConnection.Connect.Success":
                log.info("successfully connected to " + _connection.uri);
                _rtmpCluster.stop();
                _strategy.detect();
                break;

            case "NetConnection.Connect.Failed":
                log.info("Couldn't connect to " + _connection.uri);
                _rtmpCluster.setFailedServer(_connection.uri);
                _rtmpCluster.stop();

                detect();
                break;
            case "NetConnection.Connect.Rejected":
                // Fix for #259, reconnect to hddn nodes, stop the cluster timer.
                _rtmpCluster.stop();
                setTimeout(function ():void {
                    log.debug("connecting to a redirected URL " + event.info.ex.redirect);
                    _strategy.connect(event.info.ex.redirect);
                }, 100);

                break;
            //connection has closed
            case "NetConnection.Connect.Closed":
        }
    }

    private function onClusterFailed(event:ClipEvent = null):void {
        log.info("Connections failed");
        _model.dispatch(PluginEventType.PLUGIN_EVENT, event, _rtmpCluster.currentHost, _rtmpCluster.currentHostIndex);
    }

    private function onRTMPReconnect():void {
        dispatch("onRTMPReconnect()");
        _rtmpCluster.setFailedServer(_host);
        _connection.close();
        log.info("onRTMPReconnect(), Attempting reconnection");
        detect();
    }

    private function dispatch(event:String):void {
        _model.dispatch(PluginEventType.PLUGIN_EVENT, event, _rtmpCluster.currentHost, _rtmpCluster.currentHostIndex);

    }

    private function dispatchClusterFailed():void {
        var event:BandwidthDetectEvent = new BandwidthDetectEvent(BandwidthDetectEvent.CLUSTER_FAILED);
        dispatchEvent(event);
    }

    public function get host():String {
        if (_host) return _host;
        if (_rtmpCluster) return _rtmpCluster.currentHost;
        return _config.netConnectionUrl || _playlist.current.getCustomProperty("netConnectionUrl") as String;
    }
}
}
