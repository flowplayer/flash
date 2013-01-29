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
    
    /* Urchin Tracking Module Cookie A.
       The visitor tracking cookie.
       
       This cookie is typically written to the browser upon the first visit to your site from that web browser.
       If the cookie has been deleted by the browser operator, and the browser subsequently visits your site,
       a new __utma cookie is written with a different unique ID.
       
       This cookie is used to determine unique visitors to your site and it is updated with each page view.
       Additionally, this cookie is provided with a unique ID that Google Analytics uses to ensure both the
       validity and accessibility of the cookie as an extra security measure.
       
       expiration:
       2 years from set/update.
       
       format:
       __utma=<domainHash>.<sessionId>.<firstTime>.<lastTime>.<currentTime>.<sessionCount>
     */
    public class UTMA  extends UTMCookie
    {
        private var _domainHash:Number;   //0
        private var _sessionId:Number;    //1
        private var _firstTime:Number;    //2
        private var _lastTime:Number;     //3
        private var _currentTime:Number;  //4
        private var _sessionCount:Number; //5
        
        /**
         * Creates a new UTMA instance.
         */
        public function UTMA( domainHash:Number = NaN, sessionId:Number = NaN, firstTime:Number = NaN,
                              lastTime:Number = NaN, currentTime:Number = NaN, sessionCount:Number = NaN )
        {
            super( "utma",
                   "__utma",
                   ["domainHash","sessionId","firstTime","lastTime","currentTime","sessionCount"],
                   Timespan.twoyears * 1000 );
            
            this.domainHash   = domainHash;
            this.sessionId    = sessionId;
            this.firstTime    = firstTime;
            this.lastTime     = lastTime;
            this.currentTime  = currentTime;
            this.sessionCount = sessionCount;
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
         * The session id value.
         */
        public function get sessionId():Number
        {
            return _sessionId;
        }
        
        /**
        * @private
        */
        public function set sessionId( value:Number ):void
        {
            _sessionId = value;
            update();
        }
        
        /**
         * The first visit timestamp.
         */
        public function get firstTime():Number
        {
            return _firstTime;
        }
        
        /**
        * @private
        */
        public function set firstTime( value:Number ):void
        {
            _firstTime = value;
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
        
        /**
         * The current visit timestamp.
         */
        public function get currentTime():Number
        {
            return _currentTime;
        }
        
        /**
        * @private
        */
        public function set currentTime( value:Number ):void
        {
            _currentTime = value;
            update();
        }
        
        /**
         * The session count value.
         */
        public function get sessionCount():Number
        {
            return _sessionCount;
        }
        
        /**
        * @private
        */
        public function set sessionCount( value:Number ):void
        {
            _sessionCount = value;
            update();
        }
        
    }
}