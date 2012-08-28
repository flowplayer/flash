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

    public class Config {
        private var _timestamp:String;
        private var _timestampUrl:String;
        private var plugin:String;
        private var _token:String = "sn983pjcnhupclavsnda";
        private var _domains:Array = [];

        public function get timestampUrl():String {
            return _timestampUrl;
        }

        public function set timestampUrl(val:String):void {
            _timestampUrl = val;
        }

        public function toString():String {
            return "[Config] timestampUrl = '" + _timestampUrl + "'";
        }

        public function get token():String {
            return _token;
        }

        public function set token(val:String):void {
            _token = val;
        }

        public function get timestamp():String {
            return _timestamp;
        }

        public function set timestamp(val:String):void {
            _timestamp = val;
        }

        public function get clusterPlugin():String {
            return plugin;
        }

        public function set clusterPlugin(value:String):void {
            plugin = value;
        }

        public function get domains():Array {
            return _domains;
        }

        public function set domains(value:Array):void {
            _domains = value;
        }
    }
}