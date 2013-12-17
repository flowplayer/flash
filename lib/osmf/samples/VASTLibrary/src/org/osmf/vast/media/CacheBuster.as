/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vast.media
{
	// DISABLE METADATA ADDITION OF EXTRA CACHEBUSTERS FOR NOW
	//import com.eyewonder.instream.core.UIFConfig;
	import flash.display.Sprite;
	
	/**
	 * Utility class for cache-busting purposes
	 * 
	 * Used to cacheBust urls containing [timestamp] at the end of a URL using most 
	 * common cachebuster macro values for tracking pixels. Only gets applied when
	 * the ad server doesn't cachebust (such as if loaded directly from a CDN)
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	 
	public dynamic class CacheBuster extends Sprite implements ICacheBuster
	{
		
		public var _adCacheBuster:Number;
		public var _videoCacheBuster:Number;
		public var _cacheBuster:Number; // only used internally
	
		// Available CacheBusterTypes
		public static const AD:String 		= "ad";
		public static const VIDEO:String	= "video";
		
		//private var _uifConfig:UIFConfig;
		
		//standard strings
		private var _standardCachebusterList:Array = new Array("\\[timestamp\\]", "\\[cachebuster\\]", "\\[random\\]", "\\[randnum\\]");
		
		public function CacheBuster(/*uifConfig:UIFConfig*/)
		{
			//_uifConfig = uifConfig;
			
			randomizeCacheBuster(AD, true);
			randomizeCacheBuster(VIDEO, true);
		}
		
	/**
	 * Returns a url with a random cacheBusted number on the end.
	 * 
	 * @ param urlToTag url to cache bust 
	 * @ param cacheBusterType type of cache buster i.e. VIDEO
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */			
		public function cacheBustURL(urlToTag:String, cacheBusterType:String = VIDEO):String
		{
			randomizeCacheBuster(cacheBusterType, false);
			return replaceWildcardWithCacheBuster( urlToTag, _cacheBuster );	
		}
		
		// 

		/**
		 * Call once per player video load, before the preroll can be called.
		 * 
		 * @ param refresh create a new random number.
		 * @ param cacheBusterType type of cache buster i.e. VIDEO
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function randomizeCacheBuster(cacheBusterType:String, refresh:Boolean):void // randomize timestamp
		{
			var cb:Number = randomNumber;
				
			switch(cacheBusterType) {
				case AD:
					if(!isNaN(adCacheBuster) && !refresh) {
						cb = adCacheBuster;
					} else {
						_adCacheBuster = cb;
					}
					break;
				
				default:
				//case VIDEO:
					if (!isNaN(videoCacheBuster) && !refresh) {
						cb = videoCacheBuster;
					} else {
						_videoCacheBuster = cb;
					}
					break;
		}	
		
			_cacheBuster = cb;
		}
		
		public function replaceWildcardWithCacheBuster( urlToTag:String, cacheBuster:Number ):String
		{
			var cacheBusterReplaceArray:Array = _standardCachebusterList;
			
			/*
			DISABLED FOR NOW. Allow metadata configuration in future to add other cachebusters
			//add standard and the customizeable cachebusters into the array thats used to find the strings that should be replaced
			cacheBusterReplaceArray = _standardCachebusterList.concat(_uifConfig.cachebusterList);
			*/
			//cacheBusterReplaceArray = _standardCachebusterList.concat(_uifConfig.cachebusterList);
			
			for(var i:uint = 0; i < cacheBusterReplaceArray.length; i++)
			{
				urlToTag = urlToTag.replace(new RegExp(cacheBusterReplaceArray[i],"gi"), cacheBuster);
			}
			
			return urlToTag;
		}
		/**
		 * Returns a cache buster for an Ad
		 * 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get adCacheBuster():Number
		{
			return _adCacheBuster;
		}
		/**
		 * Sets a cache buster for an Ad
		 * 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */				
		public function set adCacheBuster(newNumber:Number):void
		{
			_adCacheBuster = newNumber;
		}
			/**
		 * Returns a cache buster for a Video
		 * 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get videoCacheBuster():Number
		{
			return _videoCacheBuster;
		}
		/**
		 * Sets a cache buster for a Video
		 * 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function set videoCacheBuster(newNumber:Number):void
		{
			_videoCacheBuster = newNumber;
		}
		/**
		 * Returns a random number
		 * 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get randomNumber():Number {
			return Math.round(100000000000 * Math.random());
		}	
		
	
		
	}
	
}
