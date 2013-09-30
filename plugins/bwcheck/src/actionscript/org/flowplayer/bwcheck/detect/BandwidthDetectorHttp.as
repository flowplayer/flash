/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.detect {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.utils.getTimer;

    /**
     * @author danielr
     */
    public class BandwidthDetectorHttp extends AbstractDetectionStrategy {

        private var loader:URLLoader;
        private var _startTime:Number;
        private var _bytes:Number;
        private var _bandwidth:Number;
        private var _downloadTime:Number;
        public var maximumBytes:uint;
        private var _referenceFileUrl:String;

        public function BandwidthDetectorHttp() {
            loader = new URLLoader();
        }

        public function onComplete(event:Event):void {
            log.debug("reference file successfully downloaded");
            this._bytes = event.currentTarget.bytesLoaded;
            this._downloadTime = getDownloadTime(getTimer(), this._startTime);
            this._bandwidth = getBandwidth(getKbytes(_bytes), this._downloadTime);

            log.debug("Current Time: " + getTimer().toString());
            log.debug("Download Time: " + this._downloadTime);
            log.debug("KBytes: " + getKbytes(_bytes));
            log.debug("Bytes: " + _bytes.toString());
            log.debug("Bandwidth: " + _bandwidth.toString());

            loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            loader.removeEventListener(Event.COMPLETE, onComplete);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);

            var obj:Object = new Object();
            obj.kbitDown = this._bandwidth;

            dispatchComplete(obj);
        }

        private function getDownloadTime(current:Number, start:Number):Number {
            return (current - start) / 1000;
        }

        private function getKbytes(bytes:Number):Number {
            return ((bytes * 8) / 1024);
        }

        private function getBandwidth(kBytes:Number, downloadTime:Number):Number {
            return (kBytes / downloadTime) * 0.93;
        }

        public function onProgress(event:ProgressEvent):void {
            this._bytes = event.currentTarget.bytesLoaded;
            this._downloadTime = getDownloadTime(getTimer(), this._startTime);
            this._bandwidth = getBandwidth(getKbytes(_bytes), this._downloadTime);

            if (this.maximumBytes && (this._bytes >= this.maximumBytes)) {
                loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
                loader.removeEventListener(Event.COMPLETE, onComplete);
                loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);

                loader.close();
                var e:Event = new Event(Event.COMPLETE);
                loader.dispatchEvent(e);
            }

            var obj:Object = new Object();
            obj.info = new Object();
            obj.info.count = this._bytes;

            dispatchStatus(obj);
        }

        override public function connect(host:String = null):void {
            log.debug("connect()");
            _referenceFileUrl = host;
            connection.connect(null);
        }

        override public function detect():void {
            log.debug("requesting reference file " + _referenceFileUrl);
            loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
            loader.addEventListener(Event.COMPLETE, onComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onError);

            var request:URLRequest = new URLRequest(_referenceFileUrl + "?" + Math.random());
            //#6 cache control headers don't work on chrome windows, just use the cache busting url param.
            request.method = URLRequestMethod.GET;
            loader.load(request);

            this._startTime = getTimer();
            log.debug("reference file download started at time: " + _startTime.toString());

        }

        protected function onError(event:IOErrorEvent):void {
            log.error();
            var obj:Object = new Object();
            obj.application = "";
            obj.description = event.text;
            dispatchFailed(obj);
        }
    }
}