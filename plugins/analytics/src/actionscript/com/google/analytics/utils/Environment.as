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

package com.google.analytics.utils
{
    import com.google.analytics.core.ga_internal;
    import com.google.analytics.external.HTMLDOM;
    
    import core.strings.userAgent;
    import core.uri;
    import core.version;
    
    import flash.system.Capabilities;
    import flash.system.Security;
    import flash.system.System;
    
    /**
     * Environment provides informations for the local environment.
     */
    public class Environment
    {
        private var _dom:HTMLDOM;
        
        private var _protocol:String;
        private var _appName:String;
        private var _appVersion:version;
        private var _userAgent:String;
        private var _url:String;
        
        /**
         * Creates a new Environment instance.
         * @param url The URL of the SWF.
         * @param app The application name
         * @param version The application version
         * @param dom the HTMLDOM reference.
         */
        public function Environment( url:String = "", app:String = "", version:String = "", dom:HTMLDOM = null )
        {
            var v:core.version;
            
            if( app == "" )
            {
                if( isAIR() )
                {
                    app = "AIR";
                }
                else
                {
                    app = "Flash";
                }
            }
            
            if( version == "" )
            {
                v = flashVersion;
            }
            else
            {
                v = getVersionFromString( version );
            }
            
            _url        = url;
            _appName    = app;
            _appVersion = v;
            
            _dom        = dom;
        }
        
        /**
         * @private
         */
        private function _findProtocol():void
        {
            _protocol = "";
            
            if( _url != "" )
            {
                var url:uri = new uri( _url );
                _protocol = url.scheme;
            }
        }

        /**
         * Indicates the name of the application.
         */        
        public function get appName():String
        {
            return _appName;
        }
        
        /**
         * @private
         */
        public function set appName( value:String ):void
        {
            _appName = value;
            _defineUserAgent();
        }
        
        /**
         * Indicates the version of the application.
         */
        public function get appVersion():version
        {
            return _appVersion;
        }
        
        /**
         * @private
         */
        public function set appVersion( value:version ):void
        {
            _appVersion = value;
            _defineUserAgent();
        }
        
        /**
         * Sets the stage reference value of the application.
         */
        ga_internal function set url( value:String ):void
        {
            _url = value;
        }
        
        /**
         * Indicates the location of swf.
         */
        public function get locationSWFPath():String
        {
            return _url;
        }
        
        /**
         * Indicates the referrer value.
         */        
        public function get referrer():String
        {
            var _referrer:String = _dom.referrer;
            
            if( _referrer )
            {
                return _referrer;
            }
            
            if( protocol == "file" )
            {
                return "localhost";
            }
            
            return "";
        }
        
        /**
         * Indicates the title of the document.
         */
        public function get documentTitle():String
        {
            var _title:String = _dom.title;
            
            if( _title )
            {
                return _title;
            }
            
            return "";
        }
        
        /**
         * Indicates the local domain name value.
         */
        public function get domainName():String
        {
            if( (protocol == "http") ||
                (protocol == "https") )
            {
                var url:uri = new uri( _url.toLowerCase() );
                return url.host;
            }
            
            if( protocol == "file" )
            {
                return "localhost";
            }
            
            return "";
        }
        
        /**
         * Indicates if the application is running in AIR.
         */
        public function isAIR():Boolean
        {
            return Security.sandboxType == "application";
        }
        
        /**
         * Indicates if the SWF is embeded in an HTML page.
         * @return <code class="prettyprint">true</code> if the SWF is embeded in an HTML page.
         */
        public function isInHTML():Boolean
        {
            return Capabilities.playerType == "PlugIn" ;
        }        
        
        /**
         * Indicates the locationPath value.
         */        
        public function get locationPath():String
        {
            var _pathname:String = _dom.pathname;
            
            if( _pathname )
            {
                return _pathname;
            }
            
            return "";
        }
        
        /**
         * Indicates the locationSearch value.
         */         
        public function get locationSearch():String
        {
            var _search:String = _dom.search;
            
            if( _search )
            {
                return _search;
            }
            
            return "";
        }
        
        /**
         * Returns the flash version object representation of the application. 
         * <p>This object contains the attributes major, minor, build and revision :</p>
         * <p><b>Example :</b></p>
         * <pre class="prettyprint">
         * import com.google.analytics.utils.Environment ;
         * 
         * var info:Environment = new Environment( "http://www.domain.com" ) ;
         * var version:Object = info.flashVersion ;
         * 
         * trace( version.major    ) ; // 9
         * trace( version.minor    ) ; // 0
         * trace( version.build    ) ; // 124
         * trace( version.revision ) ; // 0
         * </pre>
         * @return the flash version object representation of the application.
         */
        public function get flashVersion():version
        {
            var v:version = getVersionFromString( Capabilities.version.split( " " )[1], "," ) ;
            return v ;
        }
        
        /**
         * Returns the language string as a lowercase two-letter language code from ISO 639-1.
         * @see Capabilities.language
         */
        public function get language():String
        {
            var _lang:String = _dom.language;
            var lang:String  = Capabilities.language;
            
            if( _lang )
            {
                if( (_lang.length > lang.length) &&
                    (_lang.substr(0,lang.length) == lang) )
                {
                    lang = _lang;
                }
            }
            
            return lang;
        }
        
        /**
         * Returns the internal character set used by the flash player
         * <p>Logic : by default flash player use unicode internally so we return UTF-8.</p>
         * <p>If the player use the system code page then we try to return the char set of the browser.</p>
         * @return the internal character set used by the flash player
         */
        public function get languageEncoding():String
        {
            if( System.useCodePage )
            {
                var _charset:String = _dom.characterSet;
                if( _charset )
                {
                    return _charset;
                }
                return "-"; //not found
            }
            //default
            return "UTF-8" ;
        }
        
        /**
         * Returns the operating system string.
         * <p><b>Note:</b> The flash documentation indicate those strings</p>
         * <li>"Windows XP"</li>
         * <li>"Windows 2000"</li>
         * <li>"Windows NT"</li>
         * <li>"Windows 98/ME"</li>
         * <li>"Windows 95"</li>
         * <li>"Windows CE" (available only in Flash Player SDK, not in the desktop version)</li>
         * <li>"Linux"</li>
         * <li>"MacOS"</li>
         * <p>Other strings we can obtain ( not documented : "Mac OS 10.5.4" , "Windows Vista")</p>
         * @return the operating system string.
         * @see Capabilities.os
         */        
        public function get operatingSystem():String
        {
            return Capabilities.os ;
        }
                        
        /**
         * Returns the player type.
         * <p><b>Note :</b> The flash documentation indicate those strings.</p>
         * <li><b>"ActiveX"</b>    : for the Flash Player ActiveX control used by Microsoft Internet Explorer.</li>
         * <li><b>"Desktop"</b>    : for the Adobe AIR runtime (except for SWF content loaded by an HTML page, which has Capabilities.playerType set to "PlugIn").</li>
         * <li><b>"External"</b>   : for the external Flash Player "PlugIn" for the Flash Player browser plug-in (and for SWF content loaded by an HTML page in an AIR application).</li>
         * <li><b>"StandAlone"</b> : for the stand-alone Flash Player.</li>
         * @return the player type.
         * @see Capabilities.playerType
         */                       
        public function get playerType():String
        {
            return Capabilities.playerType;
        }
        
        /**
         * Returns the platform, can be "Windows", "Macintosh" or "Linux"
         * @see Capabilities.manufacturer
         */            
        public function get platform():String
        {
            var p:String = Capabilities.manufacturer;
            return p.split( "Adobe " )[1];
        }
        
        /**
         * Indicates the Protocols object of this local info.
         */
        public function get protocol():String
        {
            if(!_protocol)
            {
                _findProtocol();
            }
            
            return _protocol;
        }
        
        /**
         * Indicates the height of the screen.
         * @see Capabilities.screenResolutionY
         */        
        public function get screenHeight():Number
        {
            return Capabilities.screenResolutionY;
        }        
        
        /**
         * Indicates the width of the screen.
         * @see Capabilities.screenResolutionX
         */
        public function get screenWidth():Number
        {
            return Capabilities.screenResolutionX;
        }
                
        /**
         * In AIR we can use flash.display.Screen to directly get the colorDepth property 
         * in flash player we can only access screenColor in flash.system.Capabilities.
         * <p>Some ref : <a href="http://en.wikipedia.org/wiki/Color_depth">http://en.wikipedia.org/wiki/Color_depth</a></p>
         * <li>"color" -> 16-bit or 24-bit or 32-bit</li>
         * <li>"gray"  -> 2-bit</li>
         * <li>"bw"    -> 1-bit</li>
         */
        public function get screenColorDepth():String
        {
            var color:String;
            switch( Capabilities.screenColor )
            {
                case "bw":
                {
                    color = "1";
                    break;
                }
                case "gray":
                {
                    color = "2";
                    break;
                }
                /* note:
                   as we have no way to know if
                   we are in 16-bit, 24-bit or 32-bit
                   we gives 24-bit by default
                */
                case "color" :
                default      :
                {
                    color = "24" ;
                }
            }
            
            var _colorDepth:String = _dom.colorDepth;
            
            if( _colorDepth )
            {
                color = _colorDepth;
            }
            
            return color;
        }
        
        private function _defineUserAgent():void
        {
            _userAgent = core.strings.userAgent( appName + "/" + appVersion.toString(4), false, false, true );
        }
        
        /**
         * Defines a custom user agent.
         * <p>For case where the user would want to define its own application name and version 
         * it is possible to change appName and appVersion which are in sync with 
         * applicationProduct and applicationVersion properties.</p>
         */
        public function get userAgent():String
        {
            if( !_userAgent )
            {
                 _defineUserAgent();
            }
            
            return _userAgent;
        }
        
        /**
         * @private
         */
        public function set userAgent( custom:String ):void
        {
            _userAgent = custom;
        }
        
    }
}