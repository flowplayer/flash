/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Dan Rossi, <electroteque@gmail.com>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.slowmotion.ui {

import flash.events.Event;

import org.flowplayer.ui.controllers.AbstractButtonController;
    import flash.events.MouseEvent;

    import org.flowplayer.slowmotion.SlowMotionPlugin;

    public class AbstractSlowMotionController extends AbstractButtonController {

        protected var _provider:SlowMotionPlugin;

        public function AbstractSlowMotionController(provider:SlowMotionPlugin) {
            super();
            _provider = provider;
        }

        override protected function addWidgetListeners():void {
            _widget.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            _widget.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

        protected function onAddedToStage(event:Event):void
        {
            _widget.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        protected function onMouseDown(event:MouseEvent):void {

        }
    }
}
