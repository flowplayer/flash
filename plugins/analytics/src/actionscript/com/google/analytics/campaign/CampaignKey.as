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

package com.google.analytics.campaign
{
    import com.google.analytics.log;
    
    import core.Logger;

    /**
     * The CampaignKey class.
     */
    public class CampaignKey
    {
        /** @private */
        private var _log:Logger;
        
        /**
         * Creates a new CampaignKey instance.
         */
        public function CampaignKey()
        {
            LOG::P{ _log = log.tag( "CampaignKey" ); }
            LOG::P{ _log.v( "constructor()" ); }
        }
        
        public var UCCN:String   = "utm_campaign";
        
        public var UCCT:String   = "utm_content";
        
        public var UCID:String   = "utm_id";
        
        public var UCMD:String   = "utm_medium";
        
        public var UCNO:String   = "utm_nooverride";
        
        public var UCSR:String   = "utm_source";
        
        public var UCTR:String   = "utm_term";
        
        public var UGCLID:String = "gclid";
        
    }
}