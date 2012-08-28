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
    
	import org.flowplayer.ui.buttons.AbstractButton;
	import flash.display.DisplayObject;
	import org.flowplayer.ui.buttons.ConfigurableWidget;

	import org.flowplayer.util.Arrange;
	
	public class WidgetDecorator extends ConfigurableWidget {
      
        protected var _top:DisplayObject;
        protected var _bottom:DisplayObject;
        protected var _left:DisplayObject;
        protected var _right:DisplayObject;
		protected var _widget:ConfigurableWidget;
		protected var _config:Object;

		protected var _spaceAfterWidget:Number = 0;
		protected var _includeSpacing:Boolean = false;
		
		public function WidgetDecorator(top:DisplayObject, right:DisplayObject, bottom:DisplayObject, left:DisplayObject, includeSpacing:Boolean = false) {	
            _left 	= addFaceIfNotNull(left);
            _right 	= addFaceIfNotNull(right);
            _top 	= addFaceIfNotNull(top);
            _bottom = addFaceIfNotNull(bottom);

			_includeSpacing = includeSpacing;
		}
		
		public function set spaceAfterWidget(value:Number):void {
			_spaceAfterWidget = value;
		}
		
		public function get spaceAfterWidget():Number {
			return _spaceAfterWidget;
		}
		
		public function init(widget:ConfigurableWidget):ConfigurableWidget {
			if ( _widget ) throw new Error("Decorator already initialized");
			
			_widget = addFaceIfNotNull(widget) as ConfigurableWidget;
			return this;
		}
		
		public function get widget():ConfigurableWidget {
			return _widget;
		}
		
		override public function configure(config:Object):void {		
			_config = config;
			_widget.configure(config);
			onResize();
		}
      
        override public function set enabled(value:Boolean):void {
			_widget.enabled = value;
		}

		override public function get enabled():Boolean {
			return _widget.enabled;
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean  = false, priority:int  = 0, useWeakReference:Boolean  = false):void {
			_widget.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean  = false):void {
			_widget.removeEventListener(type, listener, useCapture);
		}
		
		override public function get name():String {
			return _widget.name;
		}

		protected function addFaceIfNotNull(child:DisplayObject):DisplayObject {
            if (! child) return child;
            return addChild(child);
        }
     
        override protected function onResize():void {
			_left.height = _height - _top.height - _bottom.height;
            _left.x = 0;
            _left.y = _top.height;

            _widget.x = _left.width;
            _widget.setSize(_width - _left.width - _right.width - (_includeSpacing ? spaceAfterWidget : 0), height* widgetHeightRatio);
            Arrange.center(_widget, 0, height);

			_right.height = _height - _top.height - _bottom.height;
	        _right.x = _widget.x + _widget.width + spaceAfterWidget;
	        _right.y = _top.height;
			
			_width = _widget.x + _widget.width + spaceAfterWidget + _right.width;

            _bottom.y = _height - _bottom.height;
            _bottom.width = _width;

            _top.y = 0;
            _top.width = _width;
        }

		protected function get widgetHeightRatio():Number {
			return _config['heightRatio'] || 1;
		}
    }
}
