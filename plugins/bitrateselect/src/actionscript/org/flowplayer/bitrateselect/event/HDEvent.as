/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.bitrateselect.event {
    
	import flash.events.Event;
	
	public class HDEvent extends Event {
		
		public static const HD_AVAILABILITY:String 	= "HD_AVAILABILITY";	// dispatched when HD becomes available or not
		public static const HD_SWITCHED:String 		= "HD_SWITCHED"; 		// dispatched when HD stream started or not

		private var _hasHD:Boolean;

		public function HDEvent(type:String, hasHD:Boolean) {
			super(type);
			_hasHD = hasHD;
		}
		
		public function get hasHD():Boolean {
			return _hasHD;
		}
	}
	
}