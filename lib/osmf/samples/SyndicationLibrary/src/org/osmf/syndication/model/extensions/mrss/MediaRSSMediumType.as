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
	 * MediaMediumType enumerates the available medium types
	 * in a Media RSS feed. 
	 * <p>The medium type can be used
	 * in addition to MIME type to simplify decision making
	 * on the reader side and can help to remove ambiguities
	 * between MIME type and object type.</p>
	 **/
	public final class MediaRSSMediumType
	{
		/**
		 * Specifies the medium is an image.
		 **/
		public static const IMAGE:String = "image";
		
		/**
		 * Specifies the medium is audio.
		 **/
		public static const AUDIO:String = "audio";
		
		/**
		 * Specifies the medium is video.
		 **/
		public static const VIDEO:String = "video";
		
		/**
		 * Specifies the medium is a document.
		 **/
		public static const DOCUMENT:String = "document";
		
		/**
		 * Specifies the medium is an executable.
		 **/
		public static const EXECUTABLE:String = "executable";
		
		/**
		 * @private
		 * 
		 * Collection of all types.
		 **/
		public static const ALL_TYPES:Vector.<String> = Vector.<String>([IMAGE, AUDIO, VIDEO, DOCUMENT, EXECUTABLE]);
	}
}
