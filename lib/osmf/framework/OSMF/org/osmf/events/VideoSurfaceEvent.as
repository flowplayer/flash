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
*****************************************************/
package org.osmf.events
{
	import flash.events.Event;
	
	[ExcludeClass]
	/**
	 * @private
	 * 
	 * A VideoSurfaceEvent should be dispatched when the renderer of a VideoSurface instance changes.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class VideoSurfaceEvent extends Event
	{		
		public static const RENDER_CHANGE:String = "renderSwitch";
		
		/**
		 * Constructor.
		 * 
		 * @param type Event type
		 * @param bubbles Specifies whether the event can bubble up the display
 		 * list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the
 		 * event can be prevented. 
		 * @param usesStageVideo Specifies whether the VideoSurface uses a StageVideo 
		 * instance for rendering or not.
		 *  
 		 *  @langversion 3.0
 		 *  @playerversion Flash 10
 		 *  @playerversion AIR 1.5
 		 *  @productversion OSMF 2.0
 		 */
		public function VideoSurfaceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, usesStageVideo:Boolean=false)
		{
			super(type, bubbles, cancelable);

			_usesStageVideo = usesStageVideo;
		}
		
		/**
		 * Specifies whether the VideoSurface that triggered the event uses a StageVideo 
		 * instance for rendering or not.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 2.0
		 */
		public function get usesStageVideo():Boolean
		{
			return _usesStageVideo;
		}

		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new VideoSurfaceEvent(type, bubbles, cancelable, _usesStageVideo);
		}
		
		private var _usesStageVideo:Boolean;
	}
}