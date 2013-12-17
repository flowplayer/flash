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
	 * This class represents the Media RSS extensions.
	 **/
	public class MediaRSSExtension extends MediaRSSElementBase
	{
		public function MediaRSSExtension()
		{
			super();
		}

		/** 
		 * The MediaGroup collection. 
		 **/
		public function get groups():Vector.<MediaRSSGroup>
		{
			return _groups;
		}
		
		public function set groups(value:Vector.<MediaRSSGroup>):void
		{
			_groups = value;
		}
				
		/**
		 * The contents collection.
		 **/
		public function get content():MediaRSSContent
		{
			return _content;
		}
		
		public function set content(value:MediaRSSContent):void
		{
			_content = value;
		}
		
		private var _groups:Vector.<MediaRSSGroup>;
		private var _content:MediaRSSContent;
	}
}
