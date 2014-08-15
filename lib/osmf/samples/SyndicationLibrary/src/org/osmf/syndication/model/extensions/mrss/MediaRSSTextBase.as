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
	import org.osmf.syndication.model.extensions.mrss.MediaRSSTextType;
	
	/**
	 * A base class for text elements in a Media RSS feed.
	 **/
	public class MediaRSSTextBase
	{
		/**
		 * Constructor. Sets the default value according
		 * to the Media RSS Spec.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function MediaRSSTextBase()
		{
			_type = MediaRSSTextType.PLAIN;
		}
		
		/**
		 * The type of text embedded for the element. Should be 
		 * one of the values in MediaTextType.
		 * 
		 * @see MediaTextType
		 **/
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}
		
		/**
		 * The text of the element.
		 **/
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			_text = value;
		}
		
		private var _type:String;
		private var _text:String;
	}
}
