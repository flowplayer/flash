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
package org.flowplayer.bitrateselect.config {
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.util.PropertyBinder;

    public class HDButtonConfig {
        public static const HD_BUTTON_BOTH:String = "both";
        public static const HD_BUTTON_DOCK:String = "dock";
        public static const HD_BUTTON_CONTROLS:String = "controls";

        private var _place:String = "both";
        private var _onLabel:String = "IS ON";
        private var _offLabel:String = "IS OFF";
        private var _splash:DisplayProperties;

        public function HDButtonConfig() {
            _splash = new DisplayPropertiesImpl(null, "hdbutton");
            _splash.width = "50%";
            _splash.height = "50%";
        }

        public function set place(value:*):void {
            _place = value == true ? HD_BUTTON_CONTROLS : value;
        }

		public function get docked():Boolean {
			return _place == HD_BUTTON_BOTH || _place == HD_BUTTON_DOCK;
		}

		public function get controls():Boolean {
			return _place == HD_BUTTON_BOTH || _place == HD_BUTTON_CONTROLS;
		}

        public function get onLabel():String {
            return _onLabel;
        }

        public function set onLabel(value:String):void {
            _onLabel = value;
        }

        public function get offLabel():String {
            return _offLabel;
        }

        public function set offLabel(value:String):void {
            _offLabel = value;
        }

        public function get splash():DisplayProperties {
            return _splash;
        }

        public function setSplash(value:Object):void {
            if (value is Boolean && ! value) {
                // disables splash
                _splash = null;
                return;
            }

            //#388 specify splash labels here as they are not specific to display properties so don't get set.
            if (value.onLabel) this.onLabel = value.onLabel;
            if (value.offLabel) this.offLabel = value.offLabel;

            new PropertyBinder(_splash).copyProperties(value);
        }
    }
}
