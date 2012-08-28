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

    import fp.SlowMotionFFwdButton;
    import flash.events.MouseEvent;

    import org.flowplayer.slowmotion.SlowMotionPlugin;

    public class SlowMotionFfwdController extends AbstractSlowMotionController {

        public function SlowMotionFfwdController(provider:SlowMotionPlugin) {
            super(provider);
        }

        override public function get name():String {
			return "fastForward";
		}

		override public function get groupName():String {
			return "slowmotion";
		}

        override public function get defaults():Object {
			return {
				enabled: false,
				visible: true,
				tooltipEnabled : true,
				tooltipLabel: 'Fast Forward'
			};
		}

        override protected function get faceClass():Class {
			return fp.SlowMotionFFwdButton;
		}

        override protected function onMouseDown(event:MouseEvent):void {
            _provider.onSlowMotionClicked(true, true);
        }
    }
}
