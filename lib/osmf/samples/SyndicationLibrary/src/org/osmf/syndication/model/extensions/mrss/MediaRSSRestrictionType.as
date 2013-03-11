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
	
	/**
	 * Enumerates all available values
	 * for the restriction tag in a Media RSS feed.
	 * 
	 * @see http://video.search.yahoo.com/mrss
	 **/
	public final class MediaRSSRestrictionType
	{
		/**
		 * Relationship attribute value, 
		 * indicates the media should be allowed.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public static const ALLOW:String = "allow";
		
		/**
		 * Relationship attribute value, 
  		 * indicates the media should be denied.
  		 * 
		 * @see http://video.search.yahoo.com/mrss
  		 **/
		public static const DENY:String = "deny";
		
		/**
		 * Type attribute value, 
		 * indicates the type of restriction.  
		 * Allows restrictions to be placed
		 * based on country code.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public static const COUNTRY:String = "country";
		
		/**
		 * Type attribute value,
		 * indicates the type of restriction.
		 * Allows restrictions based on URI.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public static const URI:String = "uri";

		/**
		 * @private
		 * 
		 * Collection of all types.
		 **/
		public static const ALL_TYPES:Vector.<String> = Vector.<String>([ALLOW, DENY]);
	}
}
