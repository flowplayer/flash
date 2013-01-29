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
    import com.google.analytics.v4.GoogleAnalyticsAPI;
    
    //TODO: create example in doc, upcast EventTracker, create a custom tracker class, etc.
    
    /**
     * The EventTracker class.
     * <p><b>Example :</b></p>
     * <pre class="prettyprint">
     * var buttonTracker:EventTracker = tracker.createEventTracker( "Button" ) ;
     * buttonTracker.trackEvent( "click", "hello world" ) ;
     * </pre>
     */
    public class EventTracker
    {
        
        /**
         * @private
         */
        private var _parent:GoogleAnalyticsAPI;
        
        /**
         * The name of the tracker.
         */
        public var name:String;
        
        /**
         * Creates a new EventTracker instance.
         */
        public function EventTracker( name:String, parent:GoogleAnalyticsAPI )
        {
            this.name = name;
            _parent   = parent;
        }
        
        /**
         * Constructs and sends the event tracking call to GATC with the name register in the EventTracker instance.
         */
        public function trackEvent( action:String, label:String = null, value:Number = NaN ):Boolean
        {
            return _parent.trackEvent( name, action, label, value );
        }
        
    }
}