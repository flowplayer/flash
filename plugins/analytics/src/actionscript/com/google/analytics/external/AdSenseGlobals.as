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

package com.google.analytics.external
{
    import com.google.analytics.log;
    
    import core.Logger;

    /**
    * Globals used by AdSense for revenue per page tracking.
    */
    public class AdSenseGlobals extends JavascriptProxy
    {
        private var _log:Logger;
        
        /**
         * @private
         */
        private var _gaGlobalVerified:Boolean = false;
        
        /**
         * The gaGlobal_js Javascript injection.
         */
        public static var gaGlobal_js:XML =
        <script>
            <![CDATA[
                function()
                {
                    try
                    {
                        gaGlobal
                    }
                    catch(e)
                    {
                        gaGlobal = {} ;
                    }
                }
            ]]>
        </script>;
        
        /**
         * Creates a new AdSenseGlobals instance.
         */
        public function AdSenseGlobals()
        {
            super();
            
            LOG::P{ _log = log.tag( "AdSenseGlobals" ); }
            LOG::P{ _log.v( "constructor()" ); }
        }
        
        /**
         * @private
         */
        private function _verify():void
        {
            LOG::P{ _log.v( "_verify()" ); }
            
            if( !_gaGlobalVerified )
            {
                executeBlock( gaGlobal_js );
                _gaGlobalVerified = true ;
            }
        }
        
        /**
         * Returns the "gaGlobal" object.
         * @return the "gaGlobal" object.
         */
        public function get gaGlobal():Object
        {
            LOG::P{ _log.v( "get gaGlobal()" ); }
            if( !isAvailable() ) { return null; }
            
            _verify();
            return getProperty( "gaGlobal" );
        }
        
        /**
         * Domain hash.
         */
        public function get dh():String
        {
            LOG::P{ _log.v( "get dh()" ); }
            if( !isAvailable() ) { return null; }
            
            _verify();
            return getProperty( "gaGlobal.dh" );
        }
        
        /**
         * Determinates the Hit id.
         */
        public function get hid():String
        {
            LOG::P{ _log.v( "get hid()" ); }
            if( !isAvailable() ) { return null; }
            
            _verify();
            return getProperty( "gaGlobal.hid" );
        }
        
        /**
         * @private
         */
        public function set hid( value:String ):void
        {
            LOG::P{ _log.v( "set hid( " + value + " )" ); }
            if( !isAvailable() ) { return; }
            
            _verify();
            setProperty( "gaGlobal.hid", value );
        }
        
        /**
         * Determinates the session id.
         */
        public function get sid():String
        {
            LOG::P{ _log.v( "get sid()" ); }
            if( !isAvailable() ) { return null; }
            
            _verify();
            return getProperty( "gaGlobal.sid" );
        }
        
        /**
         * @private
         */
        public function set sid( value:String ):void
        {
            LOG::P{ _log.v( "set sid( " + value + " )" ); }
            if( !isAvailable() ) { return; }
            
            _verify();
            setProperty( "gaGlobal.sid", value );
        }
        
        /**
         * Determinates the visitor id.
         * <p><b>Note:</b> vid format is <b>&lt;sessionid&gt;.&lt;firsttime&gt;</b></p>
         */
        public function get vid():String
        {
            LOG::P{ _log.v( "get vid()" ); }
            if( !isAvailable() ) { return null; }
            
            _verify();
            return getProperty( "gaGlobal.vid" );
        }
        
        /**
         * @private
         */
        public function set vid( value:String ):void
        {
            LOG::P{ _log.v( "set vid( " + value + " )" ); }
            if( !isAvailable() ) { return; }
            
            _verify();
            setProperty( "gaGlobal.vid", value );
        }
        
    }
}