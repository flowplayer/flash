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
	 * An action to take upon the video being clicked.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTVideoClick
	{	
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function VASTVideoClick()
		{
			super();
			
			_clickTrackings = new Vector.<VASTUrl>();
			_customClicks = new Vector.<VASTUrl>();
		}
		
		/**
		 * URL to open as destination page when a user clicks on the video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get clickThrough():VASTUrl 
		{
			return _clickThrough;
		}
		
		public function set clickThrough(value:VASTUrl):void 
		{
			_clickThrough = value;
		}
				
		/**
		 * A Vector of VASTUrl objects to request for tracking
		 * purposes when a user clicks on the video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get clickTrackings():Vector.<VASTUrl> 
		{
			return _clickTrackings;
		}
		
		public function set clickTrackings(value:Vector.<VASTUrl>):void
		{
			_clickTrackings = value;
		}
		
		/**
		 * A Vector of VASTUrl objects to request on custom
		 * events such as hotspotted video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get customClicks():Vector.<VASTUrl> 
		{
			return _customClicks;
		}
		
		public function set customClicks(value:Vector.<VASTUrl>):void 
		{
			_customClicks = value;
		}
		
		private var _clickThrough:VASTUrl;
		private var _clickTrackings:Vector.<VASTUrl>;
		private var _customClicks:Vector.<VASTUrl>;
	}
}
