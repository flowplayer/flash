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
package org.flowplayer.net {
    import flash.utils.flash_proxy;

    import org.flowplayer.config.Config;
    import org.flowplayer.controller.NetStreamCallbacks;
    import org.flowplayer.controller.NetStreamClient;
    import org.flowplayer.model.Clip;
    import org.flowplayer.util.Log;
    import org.osmf.net.NetClient;
    import org.osmf.net.NetStreamCodes;

    /**
     * A OSMF and Flowplayer compatible NetStream client.
     */
    public class OsmfNetStreamAdapter extends NetClient implements NetStreamCallbacks {
        protected var log:Log = new Log(this);
        private var _fpClient:NetStreamClient;
        private var _onTransitionComplete:Function;
        private var _osmfClient:NetClient;

        public function OsmfNetStreamAdapter(flowplayerNetStreamClient:NetStreamClient, serverType:String = "fms", osmfClient:NetClient = null) {
            log.debug("OsmfNetStreamAdapter()");
            _fpClient = flowplayerNetStreamClient;
            _osmfClient = osmfClient;
            addHandler(NetStreamCodes.ON_PLAY_STATUS, serverType == "wowza" ? playStatusHandlerWowza : playStatusHandler);
        }

        public static function fromOsmfClient(osmfClient:NetClient, clip:Clip, config:Config):OsmfNetStreamAdapter {
            return new OsmfNetStreamAdapter(new NetStreamClient(clip, config, null), null, osmfClient);
        }

        // **** NetStreamCallbacks ****/

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

        public function set onTransitionComplete(onTransitionComplete:Function):void {
            _onTransitionComplete = onTransitionComplete;
        }

        public function playStatusHandler(info:Object):void {
            log.debug("playStatusHandler() -- " + info.code, info);
            if (info.code == "NetStream.Play.TransitionComplete" && _onTransitionComplete != null) {
                _onTransitionComplete();
                return;
            }
        }

        public function playStatusHandlerWowza(info:Object, info2:Object, info3:Object):void {
            log.debug("onPlayStatus() - " + info + ", " + info2 + ", " + info3);
            if (info3 && info3.code == "NetStream.Play.TransitionComplete" && _onTransitionComplete != null) {
                _onTransitionComplete();
                return;
            }
        }


        // *** OSMF NetClient's methods ****/

        override public function addHandler(name:String, handler:Function, priority:int=0):void {
            osmfClient.addHandler(name, handler, priority);
        }

        override public function removeHandler(name:String,handler:Function):void {
            osmfClient.removeHandler(name, handler);
        }

//        override flash_proxy function callProperty(methodName:*, ... args):* {
//            return osmfClient.callProperty.apply(methodName, args);
//        }
//
//        override flash_proxy function hasProperty(name:*):Boolean {
//            return osmfClient.hasProperty(name);
//        }

        private function get osmfClient():NetClient {
            return _osmfClient || this;
        }
    }
}