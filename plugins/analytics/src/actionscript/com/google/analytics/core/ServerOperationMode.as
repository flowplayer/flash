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
    
    /**
     * ServerOperationMode Enumeration
     */
    public class ServerOperationMode
    {
        
        private var _name:String;
        
        private var _value:int;
        
        /**
         * Creates a new ServerOperationMode instance.
         * @param value The 
         */
        public function ServerOperationMode( value:int = 0, name:String = "" )
        {
            _value = value;
            _name  = name;
        }
                
        /**
         * Returns the String representation of the object.
         * @return the String representation of the object.
         */
        public function toString():String
        {
            return _name;
        }
        
        /**
         * Returns the primitive value of the object.
         * @return the primitive value of the object.
         */
        public function valueOf():int
        {
            return _value;
        }
        
        /**
         * Send data to the Urchin tracking software on your local servers.
         */
        public static const local:ServerOperationMode  = new ServerOperationMode( 0, "local" );
        
        /**
         * Send tracking data to the Google Analytics server (Default installations of Google Analytics).
         */
        public static const remote:ServerOperationMode = new ServerOperationMode( 1, "remote" );
        
        /**
         * Send your tracking data both to a local server and to the Google Analytics backend servers.
         */
        public static const both:ServerOperationMode   = new ServerOperationMode( 2, "both" );
        
    }
}