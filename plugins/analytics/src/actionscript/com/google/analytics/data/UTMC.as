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
    /* Urchin Tracking Module Cookie C.
       The session tracking cookie.
       
       This cookie operates in conjunction with the __utmb cookie to determine whether or not
       to establish a new session for the user.
       In particular, this cookie is not provided with an expiration date,
       so it expires when the user exits the browser.
       
       Should a user visit your site, exit the browser and then return to your website within 30 minutes,
       the absence of the __utmc cookie indicates that a new session needs to be established,
       despite the fact that the __utmb cookie has not yet expired.
       
       expiration:
       Not set.
       
       format:
       __utmc=<domainHash>
     */
    public class UTMC extends UTMCookie
    {
        private var _domainHash:Number; //0
        
        /**
         * Creates a new UTMC instance.
         */
        public function UTMC( domainHash:Number = NaN )
        {
            super( "utmc", "__utmc", ["domainHash"] );
            this.domainHash = domainHash;
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
        
    }
}