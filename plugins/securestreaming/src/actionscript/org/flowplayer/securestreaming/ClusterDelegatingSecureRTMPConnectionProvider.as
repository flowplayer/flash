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
package org.flowplayer.securestreaming {
    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;

    import org.flowplayer.controller.ConnectionProvider;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.util.Log;

    public class ClusterDelegatingSecureRTMPConnectionProvider implements ConnectionProvider {
        private const log:Log = new Log(this);
        private var _clusterProvider:ConnectionProvider;
        private var _failureListener:Function;
        private var _sharedSecret:String;

        public function ClusterDelegatingSecureRTMPConnectionProvider(config:Config, clusterProvider:ConnectionProvider) {
            _sharedSecret = config.token;
            clusterProvider["onConnectionStatus"] = onConnectionStatus;
            _clusterProvider = clusterProvider;
        }

        public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding:uint, connectionArgs:Array):void {
            _clusterProvider.connect(provider, clip, successListener, objectEncoding, connectionArgs);
        }

        private function onConnectionStatus(event:NetStatusEvent, connection:NetConnection):void {
            if (event.info.code == "NetConnection.Connect.Success") {
				if (event.info.secureToken != undefined) {
                    log.debug("onConnectionStatus(), received secure token");
                    SecureParallelRTMPConnector.handleSecureTokenResponse(event, connection, handleError, _sharedSecret);
                } else {
                    log.error("secureToken not recieved");
                    handleError("secureToken not received");
                }
            }
        }

        private function handleError(msg:String):void {
            if (_failureListener != null) {
                _failureListener(msg);
            }
        }

        public function set connectionClient(client:Object):void {
            _clusterProvider.connectionClient = client;
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
            _clusterProvider.onFailure = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return false;
        }
    }
}