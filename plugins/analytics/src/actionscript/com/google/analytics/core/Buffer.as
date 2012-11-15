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
    import com.google.analytics.data.UTMA;
    import com.google.analytics.data.UTMB;
    import com.google.analytics.data.UTMC;
    import com.google.analytics.data.UTMK;
    import com.google.analytics.data.UTMV;
    import com.google.analytics.data.UTMX;
    import com.google.analytics.data.UTMZ;
    import com.google.analytics.log;
    import com.google.analytics.v4.Configuration;
    
    import core.Logger;
    
    import flash.events.NetStatusEvent;
    import flash.net.SharedObject;
    import flash.net.SharedObjectFlushStatus;
    
    /**
     * Google Analytics Tracker Code (GATC)'s memory module.
     */
    public dynamic class Buffer
    {
        private var _log:Logger;
        
        private var _config:Configuration;
        
        private var _SO:SharedObject;
        private var _OBJ:Object;
        private var _data:Object;

        
        /* indicates if the buffer has a volatile memory
           volatile means we'll lose the memory as soon as the application is closed
           non-volatile means we are saving the memory data on the local hard drive
        */
        private var _volatile:Boolean;
        
        private var _utma:UTMA;
        private var _utmb:UTMB;
        private var _utmc:UTMC;
        private var _utmk:UTMK;
        private var _utmx:UTMX;
        private var _utmv:UTMV;
        private var _utmz:UTMZ;
        
        private function _onFlushStatus( event:NetStatusEvent ):void
        {
            LOG::P{ _log.v( "_onFlushStatus()" ); }
            
            LOG::P{ _log.i( "User closed permission dialog..." ); }
            
            LOG::P
            {
                switch( event.info.code )
                {
                    case "SharedObject.Flush.Success":
                    _log.i( "User granted permission -- value saved." );
                    break;
                    
                    case "SharedObject.Flush.Failed":
                    _log.i( "User denied permission -- value not saved." );
                    break;
                }
            }
            
            _SO.removeEventListener( NetStatusEvent.NET_STATUS, _onFlushStatus );
        }
        
        private function _clearUTMA():void
        {
            LOG::P{ _log.v( "_clearUTMA()" ); }
            
            _utma = null;
            
            if( !isVolatile() )
            {
                _SO.data.utma = null;
                delete _SO.data.utma;
            }
            
        }
        
        private function _clearUTMB():void
        {
            LOG::P{ _log.v( "_clearUTMB()" ); }
            
            _utmb = null;
            
            if( !isVolatile() )
            {
                _SO.data.utmb = null;
                delete _SO.data.utmb;
            }
            
        }
        
        private function _clearUTMC():void
        {
            LOG::P{ _log.v( "_clearUTMC()" ); }
            
            _utmc = null;
            //utmc is not saved in SO
        }
        
        private function _clearUTMV():void
        {
            LOG::P{ _log.v( "_clearUTMV()" ); }
            
            _utmv = null;
            
            if( !isVolatile() )
            {
                _SO.data.utmv = null;
                delete _SO.data.utmv;
            }
            
        }
        
        private function _clearUTMZ():void
        {
            LOG::P{ _log.v( "_clearUTMZ()" ); }
            
            _utmz = null;
            
            if( !isVolatile() )
            {
                _SO.data.utmz = null;
                delete _SO.data.utmz;
            }
            
        }
        
        private function _createUMTA():void
        {
            LOG::P{ _log.v( "_createUMTA()" ); }
            
            _utma = new UTMA();
            _utma.proxy = this;
        }
        
        private function _createUMTB():void
        {
            LOG::P{ _log.v( "_createUMTB()" ); }
            
            _utmb = new UTMB();
            _utmb.proxy = this;
        }
        
        private function _createUMTC():void
        {
            LOG::P{ _log.v( "_createUMTC()" ); }
            
            _utmc = new UTMC();
            //_utmc.proxy = this;
        }
        
        private function _createUMTK():void
        {
            LOG::P{ _log.v( "_createUMTK()" ); }
            
            _utmk = new UTMK();
            _utmk.proxy = this;
        }
        
        private function _createUMTX():void
        {
            LOG::P{ _log.v( "_createUMTX()" ); }
            
        	_utmx = new UTMX();
        	_utmx.proxy = this;
        }
        
        private function _createUMTV():void
        {
            LOG::P{ _log.v( "_createUMTV()" ); }
            
            _utmv = new UTMV();
            _utmv.proxy = this;
        }
        
        private function _createUMTZ():void
        {
            LOG::P{ _log.v( "_createUMTZ()" ); }
            
            _utmz = new UTMZ();
            _utmz.proxy = this;
        }
        
        /**
         * Creates a new Buffer instance.
         * @param config The Configuration reference use in the Buffer to set it.
         * @param volatile If true no use of SharedObject, only in-memory data.
         * @param data Can be used to inject data into OBJ or SO.
         */
        public function Buffer( config:Configuration, volatile:Boolean = false, data:Object = null )
        {
            LOG::P{ _log = log.tag( "Buffer" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
            // note : data should be used to inject the data from the query string
            
            _config = config;
            _data = data;
            
            /* note:
               we update the timespan from config only once
               (when the factory is created)
               if we wanted to interactively change the timespan
               we would have to dispatch events and use
               a changeTimespan() method on UTMCookie objects
               
               UTMA/UTMV/UTMX timespan are not user configurable
            */
                        
            _volatile = volatile;
            /*
            If not using SO, can just store data here.
            */
            if (_volatile) 
            {
            	_OBJ = new Object();
                
                if( _data )
                {
                    //inject data
                    for( var prop:String in _data )
                    {
                        _OBJ[prop] = _data[prop];
                    }
                }
            }
                    
        }
        
        /**
        * Public function to create Shared Object
        * 
        */
        public function createSO():void 
        {
            LOG::P{ _log.v( "createSO()" ); }
            
        	UTMZ.defaultTimespan = _config.conversionTimeout;
        	UTMB.defaultTimespan = _config.sessionTimeout;        	
        	
        	if( !_volatile )
            {
            	
            	try
            	{
            		_SO = SharedObject.getLocal( _config.cookieName, _config.cookiePath );
             	}
                catch( e:Error )
                {
                    var msg:String = "Shared Object "+ _config.cookieName +" failed to be set\nreason: " + e.message;
                    LOG::P{ _log.e( msg ); }
                    if( _config.enableErrorChecking ) { throw new Error( msg ); }
                }
                
                
                /* note:
                   if some data of the SO are deleted
                   we want to force a save()
                */
                var saveSO:Boolean = false;
                
                //utma value
                if( _SO.data.utma )
                {
                    if( !hasUTMA() ) { _createUMTA(); }
                    
                    _utma.fromSharedObject( _SO.data.utma );
                    
                    LOG::P{ _log.i( "utma = " + _utma.toString(true) ); }
                    
                    if( _utma.isExpired() )
                    {
                        LOG::P{ _log.w( "UTMA has expired" ); }
                        
                        _clearUTMA();
                        saveSO = true;
                    }
                    
                }
                
                if( _SO.data.utmb )
                {
                    if( !hasUTMB() ) { _createUMTB(); }
                    
                    _utmb.fromSharedObject( _SO.data.utmb );
                    
                    LOG::P{ _log.i( "utmb = " + _utmb.toString(true) ); }
                    
                    if( _utmb.isExpired() )
                    {
                        LOG::P{ _log.w( "UTMB has expired" ); }
                        
                        _clearUTMB();
                        saveSO = true;
                    }
                    
                }
                
                /* note:
                   utmc should always be volatile
                   as we never save it in a cookie, it expires as soon as
                   the user end the session
                */
                if( _SO.data.utmc )
                {
                    delete _SO.data.utmc;
                    saveSO = true;
                }
                
                if( _SO.data.utmk )
                {
                    if( !hasUTMK() ) { _createUMTK(); }
                    
                    _utmk.fromSharedObject( _SO.data.utmk );
                    
                    LOG::P{ _log.i( "utmk = " + _utmk.toString() ); }
                }
                
                //utmx value
                if( !hasUTMX() ) { _createUMTX(); }
                
                if( _SO.data.utmv )
                {
                    if( !hasUTMV() ) { _createUMTV(); }
                    
                    _utmv.fromSharedObject( _SO.data.utmv );
                    
                    LOG::P{ _log.i( "utmv = " + _utmv.toString(true) ); }
                    
                    if( _utmv.isExpired() )
                    {
                        LOG::P{ _log.w( "UTMV has expired" ); }
                        
                        _clearUTMV();
                        saveSO = true;
                    }
                    
                }
                
                if( _SO.data.utmz )
                {
                    if( !hasUTMZ() ) { _createUMTZ(); }
                    
                    _utmz.fromSharedObject( _SO.data.utmz );
                    
                    LOG::P{ _log.i( "utmz = " + _utmz.toString(true) ); }
                    
                    if( _utmz.isExpired() )
                    {
                        LOG::P{ _log.w( "UTMZ has expired" ); }
                        
                        _clearUTMZ();
                        saveSO = true;
                    }
                    
                }
                
                if( saveSO ) { save(); }
            }
        }
        
        /**
         * Indicates the utma value of the buffer.
         */
        public function get utma():UTMA
        {
            LOG::P{ _log.v( "get utma()" ); }
            
            if( !hasUTMA() ) { _createUMTA(); }
            return _utma;
        }
        
        /**
         * Indicates the utmb value of the buffer.
         */         
        public function get utmb():UTMB
        {
            LOG::P{ _log.v( "get utmb()" ); }
            
            if( !hasUTMB() ) { _createUMTB(); }
            return _utmb;
        }
        
        /**
         * Indicates the utmc value of the buffer.
         */ 
        public function get utmc():UTMC
        {
            LOG::P{ _log.v( "get utmc()" ); }
            
            if( !hasUTMC() ) { _createUMTC(); }
            return _utmc;
        }
        
        /**
         * Indicates the utmk value of the buffer.
         */             
        public function get utmk():UTMK
        {
            LOG::P{ _log.v( "get utmk()" ); }
            
            if( !hasUTMK() ) { _createUMTK(); }
            return _utmk;
        }
        
         /**
         * Indicates the utmx value of the buffer.
         */             
        public function get utmx():UTMX
        {
            LOG::P{ _log.v( "get utmx()" ); }
            
            if( !hasUTMX() ) { _createUMTX(); }
            return _utmx;
        }
        
        /**
         * Indicates the utmv value of the buffer.
         */        
        public function get utmv():UTMV
        {
            LOG::P{ _log.v( "get utmv()" ); }
            
            if( !hasUTMV() ) { _createUMTV(); }
            return _utmv;
        }
        
        /**
         * Indicates the utmz value of the buffer.
         */
        public function get utmz():UTMZ
        {
            LOG::P{ _log.v( "get utmz()" ); }
            
            if( !hasUTMZ() ) { _createUMTZ(); }
            return _utmz;
        }
        
        /**
         * Indicates if the buffer contains an UTMA value.
         */          
        public function hasUTMA():Boolean
        {
            LOG::P{ _log.v( "hasUTMA()" ); }
            
            if( _utma ) { return true; }
            return false;
        }
        
        /**
         * Indicates if the buffer contains an UTMB value.
         */           
        public function hasUTMB():Boolean
        {
            LOG::P{ _log.v( "hasUTMB()" ); }
            
            if( _utmb ) { return true; }
            return false;
        }
        
        /**
         * Indicates if the buffer contains an UTMC value.
         */         
        public function hasUTMC():Boolean
        {
            LOG::P{ _log.v( "hasUTMC()" ); }
            
            if( _utmc ) { return true; }
            return false;
        }
        
        /**
         * Indicates if the buffer contains an UTMK value.
         */
        public function hasUTMK():Boolean
        {
            LOG::P{ _log.v( "hasUTMK()" ); }
            
            if( _utmk ) { return true; }
            return false;
        }
        
        /**
         * Indicates if the buffer contains an UTMV value.
         */        
        public function hasUTMV():Boolean
        {
            LOG::P{ _log.v( "hasUTMV()" ); }
            
            if( _utmv ) { return true; }
            return false;
        }
        
        /**
         * Indicates if the buffer contains an UTMV value.
         */        
        public function hasUTMX():Boolean
        {
            LOG::P{ _log.v( "hasUTMX()" ); }
            
            if( _utmx ) { return true; }
            return false;
        }
        
        /**
         * Indicates if the buffer contains an UTMZ value.
         */
        public function hasUTMZ():Boolean
        {
            LOG::P{ _log.v( "hasUTMZ()" ); }
            
            if( _utmz ) { return true; }
            return false;
        }
        
        /**
         * Updates a property in the buffer.
         */
        public function update( name:String, value:* ):void
        {
            LOG::P{ _log.v( "update( " + [name,value].join(", ") + " )" ); }
            
            if( isVolatile() )
            {
                _OBJ[name] = value;
            }
            else
            {
                _SO.data[name] = value;
            }
        }
        
        /**
         * This method clears all the fields of the cookie.
         */
        public function clearCookies():void
        {
            LOG::P{ _log.v( "clearCookies()" ); }
            
            utma.reset();
            utmb.reset();
            utmc.reset();
            utmz.reset();
            utmv.reset();
            utmk.reset();
        }
        
        /**
         * This method generates a digest of all the __utm* values.
         */
        public function generateCookiesHash():Number
        {
            LOG::P{ _log.v( "generateCookiesHash()" ); }
            
            var value:String = "";
                value += utma.valueOf();
                value += utmb.valueOf();
                value += utmc.valueOf();
                value += utmx.valueOf(); //"-";				//for utmx param
                value += utmz.valueOf();
                value += utmv.valueOf();
            
            return generateHash( value );
        }
        
        /**
        * Returns the cookie data as a string
        */ 
        public function toLinkerParams():String
        {
            LOG::P{ _log.v( "toLinkerParams()" ); }
            
        	var output:String = "";
        		output += utma.toURLString();
        		output += "&"+ utmb.toURLString();
        		output += "&"+ utmc.toURLString();
        		output += "&"+ utmx.toURLString(); //__utmx=-";
        		output += "&"+ utmz.toURLString();
        		output += "&"+ utmv.toURLString();  
           		output += "&__utmk=" + generateCookiesHash();
        	
        	return output;
        }
   
        /**
        * Returns the cookie data appended to a URL.
        */ 
        public function getLinkerUrl( targetUrl:String = "", useHash:Boolean = false ):String
        {
            LOG::P{ _log.v( "getLinkerUrl( " + [targetUrl,useHash].join(", ") + " )" ); }
            
        	var linkerParams:String = toLinkerParams();
        	var formattedUrl:String = targetUrl;
        	var urlFields:Array = targetUrl.split("#");
        	
        	// if there are linker parameters        	
        	if ( linkerParams )
        	{
       			//Using hash to seperate out linker parameter, and there is no hash in URL, proceed.
       			if ( useHash ) 
       			{
       				if ( 1 >= urlFields.length )
       				{
        				formattedUrl += "#" + linkerParams;
        			}
        			else //hash exists in URL
        			{
        				formattedUrl += "&" + linkerParams; //formatwww.test.com#trail&__utma.....
        			}
      			} 
      			else  // there is no hash in URL
      			{ 
        			if (1 >= urlFields.length) 
        			{
			            // If there are no query string, then use "?".  if there is already a query string, then use "&".
			            if ( targetUrl.indexOf("?") > -1 )
						{
							formattedUrl += "&";
						}
						else
						{
							formattedUrl += "?";
						}

						formattedUrl += linkerParams;    			
        			} 
        			else //hash exists in URL
        			{
			            //If there are no query string, then use "?".  if there is already a query string, then use "&".			            
			            formattedUrl = urlFields[0];
			            
			           	if ( targetUrl.indexOf("?") > -1 )
						{
							formattedUrl += "&";
						}
						else
						{
							formattedUrl += "?";
						}
						
			            formattedUrl += linkerParams + "#" + urlFields[1];
        			}
      			}         			     		
        	} 
            return formattedUrl;	
    	}	        	        	
    
        
        /**
         * Indicates if the buffer is volatile.
         */
        public function isVolatile():Boolean
        {
            LOG::P{ _log.v( "isVolatile()" ); }
            
            return _volatile;
        }
        
        public function isGenuine():Boolean
        {
            LOG::P{ _log.v( "isGenuine()" ); }
            
            if( !hasUTMK() ) { return true;}
            return (utmk.hash == generateCookiesHash() );
        }
        
        /**
         * Updates the UTMA value with the specified timestamp value.
         */
        public function updateUTMA( timestamp:Number ):void
        {
            LOG::P{ _log.v( "updateUTMA( " + timestamp + " )" ); }
            
            // if __utma value is not empty, update
            if( !utma.isEmpty() )
            {
                // update session count
                if( isNaN( utma.sessionCount ) )
                {
                    utma.sessionCount = 1;
                }
                else
                {
                    utma.sessionCount += 1;
                }
                
                // last session time, is current session time (update)
                utma.lastTime = utma.currentTime;
                
                // current session time is now
                utma.currentTime = timestamp;
                
                LOG::P{ _log.i( "utma = " + utma.toString(true) ); }
            }
        }
        
        /**
        * Clear the current utmb and utmc cookies
        * both in the SO and in memory
        */
        public function resetCurrentSession():void
        {
            LOG::P{ _log.v( "resetCurrentSession()" ); }
            
            _clearUTMB();
            _clearUTMC();
            save();
        }
        
        /**
         * Save the buffer.
         */
        public function save():void
        {
            LOG::P{ _log.v( "save()" ); }
            
            //we save only when using SharedObject
            if( !isVolatile() )
            {
                var flushStatus:String = null;
                try
                {
                    flushStatus = _SO.flush();
                }
                catch( e:Error )
                {
                    /* note:
                       Flash Player cannot write the shared object to disk.
                       This error might occur if the user has permanently disallowed local
                       information storage for objects from this domain. 
                    */
                    LOG::P{ _log.e( "Error...Could not write SharedObject to disk" ); }
                }
                
                switch( flushStatus )
                {
                    case SharedObjectFlushStatus.PENDING:
                    {
                        LOG::P{ _log.i( "Requesting permission to save object..." ); }
                        _SO.addEventListener( NetStatusEvent.NET_STATUS, _onFlushStatus );
                        break;
                    }
                    
                    case SharedObjectFlushStatus.FLUSHED:
                    {
                        LOG::P{ _log.i( "Value flushed to disk." ); }
                        break;
                    }
                }
            }
        }
        
    }
}
