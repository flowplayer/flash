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
 *   Marc ALCARAZ <ekameleon@gmail.com>.
 *   Zwetan Kjukov <zwetan@gmail.com>.
 */
 
package com.google.analytics.core 
{
    import com.google.analytics.v4.GoogleAnalyticsAPI;
    
    import flash.errors.IllegalOperationError;    

    /**
     * This queue is used in the GA trackers during the initialize process to keep in memory the users tracking.
     * This cache is flushing when the tracker is initialize.
     */
    public class TrackerCache implements GoogleAnalyticsAPI
    {
        
        /**
         * @private
         */
        private var _ar:Array ;
        
        /**
         * Creates a new TrackerCache instance
         * @param The GoogleAnalyticsAPI tracker object caching in memory.
         */
        public function TrackerCache( tracker:GoogleAnalyticsAPI = null )
        {
            this.tracker = tracker ;
            _ar = [] ;
        }
        
        /**
         * Indicates if the object throws errors.
         */
        public static var CACHE_THROW_ERROR:Boolean;
        
        /**
         * The GoogleAnalyticsAPI target of this tracker cache object.
         */
        public var tracker:GoogleAnalyticsAPI;
        
        /**
         * Removes all commands in memory.
         */
        public function clear():void
        {
           _ar = [];
        }
        
        /**
         * Retrieves, but does not remove, the head of this queue.
         */
        public function element():*
        {
            return _ar[0];
        }
        
        /**
         * Enqueue a new tracker command in the tracker cache.
         * @param name The name of the method to invoke.
         * @param ...args The optional arguments passed-in the method. 
         */
        public function enqueue( name:String , ...args:Array ):Boolean 
        {
            if (name == null)
            {
                return false;
            }
            _ar.push( { name:name , args:args } );
            return true;
        }
        
        /**
         * Flush the memory of the tracker cache.
         */
        public function flush():void
        {
            if ( tracker == null )
            {
                return;
            }
            if ( size() > 0 )
            {
                var o:Object;
                var name:String;
                var args:Array;
                var l:int = _ar.length;
                
                for( var i:int ; i < l ; i++ )
                {
                    o = _ar.shift() ;
                    name = o.name as String ;
                    args = o.args as Array  ;
                    if ( name != null && name in tracker )
                    {
                        (tracker[name] as Function).apply(tracker, args) ;
                    }
                }
            }
            else
            {
                // 
            }
        }
        
        /**
         * Indicates if the tracker cache is empty.
         */
        public function isEmpty():Boolean
        {
           return _ar.length == 0 ;
        }
        
        /**
         * Returns the number of commands in the tracker cache.
         * @return the number of commands in the tracker cache.
         */
        public function size():uint
        {
            return _ar.length ;	
        }
        
        //////////////////////////// GoogleAnalyticsAPI implementation
        
        public function addIgnoredOrganic( newIgnoredOrganicKeyword:String ):void
        {
            enqueue("addIgnoredOrganic", newIgnoredOrganicKeyword) ;
        }
        
        public function addIgnoredRef(newIgnoredReferrer:String):void
        {
            enqueue("addIgnoredRef", newIgnoredReferrer ) ;
        }
        
        public function addItem(item:String, sku:String, name:String, category:String, price:Number, quantity:int):void
        {
            enqueue("addItem", item, sku, name, category, price, quantity) ;
        }
        
        public function addOrganic(newOrganicEngine:String, newOrganicKeyword:String):void
        {
        	enqueue("addOrganic", newOrganicEngine, newOrganicKeyword) ;
        }
        
        public function addTrans(orderId:String, affiliation:String, total:Number, tax:Number, shipping:Number, city:String, state:String, country:String):void
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'addTrans' method for the moment.") ;             
            }
        }
        
        public function clearIgnoredOrganic():void
        {
            enqueue("clearIgnoredOrganic");
        }
        
        public function clearIgnoredRef():void
        {
            enqueue("clearIgnoredRef");
        }
        
        public function clearOrganic():void
        {
            enqueue("clearOrganic") ;
        }
        
        public function createEventTracker(objName:String):EventTracker
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'createEventTracker' method for the moment.") ;               
            }
            return null ;
        }
        
        public function cookiePathCopy(newPath:String):void
        {
            enqueue("cookiePathCopy", newPath);
        }
        
        public function getAccount():String
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'getAccount' method for the moment.") ;             
            }
            return "";
        }
        
        public function getClientInfo():Boolean
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'getClientInfo' method for the moment.") ;             
            }
            return false;
        }
        
        public function getDetectFlash():Boolean
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'getDetectFlash' method for the moment.") ;             
            }
            return false;
        }
        
        public function getDetectTitle():Boolean
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'getDetectTitle' method for the moment.") ;             
            }
            return false;
        }
        
        public function getLocalGifPath():String
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'getLocalGifPath' method for the moment.") ;             
            }
            return "";
        }
        
        public function getServiceMode():ServerOperationMode
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'getServiceMode' method for the moment.") ;             
            }
            return null;
        }
        
        public function getVersion():String
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'getVersion' method for the moment.") ;             
            }
            return "";
        }
        
        public function resetSession():void
        {
            enqueue("resetSession");
        }
        
        public function getLinkerUrl( url:String ="", useHash:Boolean=false ):String
        {
            if ( CACHE_THROW_ERROR )
            {
                throw new IllegalOperationError("The tracker is not ready and you can use the 'getLinkerUrl' method for the moment.") ;             
            }
            return "";        	
        }
        
        public function link(targetUrl:String, useHash:Boolean = false):void
        {
        	enqueue("link", targetUrl, useHash) ;
        }
        
        public function linkByPost(formObject:Object, useHash:Boolean = false):void
        {
            enqueue("linkByPost", formObject, useHash) ;
        }
        
        public function setAllowAnchor(enable:Boolean):void
        {
            enqueue("setAllowAnchor", enable) ;
        }
        
        public function setAllowHash(enable:Boolean):void
        {
        	enqueue("setAllowHash", enable) ;
        }
        
        public function setAllowLinker(enable:Boolean):void
        {
        	enqueue("setAllowLinker", enable) ;
        }
        
        public function setCampContentKey(newCampContentKey:String):void
        {
            enqueue("setCampContentKey", newCampContentKey) ;
        }
        
        public function setCampMediumKey(newCampMedKey:String):void
        {
            enqueue("setCampMediumKey", newCampMedKey) ;
        }
        
        public function setCampNameKey(newCampNameKey:String):void
        {
            enqueue("setCampNameKey", newCampNameKey) ;
        }
        
        public function setCampNOKey(newCampNOKey:String):void
        {
            enqueue("setCampNOKey", newCampNOKey) ;
        }
        
        public function setCampSourceKey(newCampSrcKey:String):void
        {
            enqueue("setCampSourceKey", newCampSrcKey) ;
        }
        
        public function setCampTermKey(newCampTermKey:String):void
        {
            enqueue("setCampTermKey", newCampTermKey) ;
        }
        
        public function setCampaignTrack(enable:Boolean):void
        {
            enqueue("setCampaignTrack", enable) ;
        }
        
        public function setClientInfo(enable:Boolean):void
        {
            enqueue("setClientInfo", enable) ;
        }
        
        public function setCookieTimeout(newDefaultTimeout:int):void
        {
            enqueue("setCookieTimeout", newDefaultTimeout) ;
        }
        
        public function setCookiePath(newCookiePath:String):void
        {
        	enqueue("setCookiePath", newCookiePath) ;
        }
        
        public function setDetectFlash(enable:Boolean):void
        {
        	enqueue("setDetectFlash", enable) ;
        }
        
        public function setDetectTitle(enable:Boolean):void
        {
        	enqueue("setDetectTitle", enable) ;
        }        
        
        public function setDomainName(newDomainName:String):void
        {
        	enqueue("setDomainName", newDomainName) ;
        }
        
        public function setLocalGifPath(newLocalGifPath:String):void
        {
        	enqueue("setLocalGifPath", newLocalGifPath) ;
        }
        
        public function setLocalRemoteServerMode():void
        {
        	enqueue("setLocalRemoteServerMode") ;
        }
        
        public function setLocalServerMode():void
        {
        	enqueue("setLocalServerMode") ;
        }
        
        public function setRemoteServerMode():void
        {
        	enqueue("setRemoteServerMode") ;
        }
        
        public function setSampleRate(newRate:Number):void
        {
        	enqueue("setSampleRate", newRate) ;
        }
        
        public function setSessionTimeout(newTimeout:int):void
        {
        	enqueue("setSessionTimeout", newTimeout) ;
        }
        
        public function setVar(newVal:String):void
        {
        	enqueue("setVar", newVal) ;
        }
         
        public function trackEvent(category:String, action:String, label:String = null, value:Number = NaN):Boolean
        {
        	enqueue("trackEvent", category, action, label, value) ;
            return true ;
        }           
        
        public function trackPageview(pageURL:String = ""):void
        {
            enqueue("trackPageview", pageURL) ;
        }         
        
        public function trackTrans():void
        {
            enqueue("trackTrans") ;
        }        

    }

}
