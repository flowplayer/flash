﻿/*
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

package com.google.analytics.external
{
    import com.google.analytics.log;
    
    import core.Logger;
    
    
    /**
     * Proxy access to HTML Document Object Model.
     */
    public class HTMLDOM extends JavascriptProxy
    {
        private var _log:Logger;
        
        private var _host:String;
        private var _language:String;
        private var _characterSet:String;
        private var _colorDepth:String;
        private var _location:String;
        private var _pathname:String;
        private var _protocol:String;
        private var _search:String;
        private var _referrer:String;
        private var _title:String;
        
        /**
         * The cache properties Javascript injection.
         */
        public static var cache_properties_js:XML =
        <script>
            <![CDATA[
                    function()
                    {
                        var obj = {};
                            obj.host         = document.location.host;
                            obj.language     = navigator.language ? navigator.language : navigator.browserLanguage;
                            obj.characterSet = document.characterSet ? document.characterSet : document.charset;
                            obj.colorDepth   = window.screen.colorDepth;
                            obj.location     = document.location.toString();
                            obj.pathname     = document.location.pathname;
                            obj.protocol     = document.location.protocol;
                            obj.search       = document.location.search;
                            obj.referrer     = document.referrer;
                            obj.title        = document.title;
                        
                        return obj;
                    }
                ]]>
         </script>;
                
        /**
         * Creates a new HTMLDOM instance.
         */
        public function HTMLDOM()
        {
            super();
            LOG::P{ _log = log.tag( "HTMLDOM" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
        }
        
        /**
         * Caches in one function call all the HTMLDOM properties.
         */
        public function cacheProperties():void
        {
            LOG::P{ _log.v( "cacheProperties()" ); }
            
            if( !isAvailable() ) { return; }
            
            var obj:Object = call( cache_properties_js );
            
            if( obj )
            {
                _host         = obj.host;
                _language     = obj.language;
                _characterSet = obj.characterSet;
                _colorDepth   = obj.colorDepth;
                _location     = obj.location;
                _pathname     = obj.pathname;
                _protocol     = obj.protocol;
                _search       = obj.search;
                _referrer     = obj.referrer;
                _title        = obj.title;
            }
        }
        
        /**
         * Determinates the 'host' String value from the HTML DOM.
         */
        public function get host():String
        {
            LOG::P{ _log.v( "get host()" ); }
            
            /* note:
               same logic applies for all properties
               
               cached values take precedence over ExternalInterface availability
               
               we first check if we have the cached value
               if yes returns it
               
               check for ExternalInterface availability,
               if not available returns null
               
               fetch the property and cache it
            */
            
            if( _host ) { return _host; }
            
            if( !isAvailable() ) { return null; }
            
            _host = getProperty( "document.location.host" );
            
            return _host;
        }
        
        /**
         * Determinates the 'langage' String value from the HTML DOM.
         */
        public function get language():String
        {
            LOG::P{ _log.v( "get language()" ); }
            
            if( _language ) { return _language; }
            
            if( !isAvailable() ) { return null; }
            
            var lang:String = getProperty( "navigator.language" );
            
            if( lang == null )
            {
                lang = getProperty( "navigator.browserLanguage" );
            }
            
            _language = lang;
            
            return _language;
        }
        
        /**
         * Indicates the characterSet value of the html dom.
         */        
        public function get characterSet():String
        {
            LOG::P{ _log.v( "get characterSet()" ); }
            
            if( _characterSet ) { return _characterSet; }
            
            if( !isAvailable() ) { return null; }
            
            var cs:String = getProperty( "document.characterSet" );
            
            if( cs == null )
            {
                cs = getProperty( "document.charset" );
            }
            
            _characterSet = cs;
            
            return _characterSet;
            
        }
        
        /**
         * Indicates the color depth of the html dom.
         */
        public function get colorDepth():String
        {
            LOG::P{ _log.v( "get colorDepth()" ); }
            
            if( _colorDepth ) { return _colorDepth; }
            
            if( !isAvailable() ) { return null; }
            
            _colorDepth = getProperty( "window.screen.colorDepth" );
            
            return _colorDepth;
        }
        
        
        /**
         * Determinates the 'location' String value from the HTML DOM.
         */     
        public function get location():String
        {
            LOG::P{ _log.v( "get location()" ); }
            
            if( _location ) { return _location; }
            
            if( !isAvailable() ) { return null; }
            
            _location = getPropertyString( "document.location" );
            
            return _location;
        }
        
        /**
         * Returns the path name value of the html dom.
         * @return the path name value of the html dom.
         */
        public function get pathname():String
        {
            LOG::P{ _log.v( "get pathname()" ); }
            
            if( _pathname ) { return _pathname; }
            
            if( !isAvailable() ) { return null; }
            
            _pathname = getProperty( "document.location.pathname" );
            
            return _pathname;
        }
        
        /**
         * Determinates the 'protocol' String value from the HTML DOM.
         */       
        public function get protocol():String
        {
            LOG::P{ _log.v( "get protocol()" ); }
            
            if( _protocol ) { return _protocol; }
            
            if( !isAvailable() ) { return null; }
            
            _protocol = getProperty( "document.location.protocol" );
            
            return _protocol;
        }
        
        /**
         * Determinates the 'search' String value from the HTML DOM.
         */        
        public function get search():String
        {
            LOG::P{ _log.v( "get search()" ); }
            
            if( _search ) { return _search; }
            
            if( !isAvailable() ) { return null; }
            
            _search = getProperty( "document.location.search" );
            
            return _search;
        }
        
        /**
         * Returns the referrer value of the html dom.
         * @return the referrer value of the html dom.
         */
        public function get referrer():String
        {
            LOG::P{ _log.v( "get referrer()" ); }
            
            if( _referrer ) { return _referrer; }
            
            if( !isAvailable() ) { return null; }
            
            _referrer = getProperty( "document.referrer" );
            
            return _referrer;
        }
        
        /**
         * Returns the title value of the html dom.
         * @return the title value of the html dom.
         */
        public function get title():String
        {
            LOG::P{ _log.v( "get title()" ); }
            
            if( _title ) { return _title; }
            
            if( !isAvailable() ) { return null; }
            
            _title = getProperty( "document.title" );
            
            return _title;
        }
             

    }
}
