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
    
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.ui.buttons.ConfigurableWidget;	
	import org.flowplayer.ui.buttons.TooltipButtonConfig;
	import org.flowplayer.ui.buttons.GenericTooltipButton;
	import org.flowplayer.ui.buttons.ToggleButton;
	import org.flowplayer.ui.buttons.ToggleButtonConfig;

	import flash.display.DisplayObjectContainer;

	public class AbstractToggleButtonController extends AbstractButtonController {
			
		public function AbstractToggleButtonController() {
			super();
		}
		
		override public function init(player:Flowplayer, controlbar:DisplayObjectContainer, defaultConfig:Object):ConfigurableWidget {
			super.init(player, controlbar, defaultConfig);
			setDefaultState();
			
			return _widget;
		}

		override protected function createWidget():void {
			var button:GenericTooltipButton = new GenericTooltipButton( 
												new faceClass(), 
												((_config as ToggleButtonConfig).config as TooltipButtonConfig), 
												_player.animationEngine);

             //#443 set accessibility options for button widget
            setAccessible(button, name);
												
			var downButton:GenericTooltipButton = new GenericTooltipButton(
												new downFaceClass(), 
												((_config as ToggleButtonConfig).downConfig as TooltipButtonConfig), 
												_player.animationEngine);

             //#443 set accessibility options for button widget
            setAccessible(downButton,  downName);
			
			_widget = new ToggleButton(button, downButton);
		}
		
		public function get isDown():Boolean {
			return (_widget as ToggleButton).isDown;
		}
		
		public function set isDown(down:Boolean):void {
			(_widget as ToggleButton).isDown = down;
		}
	
		/* This is what you should override */
		
		public function get downName():String {
			throw new Error("You need to override downName accessor");
			return null;
		}
		
		public function get downDefaults():Object {
			throw new Error("You need to override downDefaults accessor");
			return null;
		}
		
		protected function get downFaceClass():Class {
			throw new Error("You need to override downFaceClass accessor");
			return null;
		}

		protected function setDefaultState():void {
			// do something here ... or not
		}
	}
}

