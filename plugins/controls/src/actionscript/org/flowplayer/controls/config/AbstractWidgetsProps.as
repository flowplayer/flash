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
	import org.flowplayer.ui.controllers.AbstractToggleButtonController;
	
	// This is really a consultation class
	// no setters here
	public dynamic class AbstractWidgetsProps {

		protected var _props:Object;
		protected var _availableWidgets:Array;
		protected var log:Log = new Log(this);
		
		
		public function AbstractWidgetsProps(styleProps:Object, widgets:Array) {
			_props = {};
			for ( var name:String in styleProps )
				_props[name] = styleProps[name];
				
			_availableWidgets = widgets;
		}
	
		protected function addWidgetsDefaults(propName:String):void {
			for ( var i:int = 0; i < _availableWidgets.length; i++ ) {
				var controller:AbstractWidgetController = _availableWidgets[i];
				if ( controller.defaults[propName] != undefined) {
					addProperty(controller.name, controller.defaults[propName])
				}
				
				if ( controller is AbstractToggleButtonController ) {
					if ((controller as AbstractToggleButtonController).downDefaults[propName] != undefined) {
						addProperty((controller as AbstractToggleButtonController).downName, (controller as AbstractToggleButtonController).downDefaults[propName])
					}
				}
			}
		}

		protected function addProperty(name:String, defaultValue:*):void {
			// take value from config or default
			log.debug("adding "+ name + " = " + _props[name] + " || "+ defaultValue);
			
			this[name] = _props[name] == undefined ? defaultValue : _props[name];
		}


		// handy function for visibility and enabled
		protected function handleAll():void {
			
			if ( _props['all'] != undefined ) {
				for ( var i:int = 0; i < _availableWidgets.length; i++ ) {
					if ( _props[_availableWidgets[i]['name']] == undefined ) {
						log.debug("Setting all default to "+ _availableWidgets[i]['name'] + " to "+ _props['all']);
						_props[_availableWidgets[i]['name']] = _props['all'];
					}
					if ( _availableWidgets[i].hasOwnProperty('downName') && _props[_availableWidgets[i]['downName']] == undefined ) {
						log.debug("Setting all default to "+ _availableWidgets[i]['downName'] + " to "+ _props['all']);
						_props[_availableWidgets[i]['downName']] = _props['all'];
					}
				}
			}
			
			
			for ( var j:int = 0; j < _availableWidgets.length; j++ ) {
				if ( _availableWidgets[j]['groupName'] != null && _props[_availableWidgets[j]['groupName']] != undefined ) {
					log.debug("setting " + _availableWidgets[j]['name'] + " to "+ _props[_availableWidgets[j]['groupName']] + " from group "+ _availableWidgets[j]['groupName']);
					_props[_availableWidgets[j]['name']] = _props[_availableWidgets[j]['groupName']];
				}
			}
			
		}		
	}
}
