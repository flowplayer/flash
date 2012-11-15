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
    
    /**
    * The GA v4 API as documented
    * http://code.google.com/apis/analytics/docs/gaJSApi.html
    * http://code.google.com/apis/analytics/docs/gaTrackingOverview.html
    * http://code.google.com/apis/analytics/docs/gaTrackingTroubleshooting.html
    */
    public interface GoogleAnalyticsAPI
    {
        
        // ----------------------------------------
        // Basic Configuration
        // Methods that you use for customizing all aspects of Google Analytics reporting.
        
        /**
         * Returns the Google Analytics tracking ID for this tracker object.
         * If you are tracking pages on your website in multiple accounts,
         * you can use this method to determine the account that is associated
         * with a particular tracker object.
         * @return the Account ID this tracker object is instantiated with.
         */
        function getAccount():String;
        
        /**
         * Returns the GATC version number.
         * @return GATC version number.
         */
        function getVersion():String;
        
        /**
         * Reset the current session clearing the utmb and utmc cookies.
         */
        function resetSession():void;
        
        /**
         * Sets the new sample rate.
         * If your website is particularly large and subject to heavy traffic spikes,
         * then setting the sample rate ensures un-interrupted report tracking.
         * 
         * Sampling in Google Analytics occurs consistently across unique visitors,
         * so there is integrity in trending and reporting even when sampling is enabled,
         * because unique visitors remain included or excluded from the sample,
         * as set from the initiation of sampling.
         * 
         * @param newRate New sample rate to set. Provide a numeric as a whole percentage, 0.1 being 10%, 1 being 100%.
         */
        function setSampleRate( newRate:Number ):void;
        
        /**
         * Sets the new session timeout in seconds. By default, session timeout is set to 30 minutes (1800 seconds).
         * 
         * <p>Session timeout is used to compute visits,
         * since a visit ends after 30 minutes of browser inactivity or upon browser exit.</p>
         * <p>If you want to change the definition of a "session" for your particular needs, 
         * you can pass in the number of seconds to define a new value.</p>
         * 
         * <p>This will impact the Visits reports in every section where the number of 
         * visits are calculated, and where visits are used in computing other values.</p>
         * <p>For example, the number of visits will increase if you shorten the session timeout, 
         * and will decrease if you increase the session timeout.</p>
         * 
         * @param newTimeout New session timeout to set in seconds.
         */
        function setSessionTimeout( newTimeout:int ):void;
        
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
        function setVar(newVal:String):void;
        
        /**
         * Main logic for GATC (Google Analytic Tracker Code).
         * If linker functionalities are enabled, it attempts to extract cookie values from the URL.
         * Otherwise, it tries to extract cookie values from document.cookie.
         * It also updates or creates cookies as necessary, then writes them back to the document object.
         * Gathers all the appropriate metrics to send to the UCFE (Urchin Collector Front-end).
         * 
         * @param pageURL Optional parameter to indicate what page URL to track metrics under. When using this option, use a beginning slash (/) to indicate the page URL.
         */
        function trackPageview(pageURL:String=""):void
        
        
        // ----------------------------------------
        // Campaign Tracking
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
        function setAllowAnchor(enable:Boolean):void;
        
        /**
         * Sets the campaign ad content key.
         * The campaign content key is used to retrieve the ad content (description)
         * of your advertising campaign from your campaign URLs.
         * Use this function on the landing page defined in your campaign.
         * 
         * @param newCampContentKey New campaign content key to set.
         */
        function setCampContentKey(newCampContentKey:String):void;
        
        /**
         * Sets the campaign medium key,
         * which is used to retrieve the medium from your campaign URLs.
         * The medium appears as a segment option in the Campaigns report.
         * 
         * @param newCampMedKey Campaign medium key to set.
         */
        function setCampMediumKey(newCampMedKey:String):void;
        
        /**
         * Sets the campaign name key.
         * The campaign name key is used to retrieve the name of your advertising campaign from your campaign URLs.
         * You would use this function on any page that you want to track click-campaigns on.
         * 
         * @param newCampNameKey Campaign name key.
         */
        function setCampNameKey(newCampNameKey:String):void;
        
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
        function setCampNOKey(newCampNOKey:String):void;
        
        /**
         * Sets the campaign source key,
         * which is used to retrieve the campaign source from the URL.
         * "Source" appears as a segment option in the Campaigns report.
         * 
         * @param newCampSrcKey Campaign source key to set.
         */
        function setCampSourceKey(newCampSrcKey:String):void;
        
        /**
         * Sets the campaign term key,
         * which is used to retrieve the campaign keywords from the URL.
         * 
         * @param newCampTermKey Term key to set.
         */
        function setCampTermKey(newCampTermKey:String):void;
        
        /**
         * Sets the campaign tracking flag.
         * By default, campaign tracking is enabled for standard Google Analytics set up.
         * If you wish to disable campaign tracking and the associated cookies
         * that are set for campaign tracking, you can use this method.
         * 
         * @param enable True by default, which enables campaign tracking. If set to false, campaign tracking is disabled.
         */
        function setCampaignTrack(enable:Boolean):void;
        
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
        function setCookieTimeout(newDefaultTimeout:int):void;
        
        
        // ----------------------------------------
        // Domains and Directories
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
        function cookiePathCopy(newPath:String):void;
        
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
        function getLinkerUrl( url:String = "", useHash:Boolean = false ):String;
        
        /**
         * This method works in conjunction with the setDomainName() and
         * setAllowLinker() methods to enable cross-domain user tracking.
         * The link() method passes the cookies from this site to another via URL parameters (HTTP GET).
         * It also changes the document.location and redirects the user to the new URL.
         * 
         * @param targetUrl URL of target site to send cookie values to.
         * @param useHash Set to true for passing tracking code variables by using the # anchortag separator rather than the default ? query string separator. (Currently this behavior is for internal Google properties only.)
         */
        function link(targetUrl:String, useHash:Boolean = false):void;
        
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
        /* TODO:
           type formObject as HTMLFormElement ?
           define a FormElement interface ? so Flash site can define also such object.
         */
        function linkByPost(formObject:Object, useHash:Boolean = false):void;
        
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
        function setAllowHash(enable:Boolean):void;
        
        /**
         * Sets the campaign tracking flag.
         * By default, campaign tracking is enabled for standard Google Analytics set up.
         * If you wish to disable campaign tracking and the associated cookies that are set
         * for campaign tracking, you can use this method.
         * 
         * @param enable True by default, which enables campaign tracking. If set to false, campaign tracking is disabled.
         */
        //function setCampaignTrack(enable:Boolean = true):void;
        
        /**
         * Sets the linker functionality flag as part of enabling cross-domain user tracking.
         * By default, this method is set to false and linking is disabled.
         * See also link(), linkByPost(), and setDomainName() methods to enable cross-domain tracking.
         * 
         * @param enable If this parameter is set to true, then linker is enabled. Else, linker is disabled.
         */
        function setAllowLinker(enable:Boolean):void;
        
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
        function setCookiePath(newCookiePath:String):void;
        
        /**
         * Sets the domain name for cookies.
         * There are three modes to this method: ("auto" | "none" | [domain]).
         * By default, the method is set to auto, which attempts to resolve
         * the domain name based on the location object in the DOM.
         * 
         * @param newDomainName New default domain name to set.
         */
        /* TODO:
           use an Enum that resolve to "none", "auto", or a domain ?
         */
        function setDomainName(newDomainName:String):void;
        
        
        // ----------------------------------------
        // Ecommerce
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
        function addItem(item:String, sku:String, name:String, category:String, price:Number, quantity:int):void;
        
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
        function addTrans(orderId:String, affiliation:String, total:Number, tax:Number, shipping:Number, city:String, state:String, country:String):void;
        
        /**
         * Sends both the transaction and item data to the Google Analytics server.
         * This method should be called after trackPageview(),
         * and used in conjunction with the addItem() and addTrans() methods.
         * It should be called after items and transaction elements have been set up.
         */
        function trackTrans():void;
        
        
        // ----------------------------------------
        // Event Tracking
        // Methods that you use for setting up Event Tracking in Google Analytics reporting.
        
        /**
         * Creates an event tracking object with the specified name.
         * <p>Call this method when you want to create a new web page object to track 
         * in the Event Tracking section of the reporting.</p>
         * <p>See the Event Tracking Guide for more information.</p>
         * @param objName The name of the tracked object.
         * @return A new EventTracker instance.
         */
        function createEventTracker( objName:String ):EventTracker;
        
        /**
         * Constructs and sends the event tracking call to GATC.
         * 
         * @param category The general event category (e.g. "Videos").
         * @param action The action for the event (e.g. "Play"). 
         * @param label An optional descriptor for the event.
         * @param value An optional value to be aggregated with the event.
         * 
         * @return Whether the event was successfully sent.
         */
        function trackEvent( category:String, action:String, label:String = null, value:Number = NaN ):Boolean;
        
        // ----------------------------------------
        // Search Engines and Referrers
        // Methods that you use for customizing search engines and referral traffic in Google Analytics reporting.
        
        /**
         * Sets the string as ignored term(s) for Keywords reports.
         * <p>Use this to configure Google Analytics to treat certain search terms as direct traffic,
         * such as when users enter your domain name as a search term.</p>
         * <p>When you set keywords using this method, 
         * the search terms are still included in your overall page view counts, 
         * but not included as elements in the Keywords reports.</p>
         * @param newIgnoredOrganicKeyword Keyword search terms to treat as direct traffic.
         */
        function addIgnoredOrganic(newIgnoredOrganicKeyword:String):void;
        
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
        function addIgnoredRef(newIgnoredReferrer:String):void;
        
        /**
         * Adds a search engine to be included as a potential search engine traffic source.
         * By default, Google Analytics recognizes a number of common search engines,
         * but you can add additional search engine sources to the list.
         * 
         * @param newOrganicEngine Engine for new organic source.
         * @param newOrganicKeyword Keyword name for new organic source.
         */
        function addOrganic(newOrganicEngine:String, newOrganicKeyword:String):void;
        
        /**
         * Clears all strings previously set for exclusion from the Keyword reports.
         */
        function clearIgnoredOrganic():void;
        
        /**
         * Clears all items previously set for exclusion from the Referring Sites report.
         */
        function clearIgnoredRef():void;
        
        /**
         * Clears all search engines as organic sources.
         * Use this method when you want to define a customized search engine ordering precedence.
         */
        function clearOrganic():void;
        
        
        // ----------------------------------------
        // Web Client
        // Methods that you use to customize web client information tracking in Google Analytics reporting.
        
        /* NOTE:
           GA docs is misleading
           http://code.google.com/apis/analytics/docs/gaJSApiWebClient.html
           _getClientInfo(1)
           _getDetectFlash(1)
           _getDetectTitle(1)
           make no sens and must be the result of automated doc generation
           
           TODO:
           maybe clean up for AS3, as we have getter/setter
           something like
           function get clientInfo():Boolean
           function set clientInfo(value:Boolean):void
           etc.
           or let the functions as they are but add those for AS3
           function get trackClientInfo():Boolean
           function set trackClientInfo(value:Boolean):void
         */
        
        /**
         * Gets the flag that indicates whether the browser tracking module is enabled.
         * See setClientInfo() for more information.
         * 
         * @return 1 if enabled, 0 if disabled.
         */
        function getClientInfo():Boolean;
        
        /**
         * Gets the Flash detection flag.
         * See setDetectFlash() for more information.
         * 
         * @return 1 if enabled, 0 if disabled.
         */
        function getDetectFlash():Boolean;
        
        /**
         * Gets the title detection flag.
         * 
         * @return 1 if enabled, 0 if disabled.
         */
        function getDetectTitle():Boolean;
        
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
        function setClientInfo(enable:Boolean):void;
        
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
        function setDetectFlash(enable:Boolean):void;
        
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
        function setDetectTitle(enable:Boolean):void;
        
        
        // ----------------------------------------
        // Urchin Server
        // Methods that you use for configuring your server setup when you are using
        // both Google Analytics and the Urchin software to track your website.
        
        /**
         * Gets the local path for the Urchin GIF file.
         * See setLocalGifPath() for more information.
         * 
         * @return Path to GIF file on the local server.
         */
        function getLocalGifPath():String;
        
        /**
         * Returns the server operation mode.
         * Possible return values are 0 for local mode (sending data to local server set by setLocalGifPath()),
         * 1 for remote mode (send data to Google Analytics backend server), or 2 for both local and remote mode.
         * 
         * @return  Server operation mode.
         */
        function getServiceMode():ServerOperationMode;
        
        /**
         * Sets the local path for the Urchin GIF file.
         * Use this method if you are running the Urchin tracking software on your local servers.
         * The path you specific here is used by the setLocalServerMode() and setLocalRemoteServerMode()
         * methods to determine the path to the local server itself.
         * 
         * @param newLocalGifPath Path to GIF file on the local server.
         */
        function setLocalGifPath(newLocalGifPath:String):void;
        
        /**
         * Invoke this method to send your tracking data both to a local server
         * and to the Google Analytics backend servers.
         * You would use this method if you are running the Urchin tracking software
         * on your local servers and want to track data locally as well as via Google Analytics servers.
         * In this scenario, the path to the local server is set by setLocalGifPath().
         */
        function setLocalRemoteServerMode():void;
        
        /**
         * Invoke this method to send your tracking data to a local server only.
         * You would use this method if you are running the Urchin tracking software on your local servers
         * and want all tracking data to be sent to your servers.
         * In this scenario, the path to the local server is set by setLocalGifPath().
         */
        function setLocalServerMode():void;
        
        /**
         * Default installations of Google Analytics send tracking data to the Google Analytics server.
         * You would use this method if you have installed the Urchin software for your website
         * and want to send particular tracking data only to the Google Analytics server.
         */
        function setRemoteServerMode():void;
        
    }
}