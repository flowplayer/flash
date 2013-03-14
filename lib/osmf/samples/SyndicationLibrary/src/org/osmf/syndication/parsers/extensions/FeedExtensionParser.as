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
package org.osmf.syndication.parsers.extensions
{
	import org.osmf.syndication.model.extensions.FeedExtension;
	
	/**
	 * Base class for all feed extension parsers. An
	 * extension parser understands the feed extension
	 * XML tags for a particular syndication feed.
	 **/
	public class FeedExtensionParser
	{
		/**
		 * Override to implement parsing for a particular syndication feed's extension.
		 * <p>
		 * Note the feed extension parser may not want to parse child nodes. For example, a feed
		 * parser such as an RSS parser may typically call this parse method passing in each
		 * item node in the feed and then finally the single channel node in the feed. And therefore
		 * the feed parser does not need to concern itself with iterating over all the items in a channel,
		 * for example.
		 * 
		 * @param xml A single XML node to parse.
		 **/
		public function parse(xml:XML):FeedExtension
		{
			return null;
		}
	}
}
