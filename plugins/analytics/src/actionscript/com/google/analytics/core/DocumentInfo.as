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
 */

package com.google.analytics.core
{
    import com.google.analytics.external.AdSenseGlobals;
    import com.google.analytics.log;
    import com.google.analytics.utils.Environment;
    import com.google.analytics.utils.Variables;
    import com.google.analytics.v4.Configuration;
    
    import core.Logger;
    
    /**
     * The DocumentInfo class.
     */
    public class DocumentInfo
    {
        private var _log:Logger;
        
        private var _config:Configuration;
        private var _info:Environment;
        private var _adSense:AdSenseGlobals;
        
        private var _pageURL:String;
        private var _utmr:String;
        
        /**
         * Creates a new DocumentInfo instance.
         */
        public function DocumentInfo( config:Configuration, info:Environment, formatedReferrer:String,
                                      pageURL:String = null, adSense:AdSenseGlobals = null )
        {
            LOG::P{ _log = log.tag( "DocumentInfo" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
            _config  = config;
            _info    = info;
            _utmr    = formatedReferrer;
            _pageURL = pageURL;
            _adSense = adSense;
        }
        
        /**
         * Generates hit id for revenue per page tracking for AdSense. 
         * <p>This method first examines the DOM for existing hid.</p>  
         * <p>If there is already a hid in DOM, then this method will return the existing hid.</p> 
         * <p>If there isn't any hid in DOM, then this method will generate a new hid, and both stores it in DOM, and returns it to the caller.</p>
         * @return hid used by AdSense for revenue per page tracking
         */
        private function _generateHitId():Number
        {
            LOG::P{ _log.v( "_generateHitId()" ); }
            
            var hid:Number;
            
            //have hid in DOM
            if( _adSense.hid && (_adSense.hid != "") )
            {
                hid = Number( _adSense.hid );
            }
            //doesn't have hid in DOM
            else
            {
                hid = Math.round( Math.random() * 0x7fffffff );
                _adSense.hid = String( hid );
            }
            
            return hid;
        }
        
        /**
         * This method will collect and return the page URL information based on
         * the page URL specified by the user if present. If there is no parameter,
         * the URL of the HTML page embedding the SWF will be sent. If 
         * ExternalInterface.avaliable=false, a default of "/" will be used. 
         *
         * @private
         * @param {String} opt_pageURL (Optional) User-specified Page URL to assign
         *     metrics to at the back-end.
         *
         * @return {String} Final page URL to assign metrics to at the back-end.
         */
        private function _renderPageURL( pageURL:String = "" ):String
        {
            LOG::P{ _log.v( "_renderPageURL()" ); }
            
            var pathname:String = _info.locationPath;
            var search:String   = _info.locationSearch;
            
            if( !pageURL || (pageURL == "") )
            {
                pageURL = pathname + unescape( search );
            	if ( pageURL == "" )
            	{
            		pageURL = "/";
            	}
            }
            
            return pageURL;
        }
        
        /**
         * Page title, which is a URL-encoded string.
         * <p><b>Example :</b></p>
         * <pre class="prettyprint">utmdt=analytics%20page%20test</pre>
         */
        public function get utmdt():String
        {
            return _info.documentTitle;
        }
        
        /**
         * Hit id for revenue per page tracking for AdSense.
         * <p><b>Example :</b><code class="prettyprint">utmhid=2059107202</code></p>
         */
        public function get utmhid():String
        {
            return String( _generateHitId() );
        }
        
        /**
         * Referral, complete URL.
         * <p><b>Example :</b><code class="prettyprint">utmr=http://www.example.com/aboutUs/index.php?var=selected</code></p>
         */
        public function get utmr():String
        {
            if( !_utmr )
            {
                return "-";
            }
            
            return _utmr;
        }
        
        /**
         * Page request of the current page. 
         * <p><b>Example :</b><code class="prettyprint">utmp=/testDirectory/myPage.html</code></p>
         */
        public function get utmp():String
        {
            return _renderPageURL( _pageURL );
        }
        
        /**
         * Returns a Variables object representation.
         * @return a Variables object representation.
         */       
        public function toVariables():Variables
        {
            LOG::P{ _log.v( "toVariables()" ); }
            
            var variables:Variables = new Variables();
                variables.URIencode = true;
                
                if( _config.detectTitle && ( utmdt != "") )
                {
                    variables.utmdt = utmdt;
                }
                
                variables.utmhid = utmhid;
                variables.utmr   = utmr;
                variables.utmp   = utmp;
            
            return variables;
        }
        
        /**
         * Returns the url String representation of the object.
         * @return the url String representation of the object.
         */
        public function toURLString():String
        {
            LOG::P{ _log.v( "toURLString()" ); }
            
            var v:Variables = toVariables();
            return v.toString();
        }
    }
}