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
package org.osmf.syndication.model
{
	/**
	 * Enumerates all possible values for the text type
	 * attribute in a syndication feed.
	 **/
	public class FeedTextType
	{
		/**
		 * Indicates the element contains plain text 
		 * with no entity escaped html.
		 **/
		public static const TEXT:String = "text";
		
		/**
		 * Indicates the element contains entity
		 * escaped html.
		 **/
		public static const HTML:String = "html";
		
		/**
		 * Indicates the element contains inline xhtml,
		 * wrapped in a div element.
		 **/
		public static const XHTML:String = "xhtml";
		
		/**
		 * @private
		 * 
		 * Collection of all types.
		 **/
		public static const ALL_TYPES:Vector.<String> = Vector.<String>([TEXT, HTML, XHTML]);		
	}
}
