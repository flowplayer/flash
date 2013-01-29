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
 */

package com.google.analytics.data
{
    import com.google.analytics.utils.Timespan;
    
    /* Urchin Tracking Module Cookie B.
       The session timeout cookie.
       
       This cookie is used to establish and continue a user session with your site.
       When a user views a page on your site, the Google Analytics code attempts to update this cookie.
       If it does not find the cookie, a new one is written and a new session is established.
       
       Each time a user visits a different page on your site, this cookie is updated to expire in 30 minutes,
       thus continuing a single session for as long as user activity continues within 30-minute intervals.
       
       This cookie expires when a user pauses on a page on your site for longer than 30 minutes.
       You can modify the default length of a user session with the setSessionTimeout() method.
       
       expiration:
       30 minutes from set/update.
       
       format:
       __utmb=<domainHash>.<trackCount>.<token>.<lastTime>
     */
    public class UTMB extends UTMCookie
    {
        private var _domainHash:Number; //0
        private var _trackCount:Number; //1
        private var _token:Number;      //2
        private var _lastTime:Number;   //3
        
        public static var defaultTimespan:Number = Timespan.thirtyminutes; //seconds
        
        /**
         * Creates a new UTMB instance.
         */
        public function UTMB( domainHash:Number = NaN, trackCount:Number = NaN, token:Number = NaN, lastTime:Number = NaN )
        {
            super( "utmb",
                   "__utmb",
                   ["domainHash","trackCount","token","lastTime"],
                   defaultTimespan * 1000 ); //milliseconds
            
            this.domainHash = domainHash;
            this.trackCount = trackCount;
            this.token      = token;
            this.lastTime   = lastTime;
        }
        
        /**
         * The domain hash value.
         */
        public function get domainHash():Number
        {
            return _domainHash;
        }
        
        /**
        * @private
        */
        public function set domainHash( value:Number ):void
        {
            _domainHash = value;
            update();
        }
        
        /**
        * The tracking count value.
        */
        public function get trackCount():Number
        {
            return _trackCount;
        }
        
        /**
        * @private
        */
        public function set trackCount( value:Number ):void
        {
            _trackCount = value;
            update();
        }
        
        /**
        * Number of token in bucket.
        */
        public function get token():Number
        {
            return _token;
        }
        
        /**
        * @private
        */
        public function set token( value:Number ):void
        {
            _token = value;
            update();
        }
        
        /**
        * The last visit timestamp.
        */
        public function get lastTime():Number
        {
            return _lastTime;
        }
        
        /**
        * @private
        */
        public function set lastTime( value:Number ):void
        {
            _lastTime = value;
            update();
        }
        
    }
}