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
    import com.google.analytics.core.Buffer;
    
    /* The Urchin Tracking Module base cookie.
       
       note:
       all utm* cookies should be able to
       - serialize/deserialize to SharedObject
       - keep the field sort order in serrialization
         ex:
         if utma cookie serialize to
         __utma=<domainHash>.<sessionId>.<firstTime>.<lastTime>.<currentTime>.<sessionCount>
         then domainHash should have field index 0, sessionId field index 1, etc.
       - each cookie should be able to notify a parent proxy
         when one of their field is updated
     */
    public class UTMCookie implements Cookie
    {
        private var _creation:Date;
        private var _expiration:Date;
        private var _timespan:Number;
        
        protected var name:String;
        protected var inURL:String;
        protected var fields:Array;
        public var proxy:Buffer;
        
        /**
         * Creates a new UTMCookie instance.
         * @param name The name of the cookie.
         * @param inURL The name of cookie when is serialized in the url.
         * @param fields The fiels in the order of the cookie.
         * @param timespan The timespan value of the cookie.
         */
        public function UTMCookie( name:String, inURL:String, fields:Array, timespan:Number = 0 )
        {
            
            this.name   = name;
            this.inURL  = inURL;
            this.fields = fields;
            
            _timestamp( timespan );
        }
        
        /**
         * @private
         */
        private function _timestamp( timespan:Number ):void
        {
            creation = new Date();
            _timespan = timespan;
            
            /* note:
               we only set the expiration date
               if the timespan has been defined
            */
            if( timespan > 0 )
            {
                expiration = new Date( creation.valueOf() + timespan );
            }
        }
        
        /**
         * Update the cookie.
         */
        protected function update():void
        {
            resetTimestamp();
            
            if( proxy )
            {
                proxy.update( name, toSharedObject() );
            }
        }
        
        /**
         * The cookie creation date
         */
        public function get creation():Date
        {
            return _creation;
        }
        
        /**
         * @private
         */
        public function set creation( value:Date ):void
        {
            _creation = value;
        }
        
        /**
         * The cookie expiration date.
         */
        public function get expiration():Date
        {
            if( _expiration )
            {
                return _expiration;
            }
            
            /* note:
               if _expiration has not been set
               either by the ctor or setter
               we always return something a
               little bigger than the current date
            */
            return new Date( (new Date()).valueOf() + 1000 );
        }
        
        /**
        * @private
        */
        public function set expiration( value:Date ):void
        {
            _expiration = value;
        }
        
        /**
         * Deserialize data from a simple object.
         */
        public function fromSharedObject( data:Object ):void
        {
            var field:String;
            var len:int = fields.length ;
            for( var i:int = 0; i<len ; i++ )
            {
                field = fields[i];
                
                if( data[ field ] )
                {
                    this[ field ] = data[ field ];
                }
            }
            
            if( data.creation )
            {
                this.creation = data.creation;
            }
            
            if( data.expiration )
            {
                this.expiration = data.expiration;
            }
            
        }
                
        /**
         * Indicates if the cookie is empty.
         */
        public function isEmpty():Boolean
        {
            var empty:int = 0;
            var field:String;
            
            for( var i:int = 0; i<fields.length; i++ )
            {
                field = fields[i];
                
                if( (this[ field ] is Number) && isNaN( this[ field ] ) )
                {
                    empty++;
                }
                else if( (this[ field ] is String) && (this[ field ] == "") )
                {
                    empty++;
                }
            }
            
            if( empty == fields.length )
            {
                return true;
            }
            
            return false;
        } 
        
        /**
        * Indicates if the cookie has expired.
        */
        public function isExpired():Boolean
        {
            /* note:
               if timespan was not defined in the ctor
               we will always return false, eg the cookie
               will never expire
            */
            var current:Date = new Date();
            var diff:Number = expiration.valueOf() - current.valueOf();
            
            if( diff <= 0 )
            {
                return true;
            }
            
            return false;
        }
        
        /**
         * Reset the cookie.
         */
        public function reset():void
        {
            var field:String;
            
            for( var i:int = 0; i<fields.length; i++ )
            {
                field = fields[i];
                
                if( this[ field ] is Number )
                {
                    this[ field ] = NaN;
                }
                else if( this[ field ] is String )
                {
                    this[ field ] = "";
                }
            }
            
            resetTimestamp();
            
            update();
        }
        
        /**
         * Reset the timestamp of the cookie.
         */
        public function resetTimestamp( timespan:Number = NaN ):void
        {
            if( !isNaN( timespan ) )
            {
                _timespan = timespan;
            }
            
            _creation = null;
            _expiration = null;
            _timestamp( _timespan );
        }
        
        /**
         * Format data to render in the URL.
         */
        public function toURLString():String
        {
            return inURL + "=" + valueOf();
        }
        
        /**
         * Serialize data to a simple object.
         */
        public function toSharedObject():Object
        {
            var data:Object = {};
            var field:String;
            var value:*;
            
            for( var i:int = 0; i<fields.length; i++ )
            {
                field = fields[i];
                value = this[ field ];
                
                if( value is String )
                {
                    data[ field ] = value;
                }
                else
                {
                    if( value == 0 )
                    {
                        data[ field ] = value;
                    }
                    else if( isNaN(value) )
                    {
                        continue;
                    }
                    else
                    {
                        data[ field ] = value;
                    }
                }
                
            }
            
            data.creation   = creation;
            data.expiration = expiration;
            
            return data;
        }
                
        /**
         * Returns the String representation of the object.
         * @return the String representation of the object.
         */
        public function toString( showTimestamp:Boolean = false ):String
        {
            var data:Array = [];
            var field:String;
            var value:*;
            
            var len:int = fields.length ; 
            for( var i:int = 0 ; i<len ; i++ )
            {
                field = fields[i];
                value = this[ field ];
                
                if( value is String )
                {
                    data.push( field + ": \"" + value +"\"" );
                }
                else
                {
                    if( value == 0 )
                    {
                        data.push( field + ": " + value );
                    }
                    else if( isNaN( value ) )
                    {
                        continue;
                    }
                    else
                    {
                        data.push( field + ": " + value );
                    }
                }
            }
            
            var str:String =name.toUpperCase() + " {" + data.join( ", " ) + "}";
            
            if( showTimestamp )
            {
                str += " creation:"+creation+", expiration:"+expiration;
            }
            
            return str;
        }
        
        /**
         * Returns the primitive value of the object.
         * @return the primitive value of the object.
         */
        public function valueOf():String
        {
            var data:Array = [];
            var field:String;
            var value:*;
            var testData:Array;
            var testOut:String = "";
            
            for( var i:int = 0; i<fields.length; i++ )
            {
                field = fields[i];
                value = this[ field ];
                
                if( value is String )
                {
                    if( value == "" )
                    {
                        value = "-";
                        data.push( value );
                    }
                    else
                    {
                        data.push( value );
                    }
                }
                else if( value is Number )
                {
                    if( value == 0 )
                    {
                        data.push( value );
                    }
                    else if( isNaN( value ) )
                    {
                        value = "-";
                        data.push( value );
                    }
                    else
                    {
                        data.push( value );
                    }
                }
                
            }
            
            //default to "-" if there is no data
            if ( isEmpty() )
            	return "-";
            
            
            return ""+data.join( "." );
        }
        
    }
}