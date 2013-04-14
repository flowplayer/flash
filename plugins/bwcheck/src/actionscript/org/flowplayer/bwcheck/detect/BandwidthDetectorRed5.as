/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.detect {

    /**
     * @author danielr
     */
    public class BandwidthDetectorRed5 extends AbstractDetectionStrategy {

        private var info:Object = new Object();

        public function BandwidthDetectorRed5() {
            _service = "bwCheckService.onServerClientBWCheck";
        }

        public function onBWCheck(obj:Object):void {
            dispatchStatus(obj);
        }

        public function onBWDone(obj:Object):void {
            dispatchComplete(obj);
        }

        override public function connect(host:String = null):void {
            connection.connect(host);
        }

        protected function onStatus(obj:Object):void {
            switch (obj.code) {
                case "NetConnection.Call.Failed":
                    dispatchFailed(obj);
                    break;
            }

        }
    }
}
