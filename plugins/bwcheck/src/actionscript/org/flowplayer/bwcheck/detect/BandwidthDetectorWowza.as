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
    public class BandwidthDetectorWowza extends AbstractDetectionStrategy {

        public function onBwCheck(obj:Object):Boolean {
            return onBWCheck(obj);
        }

        public function onBWCheck(obj:Object):Boolean {
            log.debug("onBWCheck");
            dispatchStatus(obj);
            return true;
        }

        public function onBWDone(...args):void {
            log.debug("onBWDone, ");
            //#47 close the connection or else wowza dispatches two bwcheck events.
            connection.close();
            var obj:Object = new Object();
            var kbitDown:int = args[0];
            var deltaDown:int = args[1];
            var deltaTime:int = args[2];
            var latency:int = args[3];
            obj.kbitDown = kbitDown;
            obj.delatDown = deltaDown;
            obj.deltaTime = deltaTime;
            obj.latency = latency;
            dispatchComplete(obj);
        }

        override public function connect(host:String = null):void {
            connection.connect(host, true);
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