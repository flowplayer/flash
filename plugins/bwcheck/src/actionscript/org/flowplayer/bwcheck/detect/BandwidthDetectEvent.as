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

    public class BandwidthDetectEvent extends Event {
        public static const DETECT_STATUS:String = "detect_status";
        public static const DETECT_COMPLETE:String = "detect_complete";
        public static const DETECT_FAILED:String = "detect_failed";
        public static const CLUSTER_FAILED:String = "cluster_failed";

        private var _info:Object;

        public function BandwidthDetectEvent(eventName:String) {
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