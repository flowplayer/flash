/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Thomas Dubois, thomas _at_ flowplayer.org
 * Copyright (c) 2010 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.cloudfrontsignedurl {
    import flash.events.NetStatusEvent;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.StreamProvider;

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.PluginError;
    
    import org.flowplayer.util.Log;
    import org.flowplayer.util.URLUtil;
	import com.adobe.utils.StringUtil;

    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

    public class CloudFrontSignedUrl implements ClipURLResolver, Plugin {
        private const log:Log = new Log(this);
        private var _model:PluginModel;
        private var _config:Config;
        private var _player:Flowplayer;
		private var _signedUrlGenerator:SignedUrlGenerator;

        /*
         * URL resolving is used for HTTP
         */
        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            var signedUrl:String = _getUrl(clip);
			clip.setResolvedUrl(this, signedUrl);
			successListener(clip);
        }

		private function _getUrl(clip:Clip):String {
			
			var url:String = clip.getPreviousResolvedUrl(this);
			
			var isRTMPStream:Boolean = url.toLowerCase().indexOf('mp4:') == 0;
			if ( isRTMPStream )
				url = url.substr(4);
								
			var expires:Number = Math.round((new Date()).getTime() / 1000 + _config.timeToLive);
			
			var signedUrl:String = _signedUrlGenerator.signUrl(url, expires);
			if ( isRTMPStream )
				signedUrl = 'mp4:'+ signedUrl;
				
			return signedUrl;
		}

		private function _checkDomains():Boolean {
			if ( _config.domains.length == 0 )
				return true;
				
			var url:String = URLUtil.pageUrl;
			
			if ( url == null )
				return false;
			
			if ( URLUtil.localDomain(url) )
				return true;
			
			
			var domain:String = _getDomain();
			domain = domain.toLowerCase();	
			var strippedDomain:String = _stripSubdomain(domain);
			
			log.debug("Found domain "+ domain + " "+ strippedDomain);
				
			return _config.domains.indexOf(domain) != -1 || _config.domains.indexOf(strippedDomain) != -1;
		}
		
		private function _getDomain():String {
			var url:String = URLUtil.pageUrl;
			var domain:String = url.substr(url.indexOf('://')+3);
			if ( domain.indexOf('/') != -1 )
				domain = domain.substr(0, domain.indexOf('/'));
				
			if ( domain.indexOf(':') != -1 )
				domain = domain.substr(0, domain.indexOf(':'));
				
			return domain;
		}
		
		private function _stripSubdomain(domain:String):String {
			var els:Array = domain.split(".");
			var len:int = els.length;

			// 2 parts --> cannot strip
			if (len == 2) return domain;

			if ("co,com,net,org,web,gov,edu,".indexOf(els[len-2] + ",") != -1 || StringUtil.endsWith(domain, "ac.uk")) {
				// special ending (amazon.co.uk)
				return els[len-3] + "." + els[len-2] + "." + els[len-1];;
			} else {
				return els[len-2] + "." + els[len-1];
			}
		}
		
		public function set onFailure(listener:Function):void {
            
        }
		public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
			log.error("handeNetStatusEvent", event);
            return true;
        }

        public function onConfig(model:PluginModel):void {
            _model = model;
			_config = new Config();
			
			if ( ! model.config )
				return;
			
			// only allow to overide default config.
			if ( ! _config.privateKey )
				_config.privateKey = model.config['privateKey'];
				
			if ( _config.domains.length == 0 )
				_config.domains = model.config['domains'];	
				
			if ( ! _config.keyPairId )
				_config.keyPairId = model.config['keyPairId'];	
			
			if ( ! _config.timeToLive )
				_config.timeToLive = model.config['timeToLive'];
	    }

        public function onLoad(player:Flowplayer):void {
            _player = player;
			try {
			if ( ! _checkDomains() ) {
				_model.dispatchError(PluginError.ERROR, "Incorrect domain : " + _getDomain() +", allowed : "+ _config.domains.join(", ") +")");
				return;
			}
					} catch(e:Error) {
						log.error("error", e);
					}
			
			_signedUrlGenerator = new SignedUrlGenerator(_config);
			
			
            _model.dispatchOnLoad();
        }


        public function getDefaultConfig():Object {
            return null;
        }

 

    }
}