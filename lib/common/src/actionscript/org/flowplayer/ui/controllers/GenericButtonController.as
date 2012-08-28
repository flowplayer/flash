/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.ui.controllers {

	import org.flowplayer.ui.buttons.ButtonEvent;

	public class GenericButtonController extends AbstractButtonController {
		
		private var _name:String;
		private var _face:Class;
		private var _callback:Function;
		private var _defaults:Object;
		private var _groupName:String = groupName;
		
		public function GenericButtonController(name:String, face:Class, defaults:Object = null, callback:Function = null, groupName:String = null) {
			super();
			
			_name 		= name;
			_face 		= face;
			_defaults	= defaults || {
				enabled: true,
				visible: true,
				tooltipEnabled : false,
				tooltipLabel: null
			};
			_callback 	= callback;
			_groupName  = groupName;
		}
		
	
		override protected function addWidgetListeners():void {
			_widget.addEventListener(ButtonEvent.CLICK, _callback != null ? _callback : onButtonClicked);
		}
				
		override public function get name():String {
			return _name;
		}
		
		override protected function get faceClass():Class {
			return _face
		}
		
		override public function get defaults():Object {
			return _defaults;
		}
		
		override public function get groupName():String {
			return _groupName;
		}
	}
}

