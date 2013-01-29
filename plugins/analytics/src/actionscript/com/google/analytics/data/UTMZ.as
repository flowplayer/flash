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
    import com.google.analytics.utils.Timespan;
    
    /* Urchin Tracking Module Cookie Z.
       The campaign tracking cookie.
       
       This cookie stores the type of referral used by the visitor to reach your site,
       whether via a direct method, a referring link, a website search, or a campaign such as an ad or an email link.
       
       It is used to calculate search engine traffic, ad campaigns and page navigation within your own site.
       The cookie is updated with each page view to your site.
       
       expiration:
       6 months from set/update.
       
       format:
       __utmz=<domainHash>.<campaignCreation>.<campaignSessions>.<responseCount>.<campaignTracking>
     */
    public class UTMZ extends UTMCookie
    {
        private var _domainHash:Number;          //0
        private var _campaignCreation:Number;    //1
        private var _campaignSessions:Number;    //2
        private var _responseCount:Number;       //3
        private var _campaignTracking:String;    //4
        
        public static var defaultTimespan:Number = Timespan.sixmonths;
        
        /**
         * Creates a new UTMZ instance.
         */
        public function UTMZ( domainHash:Number = NaN, campaignCreation:Number = NaN, campaignSessions:Number = NaN,
                              responseCount:Number = NaN, campaignTracking:String = "" )
        {
            super( "utmz",
                   "__utmz",
                   ["domainHash","campaignCreation","campaignSessions","responseCount","campaignTracking"],
                   defaultTimespan * 1000 );
            
            this.domainHash       = domainHash;
            this.campaignCreation = campaignCreation;
            this.campaignSessions = campaignSessions;
            this.responseCount    = responseCount;
            this.campaignTracking = campaignTracking;
        }
        
        /**
         * The domain hash value.
         */
        public function get domainHash():Number
        {
            return _domainHash;
        }
        
        /**
        * @private
        */
        public function set domainHash( value:Number ):void
        {
            _domainHash = value;
            update();
        }
        
        /**
        * The campaign creation timestamp.
        */
        public function get campaignCreation():Number
        {
            return _campaignCreation;
        }
        
        /**
        * @private
        */
        public function set campaignCreation( value:Number ):void
        {
            _campaignCreation = value;
            update();
        }
        
        /**
        * The campaign session count.
        */
        public function get campaignSessions():Number
        {
            return _campaignSessions;
        }
        
        /**
        * @private
        */
        public function set campaignSessions( value:Number ):void
        {
            _campaignSessions = value;
            update();
        }
        
        /**
        * The response count.
        */
        public function get responseCount():Number
        {
            return _responseCount;
        }
        
        /**
        * @private
        */
        public function set responseCount( value:Number ):void
        {
            _responseCount = value;
            update();
        }
        
        /**
        * The campaign tracker value
        */
        public function get campaignTracking():String
        {
            return _campaignTracking;
        }
        
        /**
        * @private
        */
        public function set campaignTracking( value:String ):void
        {
            _campaignTracking = value;
            update();
        }
    }
}