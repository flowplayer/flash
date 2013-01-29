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
    import flash.net.URLRequest;
    import flash.utils.getTimer;
    
    /**
     * The RequestObject class.
     */
    public class RequestObject
    {
        public var start:int;
        public var end:int;
        
        public var request:URLRequest;
        
        /**
         * Creates a new RequestObject instance.
         */   
        public function RequestObject( request:URLRequest )
        {
            start = getTimer();
            this.request = request;
        }
        
        /**
         * Indicates the duration of the request.
         */
        public function get duration():int
        {
            if( !hasCompleted() ) { return 0; }
            return end - start;
        }
        
        /**
         * Complete the request.
         */
        public function complete():void
        {
            end = getTimer();
        }
        
        /**
         * Indicates if the request is complete.
         */
        public function hasCompleted():Boolean
        {
            return end > 0;
        }
        
        /**
         * Returns the String representation of the object.
         * @return the String representation of the object.
         */
        public function toString():String
        {
            var data:Array = [];
                data.push( "duration: " + duration +"ms" );
                data.push( "url: " + request.url );
            
            return "{ " + data.join( ", " ) + " }";
        }
        
    }
}