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
	 * MediaExpressionType enumerates all available values
	 * for the expression tag in a Media RSS feed.
	 * <p>
	 * The expression tag determines if the object is a 
	 * sample or the full version of the object, or even 
	 * if it is a continuous stream (sample | full | nonstop). 
	 **/
	public final class MediaRSSExpressionType
	{
		/**
		 * Indicates the object is a sample and not the 
		 * full version of the object.
		 **/
		public static const SAMPLE:String = "sample";
		
		/**
		 * Indicates the object is the full version.
		 **/
		public static const FULL:String = "full";
		
		/**
		 * Indicates the object is a continuous stream.
		 **/
		public static const NONSTOP:String = "nonstop";
		
		/**
		 * @private
		 * 
		 * Collection of all types.
		 **/
		public static const ALL_TYPES:Vector.<String> = Vector.<String>([SAMPLE, FULL, NONSTOP]);
	}
}
