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
    
    /* Urchin Tracking Module Cookie V.
       The user defined cookie.
       
       This cookie is not normally present in a default configuration of the tracking code.
       The __utmv cookie passes the information provided via the setVar() method,
       which you use to create a custom user segment.
       
       This string is then passed to the Analytics servers in the GIF request URL via the utmcc parameter.
       This cookie is only written if you have added the setVar() method for the tracking code on your website page.
       
       expiration:
       2 years from set/update.
       
       format:
       __utmv=<domainHash>.<value>
     */
    public class UTMV extends UTMCookie
    {
        private var _domainHash:Number; //0
        private var _value:String;      //1
        
        /**
         * Creates a new UTMV instance.
         */
        public function UTMV( domainHash:Number = NaN, value:String = "" )
        {
            super( "utmv",
                   "__utmv",
                   ["domainHash","value"],
                   Timespan.twoyears * 1000 );
            
            this.domainHash = domainHash;
            this.value      = value;
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
         * The user defined value.
         */
        public function get value():String
        {
            return _value;
        }
        
        /**
        * @private
        */
        public function set value( value:String ):void
        {
            _value = value;
            update();
        }
    }
}