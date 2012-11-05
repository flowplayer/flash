/*
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2012 Electroteque Media
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.electroteque.m3u8 {

    public class Config {
        private var _retryInterval:int = 10;
        private var _maxRetries:int = 100;

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
