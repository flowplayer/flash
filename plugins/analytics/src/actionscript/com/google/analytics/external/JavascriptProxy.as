﻿﻿/*
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
    
    import flash.external.ExternalInterface;
    import flash.system.Capabilities;
    
    /**
     * Javascript proxy access class.
     */
    public class JavascriptProxy
    {
        private var _log:Logger;
        
        /**
         * @private
         */
        private var _notAvailableWarning:Boolean = true;
        
        /**
         * The hasProperty Javascript injection.
         */
        public static var hasProperty_js:XML =
        <script>
                <![CDATA[
                    function( path )
                    {
                        var paths;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                        }
                        else
                        {
                            paths = [path];
                        }
                        var target = window ;
                        var len    = paths.length ;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            target = target[ paths[i] ] ;
                        }
                        if( target )
                        {
                            return true;
                        }
                        else
                        {
                            return false;
                        }
                    }
                ]]>
            </script>;
        
        
        /**
         * The setProperty Javascript injection.
         */
        public static var setProperty_js:XML =
        <script>
                <![CDATA[
                    function( path , value )
                    {
                        var paths;
                        var prop;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                            prop  = paths.pop() ;
                        }
                        else
                        {
                            paths = [];
                            prop  = path;
                        }
                        var target = window ;
                        var len    = paths.length ;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            target = target[ paths[i] ] ;
                        }
                        
                        target[ prop ] = value ;
                    }
                ]]>
            </script>;
        
        /**
         * The setPropertyReference Javascript injection.
         */
        public static var setPropertyRef_js:XML = 
            <script>
                <![CDATA[
                    function( path , target )
                    {
                        var paths;
                        var prop;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                            prop  = paths.pop() ;
                        }
                        else
                        {
                            paths = [];
                            prop  = path;
                        }
                        alert( "paths:"+paths.length+", prop:"+prop );
                        var targets;
                        var name;
                        if( target.indexOf(".") > 0 )
                        {
                            targets = target.split(".");
                            name    = targets.pop();
                        }
                        else
                        {
                            targets = [];
                            name    = target;
                        }
                        alert( "targets:"+targets.length+", name:"+name );
                        var root = window;
                        var len  = paths.length;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            root = root[ paths[i] ] ;
                        }
                        var ref   = window;
                        var depth = targets.length;
                        for( var j = 0 ; j < depth ; j++ )
                        {
                            ref = ref[ targets[j] ] ;
                        }
                        root[ prop ] = ref[name] ;
                    }
                ]]>
            </script>;
                
        /////
        
        /**
         * Creates a new JavascriptProxy instance.
         */
        public function JavascriptProxy()
        {
            LOG::P{ _log = log.tag( "JavascriptProxy" ); }
            LOG::P{ _log.v( "constructor()" ); }
        }
        
        /**
         * Call a Javascript injection block (String or XML) with parameters and return the result.
         */
        public function call( functionName:String, ...args:Array ):*
        {
            LOG::P{ _log.v( "call()" ); }
            
            if( isAvailable() )
            {
                try
                {
                    LOG::P
                    {
                        var output:String = "";
                            output  = "Flash->JS: "+ functionName;
                            output += "( ";
                        if (args.length > 0)
                        {
                            output += args.join(",");
                        } 
                        output += " )";
                        
                        _log.i( output );
                    }
                    
                    args.unshift( functionName );
                    return ExternalInterface.call.apply( ExternalInterface, args );
                }
                catch( e:SecurityError )
                {
                    LOG::P{ _log.w( "ExternalInterface is not allowed.\nEnsure that allowScriptAccess is set to \"always\" in the Flash embed HTML." ); }
                }
                catch( e:Error )
                {
                    LOG::P{ _log.w( "ExternalInterface failed to make the call\nreason: " + e.message ); }
                }
            }
            return null;
        }
        
        /**
         * Execute a Javascript injection block (String or XML) without any parameters and without return values.
         */
        public function executeBlock( data:String ):void
        {
            LOG::P{ _log.v( "executeBlock( " + data + " )" ); }
            
            if( isAvailable() )
            {
                try
                {
                    ExternalInterface.call( data );
                }
                catch( e:SecurityError )
                {
                    LOG::P{ _log.w( "ExternalInterface is not allowed.\nEnsure that allowScriptAccess is set to \"always\" in the Flash embed HTML." ); }
                }
                catch( e:Error )
                {
                    LOG::P{ _log.w( "ExternalInterface failed to make the call\nreason: " + e.message ); }
                }
            }
        }        
        
        /**
         * Returns the value property defines with the passed-in name value.
         * @return the value property defines with the passed-in name value.
         */        
        public function getProperty( name:String ):*
        {
            LOG::P{ _log.v( "getProperty( " + name + " )" ); }
            
            /* note:
               we use a little trick here 
               we can not diretly get a property from JS
               we can only call a function
               so we use valueOf() to automatically get the property
               and yes it will work only with primitives
            */
            return call( name + ".valueOf" ); //ExternalInterface.call( name + ".valueOf" ) ;
        }
        
        /**
         * Returns the String property defines with the passed-in name value.
         * @return the String property defines with the passed-in name value.
         */
        public function getPropertyString( name:String ):String
        {
            LOG::P{ _log.v( "getPropertyString( " + name + " )" ); }
            
            return call( name + ".toString" ); 
        }
        
        /**
         * Indicates if the specified path object exist.
         */
        public function hasProperty( path:String ):Boolean
        {
            LOG::P{ _log.v( "hasProperty( " + path + " )" ); }
            
            return call( hasProperty_js, path ); 
        }        
        
        /**
         * Indicates if the javascript proxy is available.
         */
        public function isAvailable():Boolean
        {
            LOG::P{ _log.v( "isAvailable()" ); }
            
            var available:Boolean = ExternalInterface.available;
            LOG::P{ _log.i( "ExternalInterface.available = " + available ); }
            
            if( available && (Capabilities.playerType == "External") )
            {
                /* note:
                   ExternalInterface is available when testing
                   from the Flash IDE (publish)
                   to allow testing locally we desactivate it
                */
                available = false;
            }
            
            /* note:
               we want to notify only once that ExternalInterface is not available.
            */
            if( !available && _notAvailableWarning )
            {
                LOG::P{ _log.w( "ExternalInterface is not available." ); }
                _notAvailableWarning = false;
            }
            
            return available;
        }
        
        /**
         * Creates a JS property.
         */
        public function setProperty( path:String, value:* ):void
        {
            LOG::P{ _log.v( "setProperty( " + [path,value].join( ", " ) + " )" ); }
            
            call( setProperty_js, path, value ); 
        }
        
        /**
         * Creates a JS property by reference.
         */
        public function setPropertyByReference( path:String, target:String ):void
        {
            LOG::P{ _log.v( "setPropertyByReference( " + [path,target].join( ", " ) + " )" ); }
            
            call( setPropertyRef_js, path, target );
        }
        
    }
}