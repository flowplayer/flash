/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.bwcheck.net {
    import org.flowplayer.controller.NetStreamCallbacks;
    import org.flowplayer.controller.NetStreamClient;
    import org.flowplayer.util.Log;
    import org.osmf.net.NetClient;
    import org.osmf.net.NetStreamCodes;

    /**
     * A OSMF and Flowplayer compatible NetStream client.
     */
    public class OsmfNetStreamClient extends NetClient implements NetStreamCallbacks {
        protected var log:Log = new Log(this);
        private var _fpClient:NetStreamClient;

        public function OsmfNetStreamClient(flowplayerNetStreamClient:NetStreamClient) {
            _fpClient = flowplayerNetStreamClient;
            //set a low priority here
            addHandler(NetStreamCodes.ON_PLAY_STATUS, onCustomPlayStatus, -1);
        }

        public function onMetaData(infoObject:Object):void {
            log.debug("onMetaData", infoObject);
            _fpClient.onMetaData(infoObject);
        }

        public function onXMPData(infoObject:Object):void {
            _fpClient.onXMPData(infoObject);
        }

        public function onCaption(cps:String, spk:Number):void {
            _fpClient.onCaption(cps, spk);
        }

        public function onCaptionInfo(obj:Object):void {
            _fpClient.onCaptionINfo(obj);
        }

        public function onImageData(obj:Object):void {
            _fpClient.onImageData(obj);
        }

        public function RtmpSampleAccess(obj:Object):void {
            _fpClient.RtmpSampleAccess(obj);
        }

        public function onTextData(obj:Object):void {
            _fpClient.onTextData(obj);
        }

        //fix for #336, send the correct playStatus object
        //fix for #347 create custom playstatus handler or else it breaks dynamic events
        //fix for #347 send rest arguments directly netstreamclient will handle arguments for wowza
        public function onCustomPlayStatus(...rest):void {
             var info:Object = rest.length > 1 ? rest[2] : rest[0];
            _fpClient.onPlayStatus(info);

        }
    }
}