/*
 *    Copyright (c) 2008-2011 Flowplayer Oy *
 *    This file is part of FlowPlayer.
 *
 *    FlowPlayer is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    FlowPlayer is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with FlowPlayer.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.flowplayer.rtmp {
    import flash.net.NetConnection;

    import flash.net.Responder;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.util.Log;

    public class DurationQueryingRTMPConnectionProvider extends RTMPConnectionProvider{
        private var _durationFunc:String;

        //        private var _onSuccess:Function;
        private var _clip:Clip;

        public function DurationQueryingRTMPConnectionProvider(config:Config, durationFunc:String) {
            super(config);
            _durationFunc = durationFunc;
        }


        override public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding:uint, connectionArgs:Array):void {
//            clip.onConnectionEvent(onConnectionEvent);
            _clip = clip;
//            _onSuccess = successListener;
            super.connect(provider, clip, function(connection:NetConnection):void {
                getStreamLength(connection, clip);
                successListener(connection);
            }, objectEncoding, connectionArgs);
        }

        private function getStreamLength(connection:NetConnection, clip:Clip):void {
            log.debug("getStreamLength(), calling duration for stream named '" + clip.url + "'");
            connection.call(_durationFunc, new Responder(onResult), clip.url);
        }

        private function onResult(info:Object):void {
            log.debug("onResult(), received result " + info);
            _clip.duration = info as Number;
        }
//
//        private function onConnectionEvent():void {
//        }
    }
}