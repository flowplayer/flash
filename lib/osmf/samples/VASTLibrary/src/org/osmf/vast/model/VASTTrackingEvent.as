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
	 * This class represents a Tracking element in a VAST document.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTTrackingEvent
	{		
		/**
		 * Constructor.
		 * 
		 * @param type The type of the event to track.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTTrackingEvent(type:VASTTrackingEventType) 
		{
			this.type = type;
			
			_urls = new Vector.<VASTUrl>();
		}
		
		/**
		 * The type of the event to track.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get type():VASTTrackingEventType 
		{
			return _type;
		}
		public function set type(value:VASTTrackingEventType):void 
		{
			_type = value;
		}
		
		/**
		 * URL(s) to track this event during play back. There could be zero or
		 * many for this event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get urls():Vector.<VASTUrl> 
		{
			return _urls;
		}
		
		public function set urls(value:Vector.<VASTUrl>):void 
		{
			_urls = value;
		}
		
		private var _type:VASTTrackingEventType;
		private var _urls:Vector.<VASTUrl>;		
	}
}
