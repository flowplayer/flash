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
    /* Urchin Tracking Module Cookie K.
       The Hash cookie.
       
       Contains a hash (digest) of all the __utm* values
       
       expiration:
       Not set.
       
       format:
       __utmk=<hash>
     */
    public class UTMK extends UTMCookie
    {
        private var _hash:Number; //0
        
        /**
         * Creates the new UTMK instance.
         */
        public function UTMK( hash:Number = NaN )
        {
            super( "utmk", "__utmk", ["hash"] );
            this.hash = hash;
        }
        
        public function get hash():Number
        {
            return _hash;
        }
        
        public function set hash( value:Number ):void
        {
            _hash = value;
            update();
        }
    }
}