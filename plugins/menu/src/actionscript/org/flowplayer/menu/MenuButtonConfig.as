/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.menu {
    import org.flowplayer.ui.buttons.ButtonConfig;

    public class MenuButtonConfig extends ButtonConfig {
        private static const PLACE_BOTH:String = "both";
        private static const PLACE_DOCK:String = "dock";
        private static const PLACE_CONTROLS:String = "controls";

        private var _place:Object = PLACE_CONTROLS;

        public function MenuButtonConfig() {
            setColor("rgba(140,142,140,1)");
            setOverColor("rgba(140,142,140,1)");
            setFontColor("rgb(255,255,255)");
        }

        public function set place(value:*):void {
            _place = value == true ? PLACE_CONTROLS : value;
        }

		public function get docked():Boolean {
			return _place == PLACE_BOTH || _place == PLACE_DOCK;
		}

		public function get controls():Boolean {
			return _place == PLACE_BOTH || _place == PLACE_CONTROLS;
		}

        public function get dockedOrControls():Boolean {
            return docked || controls;
        }
    }
}
