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
package org.osmf.net.qos
{
	/**
	 * PlaybackDetails represents a collection of data about the
	 * playback of a specific quality level that took place between 
	 * two ABREvent.QOS_UPDATE events
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class PlaybackDetails
	{
		/**
		 * Constructor.
		 * 
		 * @param index The index of the quality level to which the content is a part
		 * @duration The total time the quality level was played back, in seconds
		 * @param droppedFrames The number of frames dropped during playback
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function PlaybackDetails(index:uint, duration:Number, droppedFrames:Number)
		{
			_index = index;
			_duration = duration;
			_droppedFrames = droppedFrames;
		}
		
		/**
		 * The index of the stream of which this fragment is a part
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get index():uint
		{
			return _index;
		}
		
		/**
		 * The total time the quality level was played back, in seconds
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get duration():Number
		{
			return _duration;
		}
		
		public function set duration(value:Number):void
		{
			_duration = value;
		}
		
		/**
		 * The number of frames dropped during playback
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get droppedFrames():Number
		{
			return _droppedFrames;
		}
		
		public function set droppedFrames(value:Number):void
		{
			_droppedFrames = value;
		}
		
		private var _index:uint;
		private var _duration:Number;
		private var _droppedFrames:Number;
	}
}