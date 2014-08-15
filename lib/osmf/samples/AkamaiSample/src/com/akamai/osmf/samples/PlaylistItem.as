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
package com.akamai.osmf.samples
{
	import org.osmf.syndication.model.Entry;
	import org.osmf.syndication.model.extensions.FeedExtension;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSExtension;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSThumbnail;
	import org.osmf.syndication.model.rss20.RSSItem;
	
	public class PlaylistItem
	{
		public function PlaylistItem(entry:Entry):void
		{
			_entry = entry;
		}
		
		public function get title():String
		{
			return entry.title.text;	
		}
		
		public function get thumbnail():MediaRSSThumbnail
		{
			return getRSSThumbnail();
		}
		
		public function get entry():Entry
		{
			return _entry;
		}
		
		private function getRSSThumbnail():MediaRSSThumbnail
		{
			var thumbnail:MediaRSSThumbnail;
			
			// Get the RSS item
			var rssItem:RSSItem = entry as RSSItem;
			if (rssItem != null)
			{
				// Check for feed extenstions
				for each (var feedExtension:FeedExtension in rssItem.feedExtensions)
				{
					var mrssExtension:MediaRSSExtension = feedExtension as MediaRSSExtension;
					if (mrssExtension == null)
					{
						continue;
					}
	
					// There could be multiple thumbnails so we'll pick the first one
					var thumbnails:Vector.<MediaRSSThumbnail> = mrssExtension.thumbnails;
					thumbnail = thumbnails[0];
					break;
				}
			}
			return thumbnail;
		}
		
		private var _entry:Entry;
	}
}
