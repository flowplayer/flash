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
    import com.google.analytics.data.X10;
    import com.google.analytics.utils.Variables;
    
    /**
     * The EventInfo class.
     */
    public class EventInfo
    {
        private var _isEventHit:Boolean;
        private var _x10:X10;
        private var _ext10:X10;
        
        /**
         * Creates a new EventInfo instance.
         */
        public function EventInfo( isEventHit:Boolean, xObject:X10, extObject:X10 = null )
        {
            _isEventHit = isEventHit;
            _x10   = xObject;
            _ext10 = extObject;
        }
        
        /**
        * Hit type.
        * <p><b>Example :</b></p>
        * <pre class="prettyprint">utmt=event</pre>
        */
        public function get utmt():String
        {
            return "event";
        }
        
        /**
        * X10 data.
        */
        public function get utme():String
        {
            return _x10.renderMergedUrlString( _ext10 );
        }
        
        /**
         * Returns a Variables object representation.
         * @return a Variables object representation.
         */        
        public function toVariables():Variables
        {
            var variables:Variables = new Variables();
                variables.URIencode = true;
                
                if( _isEventHit )
                {
                    variables.utmt   = utmt;
                }
                
                variables.utme   = utme;
            
            return variables;
        }
        
        /**
         * Returns the url String representation of the object.
         * @return the url String representation of the object.
         */
        public function toURLString():String
        {
            var v:Variables = toVariables();
            return v.toString();
        }
    }
}