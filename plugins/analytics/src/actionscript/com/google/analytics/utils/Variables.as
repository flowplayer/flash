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
    import flash.net.URLVariables;
    
    /**
     * The Variables class.
     */
    public dynamic class Variables
    {
        
        private function _join( vars:Variables ):void
        {
            if( !vars )
            {
                return;
            }
            
            for( var prop:String in vars )
            {
                this[prop] = vars[prop];
            }
        }        
        
        /**
         * The URIencode flag.
         */ 
        public var URIencode:Boolean;
        
        /**
         * The Array representation of all "pre" values.
         */
        public var pre:Array  = [];
        
        /**
         * The Array representation of all "post" values.
         */        
        public var post:Array = [];
        
        /**
         * The sort flag.
         */
        public var sort:Boolean  = true;
        
        /**
         * Creates a new Variables instance.
         * @param source The source name value.
         * @param pre The Array representation of all "pre" values.
         * @param post The Array representation of all "post" values.
         */
        public function Variables( source:String = null, pre:Array = null, post:Array = null )
        {
            if( source )
            {
                decode( source );
            }
            
            if( pre )
            {
                this.pre = pre;
            }
            
            if( post )
            {
                this.post = post;
            }
        }
        
        /**
         * Decodes the variable with the specified String source.
         */
        public function decode( source:String ):void
        {
            if( source == "" )
            {
                return;
            }
            
            var data:Array;
            
            if( source.charAt(0) == "?")
            {
            	source = source.substr(1,source.length);  	
            }
            
            if( source.indexOf( "&" ) > -1 )
            {
                data = source.split( "&" );
            }
            else
            {
                data = [ source ];
            }
            
            var prop:String;
            var name:String;
            var value:String;
            var tmp:Array;
            
            for( var i:int = 0; i<data.length; i++ )
            {
                prop = data[i];
                if( prop.indexOf( "=" ) > -1 )
                {
                    tmp = prop.split( "=" );
                    name = tmp[0];
                    value = decodeURI( tmp[1] );
                    this[name] = value;
                }
            }
            
        }
        
        /**
         * Joins all passed-in Variables objects.
         * @param ...variables The collection of all variables arguments to join.
         */
        public function join( ...variables ):void
        {
            var l:int = variables.length ;
            for( var i:int = 0; i< l; i++ )
            {
                if( !(variables[i] is Variables) )
                {
                    continue;
                }
                _join( variables[i] );
            }
        }
        
        /**
         * Returns the String representation of the object.
         * @return the String representation of the object.
         */
        public function toString():String
        {
            var data:Array = [];
            var value:String;
            
            for( var p:String in this )
            {
                value = this[p];
                
                if( URIencode )
                {
                    value = encodeURI( value );
                }
                
                data.push( p + "=" + value );
            }
            
            if( sort )
            {
                data.sort();
            }
            
            var component:String;
            var i:int;
            var j:int;
            
            if( pre.length > 0 )
            {
                pre.reverse();
                
                var priority:String;
                for( i = 0; i<pre.length; i++ )
                {
                    priority = pre[i];
                    for( j = 0; j<data.length; j++ )
                    {
                        component = data[j];
                        if( component.indexOf( priority ) == 0 )
                        {
                            data.unshift( data.splice( j, 1 )[0] );
                        }
                    }
                    
                }
                
                pre.reverse();
            }
            
            if( post.length > 0 )
            {
                var last:String;
                for( i = 0; i<post.length; i++ )
                {
                    last = post[i];
                    for( j = 0; j<data.length; j++ )
                    {
                        component = data[j];
                        if( component.indexOf( last ) == 0 )
                        {
                            data.push( data.splice( j, 1 )[0] );
                        }
                    }
                    
                }
            }
            
            return data.join( "&" );
        }
        
        /**
         * Returns the URLVariables representation of the object.
         * @return the URLVariables representation of the object.
         */
        public function toURLVariables():URLVariables
        {
            var urlvars:URLVariables = new URLVariables();
            
            for( var p:String in this )
            {
                urlvars[p] = this[p];
            }
            
            return urlvars;
        }
        
    }
}