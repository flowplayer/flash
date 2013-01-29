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
    
    /**
     * Urchin Tracking Module Cookie X.
     * The Website Optimizer cookie.
     * 
     * This cookie is used by Website Optimizer and only set when
     * the Website Optimizer tracking code is installed and correctly configured for your pages.
     * See the Google Website Optimizer Help Center for details.
     * 
     * expiration:
     * 2 years from set/update.
     * 
     * note:
     * - ALPO value
     * - document.location.search
     */
    public class UTMX extends UTMCookie
    {
        private var _value:String;
        
        //_udn
        //_uhash
        //_utimeout
        //_utcp
        
        public function UTMX()
        {
            //not implemented yet
            super( "utmx",
                   "__utmx",
                   ["value"], 
                   0 );
                   
            _value = "-";       
        }
        
        /**
         * returns dummy variable
         */
        public function get value():String
        {
            return _value;
        }
        
        /**
        * Sets dummy variable.
        */
        public function set value( value:String ):void
        {
            _value = value;
        }
        
    }
}