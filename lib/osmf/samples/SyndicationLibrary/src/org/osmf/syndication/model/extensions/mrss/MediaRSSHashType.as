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
	 * Enumerates the available hash types
	 * in a Media RSS feed. 
	 **/
	public final class MediaRSSHashType
	{
		/**
		 * Specifies the hash type is md5.
		 **/
		public static const MD5:String = "md5";
		
		/**
		 * Specifies the hash type is sha-1.
		 **/
		public static const SHA_1:String = "sha-1";
		
		/**
		 * @private
		 * 
		 * Collection of all types.
		 **/
		public static const ALL_TYPES:Vector.<String> = Vector.<String>([MD5, SHA_1]);
	}
}
