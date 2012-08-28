/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.f4m.config {


    public class Config {

        private var _version:Number = 1;
        private var _dvrBufferTime:int = 4;
        private var _liveBufferTime:int = 2;
        private var _dynamicBufferTime:int = 4;
        private var _dvrDynamicBufferTime:int = 4;
        private var _liveDynamicBufferTime:int = 4;
        private var _includeApplicationInstance:Boolean = false;
        private var _retryInterval:int = 10;
        private var _maxRetries:int = 100;

        public function get version():Number {
            return _version;
        }

        public function set version(value:Number):void {
            _version = value;
        }

        public function set dvrBufferTime(value:int):void
        {
            _dvrBufferTime = value;
        }

        public function get dvrBufferTime():int
        {
            return _dvrBufferTime;
        }

        public function set liveBufferTime(value:int):void
        {
            _liveBufferTime = value;
        }

        public function get liveBufferTime():int
        {
            return _liveBufferTime;
        }

        public function set dynamicBufferTime(value:int):void
        {
            _dynamicBufferTime = value;
        }

        public function get dynamicBufferTime():int
        {
            return _dynamicBufferTime;
        }

        public function set dvrDynamicBufferTime(value:int):void
        {
            _dvrDynamicBufferTime = value;
        }

        public function get dvrDynamicBufferTime():int
        {
            return _dvrDynamicBufferTime;
        }

        public function set liveDynamicBufferTime(value:int):void
        {
            _liveDynamicBufferTime = value;
        }

        public function get liveDynamicBufferTime():int
        {
            return _liveDynamicBufferTime;
        }

        public function set includeApplicationInstance(value:Boolean):void
        {
            _includeApplicationInstance = value;
        }

        public function get includeApplicationInstance():Boolean
        {
            return _includeApplicationInstance;
        }

        public function set retryInterval(value:int):void
        {
            _retryInterval = value;
        }

        public function get retryInterval():int
        {
            return _retryInterval * 1000;
        }

        public function set maxRetries(value:int):void
        {
            _maxRetries = value;
        }

        public function get maxRetries():int
        {
            return _maxRetries;
        }


        
    }
}
