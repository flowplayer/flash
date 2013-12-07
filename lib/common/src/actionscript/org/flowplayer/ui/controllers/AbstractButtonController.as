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
	import org.flowplayer.ui.buttons.GenericTooltipButton;
	import org.flowplayer.ui.buttons.TooltipButtonConfig;
	import org.flowplayer.ui.buttons.ButtonEvent;

	import flash.display.DisplayObjectContainer;

	

	public class AbstractButtonController extends AbstractWidgetController {
		
		public function AbstractButtonController() {
			super();
		}
		
		override public function init(player:Flowplayer, controlbar:DisplayObjectContainer, defaultConfig:Object):ConfigurableWidget {
			super.init(player, controlbar, defaultConfig);
			addWidgetListeners();
			
			return _widget;
		}
				
		override protected function createWidget():void {
			_widget = new GenericTooltipButton(new faceClass(), _config as TooltipButtonConfig, _player.animationEngine);
            //#443 set accessibility options for button widget

            setAccessible(_widget, (_config as TooltipButtonConfig).tooltipLabel ? (_config as TooltipButtonConfig).tooltipLabel : name);
		}
		
		protected function addWidgetListeners():void {
			_widget.addEventListener(ButtonEvent.CLICK, onButtonClicked);
		}
		
		/* This is what you should override */
		protected function get faceClass():Class {
			throw new Error("You need to override faceClass accessor");
			return null;
		}
		
		protected function onButtonClicked(event:ButtonEvent):void {
			
		}
	}
}

