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
    /**
    * Utils to store "period of time" in seconds
    */
    public class Timespan
    {
        /**
        * Two year of time in seconds
        * 
        * note:
        * 63072000000 is the number of milliseconds in 2 year.
        *
        *           2 (year)
        *         365 (days / year)
        *          24 (hours / day)
        *          60 (min / hour)
        *          60 (sec / min)
        * x      1000 (millisec / sec)
        * -----------
        * 63072000000 (millisec)
        */
        public static var twoyears:Number  = 63072000;
        
        /**
        * Six months of time in seconds.
        */
        public static var sixmonths:Number = 15768000;
        
        /**
        * Thirty minutes of time in seconds.
        */
        public static var thirtyminutes:Number = 1800;
    }
}