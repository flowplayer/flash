/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.util {
public class DomainUtil {
//       private static var log:Log = new Log("org.flowplayer.util::DomainUtil");

        /**
         * Parses and returns the domain name from the specified URL.
         * @param url
         * @param stripSubdomains if true the top private domain name is returned with other subdomains stripped out
         * @return
         */
        public static function parseDomain(url:String, stripSubdomains:Boolean, secondaries:Array):String {
            var domain:String = getDomain(url);
            if (stripSubdomains || domain.indexOf("www.") == 0) {
                if (hasAllNumbers(domain)) {
                    trace("IP address in URL");
                    return parseIPAddressDomain(domain);
                }

                domain = stripSubdomain(domain, secondaries);
                trace("stripped out subdomain, resulted in " + domain);
            }
            return domain.toLowerCase();
        }

        private static function hasAllNumbers(domain:String):Boolean {
            var parts:Array = domain.split(".");
            for (var i:int = 0; i < parts.length; i++) {
                if (! isNumber(parts[i])) {
                    return false;
                }
            }
            return true;
        }

        private static function parseIPAddressDomain(domain:String):String {
            var parts:Array = domain.split(".");
            if (parts.length <= 2) return domain;
            return parts[parts.length - 2] + "." + parts[parts.length - 1];
        }

        private static function isNumber(n:String):Boolean {
           return !isNaN(parseFloat(n)) && isFinite(n as Number);
        }

       public static function stripSubdomain(host:String, secondaries:Array):String {
//          log.debug("secondaries: " + secondaries);

          host = host.toLowerCase();
          var bits:Array = host.split(".");

          if (bits.length < 2) return host;

          var secondary:String = bits.slice(bits.length - 2).join('.');
          if (bits.length >= 3 && secondaries.indexOf(secondary) >= 0) {
             return bits.slice(bits.length - 3).join('.');
          }
          return bits.slice(bits.length - 2).join('.');
       }

        public static function getDomain(url:String):String {
            var schemeEnd:int = getSchemeEnd(url);
            var domain:String = url.substr(schemeEnd);
            var endPos:int = getDomainEnd(domain);
            return domain.substr(0, endPos).toLowerCase();
        }

        internal static function getSchemeEnd(url:String):int {
            var pos:int = url.indexOf("///");
            if (pos >= 0) return pos + 3;
            pos = url.indexOf("//");
            if (pos >= 0) return pos + 2;
            return 0;
        }

        internal static function getDomainEnd(domain:String):int {
            var colonPos:int = domain.indexOf(":");
            var pos:int = domain.indexOf("/");
            if (colonPos > 0 && pos > 0 && colonPos < pos) return colonPos;
            if (pos > 0) return pos;

            pos = domain.indexOf("?");
            if (pos > 0) return pos;
            return domain.length;
        }

        public static function isLocal(url:String):Boolean {
            trace("localDomain? " + url);
            if (url.indexOf("http://localhost") == 0) return true;
            if (url.indexOf("http://localhost:") == 0) return true;
            if (url.indexOf("file://") == 0) return true;
            if (url.indexOf("http://127.0.0.1") == 0) return true;
            if (url.indexOf("http://") == 0) return false;
            if (url.indexOf("/") == 0) return true;
            return false;
        }

        public static function allowCodeLoading(resourceUrl:String, secondaries:Array):Boolean {
            if (! URLUtil.isCompleteURLWithProtocol(resourceUrl)) return true;
            var playerUrl:String = URLUtil.playerBaseUrl;

            if (isLocal(playerUrl)) return true;

            var playerDomain:String = parseDomain(playerUrl, true, secondaries);
            var resourceDomain:String = parseDomain(resourceUrl, true, secondaries);

            trace("player domain " + playerDomain);
            trace("resource domain " + resourceDomain);
            return playerDomain == resourceDomain;
        }
    }
}
