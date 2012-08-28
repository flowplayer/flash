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
  
	public class ButtonDecorator extends WidgetDecorator {
      
     
		// same as Decorated widget except that it keeps aspect ratio of face
		public function ButtonDecorator(top:DisplayObject, right:DisplayObject, bottom:DisplayObject, left:DisplayObject ) {
			super(top, right, bottom, left )
		}
		
        override protected function onResize():void {

            // We scale width according to the current height! The aspect ratio of the face is always preserved.

            _widget.x = _left.width;
            _widget.y = _top.height;

			var h:Number = height - _top.height - _bottom.height;
			var w:Number = h / _widget.height * _widget.width;
			
			_widget.setSize(w, h);

            _left.x = 0;
            _left.y = _top.height;
            _left.height = height - _top.height - _bottom.height;

            _top.x = 0;
            _top.y = 0;
            _top.width = _widget.width + _left.width + _right.width + spaceAfterWidget;

            _right.x = _left.width + _widget.width + spaceAfterWidget;
            _right.y = _top.height;
            _right.height = height - _top.height - _bottom.height;

            _bottom.x = 0;
            _bottom.y = height - _bottom.height;
            _bottom.width = _widget.width + _left.width + _right.width + spaceAfterWidget;

            _height = _top.height + _widget.height + _bottom.height;
            _width = _left.width + _widget.width + _right.width + spaceAfterWidget; 
        }

    }
}
