/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.cluster
{
import flash.events.TimerEvent;
import flash.net.SharedObject;
import flash.utils.Timer;

import mx.utils.URLUtil;

import org.flowplayer.flow_internal;
import org.flowplayer.model.ClipEvent;
import org.flowplayer.model.PluginEventDispatcher;
import org.flowplayer.model.PluginEventType;
import org.flowplayer.model.PluginModel;
import org.flowplayer.model.PluginModelImpl;
import org.flowplayer.util.Log;

use namespace flow_internal;

public class RTMPCluster {
    protected var _hosts:Array;
    protected var _timer:Timer;
    protected var _hostIndex:int = 0;
    protected var _hostCount:int = 0;
    protected var _connectCount:int = 0;
    protected var _reConnectCount:int = 0;
    protected var _connectTimeout:int = 2000;
    protected var _loadBalanceServers:Boolean = false;
    protected var _liveHosts:Array;
    protected var _liveRandomServers:Array = [];
    private var _startAfterConnect:Boolean;
    protected var _failureExpiry:int = 0;
        protected var _reconnectFailureExpiry:int = 0;
    private var _config:*;
    private var _dispatcher:PluginModelImpl;
    private var log:Log = new Log(this);
    private var _reconnectListener:Function;
    private var _failureListener:Function;
    private var _currentHost:Object;


    public function RTMPCluster(config:*)
    {
        _config = config;

        // there can be several hosts, or we are just using one single netConnectionUrl
        initHosts(_config.hosts, config.netConnectionUrl);

        _connectCount = config.connectCount;
        _connectTimeout = config.connectTimeout;
        _failureExpiry = config.failureExpiry;
        _currentHost = _hosts ? _hosts[0] : null;
    }

    private function initHosts(hosts:Array, fallback:String):void {
        log.debug("initHosts()");
        var myHosts:Array = [];
        if (! hosts || hosts.length == 0) {
            if (! fallback) {
                throw new Error("A hosts array or a netConnectionUrl must be configured");
            }
            myHosts.push({ 'host': fallback});
        } else {
            for (var i:int = 0; i < hosts.length; i++) {
                myHosts.push(hosts[i] is String ? { 'host': hosts[i] } : hosts[i]);
            }
        }

        _hosts = myHosts;
        _liveHosts = _hosts;
        log.debug("initHosts(), we have " + _liveHosts.length + " live hosts initially");
    }


    public function onReconnected(listener:Function):void {
        _reconnectListener = listener;
    }

    public function onFailed(listener:Function):void {
        _failureListener = listener;
    }

    public function get currentHosts():Array
    {
        return _hosts.filter(_checkLiveHost);
    }

    public function get hosts():Array
    {
        return _hosts;
    }

    public function get nextHost():String
    {
        if (hasMultipleHosts())
        {
            _liveHosts = currentHosts;
            if (_liveHosts.length == 0) {
                log.error("no live hosts available");
                if (_failureListener != null) {
                    _failureListener();
                    return null;
                }
            }
            if (_config.loadBalance)
            {
                _hostIndex = getRandomIndex();
                log.debug("Load balanced index " + _hostIndex);
            }
            if (_liveHosts.length > _hostIndex) {
                log.debug("cluster has multiple hosts");
                _currentHost = _liveHosts[_hostIndex];
                return _currentHost["host"];
            }
        }
        log.error("no hosts available");
        return null;
    }

    public function start():void
    {
        if (_timer && _timer.running) {
            _timer.stop();
        }
        _timer = new Timer(_connectTimeout, _liveHosts.length);
        _timer.addEventListener(TimerEvent.TIMER , tryFallBack);
        if (hasMultipleHosts()) {
            log.debug("starting connection timeout timer, with a delay of " + _connectTimeout);
            _timer.start();
        }
    }

    public function stop():void
    {
        if (_timer != null && _timer.running) _timer.stop();
    }

    public function hasMultipleHosts():Boolean
    {
        return _liveHosts.length > 0;
    }

    public function getRandomIndex():uint {
        return Math.round(Math.random() * (_liveHosts.length - 1));
    }

    public function get liveServers():Array
    {
        return _liveHosts;
    }

    private function _checkLiveHost(element:*, index:int, arr:Array):Boolean
    {
        return _isLiveServer(element);
    }

    private function _getFailedServerSO(host:String):SharedObject
    {
        var domain:String = URLUtil.getServerName(host);
        return SharedObject.getLocal(domain,"/");
    }

    public function setFailedServer(host:String):void
    {
        log.debug("Setting Failed Server: " + host);
        var server:SharedObject = _getFailedServerSO(host);
        server.data.failureTimestamp = new Date();
    }

    public function set connectCount(count:Number):void
    {
        _connectCount = count;
    }

    internal function hasMoreHosts():Boolean
    {
        if (_failureExpiry == 0)
            _hostIndex++
        else
            _hostIndex = 0;

        _liveHosts = currentHosts;

        if (_hostIndex >= _liveHosts.length)
        {
            //
            _reConnectCount++;
            if (_reConnectCount < _connectCount)
            {
                log.debug("Restarting Connection Attempts");
                _hostIndex = 0;
                    //#427 when reconnecting to the max reconnect count, clear the failure expiry and reset the live hosts to enable to try again ?
                    _reconnectFailureExpiry = 0;
                    _liveHosts = currentHosts;

            }
            } else {
                //#427 set the normal failure expiry during retries.
                _reconnectFailureExpiry = _failureExpiry;
        }
        log.debug("Host Index: " + _hostIndex + " LiveServers: " + _liveHosts.length);
        return (_hostIndex <= _liveHosts.length && _liveHosts[_hostIndex]);
    }

    private function _isLiveServer(element:*):Boolean
    {
        var host:String = element.host;
        var server:SharedObject = _getFailedServerSO(host);
        // Server is failed, determine if the failure expiry interval has been reached and clear it
        if (server.data.failureTimestamp)
        {
            var date:Date = new Date();

            // Determine the failure offset
            var offset:int = date.getTime() - server.data.failureTimestamp.getTime();

            log.debug("Failed Server Remaining Expiry: " + offset + " Start Time: " + server.data.failureTimestamp.getTime() + " Current Time: " + date.getTime());

            // Failure offset has reached the failureExpiry setting, clear it from the list to allow a connection
                //#427 failure expiry was not being reset to honour connect retry.
                if (offset >= _reconnectFailureExpiry && _reConnectCount < _connectCount)
            {
                log.debug("Clearing Failure Period " + _config.failureExpiry);
                server.clear();
                return true;
            }
            return false;
        }
        return true;
    }

    protected function tryFallBack(e:TimerEvent):void
    {
        // Check if there is more hosts to attempt reconnection to
        if (hasMoreHosts())
        {
            log.debug("invoking reconnect listener");
            if (_reconnectListener != null) {
                _reconnectListener();
            }

        } else {
            // we have reached the end of the hosts list stop reconnection attempts and send a failed event
            stop();
            if (_failureListener != null) {
                _failureListener();
            }
        }
    }

    public function get currentHost():String {
        return _currentHost["host"];
    }

    public function get currentHostIndex():int {
        return _hosts.indexOf(_currentHost);
    }
}


}