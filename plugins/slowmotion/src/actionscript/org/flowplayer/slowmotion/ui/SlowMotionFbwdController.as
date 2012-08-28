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

    import fp.SlowMotionFBwdButton;

    import flash.events.MouseEvent;

    import org.flowplayer.slowmotion.SlowMotionPlugin;

    public class SlowMotionFbwdController extends AbstractSlowMotionController {

        public function SlowMotionFbwdController(provider:SlowMotionPlugin) {
            super(provider);
        }

        override public function get name():String {
			return "fastBackward";
		}

		override public function get groupName():String {
			return "slowmotion";
		}

        override public function get defaults():Object {
			return {
				enabled: false,
				visible: true,
				tooltipEnabled : true,
				tooltipLabel: 'Fast Backward'
			};
		}

        override protected function get faceClass():Class {
			return fp.SlowMotionFBwdButton;
		}

        override protected function onMouseDown(event:MouseEvent):void {
            _provider.onSlowMotionClicked(true, false);
        }
    }
}
