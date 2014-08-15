/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.syndication.model.extensions.mrss
{
	/**
	 * Represents a media:community element in
	 * a Media RSS feed.
	 **/
	public class MediaRSSCommunity
	{
		/**
		 * The average attribute of the media:starRating
		 * element.
		 **/
		public function get starRatingAverage():Number
		{
			return _starRatingAvg;
		}
		
		public function set starRatingAverage(value:Number):void
		{
			_starRatingAvg = value;
		}
		
		/**
		 * The count attribute of the media:starRating
		 * element.
		 **/
		public function get starRatingCount():int
		{
			return _starRatingCount;
		}
		
		public function set starRatingCount(value:int):void
		{
			_starRatingCount = value;
		}
		
		/**
		 * The min attribute of the media:starRating
		 * element.
		 **/
		public function get starRatingMin():int
		{
			return _starRatingMin;
		}
		
		public function set starRatingMin(value:int):void
		{
			_starRatingMin = value;
		}
		
		/**
		 * The max attribute of the media:starRating
		 * element.
		 **/
		public function get starRatingMax():int
		{
			return _starRatingMax;
		}
		
		public function set starRatingMax(value:int):void
		{
			_starRatingMax = value;
		}
		
		/**
		 * The views attribute of the media:statistics
		 * element.
		 **/
		public function get statisticsViews():int
		{
			return _statViews;
		}
		
		public function set statisticsViews(value:int):void
		{
			_statViews = value;
		}
		
		/**
		 * The favorites attribute of the media:statistics
		 * element.
		 **/
		public function get statisticsFavorites():int
		{
			return _statFavorites;
		}
		
		public function set statisticsFavorites(value:int):void
		{
			_statFavorites = value;
		}
		
		/**
		 * The media:tag element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get tags():String
		{
			return _tags;
		}
		
		public function set tags(value:String):void
		{
			_tags = value;
		}
		
		private var _starRatingAvg:Number;
		private var _starRatingCount:int;
		private var _starRatingMin:int;
		private var _starRatingMax:int;
		private var _statViews:int;
		private var _statFavorites:int;
		private var _tags:String;
	}
}
