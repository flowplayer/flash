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
package org.osmf.syndication.loader
{
	import org.osmf.syndication.model.Feed;
	import org.osmf.media.MediaResourceBase;	
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;

	/**
	 * This class contains information about the output of a load operation
	 * performed by a FeedLoader, specifically, the Feed object which is the root
	 * level object in the object model representation of a syndication document.
	 **/
	public class FeedLoadTrait extends LoadTrait
	{
		/**
		 * Constructor.
		 **/
		public function FeedLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
		}
		
		/**
		 * The root level object in the syndication document object model.
		 */
		public function get feed():Feed
		{
			return _feed;
		}
		
		public function set feed(value:Feed):void
		{
			_feed = value;
		}
		
		private var _feed:Feed;
	}
}
