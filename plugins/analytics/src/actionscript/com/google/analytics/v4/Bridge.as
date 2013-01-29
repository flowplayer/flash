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

package com.google.analytics.v4
{
    import com.google.analytics.core.EventTracker;
    import com.google.analytics.core.ServerOperationMode;
    import com.google.analytics.core.validateAccount;
    import com.google.analytics.external.JavascriptProxy;
    import com.google.analytics.log;
    
    import core.Logger;
    
    /**
     * This api use a Javascript bridge to fill the GATracker properties.
     */
    public class Bridge implements GoogleAnalyticsAPI
    {
        private var _log:Logger;
        
        private var _account:String;
        private var _config:Configuration;
        private var _proxy:JavascriptProxy;
        
        private var _hasGATracker:Boolean = false ;
        private var _jsContainer:String   = "_GATracker" ;
        
        ///// javascript injection with E4X        
        
        private static var _checkGAJS_js:XML = 
        <script>
            <![CDATA[
                function()
                {
                    if( _gat && _gat._getTracker )
                    {
                        return true;
                    }
                    return false;
                }
            ]]>
        </script>; 
        
        private static var _checkValidTrackingObject_js:XML =
        <script>
            <![CDATA[
                function(acct)
                {
                    if( _GATracker[acct] && (_GATracker[acct]._getAccount) )
                    {
                        return true ;
                    }
                    else
                    {
                        return false;
                    }
                }
            ]]>
        </script>;
        
        private static var _createTrackingObject_js:XML =
        <script>
            <![CDATA[
                function( acct )
                {
                    _GATracker[acct] = _gat._getTracker(acct);
                }
            ]]>
        </script>;
                  
        private static var _injectTrackingObject_js:XML =
        <script>
            <![CDATA[
                function()
                {
                    try 
                    {
                        _GATracker
                    }
                    catch(e) 
                    {
                        _GATracker = {};
                    }
                }
            ]]>
        </script>;
        
        private static var _linkTrackingObject_js:XML =
        <script>
            <![CDATA[
                function( container , target )
                {
                    var targets ;
                    var name ;
                    if( target.indexOf(".") > 0 )
                    {
                        targets = target.split(".");
                        name    = targets.pop();
                    }
                    else
                    {
                        targets = [];
                        name    = target;
                    }
                    var ref   = window;
                    var depth = targets.length;
                    for( var j = 0 ; j < depth ; j++ )
                    {
                        ref = ref[ targets[j] ] ;
                    }
                    window[container][target] = ref[name] ;
                }
            ]]>
        </script>;
                
        /////        
        
        /**
         * Creates a new Bridge instance.
         * If the parameter is a correct account id we assume user wants to create a new JS tracking object
         * Otherwise we assume the value is the parameter of an existing JS object the users wants to track against
         * We then to check if that object actually exists in DOM and is a GA tracking object. If object doesn't exits
         * an Error is thrown
         * 
         * @param account Urchin Account to record metrics in.
         */
        public function Bridge( account:String,
                                config:Configuration, jsproxy:JavascriptProxy )
        {
            LOG::P{ _log = log.tag( "Bridge" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
            _account = account;
            
            _config  = config;
            _proxy   = jsproxy;
            
            if( !_checkGAJS() )
            {
                var msg0:String = "";
                    msg0 += "ga.js not found, be sure to check if\n";
                    msg0 += "<script src=\"http://www.google-analytics.com/ga.js\"></script>\n";
                    msg0 += "is included in the HTML.";
                
                LOG::P{ _log.e( msg0 ); }
                if( _config.enableErrorChecking ) { throw new Error( msg0 ); }
            }
            
            if( !_hasGATracker )
            {
                var msg1:String = ""; 
                    msg1 += "The Google Analytics tracking code was not found on the container page\n";
                    msg1 += "we create it";
                
                LOG::P{ _log.i( msg1 ); }
                
                _injectTrackingObject();
            }
            
            if( validateAccount( account ) )
            {
                _createTrackingObject( account );
            }
            else
            {
                if( _checkTrackingObject( account ) )
                {
                    _linkTrackingObject( account );
                }
                else
                {
                    var msg2:String = "";
                        msg2 += "JS Object \"" + account + "\" doesn't exist in DOM\n";
                        msg2 += "Bridge object not created.";
                    
                    LOG::P{ _log.e( msg2 ); }
                    if( _config.enableErrorChecking ) { throw new Error( msg2 ); }
                }
            }
            
        }
        
        /**
         * Wrapper to simplify readability of External JS object calls in methods above 
         */
        private function _call( functionName:String, ...args ):*
        {
            args.unshift( "window."+ _jsContainer +"[\""+ _account +"\"]."+functionName );
            return _proxy.call.apply( _proxy, args );
        }
                
        /**
         * @private
         */
        private function _checkGAJS():Boolean
        {
            return _proxy.call( _checkGAJS_js );
        }
                                
        /**
         * @private
         */
        private function _checkTrackingObject( account:String ):Boolean
        {
            var hasObj:Boolean    = _proxy.hasProperty( account ) ;
            var isTracker:Boolean = _proxy.hasProperty( account + "._getAccount" ) ;
            return hasObj && isTracker ;
        }
        
        /**
         * Checks to ses if the tracking object Name passed into the functions exists in the DOM and is a real Google Analytics tracking object
         * @private
         */
        private function _checkValidTrackingObject( account:String ):Boolean
        {
            return _proxy.call( _checkValidTrackingObject_js , account ) ;
        }        
        
        /**
         * This function creates a JS tracking object in the DOM.
         * @private
         */
        private function _createTrackingObject( account:String ):void
        {
            _proxy.call( _createTrackingObject_js, account );
        }        
        
        /**
         * Indicates if the bridge has a reference whith the JS GA tracker.
         */
        public function hasGAJS():Boolean
        {
            return _checkGAJS();
        }
        
        /**
         * Indicates if the bridge has the passed-in tracking account.
         */
        public function hasTrackingAccount( account:String ):Boolean
        {
            if( validateAccount( account ) )
            {
                return _checkValidTrackingObject( account );
            }
            else
            {
                return _checkTrackingObject( account );
            }
        }
        
        /**
         * @private
         */        
        private function _injectTrackingObject():void
        {
            _proxy.executeBlock( _injectTrackingObject_js );
            _hasGATracker = true;
        }
                
        /**
         * @private
         */
        private function _linkTrackingObject( path:String ):void
        {
            _proxy.call( _linkTrackingObject_js , _jsContainer, path );
        }        
        
        // -----------------------------------------------------------------------------
        // START CONFIGURATION
        
        /**
         * Returns the Google Analytics tracking ID for this tracker object.
         * If you are tracking pages on your website in multiple accounts,
         * you can use this method to determine the account that is associated
         * with a particular tracker object.
         * @return the Account ID this tracker object is instantiated with.
         */
        public function getAccount():String
        {
            LOG::P{ _log.v( "getAccount()" ); }
            
            return _call( "_getAccount" );
        }
        
        /**
         * Returns the GATC version number.
         * @return GATC version number.
         */
        public function getVersion():String
        {
            LOG::P{ _log.v( "getVersion()" ); }
            
            return _call( "_getVersion" );
        }
        
        /**
         * Reset the current session clearing the utmb and utmc cookies.
         */
        public function resetSession():void
        {
            LOG::P{ _log.v( "resetSession()" ); }
            LOG::P{ _log.d( "resetSession() not implemented" ); }
            
            /* note:
               not implemented
               we could inject some JS to force the reset
               of the utmb and utmc cookies on the JS side
            */
        }
        
        /**
         * Sets the new sample rate.
         * If your website is particularly large and subject to heavy traffic spikes,
         * then setting the sample rate ensures un-interrupted report tracking.
         * 
         * Sampling in Google Analytics occurs consistently across unique visitors,
         * so there is integrity in trending and reporting even when sampling is enabled,
         * because unique visitors remain included or excluded from the sample,
         * as set from the initiation of sampling.
         * @param newRate New sample rate to set. Provide a numeric as a whole percentage, 0.1 being 10%, 1 being 100%.
         */
        public function setSampleRate(newRate:Number):void
        {
            LOG::P{ _log.v( "setSampleRate( " + newRate + " )" ); }
            
            _call( "_setSampleRate", newRate );
        }
        
        /**
         * Sets the new session timeout in seconds.
         * By default, session timeout is set to 30 minutes (1800 seconds).
         * 
         * Session timeout is used to compute visits,
         * since a visit ends after 30 minutes of browser inactivity or upon browser exit.
         * If you want to change the definition of a "session" for your particular needs,
         * you can pass in the number of seconds to define a new value.
         * 
         * This will impact the Visits reports in every section where the number of
         * visits are calculated, and where visits are used in computing other values.
         * For example, the number of visits will increase if you shorten the session timeout,
         * and will decrease if you increase the session timeout.
         * 
         * @param newTimeout New session timeout to set in seconds.
         */
        public function setSessionTimeout(newTimeout:int):void
        {
            LOG::P{ _log.v( "setSessionTimeout( " + newTimeout + " )" ); }
            
            _call( "_setSessionTimeout", newTimeout );
        }
        
        /**
         * Sets a user-defined value.
         * The value you supply appears as an option in the Segment pull-down for the Traffic Sources reports.
         * You can use this value to provide additional segmentation on users to your website.
         * 
         * For example, you could have a login page or a form that triggers a value based on a visitor's input,
         * such as a preference the visitor chooses, or a privacy option.
         * This variable is then updated in the cookie for that visitor.
         * 
         * @param newVal New user defined value to set.
         */
        public function setVar(newVal:String):void
        {
            LOG::P{ _log.v( "setVar( " + newVal + " )" ); }
            
            _call( "_setVar", newVal );
        }
        
        /**
         * Main logic for GATC (Google Analytic Tracker Code).
         * If linker functionalities are enabled, it attempts to extract cookie values from the URL.
         * Otherwise, it tries to extract cookie values from document.cookie.
         * It also updates or creates cookies as necessary, then writes them back to the document object.
         * Gathers all the appropriate metrics to send to the UCFE (Urchin Collector Front-end).
         * 
         * @param pageURL Optional parameter to indicate what page URL to track metrics under. When using this option, use a beginning slash (/) to indicate the page URL.
         */
        public function trackPageview(pageURL:String=""):void
        {
            LOG::P{ _log.v( "trackPageview( " + pageURL + " )" ); }
            
            _call( "_trackPageview", pageURL );
        }
        
        // END CONFIGURATION
        // -----------------------------------------------------------------------------
        // START Campaign Tracking
        // Methods that you use for setting up and customizing campaign tracking in Google Analytics reporting.
        
        /**
        * Allows the # sign to be used as a query string delimiter in campaign tracking.
        * This option is disabled by default.
        * 
        * Typically, campaign tracking URLs are comprised of the question mark (?) separator
        * and the ampersand (&amp;) as delimiters for the key/value pairs that make up the query.
        * By enabling this option, your campaign tracking URLs can use a pound (#) sign
        * instead of the question mark (?).
        * 
        * @param enable If this parameter is set to true, then campaign will use anchors. Else, campaign will use search strings.
        */
        public function setAllowAnchor(enable:Boolean):void
        {
            LOG::P{ _log.v( "setAllowAnchor( " + enable + " )" ); }
            
            _call( "_setAllowAnchor", enable );
        }
        
        /**
         * Sets the campaign ad content key.
         * The campaign content key is used to retrieve the ad content (description)
         * of your advertising campaign from your campaign URLs.
         * Use this function on the landing page defined in your campaign.
         * 
         * @param newCampContentKey New campaign content key to set.
         */
        public function setCampContentKey(newCampContentKey:String):void
        {
            LOG::P{ _log.v( "setCampContentKey( " + newCampContentKey + " )" ); }
            
            _call( "_setCampContentKey", newCampContentKey );
        }
        
        /**
         * Sets the campaign medium key,
         * which is used to retrieve the medium from your campaign URLs.
         * The medium appears as a segment option in the Campaigns report.
         * 
         * @param newCampMedKey Campaign medium key to set.
         */
        public function setCampMediumKey(newCampMedKey:String):void
        {
            LOG::P{ _log.v( "setCampMediumKey( " + newCampMedKey + " )" ); }
            
            _call( "_setCampMediumKey", newCampMedKey );
        }
        
        /**
         * Sets the campaign name key.
         * The campaign name key is used to retrieve the name of your advertising campaign from your campaign URLs.
         * You would use this function on any page that you want to track click-campaigns on.
         * 
         * @param newCampNameKey Campaign name key.
         */
        public function setCampNameKey(newCampNameKey:String):void
        {
            LOG::P{ _log.v( "setCampNameKey( " + newCampNameKey + " )" ); }
            
            _call( "_setCampNameKey", newCampNameKey );
        }
        
        /**
         * Sets the campaign no-override key variable,
         * which is used to retrieve the campaign no-override value from the URL.
         * By default, this variable and its value are not set.
         * 
         * For campaign tracking and conversion measurement, this means that, by default,
         * the most recent impression is the campaign that is credited in your conversion tracking.
         * If you prefer to associate the first-most impressions to a conversion,
         * you would set this method to a specific key, and in the situation where you use custom campaign variables,
         * you would use this method to set the variable name for campaign overrides.
         * The no-override value prevents the campaign data from being over-written
         * by similarly-defined campaign URLs that the visitor might also click on.
         * 
         * @param newCampNOKey Campaign no-override key to set.
         */
        public function setCampNOKey( newCampNOKey:String ):void
        {
            LOG::P{ _log.v( "setCampNOKey( " + newCampNOKey + " )" ); }
            
            _call( "_setCampNOKey", newCampNOKey );
        }
        
        /**
         * Sets the campaign source key,
         * which is used to retrieve the campaign source from the URL.
         * "Source" appears as a segment option in the Campaigns report.
         * 
         * @param newCampSrcKey Campaign source key to set.
         */
        public function setCampSourceKey(newCampSrcKey:String):void
        {
            LOG::P{ _log.v( "setCampSourceKey( " + newCampSrcKey + " )" ); }
            
            _call( "_setCampSourceKey", newCampSrcKey );
        }
        
        /**
         * Sets the campaign term key,
         * which is used to retrieve the campaign keywords from the URL.
         * 
         * @param newCampTermKey Term key to set.
         */
        public function setCampTermKey(newCampTermKey:String):void
        {
            LOG::P{ _log.v( "setCampTermKey( " + newCampTermKey + " )" ); }
            
            _call( "_setCampTermKey", newCampTermKey );
        }
        
        /**
         * Sets the campaign tracking flag.
         * By default, campaign tracking is enabled for standard Google Analytics set up.
         * If you wish to disable campaign tracking and the associated cookies
         * that are set for campaign tracking, you can use this method.
         * 
         * @param enable True by default, which enables campaign tracking. If set to false, campaign tracking is disabled.
         */
        public function setCampaignTrack(enable:Boolean):void
        {
            LOG::P{ _log.v( "setCampaignTrack( " + enable + " )" ); }
            
            _call( "_setCampaignTrack", enable );
        }
        
        /**
         * Sets the campaign tracking cookie expiration time in seconds.
         * By default, campaign tracking is set for 6 months.
         * In this way, you can determine over a 6-month period whether visitors
         * to your site convert based on a specific campaign.
         * However, your business might have a longer or shorter campaign time-frame,
         * so you can use this method to adjust the campaign tracking for that purpose.
         * 
         * @param newDefaultTimeout New default cookie expiration time to set.
         */
        public function setCookieTimeout(newDefaultTimeout:int):void
        {
            LOG::P{ _log.v( "setCookieTimeout( " + newDefaultTimeout + " )" ); }
            
            _call( "_setCookieTimeout", newDefaultTimeout );
        }
        
        // END CAMPAIGN TRACKING
        // -----------------------------------------------------------------------------
        // START DOMAINS AND DIRECTORIES
        // Methods that you use for customizing how Google Analytics reporting works across domains,
        // across different hosts, or within sub-directories of a website.
        
        /**
         * Changes the paths of all GATC cookies to the newly-specified path.
         * Use this feature to track user behavior from one directory structure
         * to another on the same domain.
         * 
         * In order for this to work, the GATC tracking data must be initialized (initData() must be called).
         * 
         * @param newPath New path to store GATC cookies under.
         */
        public function cookiePathCopy(newPath:String):void
        {
            LOG::P{ _log.v( "cookiePathCopy( " + newPath + " )" ); }
            
            _call( "_cookiePathCopy", newPath );
        }
   
        /**
        * This method works in conjunction with the setDomainName() and
        * setAllowLinker() methods to enable cross-domain user tracking.
        * The getLinkerURL method returns all the cookie values as a string
        * 
        * @param targetUrl URL of target site to send cookie values to.
        * @param useHash Set to true for passing tracking code variables by using the # anchortag separator rather than the default ? query string separator. (Currently this behavior is for internal Google properties only.)
        *
        * @return String containing all cookie data
        */        
        public function getLinkerUrl( targetUrl:String = "", useHash:Boolean=false ):String
        {
        	LOG::P{ _log.v( "getLinkerUrl("+ [targetUrl,useHash].join(", ") +")" ); }
            
        	return _call( "_getLinkerUrl", targetUrl, useHash );
        }
        
        /**
         * This method works in conjunction with the setDomainName() and
         * setAllowLinker() methods to enable cross-domain user tracking.
         * The link() method passes the cookies from this site to another via URL parameters (HTTP GET).
         * It also changes the document.location and redirects the user to the new URL.
         * 
         * @param targetUrl URL of target site to send cookie values to.
         * @param useHash Set to true for passing tracking code variables by using the # anchortag separator rather than the default ? query string separator. (Currently this behavior is for internal Google properties only.)
         */
        public function link( targetUrl:String, useHash:Boolean=false ):void
        {
            LOG::P{ _log.v( "link( " + [targetUrl,useHash].join(", ") + " )" ); }
            
            _call( "_link", targetUrl, useHash );
        }
        
        /**
         * This method works in conjunction with the setDomainName() and
         * setAllowLinker() methods to enable cross-domain user tracking.
         * The linkByPost() method passes the cookies from the referring form
         * to another site in a string appended to the action value of the form (HTTP POST).
         * This method is typically used when tracking user behavior from one site to
         * a 3rd-party shopping cart site, but can also be used to send cookie data to
         * other domains in pop-ups or in iFrames.
         * 
         * @param formObject Form object encapsulating the POST request.  
         * @param useHash Set to true for passing tracking code variables by using the # anchortag separator rather than the default ? query string separator.
         */
        public function linkByPost( formObject:Object, useHash:Boolean=false ):void
        {
            LOG::P{ _log.v( "linkByPost( " + [formObject,useHash].join(", ") + " )" ); }
            LOG::P{ _log.d( "linkByPost() not implemented" ); }
            
            /* TODO:
               this might not make any sense to provide..
               ie what form object would we provide?
            */
            //_proxy.call( "function() { "+_jsObjName.toString()+"._linkByPost("+formObject+","+useHash+"); }" );
        }
        
        /**
         * Sets the allow domain hash flag.
         * By default, this value is set to true.
         * The domain hashing functionality in Google Analytics creates a hash value from your domain,
         * and uses this number to check cookie integrity for visitors.
         * If you have multiple sub-domains, such as example1.example.com and example2.example.com,
         * and you want to track user behavior across both of these sub-domains,
         * you would turn off domain hashing so that the cookie integrity check will not reject
         * a user cookie coming from one domain to another.
         * Additionally, you can turn this feature off to optimize per-page tracking performance.
         * 
         * @param enable If this parameter is set to true, then domain hashing is enabled. Else, domain hashing is disabled. True by default.
         */
        public function setAllowHash( enable:Boolean ):void
        {
            LOG::P{ _log.v( "setAllowHash( " + enable + " )" ); }
            
            _call( "_setAllowHash" , enable ) ;
        }
        
        /**
         * Sets the linker functionality flag as part of enabling cross-domain user tracking.
         * <p>By default, this method is set to false and linking is disabled.</p>
         * <p>See also link(), linkByPost(), and setDomainName() methods to enable cross-domain tracking.</p>
         * @param enable If this parameter is set to <code class="prettyprint">true</code>, then linker is enabled. Else, linker is disabled.
         */
        public function setAllowLinker( enable:Boolean ):void
        {
            LOG::P{ _log.v( "setAllowLinker( " + enable + " )" ); }
            
            _call( "_setAllowLinker", enable ) ;
        }
        
        /**
         * Sets the new cookie path for your site.
         * By default, Google Analytics sets the cookie path to the root level (/).
         * In most situations, this is the appropriate option and works correctly with
         * the tracking code you install on your website, blog, or corporate web directory.
         * However, in a few cases where user access is restricted to only a sub-directory of a domain,
         * this method can resolve tracking issues by setting a sub-directory as the default path for all tracking.
         * Typically, you would use this if your data is not being tracked and you subscribed to a blog service
         * and only have access to your defined sub-directory, or if you are on a Corporate or University network
         * and only have access to your home directory.
         * In these cases, using a terminal slash is the recommended practice for defining the sub-directory.
         * 
         * @param newCookiePath New cookie path to set.
         */
        public function setCookiePath(newCookiePath:String):void
        {
            LOG::P{ _log.v( "setCookiePath( " + newCookiePath + " )" ); }
            
            _call( "_setCookiePath", newCookiePath );
        }
        
        /**
         * Sets the domain name for cookies.
         * There are three modes to this method: ("auto" | "none" | [domain]).
         * By default, the method is set to auto, which attempts to resolve
         * the domain name based on the location object in the DOM.
         * 
         * @param newDomainName New default domain name to set.
         */
        public function setDomainName(newDomainName:String):void
        {
            LOG::P{ _log.v( "setDomainName( " + newDomainName + " )" ); }
            
            _call( "_setDomainName", newDomainName );
        }
        
        // END DOMAIN AND DIRECTORIES
        // -----------------------------------------------------------------------------
        // START ECOMMERCE
        // Methods that you use for customizing ecommerce in Google Analytics reporting.
        
        /**
         * Adds a transaction item to the parent transaction object.
         * Use this method to track items purchased by visitors to your ecommerce site.
         * This method tracks items by SKU and performs no additional ecommerce calculations (such as quantity calculations).
         * Therefore, if the item being added is a duplicate (by SKU) of an existing item for that session,
         * then the old information is replaced with the new.
         * Additionally, it does not enforce the creation of a parent transation object,
         * but it is advised that you set this up explicitly in your transaction tracking code.
         * If no parent transaction object exists for the item, the item is attached to an empty transaction object instead.
         * 
         * @param item
         * @param sku Item's SKU code (required).
         * @param name Product name.
         * @param category Product category.
         * @param price Product price (required).
         * @param quantity Purchase quantity (required).
         */
        public function addItem(item:String, sku:String, name:String, category:String, price:Number, quantity:int):void
        {
            LOG::P{ _log.v( "addItem( " + [item,sku,name,category,price,quantity].join( ", " ) + " )" ); }
            
            _call( "_addItem", item, sku, name, category, price, quantity );
        }
        
        /**
         * Creates a transaction object with the given values.
         * As with addItem(), this method handles only transaction tracking and provides no additional ecommerce functionality.
         * Therefore, if the transaction is a duplicate of an existing transaction for that session,
         * the old transaction values are over-written with the new transaction values.
         * 
         * @param orderId Internal unique order id number for this transaction.
         * @param affiliation Optional partner or store affiliation. (undefined if absent)
         * @param total Total dollar amount of the transaction.
         * @param tax Tax amount of the transaction.
         * @param shipping Shipping charge for the transaction.
         * @param city City to associate with transaction.
         * @param state State to associate with transaction.
         * @param country Country to associate with transaction.
         */
        public function addTrans(orderId:String, affiliation:String, total:Number, tax:Number, shipping:Number, city:String, state:String, country:String):void
        {
            LOG::P{ _log.v( "addTrans( " + [orderId,affiliation,total,tax,shipping,city,state,country].join( ", " ) + " )" ); }
            
            /* TODO:
               decide if we want to return an actual transaction object from this ?
            */
            _call( "_addTrans", orderId, affiliation, total, tax, shipping, city, state, country );
            
        }
        
        /**
         * Sends both the transaction and item data to the Google Analytics server.
         * This method should be called after trackPageview(),
         * and used in conjunction with the addItem() and addTrans() methods.
         * It should be called after items and transaction elements have been set up.
         */
        public function trackTrans():void
        {
            LOG::P{ _log.v( "trackTrans()" ); }
            
            _call( "_trackTrans" );
        }
        
        // END ECOMMERCE TRACKING
        // -----------------------------------------------------------------------------
        // START EVENT TRACKING
        
        public function createEventTracker( objName:String ):EventTracker
        {
            LOG::P{ _log.v( "createEventTracker( " + objName + " )" ); }
            
            /* note:
               we don't need to forward to a JS call
               as ultimately the EventTracker.trackEvent()
               will redirect to the Bridge which then proxy to JS.
               
               In short, JS EventTrackers should be stored JS side
               and AS3 EventTrackers should be stored AS3 side.
            */
            return new EventTracker( objName, this );
        }
        
       /**
        * Constructs and sends the event tracking call to the Google Analytics Tracking Code. 
        * Use this to track visitor behavior on your website that is not related to a web page visit, 
        * such as interaction with a Flash video movie control or any user event that does not
        * trigger a page request. 
        * 
        * @param category The general event category (e.g. "Videos"). 
        * @param action The action for the event (e.g. "Play"). 
        * @param opt_label An optional descriptor for the event. 
        * @param opt_value An optional value to be aggregated with the event.
        * 
        * @return whether the event was sucessfully sent
        */
        public function trackEvent( category:String, action:String, label:String = null, value:Number = NaN ):Boolean
        {
            var param:int = 2;
            
            if( label && (label != "") )
            {
                param = 3;
            }
            
            //check if value=0 can pass
            if( (param == 3) && !isNaN(value) )
            {
                param = 4;
            }
            
            switch( param )
            {
                case 4:
                LOG::P{ _log.v( "trackEvent( " + [category,action,label,value].join( ", " ) + " )" ); }
                return _call( "_trackEvent", category, action, label, value );
                
                case 3:
                LOG::P{ _log.v( "trackEvent( " + [category,action,label].join( ", " ) + " )" ); }
                return _call( "_trackEvent", category, action, label );
                
                case 2:
                default:
                LOG::P{ _log.v( "trackEvent( " + [category,action].join( ", " ) + " )" ); }
                return _call( "_trackEvent", category, action );
            }
            
        }
        
        // END EVENT TRACKING
        // -----------------------------------------------------------------------------
        // START SEARCH ENGINES AND REFERRERS 
        // Methods that you use for customizing search engines and referral traffic in Google Analytics reporting.
        
        /**
         * Sets the string as ignored term(s) for Keywords reports.
         * Use this to configure Google Analytics to treat certain search terms as direct traffic,
         * such as when users enter your domain name as a search term.
         * When you set keywords using this method,
         * the search terms are still included in your overall page view counts,
         * but not included as elements in the Keywords reports.
         * 
         * @param newIgnoredOrganicKeyword Keyword search terms to treat as direct traffic.
         */
        public function addIgnoredOrganic(newIgnoredOrganicKeyword:String):void
        {
            LOG::P{ _log.v( "addIgnoredOrganic( " + newIgnoredOrganicKeyword + " )" ); }
            
            _call( "_addIgnoredOrganic", newIgnoredOrganicKeyword );
        }
        
        /**
         * Excludes a source as a referring site.
         * Use this option when you want to set certain referring links as direct traffic,
         * rather than as referring sites.
         * 
         * For example, your company might own another domain that you want to track as
         * direct traffic so that it does not show up on the "Referring Sites" reports.
         * Requests from excluded referrals are still counted in your overall page view count.
         * 
         * @param newIgnoredReferrer Referring site to exclude.
         */
        public function addIgnoredRef(newIgnoredReferrer:String):void
        {
            LOG::P{ _log.v( "addIgnoredRef( " + newIgnoredReferrer + " )" ); }
            
            _call( "_addIgnoredRef", newIgnoredReferrer );
        }
        
        /**
         * Adds a search engine to be included as a potential search engine traffic source.
         * By default, Google Analytics recognizes a number of common search engines,
         * but you can add additional search engine sources to the list.
         * 
         * @param newOrganicEngine Engine for new organic source.
         * @param newOrganicKeyword Keyword name for new organic source.
         */
        public function addOrganic(newOrganicEngine:String, newOrganicKeyword:String):void
        {
            LOG::P{ _log.v( "addOrganic( " + [newOrganicEngine,newOrganicKeyword].join( ", " ) + " )" ); }
            
            _call( "_addOrganic", newOrganicEngine );
        }
        
        /**
         * Clears all strings previously set for exclusion from the Keyword reports.
         */
        public function clearIgnoredOrganic():void
        {
            LOG::P{ _log.v( "clearIgnoredOrganic()" ); }
            
            _call( "_clearIgnoreOrganic" );
        }
        
        /**
         * Clears all items previously set for exclusion from the Referring Sites report.
         */
        public function clearIgnoredRef():void
        {
            LOG::P{ _log.v( "clearIgnoredRef()" ); }
            
            _call( "_clearIgnoreRef" );
        }
        
        /**
         * Clears all search engines as organic sources.
         * Use this method when you want to define a customized search engine ordering precedence.
         */
        public function clearOrganic():void
        {
            LOG::P{ _log.v( "clearOrganic()" ); }
            
            _call( "_clearOrganic" );
        }
        
        /**
         * Gets the flag that indicates whether the browser tracking module is enabled.
         * See setClientInfo() for more information.
         * 
         * @return 1 if enabled, 0 if disabled.
         */
        public function getClientInfo():Boolean
        {
            LOG::P{ _log.v( "getClientInfo()" ); }
            
            return _call( "_getClientInfo" );
        }
        
        /**
         * Gets the Flash detection flag.
         * See setDetectFlash() for more information.
         * 
         * @return 1 if enabled, 0 if disabled.
         */
        public function getDetectFlash():Boolean
        {
            LOG::P{ _log.v( "getDetectFlash()" ); }
            
            return _call( "_getDetectFlash" );
        }
        
        /**
         * Gets the title detection flag.
         * 
         * @return 1 if enabled, 0 if disabled.
         */
        public function getDetectTitle():Boolean
        {
            LOG::P{ _log.v( "getDetectTitle()" ); }
            
            return _call( "_getDetectTitle" );
        }
        
        /**
         * Sets the browser tracking module.
         * By default, Google Analytics tracks browser information from your visitors
         * and provides more data about your visitor's browser settings that you get with a simple HTTP request.
         * If you desire, you can turn this tracking off by setting the parameter to false.
         * If you do this, any browser data will not be tracked and cannot be recovered
         * at a later date, so use this feature carefully.
         * 
         * @param enable Defaults to true, and browser tracking is enabled. If set to false, browser tracking is disabled.
         */
        public function setClientInfo(enable:Boolean):void
        {
            LOG::P{ _log.v( "setClientInfo( " + enable + " )" ); }
            
            _call( "_setClientInfo", enable );
        }
        
        /**
         * Sets the Flash detection flag.
         * By default, Google Analytics tracks Flash player information from your visitors
         * and provides detailed data about your visitor's Flash player settings.
         * If you desire, you can turn this tracking off by setting the parameter to false.
         * If you do this, any Flash player data will not be tracked and cannot be recovered
         * at a later date, so use this feature carefully.
         * 
         * @param enable Default is true and Flash detection is enabled. False disables Flash detection.
         */
        public function setDetectFlash(enable:Boolean):void
        {
            LOG::P{ _log.v( "setDetectFlash( " + enable + " )" ); }
            
            _call( "_setDetectFlash", enable );
        }
        
        /**
         * Sets the title detection flag.
         * By default, page title detection for your visitors is on.
         * This information appears in the Contents section under "Content by Title."
         * If you desire, you can turn this tracking off by setting the parameter to false.
         * You could do this if your website has no defined page titles and the Content by
         * Title report has all content grouped into the "(not set)" list.
         * You could also turn this off if all your pages have particularly long titles.
         * If you do this, any page titles that are defined in your website will not
         * be displayed in the "Content by Title" reports.
         * This information cannot be recovered at a later date once it is disabled.
         * 
         * @param enable Defaults to true, and title detection is enabled. If set to false, title detection is disabled.
         */
        public function setDetectTitle(enable:Boolean):void
        {
            LOG::P{ _log.v( "setDetectTitle( " + enable + " )" ); }
            
            _call( "_setDetectTitle", enable );
        }
        
        // END SEARCH ENGINES AND REFERRERS        
        // -----------------------------------------------------------------------------
        // START URCHIN SERVER
        // Methods that you use for configuring your server setup when you are using
        // both Google Analytics and the Urchin software to track your website.
        
        /**
         * Gets the local path for the Urchin GIF file.
         * See setLocalGifPath() for more information.
         * 
         * @return Path to GIF file on the local server.
         */
        public function getLocalGifPath():String
        {
            LOG::P{ _log.v( "getLocalGifPath()" ); }
            
            return _call( "_getLocalGifPath" );
        }
        
        /**
         * Returns the server operation mode.
         * Possible return values are 0 for local mode (sending data to local server set by setLocalGifPath()),
         * 1 for remote mode (send data to Google Analytics backend server), or 2 for both local and remote mode.
         * 
         * @return  Server operation mode.
         */
        public function getServiceMode():ServerOperationMode
        {
            LOG::P{ _log.v( "getServiceMode()" ); }
            
            return _call( "_getServiceMode" );
        }
        
        /**
         * Sets the local path for the Urchin GIF file.
         * Use this method if you are running the Urchin tracking software on your local servers.
         * The path you specific here is used by the setLocalServerMode() and setLocalRemoteServerMode()
         * methods to determine the path to the local server itself.
         * 
         * @param newLocalGifPath Path to GIF file on the local server.
         */
        public function setLocalGifPath(newLocalGifPath:String):void
        {
            LOG::P{ _log.v( "setLocalGifPath( " + newLocalGifPath + " )" ); }
            
            _call( "_setLocalGifPath", newLocalGifPath );
        }
        
        /**
         * Invoke this method to send your tracking data both to a local server
         * and to the Google Analytics backend servers.
         * You would use this method if you are running the Urchin tracking software
         * on your local servers and want to track data locally as well as via Google Analytics servers.
         * In this scenario, the path to the local server is set by setLocalGifPath().
         */
        public function setLocalRemoteServerMode():void
        {
            LOG::P{ _log.v( "setLocalRemoteServerMode()" ); }
            
            _call( "_setLocalRemoteServerMode" );
        }
        
        
        /**
         * Invoke this method to send your tracking data to a local server only.
         * You would use this method if you are running the Urchin tracking software on your local servers
         * and want all tracking data to be sent to your servers.
         * In this scenario, the path to the local server is set by setLocalGifPath().
         */
        public function setLocalServerMode():void
        {
            LOG::P{ _log.v( "setLocalServerMode()" ); }
            
            _call( "_setLocalServerMode" );
        }
        
        /**
         * Default installations of Google Analytics send tracking data to the Google Analytics server.
         * You would use this method if you have installed the Urchin software for your website
         * and want to send particular tracking data only to the Google Analytics server.
         */
        public function setRemoteServerMode():void
        {
            LOG::P{ _log.v( "setRemoteServerMode()" ); }
            
            _call( "_setRemoteServerMode" );
        }
        
        
        // END URCHIN SERVER
        // -----------------------------------------------------------------------------
        
        
    }
}
