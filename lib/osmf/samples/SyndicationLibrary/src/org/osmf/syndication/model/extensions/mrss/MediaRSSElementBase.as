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
	import __AS3__.vec.Vector;
	
	import org.osmf.syndication.model.extensions.FeedExtension;
	
	/**
	 * A base class for Media RSS XML elements. This class
	 * includes properites representing the optional
	 * elements that may appear as sub-elements of channel,
	 * item, media:content and/or media:group.
	 * 
	 * @see http://video.search.yahoo.com/mrss
	 **/
	public class MediaRSSElementBase extends FeedExtension
	{
		/**
		 * The rating.
		 **/
		public function get rating():MediaRSSRating
		{
			return _rating;
		}
		
		public function set rating(value:MediaRSSRating):void
		{
			_rating = value;
		}
		
		/**
		 * The title of the particualar media object.
		 **/
		public function get title():MediaRSSTitle
		{
			return _title;
		}
		
		public function set title(value:MediaRSSTitle):void
		{
			_title = value;
		}
		
		/**
		 * The description.
		 **/
		public function get description():MediaRSSDescription
		{
			return _description;
		}
		
		public function set description(value:MediaRSSDescription):void
		{
			_description = value;
		}

		/**
		 * Keywords and phrases are comma delimted.
		 **/
		public function get keywords():String
		{
			return _keywords;
		}
		
		public function set keywords(value:String):void
		{
			_keywords = value;
		}
		
		/**
		 * Thumbnails associated with the media object.
		 **/
		public function get thumbnails():Vector.<MediaRSSThumbnail>
		{
			return _thumbnails;
		}
		
		public function set thumbnails(values:Vector.<MediaRSSThumbnail>):void
		{
			_thumbnails = values;
		}

		/**
		 * The category collection associated with the media object.
		 **/
		public function get categories():Vector.<MediaRSSCategory>
		{
			return _categories;
		}
		
		public function set categories(values:Vector.<MediaRSSCategory>):void
		{
			_categories = values;
		}

		/**
		 * The hashes of the binary media file.
		 * 
		 * @see http://video.search.yahoo.com/mrss
 		 **/
		public function get hashes():Vector.<MediaRSSHash>
		{
			return _hashes;
		}
		
		public function set hashes(values:Vector.<MediaRSSHash>):void
		{
			_hashes = values;
		}
		
		/**
		 * Allows the media object to be accessed through a web browser
		 * media player console.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get player():MediaRSSPlayer
		{
			return _player;
		}
		
		public function set player(value:MediaRSSPlayer):void
		{
			_player = value;
		}

		/** 
		 * The MediaCredit collection.
		 **/
		public function get credits():Vector.<MediaRSSCredit>
		{
			return _credits;
		}
		
		public function set credits(values:Vector.<MediaRSSCredit>):void
		{
			_credits = values;
		}

		/**
		 * The copyright information for the media object.
		 **/
		public function get copyright():MediaRSSCopyright
		{
			return _copyright;
		}
		
		public function set copyright(value:MediaRSSCopyright):void
		{
			_copyright = value;
		}

		/** 
		 * The MediaText collection.
		 **/
		public function get texts():Vector.<MediaRSSText>
		{
			return _mediaTexts;
		}
		
		public function set texts(values:Vector.<MediaRSSText>):void
		{
			_mediaTexts = values;
		}
		
		/**
		 * Allows restrictions to be placed on the aggregator
		 * rendering the media in the feed.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get restrictions():Vector.<MediaRSSRestriction>
		{
			return _restrictions;
		}
		
		public function set restrictions(values:Vector.<MediaRSSRestriction>):void
		{
			_restrictions = values;
		}

		/**
		 * Community related content.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get community():MediaRSSCommunity
		{
			return _community;
		}
		
		public function set community(value:MediaRSSCommunity):void
		{
			_community = value;
		}
		
		/**
		 * Comments the media object has received.
		 **/
		public function get comments():Vector.<String>
		{
			return _comments;
		}
		
		public function set comments(values:Vector.<String>):void
		{
			_comments = values;
		}
		
		/**
		 * The media object embed element.
		 **/
		public function get embed():MediaRSSEmbed
		{
			return _embed;
		}
		
		public function set embed(value:MediaRSSEmbed):void
		{
			_embed = value;
		}
		
		/**
		 * Responses a media object has received.
		 **/
		public function get responses():Vector.<String>
		{
			return _responses;
		}
		
		public function set responses(values:Vector.<String>):void
		{
			_responses = values;
		}
		
		/**
		 * Inclusion of all the URLs pointing to a media object.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get backLinks():Vector.<String>
		{
			return _backLinks
		}
		
		public function set backLinks(values:Vector.<String>):void
		{
			_backLinks = values;
		}
		
		/**
		 * Specifies the status of a media object.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get status():MediaRSSStatus
		{
			return _status
		}
		
		public function set status(value:MediaRSSStatus):void
		{
			_status = value;
		}
		
		/**
		 * Pricing information for a media object.
		 *
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get prices():Vector.<MediaRSSPrice>
		{
			return _prices;
		}
		
		public function set prices(values:Vector.<MediaRSSPrice>):void
		{
			_prices = values;
		}
		
		/**
		 * License information for a media object.
		 *
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get license():MediaRSSLicense
		{
			return _license;
		}
		
		public function set license(value:MediaRSSLicense):void
		{
			_license = value;
		}
		
		/**
		 * Subtitles for the media element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get subtitles():Vector.<MediaRSSSubtitle>
		{
			return _subtitles;
		}
		
		public function set subtitles(value:Vector.<MediaRSSSubtitle>):void
		{
			_subtitles = value;
		}
		
		/**
		 * P2P link for the media element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get peerLink():MediaRSSPeerLink
		{
			return _peerLink;
		}
		
		public function set peerLink(value:MediaRSSPeerLink):void
		{
			_peerLink = value;
		}
		
		/**
		 * Rights information of a media object.
		 *
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get rights():Vector.<String>
		{
			return _rights;
		}
		
		public function set rights(values:Vector.<String>):void
		{
			_rights = values;
		}
		
		/**
		 * Scenes within a media object.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get scenes():Vector.<MediaRSSScene>
		{
			return _scenes;
		}
		
		public function set scenes(values:Vector.<MediaRSSScene>):void
		{
			_scenes = values;
		}
		
		private var _rating:MediaRSSRating;
		private var _title:MediaRSSTitle;
		private var _description:MediaRSSDescription;
		private var _keywords:String;
		private var _thumbnails:Vector.<MediaRSSThumbnail>;
		private var _categories:Vector.<MediaRSSCategory>;
		private var _hashes:Vector.<MediaRSSHash>;
		private var _player:MediaRSSPlayer;
		private var _credits:Vector.<MediaRSSCredit>;
		private var _copyright:MediaRSSCopyright;
		private var _mediaTexts:Vector.<MediaRSSText>;
		private var _restrictions:Vector.<MediaRSSRestriction>;
		private var _community:MediaRSSCommunity;
		private var _comments:Vector.<String>;
		private var _embed:MediaRSSEmbed;
		private var _responses:Vector.<String>;
		private var _backLinks:Vector.<String>;
		private var _status:MediaRSSStatus;
		private var _prices:Vector.<MediaRSSPrice>;
		private var _license:MediaRSSLicense;
		private var _subtitles:Vector.<MediaRSSSubtitle>;
		private var _peerLink:MediaRSSPeerLink;
		private var _rights:Vector.<String>;
		private var _scenes:Vector.<MediaRSSScene>;
	}
}
