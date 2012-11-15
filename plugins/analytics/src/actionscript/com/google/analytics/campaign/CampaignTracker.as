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
    
    /* Campaign tracker object.
       Contains all the data associated with a campaign.
       
       AdWords:
       The following variables
       name, source, medium, term, content
       are automatically generated for AdWords hits when autotagging
       is turned on through the AdWords interface.
       
       
       note:
       we can not use a CampaignInfo because here the serialization
       to URL have to be injected into __utmz and is then a special case.
       
       links:
       
       Understanding campaign variables: The five dimensions of campaign tracking
       http://www.google.com/support/googleanalytics/bin/answer.py?answer=55579&hl=en
       
       How does campaign tracking work? 
       http://www.google.com/support/googleanalytics/bin/answer.py?hl=en&answer=55540
       
       What is A/B Testing and how can it help me?
       http://www.google.com/support/googleanalytics/bin/answer.py?answer=55589
       
       What information do the filter fields represent?
       http://www.google.com/support/googleanalytics/bin/answer.py?hl=en&answer=55588
     */
    public class CampaignTracker
    {
        /** @private */
        private var _log:Logger;
        
        /**
         * The campaign code or id can be used to refer to a campaign lookup table,
         * or chart of referring codes used to define variables in place of multiple request query tags.
         * variable: utmcid
         */
        public var id:String;
        
        /**
         * The resource that provided the click.
         * Every referral to a web site has an origin, or source.
         * Examples of sources are the Google search engine,
         * the AOL search engine, the name of a newsletter,
         * or the name of a referring web site.
         * Other example: "AdWords".
         * 
         * variable: utmcsr
         */
        public var source:String; //required
        
        /**
        * google ad click id
        * 
        * variable: utmgclid
        */
        public var clickId:String;
        
        /**
        * Usually refers to name given to the marketing campaign or is used to differentiate campaign source.
        * The campaign name differentiates product promotions such as "Spring Ski Sale"
        * or slogan campaigns such as "Get Fit For Summer".
        * 
        * alternative:
        * Used for keyword analysis to identify a specific product promotion or strategic campaign.
        * 
        * variable: utmccn
        */
        public var name:String; //required
        
        /**
        * Method of Delivery.
        * The medium helps to qualify the source;
        * together, the source and medium provide specific information
        * about the origin of a referral.
        * For example, in the case of a Google search engine source,
        * the medium might be "cost-per-click", indicating a sponsored link for which the advertiser paid,
        * or "organic", indicating a link in the unpaid search engine results.
        * In the case of a newsletter source, examples of medium include "email" and "print".
        * Other examples: "Organic", "CPC", or "PPC".
        * 
        * variable: utmcmd
        */
        public var medium:String; //required
        
        /**
         * The term or keyword is the word or phrase that a user types into a search engine.
         * Used for paid search.
         * variable: utmctr
         */
        public var term:String;
        
        /**
         * The content dimension describes the version of an advertisement on which a visitor clicked.
         * <p>It is used in content-targeted advertising and Content (A/B) Testing to determine which version of an advertisement is most effective at attracting profitable leads.</p>
         * <p>Alternative: Used for A/B testing and content-targeted ads to differentiate ads or links that point to the same URL.</p>
         * <p>variable: utmcct</p>
         */
        public var content:String;
        
        /**
         * Creates a new CampaingTracker instance.
         */
        public function CampaignTracker( id:String = "", source:String = "", clickId:String = "",
                                         name:String = "", medium:String = "", term:String = "", content:String = "" )
        {
            LOG::P{ _log = log.tag( "CampaignTracker" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
            this.id      = id;
            this.source  = source;
            this.clickId = clickId;
            this.name    = name;
            this.medium  = medium;
            this.term    = term;
            this.content = content;
        }
        
        /**
         * @private
         */ 
        private function _addIfNotEmpty( arr:Array, field:String, value:String ):void
        {
            LOG::P{ _log.v( "_addIfNotEmpty()" ); }
            
            if( value != "" )
            {
                value = value.split( "+" ).join( "%20" );
                value = value.split( " " ).join( "%20" );
                arr.push( field + value );
            }
        }
        
        /**
         * Returns a flag indicating whether this tracker object is valid.
         * A tracker object is considered to be valid if and only if one of id, source or clickId is present.
         */
        public function isValid():Boolean
        {
            LOG::P{ _log.v( "isValid()" ); }
            
            if( (id != "") || (source != "") || (clickId != "") )
            {
                return true;
            }
            
            return false;
        }
        
        /**
         * Builds the tracker object from a tracker string.
         *
         * @private
         * @param {String} trackerString Tracker string to parse tracker object from.
         */
        public function fromTrackerString( tracker:String ):void
        {
            LOG::P{ _log.v( "fromTrackerString()" ); }
            
            /* note:
               we are basically deserializing the utmz.campaignTracking property
            */
            var data:String = tracker.split( CampaignManager.trackingDelimiter ).join( "&" );
            var vars:Variables = new Variables( data );
            
            if( vars.hasOwnProperty( "utmcid" ) )
            {
                this.id = vars["utmcid"];
            }
            
            if( vars.hasOwnProperty( "utmcsr" ) )
            {
                this.source = vars["utmcsr"];
            }
            
            if( vars.hasOwnProperty( "utmccn" ) )
            {
                this.name = vars["utmccn"];
            }
            
            if( vars.hasOwnProperty( "utmcmd" ) )
            {
                this.medium = vars["utmcmd"];
            }
            
            if( vars.hasOwnProperty( "utmctr" ) )
            {
                this.term = vars["utmctr"];
            }
            
            if( vars.hasOwnProperty( "utmcct" ) )
            {
                this.content = vars["utmcct"];
            }
            
            if( vars.hasOwnProperty( "utmgclid" ) )
            {
                this.clickId = vars["utmgclid"];
            }
            
        }
        
        /**
         * Format for tracker have the following fields (seperated by "|"):
         *         <table>
         *           <tr><td>utmcid - lookup table id</td></tr>
         * 			 <tr><td>utmcsr - campaign source</td></tr>
         * 			 <tr><td>utmgclid - google ad click id</td></tr>
         *           <tr><td>utmccn - campaign name</td></tr>
         *           <tr><td>utmcmd - campaign medium</td></tr>
         *           <tr><td>utmctr - keywords</td></tr>
         *           <tr><td>utmcct - ad content description</td></tr>
         *           
         *           
         *         </table>
         * should be in this order : utmcid=one|utmcsr=two|utmgclid=three|utmccn=four|utmcmd=five|utmctr=six|utmcct=seven
         * 
         */
        public function toTrackerString():String
        {
            LOG::P{ _log.v( "toTrackerString()" ); }
            
            var data:Array = [];
                
                /* for each value, append key=value if and only if
                   the value is not empty.
                */
                _addIfNotEmpty( data, "utmcid=",   id );                
                _addIfNotEmpty( data, "utmcsr=",   source );
                _addIfNotEmpty( data, "utmgclid=", clickId );
                _addIfNotEmpty( data, "utmccn=",   name );
                _addIfNotEmpty( data, "utmcmd=",   medium );
                _addIfNotEmpty( data, "utmctr=",   term );
                _addIfNotEmpty( data, "utmcct=",   content );
                
            return data.join( CampaignManager.trackingDelimiter );
        }
        
    }
}