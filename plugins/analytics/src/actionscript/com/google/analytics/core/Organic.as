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
    import com.google.analytics.utils.Variables;    

    /**
     * The Organic class.
     */
    public class Organic
    {
        public static var throwErrors:Boolean = false;
        
        /* note:
           about the different objects cache
           it's a little crude but it allow us
           to search engines/referrals/keywords
           in O(1) instead of O(n)
        */
        
        private var _sources:Array;
        private var _sourcesCache:Array;
        private var _sourcesEngine:Array;
        
        private var _ignoredReferrals:Array;
        private var _ignoredReferralsCache:Object;
        
        private var _ignoredKeywords:Array;
        private var _ignoredKeywordsCache:Object;
        
        /**
         * Creates a new Organic instance.
         */
        public function Organic()
        {
            _sources               = [];
            _sourcesCache          = [];
            _sourcesEngine         = [];
            _ignoredReferrals      = [];
            _ignoredReferralsCache = {};
            _ignoredKeywords       = [];
            _ignoredKeywordsCache  = {};
        }
        
        /**
         * Indicates the count value. 
         */
        public function get count():int
        {
            return _sources.length;
        }
        
        /**
         * Indicates the Array collection of all sources.
         */
        public function get sources():Array
        {
            return _sources;
        }
        
        public function get ignoredReferralsCount():int
        {
            return _ignoredReferrals.length;
        }
        
        public function get ignoredKeywordsCount():int
        {
            return _ignoredKeywords.length;
        }
        
        /**
         * Adds a source in the organic.
         */
        public function addSource( engine:String, keyword:String ):void
        {
            var orgref:OrganicReferrer = new OrganicReferrer(engine, keyword);
            
            if( _sourcesCache[ orgref.toString() ] == undefined )
            {
                _sources.push( orgref );
                _sourcesCache[ orgref.toString() ] = _sources.length-1;
                if( _sourcesEngine[ orgref.engine ] == undefined )
                {
                    _sourcesEngine[ orgref.engine ] = [ _sources.length-1 ];
                }
                else
                {
                    _sourcesEngine[ orgref.engine ].push( _sources.length-1 );
                }
            }
            else if( throwErrors )
            {
                throw new Error( orgref.toString() + " already exists, we don't add it." );
            }
        }
        
        public function addIgnoredReferral( referrer:String ):void
        {
            if( _ignoredReferralsCache[ referrer ] == undefined )
            {
                _ignoredReferrals.push( referrer );
                _ignoredReferralsCache[ referrer ] = _ignoredReferrals.length-1;
            }
            else if( throwErrors )
            {
                throw new Error( "\"" + referrer + "\" already exists, we don't add it." );
            }
        }
        
        public function addIgnoredKeyword( keyword:String ):void
        {
            if( _ignoredKeywordsCache[ keyword ] == undefined )
            {
                _ignoredKeywords.push( keyword );
                _ignoredKeywordsCache[ keyword ] = _ignoredKeywords.length-1;
            }
            else if( throwErrors )
            {
                throw new Error( "\"" + keyword + "\" already exists, we don't add it." );
            }
        }
        
        /**
         * Clear all the engines / ignored referrals / ignored keywords.
         */
        public function clear():void
        {
            clearEngines();
            clearIgnoredReferrals();
            clearIgnoredKeywords();
        }
        
        /**
        * Clear the orgnaic engines.
        */
        public function clearEngines():void
        {
            _sources       = [];
            _sourcesCache  = [];
            _sourcesEngine = [];
        }
        
        /**
        * Clear the ignored referrals.
        */
        public function clearIgnoredReferrals():void
        {
            _ignoredReferrals = [];
            _ignoredReferralsCache = {};
        }
        
        /**
        * Clear the ignored keywords.
        */
        public function clearIgnoredKeywords():void
        {
            _ignoredKeywords = [];
            _ignoredKeywordsCache = {};
        }
        
        /**
         * Returns the keyword value of the organic referrer.
         * @return the keyword value of the organic referrer.
         */
        public function getKeywordValue( or:OrganicReferrer, path:String ):String
        {
            var keyword:String = or.keyword;
            return getKeywordValueFromPath( keyword, path );
        }
        
        /**
         * Returns a keyword value from the specified path.
         * @return  a keyword value from the specified path.
         */
        public static function getKeywordValueFromPath( keyword:String, path:String ):String
        {
            var value:String;
            
            if( path.indexOf( keyword+"=" ) > -1 )
            {
                if( path.charAt(0) == "?" )
                {
                    path = path.substr(1);
                }
                
                path = path.split( "+" ).join( "%20" );
                
                var vars:Variables = new Variables( path );
                value = vars[keyword];
            }
            
            return value;
        }
        
        /**
         * Returns the OrganicReferrer by name.
         * @return the OrganicReferrer by name.
         */
        public function getReferrerByName( name:String ):OrganicReferrer
        {
            if( match( name ) )
            {
                //by default return the first referrer found
                var index:int = _sourcesEngine[ name ][0];
                return _sources[ index ];
            }
            
            return null;
        }
        
        /**
        * Indicates if the passed referrer is in the list
        * of ignored referrals.
        */
        public function isIgnoredReferral( referrer:String ):Boolean
        {
            if( _ignoredReferralsCache.hasOwnProperty( referrer ) )
            {
                return true;
            }
            
            return false;
        }
        
        /**
        * Indicates if the passed keyword is in the list
        * of ignored keywords.
        */
        public function isIgnoredKeyword( keyword:String ):Boolean
        {
            if( _ignoredKeywordsCache.hasOwnProperty( keyword ) )
            {
                return true;
            }
            
            return false;
        }
        
        
        /**
         * Match the specified value.
         */
        public function match( name:String ):Boolean
        {
            if( name == "" )
            {
                return false;
            }
            
            name = name.toLowerCase();
            
            if( _sourcesEngine[ name ] != undefined )
            {
                return true;
            }
            
            return false;
        }
        
    }
}