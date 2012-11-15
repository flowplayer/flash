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

package com.google.analytics.events
{
    import com.google.analytics.AnalyticsTracker;
    
    import flash.events.Event;
    
    /**
     * The AnalyticsEvent is notify by all the objects who implements the AnalyticsTracker interface.
     */
    public class AnalyticsEvent extends Event
    {
        
        /**
         * The name of the event when the tracker is ready.
         * @eventType ready
         */
        public static const READY:String = "ready";
        
        /**
         * The AnalyticsTracker reference.
         */
        public var tracker:AnalyticsTracker;
        
        /**
         * Creates a new AnalyticsEvent instance.
         * @param type the string type of the instance. 
         * @param tracker the AnalyticsTracker target reference of the event.
         * @param bubbles indicates if the event is a bubbling event.
         * @param cancelable indicates if the event is a cancelable event.
          */
        public function AnalyticsEvent( type:String, tracker:AnalyticsTracker,
                                        bubbles:Boolean=false, cancelable:Boolean=false )
        {
            super(type, bubbles, cancelable);
            this.tracker = tracker;
        }
        
        /**
         * Returns the shallow copy of this object.
         * @return the shallow copy of this object.
         */
        public override function clone():Event
        {
            return new AnalyticsEvent( type, tracker, bubbles, cancelable );
        }
        
    }
}