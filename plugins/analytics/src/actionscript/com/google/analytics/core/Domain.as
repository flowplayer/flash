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
    import com.google.analytics.log;
    
    import core.Logger;
    
    
    /**
     * The Domain class
     */
    public class Domain
    {
        private var _log:Logger;
        
        private var _mode:DomainNameMode;
        
        private var _name:String;
        
        /**
         * Creates a new Domain instance.
         * @param mode
         * @param name The name of the domain
         */
        public function Domain( mode:DomainNameMode = null, name:String = "" )
        {
            LOG::P{ _log = log.tag( "Domain" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
            if( mode == null )
            {
                mode = DomainNameMode.auto;
            }
            
            _mode = mode;
            
            if( mode == DomainNameMode.custom )
            {
                this.name = name;
            }
            else
            {
                _name = name;
            }
            
        }
        
        /**
         * Indicates the domain name mode of this domain.
         */
        public function get mode():DomainNameMode
        {
            return _mode;
        }
        
        public function set mode( value:DomainNameMode ):void
        {
            _mode = value;
            
            if( _mode == DomainNameMode.none )
            {
                _name = "";
            }
        }
        
        /**
         * Indicates the name of this domain.
         */
        public function get name():String
        {
            return _name;
        }
        
        /**
         * @private
         */
        public function set name( value:String ):void
        {
            LOG::P
            {
                if( value.charAt(0) != "." )
                {
                    _log.w( "missing leading period \".\", cookie will only be accessible on " + value );
                }
            }
            
            _name = value ;
        }

    }
}