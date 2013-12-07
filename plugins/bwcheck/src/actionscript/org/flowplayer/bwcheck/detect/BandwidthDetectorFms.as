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
    public class BandwidthDetectorFms extends AbstractDetectionStrategy {

    private var _host:String;

    public function set host(host:String):void {
        _host = host;
    }


    public function onBWCheck(... rest):Number {
        log.debug("onBWCheck");
        dispatchStatus(rest);
        return 0;
    }

    private function checkBandwidth():void {
        connection.call(_service, null);
    }

    public function onBWDone(... rest):void {
        //fixes for #218 cloudfront FMS is unstable to returns zero on the first few calls
        //fix for #234 was dispatching event on the first call
        if (rest[0] == 0 || rest[0] == null) {
            log.debug("Bandwidth Returned is zero starting again");
            connection.call(_service, null);
            //setTimeout(checkBandwidth, 1000);
        } else {
            connection.close();
            log.debug("onBWDone() " + rest);
            var obj:Object = new Object();
            obj.kbitDown = rest[0];
            obj.latency = rest[3];
            dispatchComplete(obj);
        }
    }

    override public function connect(host:String = null):void {
        connection.connect(host);
    }

    override public function detect():void {
        log.debug("detect() calling service " + _service);
        connection.client = this;
        connection.call(_service, null);
    }

    public function close(... rest):void {
        log.debug("close()");
    }
}
}