/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.akamai {
    import org.flowplayer.model.ClipType;
    import org.flowplayer.util.Log;

    public class URLUtil {
        private static var log:Log = new Log("org.flowplayer.akamai::URLUtil"); 

        public static function parseURL(url:String):Object
        {
            var parseResults:Object = {};
            var indexes:Array = parseProtocol(url, parseResults);
            log.debug("protocol is " + parseResults.protocol);

            if ( parseResults.protocol != null && ["rtmp:/", "rtmpt:/", "rtmps:/", "rtmpe:/", "rtmpte:/"].indexOf(parseResults.protocol) >= 0) {
                parseResults.isRTMP = true;

                if (url.charAt(indexes[0]) == '/') {
                    indexes = parseServer(url, indexes, parseResults);
                    if (! indexes) return parseResults;
                }

                if (url.charAt(indexes[0]) == '?') {
                    parseWrappedRtmp(url, indexes, parseResults);
                    return parseResults;
                }

                parseAppAndStreamName(url, indexes, parseResults);
            }
            else {
                // is http, just return the full url received as streamName
                parseResults.isRTMP = false;
                parseResults.streamName = url;
            }
            return parseResults;
        }

        private static function parseAppAndStreamName(url:String, indexes:Array, parseResults:Object):void {
            var startIndex:uint = indexes[0];
            var endIndex:uint = indexes[1];
            endIndex = url.indexOf("/", startIndex);
            if (endIndex < 0)
            {
                parseResults.appName = url.slice(startIndex, url.length);
                return;
            }
            parseResults.appName = url.slice(startIndex, endIndex);
            startIndex = endIndex + 1;

            // check for instance name to be added to application name
            endIndex = url.indexOf("/", startIndex);
            if (endIndex < 0)
            {
                parseResults.streamName = url.slice(startIndex, url.length);
                parseResults.streamName = stripFileExtension(parseResults.streamName);
                return;
            }
            parseResults.appName += "/";
            parseResults.appName += url.slice(startIndex, endIndex);
            startIndex = endIndex + 1;

            // get flv name
            parseResults.streamName = url.slice(startIndex, url.length);
            parseResults.streamName = stripFileExtension(parseResults.streamName);
        }

        private static function parseWrappedRtmp(url:String, indexes:Array, parseResults:Object):void {
            var subURL:String = url.slice(indexes[0] + 1, url.length);
            var subParseResults:Object = parseURL(subURL);
            if (!subParseResults.protocol || !subParseResults.isRTMP)
                throw new Error("Invalid URL: " + url);
            parseResults.wrappedURL = "?";
            parseResults.wrappedURL += subParseResults.protocol;
            if (subParseResults.serverName != null)
            {
                parseResults.wrappedURL += "/";
                parseResults.wrappedURL +=  subParseResults.server;
            }
            if (subParseResults.wrappedURL != null)
            {
                parseResults.wrappedURL += "/?";
                parseResults.wrappedURL +=  subParseResults.wrappedURL;
            }
            parseResults.appName = subParseResults.appName;
            parseResults.streamName = subParseResults.streamName;
        }

        private static function parseServer(url:String, indexes:Array, parseResults:Object):Array {
            log.debug("parseServer() " + url);
            var startIndex:uint = indexes[0];
            var endIndex:uint = indexes[1];
            startIndex++;
            // get server (and maybe port)
            var colonIndex:Number = url.indexOf(":", startIndex);
            var slashIndex:Number = url.indexOf("/", startIndex);
            log.debug("colon at " + colonIndex + ", slash at " + slashIndex);
            if (slashIndex < 0)
            {
                if (colonIndex < 0)
                    parseResults.serverName = url.slice(startIndex, url.length);
                else
                {
                    endIndex = colonIndex;
                    parseResults.portNumber = url.slice(startIndex, endIndex);
                    startIndex = endIndex + 1;
                    parseResults.serverName = url.slice(startIndex, url.length);
                }
                return null;
            }
            if (colonIndex >= 0 && colonIndex < slashIndex)
            {
                endIndex = colonIndex;
                parseResults.serverName = url.slice(startIndex, endIndex);
                startIndex = endIndex + 1;
                endIndex = slashIndex;
                parseResults.portNumber = url.slice(startIndex, endIndex);
            }
            else
            {
                endIndex = slashIndex;
                parseResults.serverName = url.slice(startIndex, endIndex);
            }
            startIndex = endIndex + 1;
            return [startIndex, endIndex];
        }

        private static function parseProtocol(url:String, parseResults:Object):Array {
            var startIndex:uint = 0;
            var endIndex:uint = url.indexOf(":/", startIndex);
            if (endIndex >= 0) {
                endIndex += 2;
                parseResults.protocol = url.slice(startIndex, endIndex);
                parseResults.isRelative = false;
            }
            else {
                parseResults.isRelative = true;
            }
            return [endIndex, endIndex];
        }

        public static function stripFileExtension(name:String):String {
            var knownExtensions:Array = ClipType.knownFileExtensions();
            log.debug("known file extensions", knownExtensions);

            // strip out if one of the known extensions
            if (knownExtensions.indexOf(name.slice(-4, name.length).toLowerCase()) >= 0) {
                return name.slice(0, -5);
            }
            if (knownExtensions.indexOf(name.slice(-3, name.length).toLowerCase()) >= 0) {
                return name.slice(0, -4);
            }
            return name;
        }
    }
}