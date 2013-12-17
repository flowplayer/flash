/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net.metrics
{
	/**
	 * MetricType identifies the various metric types that the Open Source Media
	 * Framework can handle out of the box.  
	 * 
	 * @see org.osmf.net.abr.MetricBase
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */ 
	public final class MetricType
	{
		/**
		 * The type constant for the fragment count metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const FRAGMENT_COUNT:String = "org.osmf.net.metrics.fragmentCount";
		
		/**
		 * The type constant for the bandwidth metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const BANDWIDTH:String = "org.osmf.net.metrics.bandwidth";
		
		/**
		 * The type constant for the available bitrates metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const AVAILABLE_QUALITY_LEVELS:String = "org.osmf.net.metrics.availableQualityLevels";
		
		/**
		 * The type constant for the current status metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const CURRENT_STATUS:String = "org.osmf.net.metrics.currentStatus";
		
		/**
		 * The type constant for the actual bitrate metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const ACTUAL_BITRATE:String = "org.osmf.net.metrics.actualBitrate";
		
		/**
		 * The type constant for the FPS metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const FPS:String = "org.osmf.net.metrics.fps";
		
		/**
		 * The type constant for the Dropped FPS metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const DROPPED_FPS:String = "org.osmf.net.metrics.droppedFPS";
		
		/**
		 * The type constant for the Buffer Occupation metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const BUFFER_OCCUPATION_RATIO:String = "org.osmf.net.metrics.bufferOccupationRatio";
		
		/**
		 * The type constant for the Buffer Length metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const BUFFER_LENGTH:String = "org.osmf.net.metrics.bufferLength";
		
		/**
		 * The type constant for the Buffer Fragments metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const BUFFER_FRAGMENTS:String = "org.osmf.net.metrics.bufferFragments";
		
		/**
		 * The type constant for the Empty Buffer metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const EMPTY_BUFFER:String = "org.osmf.net.metrics.emptyBuffer";
		
		/**
		 * The type constant for the Recent Switch metric.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const RECENT_SWITCH:String = "org.osmf.net.metrics.recentSwitch";
	}
}