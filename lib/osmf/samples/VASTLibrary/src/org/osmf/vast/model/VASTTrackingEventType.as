/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*
*  Contributor(s): Eyewonder, LLC
*  
*****************************************************/
package org.osmf.vast.model
{
	/**
	 * Enumeration of possible values for the VAST TrackingEvent element.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTTrackingEventType
	{
		/**
		 * Event constant for the initial playback of media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const START:VASTTrackingEventType 			= new VASTTrackingEventType("start");

		/**
		 * Requested by the player for new creative visible
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const CREATIVE_VIEW:VASTTrackingEventType 		= new VASTTrackingEventType("creativeView");
		/**
		 * Event constant for when the playhead reaches the 25% mark.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const FIRST_QUARTILE:VASTTrackingEventType 	= new VASTTrackingEventType("firstquartile");
		
		/**
		 * Event constant for when the playhead reaches the 50% mark.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const MIDPOINT:VASTTrackingEventType 			= new VASTTrackingEventType("midpoint");

		/**
		 * Event constant for when the playhead reaches the 75% mark.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const THIRD_QUARTILE:VASTTrackingEventType 	= new VASTTrackingEventType("thirdquartile");

		/**
		 * Event constant for when the playhead reaches the 100% mark.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const COMPLETE:VASTTrackingEventType 			= new VASTTrackingEventType("complete");

		/**
		 * Event constant for when the user mutes the media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const MUTE:VASTTrackingEventType 				= new VASTTrackingEventType("mute");

		/**
		 * Event constant for when the user pauses the media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const PAUSE:VASTTrackingEventType 			= new VASTTrackingEventType("pause");

		/**
		 * Event constant for when the user replays the media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const REPLAY:VASTTrackingEventType 			= new VASTTrackingEventType("replay");
		
		/**
		 * Event constant for when an error occurs.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const ERROR:VASTTrackingEventType 			= new VASTTrackingEventType("error");

		/**
		 * Event constant for when the user goes into fullscreen mode.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const FULLSCREEN:VASTTrackingEventType 		= new VASTTrackingEventType("fullscreen");

		/**
		 * Event constant for when the user stops playback of the media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const STOP:VASTTrackingEventType 				= new VASTTrackingEventType("stop");
		/**
		 * Event constant for when the user clicks on an Ad.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const CLICK_THRU:VASTTrackingEventType 		= new VASTTrackingEventType("clickThru");
		
		/**
		 * Event constant for when the player is muted.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const UNMUTE:VASTTrackingEventType 		= new VASTTrackingEventType("unmute");

		/**
		 * Event constant for when the player is closed
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CLOSE:VASTTrackingEventType 				= new VASTTrackingEventType("close");
		/**
		 * Event constant for when the palyer is expanded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const EXPAND:VASTTrackingEventType 		= new VASTTrackingEventType("expand");
		
				/**
		 * Event constant for when the player is collapsed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const COLLAPSE:VASTTrackingEventType 		= new VASTTrackingEventType("collapse");

		/**
		 * Event constant for when the player is resumed
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const RESUME:VASTTrackingEventType 				= new VASTTrackingEventType("resume");
		/**
		 * Event constant for when the palyer is rewind.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const REWIND:VASTTrackingEventType 		= new VASTTrackingEventType("rewind");
		
		
		/**
		 * Event constant for when the user interacts with the ad.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const ACCEPT_INVITATION:VASTTrackingEventType 		= new VASTTrackingEventType("acceptInvitation");

		/**
		 * Event constant for when the user minimize the ad
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const USER_MINIMIZE:VASTTrackingEventType 		= new VASTTrackingEventType("adUserMinimize");
				
		
		/**
		 * Requested for impressions
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const IMPRESSION:VASTTrackingEventType 		= new VASTTrackingEventType("adImpression"); // ? Impression already fired?
		
		/**
		 * @private
		 * 
		 * Constructor.
		 * 
		 * @param name The name of the event.
		 */
		public function VASTTrackingEventType(name:String)
		{
			this.name = name;
		}
		
		/**
		 * Returns the event type constant that matches the given name, null if
		 * there is none.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function fromString(name:String):VASTTrackingEventType
		{
			var lowerCaseName:String = name != null ? name.toLowerCase() : name;
			
			for each (var eventType:VASTTrackingEventType in ALL_EVENT_TYPES)
			{
				if (lowerCaseName == eventType.name)
				{
					return eventType;
				}
			}
			
			return null;
		}
		
		private static const ALL_EVENT_TYPES:Array
			= [ START
			  , FIRST_QUARTILE
			  , MIDPOINT
			  , THIRD_QUARTILE
			  , COMPLETE
			  , MUTE
			  , PAUSE
			  , REPLAY
			  , FULLSCREEN
			  , STOP
			  , CLICK_THRU
			  , UNMUTE
			  , RESUME
			  , REWIND
			  , FULLSCREEN
			  , CLOSE
			  , EXPAND
			  , COLLAPSE
			  
			  
			  ];
		
		private var name:String;
	}
}