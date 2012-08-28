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
	
	import org.flowplayer.ui.controllers.AbstractWidgetController;
	
	public interface WidgetContainer {

		function addWidget(	controller:AbstractWidgetController, after:String = null, 
									animated:Boolean = true, decorated:Boolean = true):void;
		
		// there will be a special API enlargment process
	}
	
}