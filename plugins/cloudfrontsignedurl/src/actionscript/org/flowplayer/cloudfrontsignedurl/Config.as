/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Thomas Dubois, thomas _at_ flowplayer.org
 * Copyright (c) 2010 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.cloudfrontsignedurl {

    public class Config {
        private var _privateKey:String = "";
		private var _keyPairId:String  = "";
		
		private var _timeToLive:Number = 5*60;
		private var _domains:Array	   = [];
		
		
        public function get privateKey():String {
            return _privateKey;
        }

        public function set privateKey(val:String):void {
            _privateKey = val;
        }

		public function get keyPairId():String {
            return _keyPairId;
        }

        public function set keyPairId(val:String):void {
            _keyPairId = val;
        }

        public function toString():String {
            return "[Config] keyPairId = '" + _keyPairId + "'";
        }

        public function get timeToLive():Number {
            return _timeToLive;
        }

        public function set timeToLive(val:Number):void {
            _timeToLive = val;
        }

        public function get domains():Array {
            return _domains;
        }

        public function set domains(value:Array):void {
            _domains = value;
        }
    }
}