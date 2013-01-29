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
    public interface Cookie
    {
        /**
        * The cookie creation date
        */
        function get creation():Date;
        
        /**
        * @private
        */
        function set creation( value:Date ):void;
        
        /**
        * The cookie expiration date.
        */
        function get expiration():Date;
        
        /**
        * @private
        */
        function set expiration( value:Date ):void;
        
        /**
        * Indicates if the cookie has expired.
        */
        function isExpired():Boolean;
        
        /**
         * Format data to render in the URL.
         */
        function toURLString():String;
        
        /**
         * Deserialize data from a simple object.
         */
        function fromSharedObject( data:Object ):void;
        
        /**
         * Serialize data to a simple object.
         */
        function toSharedObject():Object;
    }
}