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
	 * Base class for the top-level VAST ad packages (inline ads and wrapper ads).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTAdPackageBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTAdPackageBase()
		{
			super();
			
			_impressions = new Vector.<VASTUrl>();
			_trackingEvents = new Vector.<VASTTrackingEvent>();
			_extensions = new Vector.<XML>(); 
		}

		/**
		 * Indicates source ad server.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get adSystem():String 
		{
			return _adSystem;
		}
		
		public function set adSystem(value:String):void 
		{
			_adSystem = value;
		}
		
		/**
		 * An optional error URL so the various ad servers can be informed
		 * if the ad did not play for any reason.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get errorURL():String 
		{
			return _errorURL;
		}
		
		public function set errorURL(value:String):void 
		{
			_errorURL = value;
		}
		

		/**
		 * URLs to track impression.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get impressions():Vector.<VASTUrl> 
		{
			return _impressions;
		}

		/**
		 * Adds the given VASTUrl to this ad package as an impression.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addImpression(value:VASTUrl):void 
		{
			_impressions.push(value);
		}

		/**
		 * Tracking events associated with this ad package.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get trackingEvents():Vector.<VASTTrackingEvent> 
		{
			return _trackingEvents;
		}
		
		/**
		 * Returns the VASTTrackingEvent with the given event type, null if no
		 * such tracking event exists.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getTrackingEventByType(eventType:VASTTrackingEventType):VASTTrackingEvent
		{
			for each (var trackingEvent:VASTTrackingEvent in _trackingEvents)
			{
				if (trackingEvent.type == eventType)
				{
					return trackingEvent;
				}
			}
			
			return null;
		}
		
		/**
		 * Extension elements in the VAST document allow for customization or
		 * for ad server specific features (e.g. geo data, unique identifiers).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get extensions():Vector.<XML> 
		{
			return _extensions;
		}
		
		/**
		 * Adds the given VASTTrackingEvent to this ad package.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addTrackingEvent(value:VASTTrackingEvent):void 
		{
			_trackingEvents.push(value);
		}

		/**
		 * Adds the given extension XML to this ad package.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addExtension(value:XML):void 
		{
			_extensions.push(value);
		}
		
		private var _adSystem:String;
		private var _errorURL:String;
		private var _trackingEvents:Vector.<VASTTrackingEvent>;
		private var _extensions:Vector.<XML>;
		private var _impressions:Vector.<VASTUrl>;
	}
}