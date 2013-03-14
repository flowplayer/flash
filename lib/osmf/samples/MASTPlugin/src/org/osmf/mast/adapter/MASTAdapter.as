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
package org.osmf.mast.adapter
{
	import flash.utils.Dictionary;
	
	/**
	 * The purpose of this class is to map the OSMF
	 * properties and events to the MAST properties
	 * and events.
	 */
	public class MASTAdapter
	{
		// Properties
		
		/**
		 * The duration of the current content.
		 */
		public static const DURATION:String = "duration";
		
		/**
		 * The playhead postion of the current content.
		 */		
		public static const POSITION:String = "position";
		
		/**
		 * True if the content is currently rendering in fullscreen mode.
		 */		
		public static const FULLSCREEN:String = "fullScreen";
		
		/**
		 * True if the content is currently playing.
		 */
		public static const IS_PLAYING:String = "isPlaying";
		
		/**
		 * True if the content is currently paused.
		 */	
		public static const IS_PAUSED:String = "isPaused";
		
		/**
		 * The native width of the current content.
		 */
		public static const CONTENT_WIDTH:String = "contentWidth";
		
		/**
		 * The native height of the current content.
		 */
		public static const CONTENT_HEIGHT:String = "contentHeight";
		
		// events
		
		/**
		 * Defined as anytime the play command is issued, even after a pause
		 */		
		public static const ON_PLAY:String = "OnPlay";

		/**
		* The stop command is given
		*/
		public static const ON_STOP:String = "OnStop";

		/**
		* The pause command is given
		*/
		public static const ON_PAUSE:String = "OnPause";

		/**
		* The player was muted
		*/
		public static const ON_MUTE:String = "OnMute";

		/**
		* Volume was changed
		*/
		public static const ON_VOLUME_CHANGE:String = "OnVolumeChange";

		/**
		* The player has stopped naturally, with no new content
		*/
		public static const ON_END:String = "OnEnd";

		/**
		* The player was manually seeked
		*/
		public static const ON_SEEK:String = "OnSeek";

		/**
		* A new item is being started
		*/
		public static const ON_ITEM_START:String = "OnItemStart";
		
		/**
		 * An item has ended
		 */
		public static const ON_ITEM_END:String = "OnItemEnd";
		
		/**
		 * Constructor.
		 */
		public function MASTAdapter()
		{
			_map = new Dictionary();
			
			// Properties
			_map[DURATION] 		= "TimeTrait.duration";
			_map[POSITION] 		= "TimeTrait.currentTime";
			_map[IS_PLAYING]	= "PlayTrait.playState";
			_map[IS_PAUSED]		= "PlayTrait.playState";
			_map[CONTENT_WIDTH]	= "DisplayObjectTrait.mediaWidth";
			_map[CONTENT_HEIGHT]= "DisplayObjectTrait.mediaHeight";

			// Events					
			_map[ON_PLAY]			= "org.osmf.events.PlayEvent.PLAY_STATE_CHANGE";
			_map[ON_STOP]			= "org.osmf.events.PlayEvent.PLAY_STATE_CHANGE";
			_map[ON_PAUSE]			= "org.osmf.events.PlayEvent.PLAY_STATE_CHANGE";
			_map[ON_MUTE]			= "org.osmf.events.AudioEvent.MUTED_CHANGE";
			_map[ON_VOLUME_CHANGE]	= "org.osmf.events.AudioEvent.VOLUME_CHANGE";
			_map[ON_SEEK]			= "org.osmf.events.SeekEvent.SEEKING_CHANGE";
			_map[ON_ITEM_START]		= "org.osmf.events.PlayEvent.PLAY_STATE_CHANGE";
			_map[ON_ITEM_END]		= "org.osmf.events.TimeEvent.DURATION_REACHED";
		}
		
		/**
		 * Given one of the MAST property or event names, 
		 * returns the matching OSMF trait or event respectively.
		 * 
		 * @param conditionName The MAST condition name which maps
		 * to OSMF trait or event name.
		 */
		public function lookup(conditionName:String):String
		{
			return _map[conditionName];
		}
		
		private var _map:Dictionary;
	}
}
