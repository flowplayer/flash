/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 *Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.ui.buttons {
	import flash.events.Event;	
	
	/**
	 * @author anssi
	 */
	public class ButtonEvent extends Event {

		public static const CLICK:String = "flowclick";

		public function ButtonEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = true) {
			super(type, bubbles, cancelable);
		}

		public override function clone():Event {
			return new ButtonEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("ButtonEvent", "type");
		}
	}
}
