/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.detect {
    import flash.events.EventDispatcher;
    import flash.net.NetConnection;

    import flash.net.Responder;

    import org.flowplayer.util.Log;

    [Event(name=BandwidthDetectEvent.DETECT_STATUS, type="org.flowplayer.bwcheck.detect.BandwidthDetectEvent")]
    [Event(name=BandwidthDetectEvent.DETECT_COMPLETE, type="org.flowplayer.bwcheck.detect.BandwidthDetectEvent")]

    public class AbstractDetectionStrategy extends EventDispatcher {
        protected var log:Log = new Log(this);
        private var _connection:NetConnection;
        protected var _service:String = "checkBandwidth";
        private var _responder:Responder;

        public function AbstractDetectionStrategy() {
            _responder = new Responder(onResult, onResult);
        }

        public function connect(host:String = null):void {
        }

        protected function dispatch(info:Object, eventName:String):void {
            var event:BandwidthDetectEvent = new BandwidthDetectEvent(eventName);
            event.info = info;
            dispatchEvent(event);
        }

        protected function dispatchStatus(info:Object):void {
            var event:BandwidthDetectEvent = new BandwidthDetectEvent(BandwidthDetectEvent.DETECT_STATUS);
            event.info = info;
            dispatchEvent(event);
        }

        protected function dispatchComplete(info:Object):void {
            var event:BandwidthDetectEvent = new BandwidthDetectEvent(BandwidthDetectEvent.DETECT_COMPLETE);
            event.info = info;
            dispatchEvent(event);
        }

        protected function dispatchFailed(info:Object):void {
            var event:BandwidthDetectEvent = new BandwidthDetectEvent(BandwidthDetectEvent.DETECT_FAILED);
            event.info = info;
            dispatchEvent(event);
        }

        public function set connection(connect:NetConnection):void {
            _connection = connect;
        }

        public function detect():void {
            log.debug("detect() calling service " + _service);
            connection.client = this;
            connection.call(_service, null);
        }

        public function set service(value:String):void {
            _service = value;
        }

        public function get connection():NetConnection {
            return _connection;
        }

        protected function onResult(obj:Object):void {
            dispatchStatus(obj);
        }
    }
}