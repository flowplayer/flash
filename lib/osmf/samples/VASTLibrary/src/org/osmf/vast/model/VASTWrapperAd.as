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
*  Contributor(s): Adobe Systems Inc.
* 
*****************************************************/
package org.osmf.vast.model
{
	import __AS3__.vec.Vector;
	
	/**
	 * This class represents a Wrapper Ad which is another 
	 * VAST document that points to another VAST document from
	 * a different server.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTWrapperAd extends VASTAdPackageBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTWrapperAd()
		{
			super();
			
			_companionImpressions = new Vector.<VASTUrl>();
			_nonLinearImpressions = new Vector.<VASTUrl>();
		}
		
		/**
		 * The ad tag URL.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get vastAdTagURL():String 
		{
			return _vastAdTagURL;
		}
		
		public function set vastAdTagURL(value:String):void 
		{
			 _vastAdTagURL = value;
		}
		
		/**
		 * The actions to take upon the video being clicked.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get videoClick():VASTVideoClick
		{
			return _videoClick;
		}

		public function set videoClick(value:VASTVideoClick):void 
		{
			_videoClick = value;
		}

		/**
		 * URLs to track Companion impressions if desired by Secondary Ad Server
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get companionImpressions():Vector.<VASTUrl>
		{
			return _companionImpressions;
		}

		public function set companionImpressions(value:Vector.<VASTUrl>):void 
		{
			_companionImpressions = value;
		}

		/**
		 * URL of ad tag of Companion ad, if served or tracked separately
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get companionAdTag():VASTUrl
		{
			return _companionAdTag;
		}

		public function set companionAdTag(value:VASTUrl):void 
		{
			_companionAdTag = value;
		}

		/**
		 * URLs to track NonLinear impressions if desired by Secondary Ad Server
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get nonLinearImpressions():Vector.<VASTUrl>
		{
			return _nonLinearImpressions;
		}

		public function set nonLinearImpressions(value:Vector.<VASTUrl>):void 
		{
			_nonLinearImpressions = value;
		}

		/**
		 * URL of ad tag of NonLinear ad, if served or tracked separately
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get nonLinearAdTag():VASTUrl
		{
			return _nonLinearAdTag;
		}

		public function set nonLinearAdTag(value:VASTUrl):void 
		{
			_nonLinearAdTag = value;
		}
		
		private var _vastAdTagURL:String;
		private var _videoClick:VASTVideoClick;
		private var _companionImpressions:Vector.<VASTUrl>;
		private var _companionAdTag:VASTUrl;
		private var _nonLinearImpressions:Vector.<VASTUrl>;
		private var _nonLinearAdTag:VASTUrl;
	}
}
