/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.securestreaming {


    import org.flowplayer.controller.NetStreamControllingStreamProvider;
    import org.flowplayer.controller.ParallelRTMPConnectionProvider;
    import org.flowplayer.controller.ParallelRTMPConnector;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;

    /**
	 * @author api
	 */
	internal class SecureRTMPConnectionProvider extends ParallelRTMPConnectionProvider {

        private var _sharedSecret:String;
		private var _provider:NetStreamControllingStreamProvider;
		
        public function SecureRTMPConnectionProvider(sharedSecret:String) {
			super(null);
			
            log.debug("SecureRTMPConnectionProvider()");
            _sharedSecret = sharedSecret;
            //log.debug("Using token (shared secret) " + _sharedSecret);
        }

		override public function connect(ignored:StreamProvider, clip:Clip, successListener:Function, objectEncoding: uint, connectionArgs:Array):void {
			_provider = ignored as NetStreamControllingStreamProvider;
			super.connect(ignored, clip, successListener, objectEncoding, connectionArgs);
		}

		override protected function createConnector(url:String):ParallelRTMPConnector {
			return new SecureParallelRTMPConnector(url, _sharedSecret, _connectionClient, onConnectorSuccess, onConnectorFailure);
		}

        //#391 add message argument required to send message through to the failure callback
        override protected function onConnectorFailure(message:String = null):void {
            _failureListener(message);
        }

        private function isFailedOrNotUsed(connector:ParallelRTMPConnector):Boolean {
            if (! connector) return true;
            return connector.failed;
        }
		
		override protected function getNetConnectionUrl(clip:Clip):String {
		   if (isRtmpUrl(clip.completeUrl)) {
                var url:String = clip.completeUrl;
                var lastSlashPos:Number = url.lastIndexOf("/");
                return url.substring(0, lastSlashPos);
            }
            if (clip.customProperties && clip.customProperties.netConnectionUrl) {
                return clip.customProperties.netConnectionUrl;
            }
            return _provider ? _provider.model.config.netConnectionUrl : null;
        }
	}
}
