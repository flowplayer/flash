/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.smil {
    public class Config {
        private var _rtmpProvier:String = "rtmp";

        public function get rtmpProvier():String {
            return _rtmpProvier;
        }

        public function set rtmpProvier(value:String):void {
            _rtmpProvier = value;
        }
    }
}