/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */


package org.flowplayer.controls.config {
	import org.flowplayer.util.ObjectConverter;	
	import org.flowplayer.util.Log;	
	
	import org.flowplayer.controls.Controlbar;
	import org.flowplayer.ui.controllers.AbstractWidgetController;
	import org.flowplayer.ui.controllers.AbstractButtonController;
	
	/**
	 * @author api
	 */
	
	// This is really a consultation class
	// no setters here
	public dynamic class WidgetsEnabledStates extends AbstractWidgetsProps {

		public function WidgetsEnabledStates(styleProps:Object, widgets:Array) {
			super(styleProps, widgets);
			
			handleAll();		
			addWidgetsDefaults('enabled');
		}		
	}
}

