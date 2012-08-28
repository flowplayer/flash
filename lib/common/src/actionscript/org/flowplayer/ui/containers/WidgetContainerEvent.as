/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.ui.containers {
	
	import flash.events.Event;
	
	public class WidgetContainerEvent extends Event {
		
		public static const CONTAINER_READY:String = "CONTAINER_READY";
		public static const CONTAINER_UPDATE:String = "CONTAINER_UPDATE";
		
		private var _container:WidgetContainer;
		
		public function WidgetContainerEvent(type:String, container:WidgetContainer) {
			super(type, false, false);
			_container = container;
		}
		
		public function get container():WidgetContainer {
			return _container;
		}
		
	}
	
}