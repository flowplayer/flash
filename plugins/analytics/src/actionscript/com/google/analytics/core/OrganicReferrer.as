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
     * The OrganicReferrer class.
     */
    public class OrganicReferrer
    {
        
        private var _engine:String;
        
        private var _keyword:String;
        
        /**
         * Creates a new OrganicReferrer instance.
         * @param engine The the organic source engine value.
         * @param keyword The the organic keyword value.
         */
        public function OrganicReferrer( engine:String , keyword:String )
        {
            this.engine  = engine;
           	this.keyword = keyword;
        }
        
        /**
        * The search engine name.
        */
        public function get engine():String
        {
            return _engine;
        }
        
        public function set engine( value:String ):void
        {
            _engine = value.toLowerCase();
        }
        
        /**
        * The keyword value.
        */
        public function get keyword():String
        {
            return _keyword;
        }
        
        public function set keyword( value:String ):void
        {
            _keyword = value.toLowerCase();
        }
        
        /**
         * Returns the String representation of the object.
         * @return the String representation of the object.
         */
        public function toString():String
        {
            return engine + "?" + keyword;
        }
        
	}
}
