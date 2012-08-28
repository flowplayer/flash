/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.ui.buttons {

    import flash.display.DisplayObject;

    import org.flowplayer.util.GraphicsUtil;

    import org.flowplayer.view.AbstractSprite;

	public class ToggleButton extends ConfigurableWidget {

		protected var _button:ConfigurableWidget;
		protected var _downButton:ConfigurableWidget;
		protected var _isDown:Boolean = true;

		public function ToggleButton(button:ConfigurableWidget, downButton:ConfigurableWidget) {
			_button = button;
			_downButton= downButton;
			
			// will add the onButton
			isDown = false;
		}

		override public function addEventListener(type:String, listener:Function, useCapture:Boolean  = false, priority:int  = 0, useWeakReference:Boolean  = false):void {
			_button.addEventListener(type, listener, useCapture, priority, useWeakReference);
			_downButton.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean  = false):void {
			_button.removeEventListener(type, listener, useCapture);
			_downButton.removeEventListener(type, listener, useCapture);
		}
		
		override public function get name():String {
			return _button.name;
		}

		override protected function onResize():void {
            _button.setSize(_width, _height);
			_downButton.setSize(_width, _height);
        }

		public function get activeButton():ConfigurableWidget {
			return isDown ? _downButton : _button;
		}

		override public function configure(config:Object):void {
			_button.configure((config as ToggleButtonConfig).config);
			_downButton.configure((config as ToggleButtonConfig).downConfig);
		}
		
		override public function set enabled(value:Boolean) :void {
			_button.enabled = value;
			_downButton.enabled = value;
		}
		
		override public function get enabled():Boolean {
			return activeButton.enabled;
		}
		
		public function get isDown():Boolean {
			return _isDown;
		}

		public function set isDown(down:Boolean):void {
			if (isDown == down) return;
			if ( contains(activeButton) ) removeChild(activeButton);
			_isDown = down;
			addChild(activeButton);
		}

        public function setToggledColor(isToggled:Boolean):void {
            log.debug("setToggledColor")
            AbstractButton(_button).setToggledColor(isToggled);
            AbstractButton(_downButton).setToggledColor(isToggled);
        }

	}
}
