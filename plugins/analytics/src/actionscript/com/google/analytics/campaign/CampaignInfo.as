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
    import com.google.analytics.utils.Variables;
    
    import core.Logger;

    /**
     * The CampaingInfo class.
     */
    public class CampaignInfo
    {
        /** @private */
        private var _log:Logger;
        
        /** @private */
        private var _empty:Boolean;
        
        /** @private */
        private var _new:Boolean;
        
        /**
         * Creates a new CampaignInfo instance
         * @param empty Indicates there is no value in the gif request.
         * @param newCampaign Indicates if the campaign is a new campaign.
         */
        public function CampaignInfo( empty:Boolean = true, newCampaign:Boolean = false )
        {
            LOG::P{ _log = log.tag( "CampaignInfo" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
            _empty = empty;
            _new   = newCampaign;
        }
        
        /**
         * Indicates a new campaign.
         */
        public function get utmcn():String
        {
            return isNew() ? "1": "0";
        }
        
        /**
         * Indicates a repeated campaign.
         */
        public function get utmcr():String
        {
            return isNew() ? "0": "1";
        }
        
        /**
         * Indicates if the campaing is empty.
         */
        public function isEmpty():Boolean
        {
            LOG::P{ _log.v( "isEmpty()" ); }
            
            return _empty;
        }
        
        /**
         * Indicates if the campaign is a new campaign.
         */
        public function isNew():Boolean
        {
            LOG::P{ _log.v( "isNew()" ); }
            
            return _new;
        }
        
        /**
         * Returns a Variables object representation.
         * @return a Variables object representation.
         */
        public function toVariables():Variables
        {
            LOG::P{ _log.v( "toVariables()" ); }
            
            var variables:Variables = new Variables();
                variables.URIencode = true;
                
            if( !isEmpty() )
            {
                if( isNew() )
                {
                    variables.utmcn = utmcn;
                }
                else
                {
                    variables.utmcr = utmcr;
                }
            }
            
            return variables;
        }
        
        /**
         * Returns the url string of the campaign.
         * @return the url string of the campaign.
         */
        public function toURLString():String
        {
            LOG::P{ _log.v( "toURLString()" ); }
            
            var v:Variables = toVariables();
            return v.toString();
        }
        
    }
}