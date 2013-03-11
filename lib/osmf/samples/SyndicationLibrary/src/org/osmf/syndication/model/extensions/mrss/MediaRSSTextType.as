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
	 * Enumerates all available values for
	 * the text type in a Media RSS feed. The type
	 * specifies the type of text embedded.
	 * 
	 * @see http://video.search.yahoo.com/mrss
	 **/
	public final class MediaRSSTextType
	{
		/**
		 * Type specifying the embedded text is plain text.
		 **/
		public static const PLAIN:String = "plain";
		
		/**
		 * Type specifying the embedded text is html.
		 **/
		public static const HTML:String = "html";
		
		/**
		 * @private
		 * 
		 * A collection of all available types.
		 **/ 
		public static const ALL_TYPES:Vector.<String> = Vector.<String>([PLAIN, HTML]);
	}
}
