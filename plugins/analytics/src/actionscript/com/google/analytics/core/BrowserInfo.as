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

package com.google.analytics.core
{
    import com.google.analytics.utils.Environment;
    import com.google.analytics.utils.Variables;
    import com.google.analytics.v4.Configuration;
    
    import core.version;
    
    public class BrowserInfo
    {
        private var _config:Configuration;
        private var _info:Environment;
        
        /**
         * Creates a new BrowserInfo instance.
         * @param info The Environment reference of the BrowserInfo instance.
         */
        public function BrowserInfo( config:Configuration, info:Environment )
        {
            _config = config;
            _info   = info;
        }
        
        /**
         * Language encoding for the browser.
         * <p>Some browsers don't set this, in which case it is set to "-".</p>
         * <p>Example : <b>utmcs=ISO-8859-1</b></p>
         */
        public function get utmcs():String
        {
            return _info.languageEncoding;
        }
        
        /**
         * The Screen resolution
         * <p>Example : <b>utmsr=2400x1920</b></p>
         */
        public function get utmsr():String
        {
            return _info.screenWidth + "x" + _info.screenHeight;
        }
        
        /**
         * Screen color depth
         * <p>Example :<b>utmsc=24-bit</b></p>
         */
        public function get utmsc():String
        {
            return _info.screenColorDepth + "-bit";
        }
        
        /**
         * Browser language.
         * <p>Example :<b>utmul=pt-br</b></p>
         */
        public function get utmul():String
        {
            return _info.language.toLowerCase();
        }
        
        /**
         * Indicates if browser is Java-enabled.
         * <p>Example :<b>utmje=1</b></p>
         */
        public function get utmje():String
        {
            return "0"; //not supported
        }
        
        /**
         * Flash Version.
         * <p>Example :<b>utmfl=9.0%20r48</b></p>
         */
        public function get utmfl():String
        {
            if( _config.detectFlash )
            {
                var v:version = _info.flashVersion;
                return v.major+"."+v.minor+" r"+v.build;
            }
            
            return "-";
        }
        
        /**
         * Returns a Variables object representation.
         * @return a Variables object representation.
         */
        public function toVariables():Variables
        {
            var variables:Variables = new Variables();
                variables.URIencode = true;
                variables.utmcs = utmcs;
                variables.utmsr = utmsr;
                variables.utmsc = utmsc;
                variables.utmul = utmul;
                variables.utmje = utmje;
                variables.utmfl = utmfl;
            return variables;
        }
        
        /**
         * Returns the url String representation of the object.
         * @return the url String representation of the object.
         */
        public function toURLString():String
        {
            var v:Variables = toVariables();
            return v.toString();
        }
    }
}
