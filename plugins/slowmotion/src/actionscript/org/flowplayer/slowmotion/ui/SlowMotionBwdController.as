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

    import fp.SlowMotionBwdButton;

    import flash.events.MouseEvent;

    import org.flowplayer.slowmotion.SlowMotionPlugin;

    public class SlowMotionBwdController extends AbstractSlowMotionController {

        public function SlowMotionBwdController(provider:SlowMotionPlugin) {
            super(provider);
        }

        override public function get name():String {
			return "slowBackward";
		}

		override public function get groupName():String {
			return "slowmotion";
		}

        override public function get defaults():Object {
			return {
				enabled: false,
				visible: true,
				tooltipEnabled : true,
				tooltipLabel: 'Slow Backward'
			};
		}

        override protected function get faceClass():Class {
			return fp.SlowMotionBwdButton;
		}

        override protected function onMouseDown(event:MouseEvent):void {
            _provider.onSlowMotionClicked(false, false);
        }
    }
}
