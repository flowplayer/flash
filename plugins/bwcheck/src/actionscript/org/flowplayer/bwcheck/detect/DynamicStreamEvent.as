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

    public class DynamicStreamEvent extends Event {
        public static const SWITCH_STREAM:String = "switch_stream";

        private var _info:Object;

        public function DynamicStreamEvent(eventName:String) {
            super(eventName);
        }

        public function set info(obj:Object):void {
            _info = obj;
        }

        public function get info():Object {
            return _info;
        }

    }
}