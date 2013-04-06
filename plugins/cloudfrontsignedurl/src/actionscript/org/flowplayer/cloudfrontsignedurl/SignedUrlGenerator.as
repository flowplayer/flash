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

	import org.flowplayer.model.Clip;
	import com.hurlant.crypto.rsa.RSAKey;
	import com.hurlant.crypto.hash.SHA1;
    import flash.utils.ByteArray;
    import com.hurlant.util.Hex;
    import com.hurlant.util.der.PEM;
 	import com.hurlant.util.Base64;

	import org.flowplayer.util.Log;

    public class SignedUrlGenerator {
		
		private var log:Log = new Log(this);
		private var _config:Config = null;
		private var _rsa:RSAKey = null;
		
		
		public function SignedUrlGenerator(config:Config) {
			_config = config;
			_rsa	= PEM.readRSAPrivateKey(_config.privateKey);
		}
		
		public function signUrl(url:String, expires:Number):String {
			var resource:String = url;
			
			var rawPolicy:String 	= '{"Statement":[{"Resource":"'+ url +'","Condition":{"DateLessThan":{"AWS:EpochTime":'+ expires +'}}}]}';
			log.debug("Using policy "+ rawPolicy);
			
			var safePolicy:String 	= getSafeString(rawPolicy);
			
			var signature:String 	= getSignature(rawPolicy);
			var safeSignature:String= getSafeString(signature);
			
			var queryString:String 	= 'Expires='+ expires +'&Signature='+ safeSignature +'&Key-Pair-Id='+ _config.keyPairId;
			var separator:String   	= resource.indexOf('?') == -1 ? '?' : '&';
			
			var signedUrl:String = url + separator + queryString;
			log.debug("Generated url "+ signedUrl);
			return signedUrl;
		}
		
		private function getSignature(rawPolicy:String):String {
			var hexRawPolicy:ByteArray = Hex.toArray(Hex.fromString(rawPolicy));

			var dst:ByteArray = new ByteArray();
			_rsa.sign(hexRawPolicy, dst, hexRawPolicy.length, SHA1DigestPadding);
			
			var signature:String = com.hurlant.util.Base64.encodeByteArray(dst);
			
			return signature;
		}
		
		// thousand thanks to Kenji Urushima, derived from http://www9.atwiki.jp/kurushima/pub/jsrsa/
		private function SHA1DigestPadding(src:ByteArray, end:int, n:uint, type:uint = 0x02):ByteArray {
			var pmStrLen:Number = _rsa.n.bitLength() / 4;
			
			var _RSASIGN_SHA1_DIHEAD:String = "3021300906052b0e03021a05000414";
			
			var sha1:SHA1 = new SHA1();
			var sHashHex:ByteArray = sha1.hash(src);
			
			var sHead:String = "0001";
			var sTail:String = "00" + _RSASIGN_SHA1_DIHEAD + Hex.fromArray(sHashHex);
		 	var sMid:String = "";
		  	var fLen:Number = pmStrLen - sHead.length - sTail.length;
		  	for (var i:int = 0; i < fLen; i += 2) {
				sMid += "ff";
			}
			
			var sPaddedMessageHex:String = sHead + sMid + sTail;
			
			return Hex.toArray(sPaddedMessageHex);
		}
		
		private function getSafeString(str:String):String {
			return str.replace(/\+/g, '-').replace(/=/g, '_').replace(/\//g, '~');
		}
    }
}