/*
 * Copyright 2008 Adobe Systems Inc., 2008 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Contributor(s):
 *   Zwetan Kjukov <zwetan@gmail.com>.
 *   Marc Alcaraz <ekameleon@gmail.com>.
 *   Nick Mihailovski <nickski15@gmail.com>.
 */

package com.google.analytics.core
{
    import com.google.analytics.log;
    import com.google.analytics.utils.Environment;
    import com.google.analytics.utils.Variables;
    import com.google.analytics.v4.Configuration;
    
    import core.Logger;
    import core.version;
    
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    /**
     * Google Analytics Tracker Code (GATC)'s GIF request module.
     * This file encapsulates all the necessary components that are required to
     * generate a GIF request to the Google Analytics Back End (GABE).
     */
    public class GIFRequest
    {
        /**
         * The largest URI request length allowed by Google Analytics
         * collectors. Requests URI lengths greater than this value will not
         * be processed by Google Analytics.
         * @private
         */ 
        private static const MAX_REQUEST_LENGTH:Number = 2048;
        
        private var _log:Logger;
        
        private var _config:Configuration;
        private var _buffer:Buffer;
        private var _info:Environment;
        
        private var _utmac:String;
        
        private var _count:int;

        /**
        * @private
        * contains the list of the different requests
        * in a simple object form
        * { start:Date, request:URLRequest, end:Date }
        * the index of the array as the id (or order) of the request
        */
        private var _requests:Array;
        
        /**
         * Creates a new GIFRequest instance.
         */
        public function GIFRequest( config:Configuration, buffer:Buffer, info:Environment )
        {
            LOG::P{ _log = log.tag( "GIFRequest" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
            _config = config;
            _buffer = buffer;
            _info   = info;
            
            clearRequests();
        }
        
        private function onSecurityError( event:SecurityErrorEvent ):void
        {
            LOG::P{ _log.v( "onSecurityError()" ); }
            
            var info:LoaderInfo = event.target as LoaderInfo;
            var name:String     = info.loader.name;
            var url:String      = info.url;
            
            var ro:RequestObject = _requests[ name ];
                ro.complete();
            
            _cleanAndRemove( info );
            
            LOG::P{ _log.i( "Gif Request #" + name + " not sent" ); }
            LOG::P{ _log.e( "SecurityError on \"" + url + "\":\n" + event.text ); }
        }
        
        private function onIOError( event:IOErrorEvent ):void
        {
            LOG::P{ _log.v( "onIOError()" ); }
            
            var info:LoaderInfo = event.target as LoaderInfo;
            var name:String     = info.loader.name;
            var url:String      = info.url;
            
            var ro:RequestObject = _requests[ name ];
                ro.complete();
            
            _cleanAndRemove( info );
            
            LOG::P{ _log.i( "Gif Request #" + name + " not sent" ); }
            LOG::P{ _log.e( "IOError on \"" + url + "\":\n" + event.text ); }
        }
        
        private function onComplete( event:Event ):void
        {
            LOG::P{ _log.v( "onComplete()" ); }
            
            var info:LoaderInfo = event.target as LoaderInfo;
            var name:String     = info.loader.name;
            var url:String      = info.url;
            
            
            
            var ro:RequestObject = _requests[ name ];
                ro.complete();
            
            _cleanAndRemove( info );
            
            LOG::P{ _log.i( "Gif Request #" + name + " sent" ); }
            LOG::P{ _log.d( url ); }
        }
        
        private function _cleanAndRemove( info:LoaderInfo ):void
        {
            LOG::P{ _log.v( "_cleanAndRemove()" ); }
            
            info.loader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
            info.loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onComplete );
            info.loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
            
            var FP10:version    = new version( 10, 0 );
            var current:version = _info.flashVersion;
            
            if( current < FP10 )
            {
                info.loader.unload();
            }
            else
            {
                info.loader["unloadAndStop"]( true );
            }
            
        }
        
        private function _sendLocalRequest( variables:Variables ):void
        {
            LOG::P{ _log.v( "_sendLocalRequest()" ); }
            
            var localPath:String = _info.locationSWFPath;
 
            if( localPath.lastIndexOf( "/" ) > 0 )
            {
                localPath = localPath.substring( 0, localPath.lastIndexOf( "/" ) );
            }
            
            var localImage:URLRequest = new URLRequest();
            
            if( _config.localGIFpath.indexOf( "http" ) == 0 )
            {
                localImage.url  = _config.localGIFpath;
            }
            else
            {
                localImage.url  = localPath + _config.localGIFpath;
            }
            
            //localImage.data = variables;
            localImage.url +=  "?"+variables.toString();
            sendRequest( localImage );
        }
        
        private function _sendRemoteRequest( variables:Variables ):void
        {
            LOG::P{ _log.v( "_sendRemoteRequest()" ); }
            
            var remoteImage:URLRequest = new URLRequest();
            
            /* get remote address (depending on protocol),
               then append rest of metrics / data
            */
            if( _info.protocol == "https" )
            {
                remoteImage.url = _config.secureRemoteGIFpath;
            }
            else if( _info.protocol == "http" )
            {
                remoteImage.url = _config.remoteGIFpath;
            }
            else
            {
                remoteImage.url = _config.remoteGIFpath;
            }
            
            variables.utmac = utmac;
            variables.utmcc = encodeURIComponent(utmcc);
            
            //remoteImage.data = variables;
            remoteImage.url +=  "?"+variables.toString();
            sendRequest( remoteImage );
        }
        
        
        /**
         * Account String. Appears on all requests.
         * <p><b>Example :</b> utmac=UA-2202604-2</p>
         */
        public function get utmac():String
        {
            return _utmac;
        }
        
        /**
         * Tracking code version
         * <p><b>Example :</b> utmwv=1</p>
         */
        public function get utmwv():String
        {
            return _config.version;
        }
        
        /**
         * Unique ID generated for each GIF request to prevent caching of the GIF image.
         * <p><b>Example :</b> utmn=1142651215</p>
         */
        public function get utmn():String
        {
            return generate32bitRandom() as String;
        }
        
        /**
         * Host Name, which is a URL-encoded string.
         * <p><b>Example :</b> utmhn=x343.gmodules.com</p>
         */
        public function get utmhn():String
        {
            return _info.domainName;
        }
        
        /**
         * Sample rate
         */
        public function get utmsp():String
        {
            return (_config.sampleRate * 100) as String;
        }
        
        /**
         * Cookie values. This request parameter sends all the cookies requested from the page.
         * 
         * ex:
         * utmcc=__utma%3D117243.1695285.22%3B%2B__utmz%3D117945243.1202416366.21.10.utmcsr%3Db%7Cutmccn%3D(referral)%7Cutmcmd%3Dreferral%7Cutmcct%3D%252Fissue%3B%2B
         * 
         * note:
         * you first get each cookie
         * __utma=117243.1695285.22;
         * __utmz=117945243.1202416366.21.10.utmcsr=b|utmccn=(referral)|utmcmd=referral|utmcct=%2Fissue;
         * the rhs can already be URLencoded , see for ex %2Fissue is for /issue
         * you join all the cookie and separate them with +
         * __utma=117243.1695285.22;+__utmz=117945243.1202416366.21.10.utmcsr=b|etc
         * the you URLencode all
         * __utma%3D117243.1695285.22%3B%2B__utmz%3D117945243.1202416366.21.10.utmcsr%3Db%7Cetc
         */
        public function get utmcc():String
        {
            var cookies:Array = [];
            
            if( _buffer.hasUTMA() )
            {
                cookies.push( _buffer.utma.toURLString() + ";" );
            }
            
            if( _buffer.hasUTMZ() )
            {
                cookies.push( _buffer.utmz.toURLString() + ";" );
            }
            
            if( _buffer.hasUTMV() )
            {
                cookies.push( _buffer.utmv.toURLString() + ";" );
            }
            
            //delimit cookies by "+"
            //NOTE: forgot to URLEncode ?
            return cookies.join( "+" );
        }
        
        /**
         * Returns an array of request objects.
         */
        public function get requests():Array
        {
            return _requests;
        }
        
        /**
         * reset the array of requests.
         */
        public function clearRequests():void
        {
            LOG::P{ _log.v( "clearRequests()" ); }
            
            _count = 0;
            _requests = [];
        }
        
        /**
         * Updates the token in the bucket.
         * This method first calculates the token delta since
         * the last time the bucket count is updated.
         * 
         * If there are no change (zero delta), then it does nothing.
         * However, if there is a delta, then the delta is added to the bucket,
         * and a new timestamp is updated for the bucket as well.
         * 
         * To prevent spiking in traffic after a large number of token
         * has accumulated in the bucket (after a long period of time),
         * we have added a maximum capacity to the bucket.
         * In other words, we will not allow the bucket to accumulate
         * token passed a certain threshold.
         */
        public function updateToken():void
        {
            LOG::P{ _log.v( "updateToken()" ); }
            
            var timestamp:Number = new Date().getTime();
            var tokenDelta:Number;
            
            // calculate the token count increase since last update
            tokenDelta = (timestamp - _buffer.utmb.lastTime) * (_config.tokenRate / 1000);
            LOG::P{ _log.i( "tokenDelta: " + tokenDelta ); }
            
            // only update token when there is a change
            if( tokenDelta >= 1 )
            {
                //Only fill bucket to capacity
                _buffer.utmb.token    = Math.min( Math.floor( _buffer.utmb.token + tokenDelta ) , _config.bucketCapacity );
                _buffer.utmb.lastTime = timestamp;
                
                LOG::P{ _log.i( "utmb = " + _buffer.utmb.toString() ); }
            }
        }
        
        /*
         * Sends a request to the server. Google Analytics collectors only
         * support URIs < 2048 characters in length. If the request is too
         * long, they will not get processed. Instead of sending erroneous
         * data, this library will silently drop requests greater than the
         * max request length.
         * @param request The URLRequest object with the data to send to
         *     Google Analytics.
         */
        public function sendRequest( request:URLRequest ):void
        {
            LOG::P{ _log.v( "sendRequest()" ); }
            
            if( request.url.length > MAX_REQUEST_LENGTH )
            {
               LOG::P{ _log.e( "No request sent. URI length too long." ); }
               return;
            }
            
            /* note:
               when the gif request is send too fast
               we are probably confusing our listeners order
               
               we should put each request in an ndexed array
               and pass the index value in the loader.name or something
               so when we get the event.target we can fnd back the current index
               
               by commenting the _removeListeners call
               I can see gif requests in Google Chrome
               Firefox still does not shows those request
            */
            var loader:Loader = new Loader();
                loader.name   = String(_count++);
                
            var context:LoaderContext = new LoaderContext( false );
            
                loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
                loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
                loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
            
            _requests[ loader.name ] = new RequestObject( request );
            
            try
            {
                loader.load( request, context );
            }
            catch( e:Error )
            {
                LOG::P{ _log.e( "\"Loader.load()\" could not instanciate Gif Request" ); }
            }
        }
        
        /**
         * Send the Gif Request to the server(s).
         */
        public function send( account:String, variables:Variables = null,
                              force:Boolean = false, rateLimit:Boolean = false ):void
        {
            LOG::P{ _log.v( "send( " + [account,variables,force,rateLimit].join(", ") + " )" ); }
            
             _utmac = account;
             
             if( !variables ) { variables = new Variables(); }
             
             variables.URIencode = false;
             variables.pre  = [ "utmwv", "utmn", "utmhn", "utmt", "utme",
                                "utmcs", "utmsr", "utmsc", "utmul", "utmje",
                                "utmfl", "utmdt", "utmhid", "utmr", "utmp" ];
             variables.post = [ "utmcc" ];
             
             LOG::P{ _log.i( "tracking: " + _buffer.utmb.trackCount+"/"+_config.trackingLimitPerSession ); }
             
             /* Only send request if
                1. We havn't reached the limit yet.
                2. User forced gif hit
             */
            if( (_buffer.utmb.trackCount < _config.trackingLimitPerSession) || force )
            {
                //update token bucket
                if( rateLimit )
                {
                    updateToken();
                }
                
                //if there are token left over in the bucket, send request
                if( force || !rateLimit || (_buffer.utmb.token >= 1) )
                {
                    //Only consume a token for non-forced and rate limited tracking calls.
                    if( !force && rateLimit )
                    {
                        _buffer.utmb.token -= 1;
                    }
                    
                    //increment request count
                    _buffer.utmb.trackCount += 1;
                    
                    LOG::P{ _log.i( "utmb = " + _buffer.utmb.toString() ); }
                    
                    
                    variables.utmwv = utmwv;
                    variables.utmn  = utmn;
                    
                    if( _info.domainName != "" )
                    {
                        variables.utmhn = _info.domainName;
                    }
                    
                    if( _config.sampleRate < 1 )
                    {
                        variables.utmsp = _config.sampleRate * 100;
                    }
                    
                    switch( _config.serverMode )
                    {
                        /* If service mode is send to local,
                           then we'll sent metrics via a local GIF request.
                        */
                        case ServerOperationMode.local:
                        _sendLocalRequest( variables );
                        break;
                        
                        /* If service mode is set to remote,
                           then we'll sent metrics via a remote GIF request.
                        */
                        case ServerOperationMode.remote:
                        _sendRemoteRequest( variables );
                        break;
                        
                        /* If service mode is set to both,
                           then we'll sent metrics via a local and remote GIF request.
                        */
                        case ServerOperationMode.both:
                        _sendLocalRequest( variables );
                        _sendRemoteRequest( variables );
                        break;
                    }
                    
                }
                
            }
        }
        
        
    }
}