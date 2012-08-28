/*
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.ui {

    public class AutoHideConfig {
        private var _enabled:Boolean = true;
        //#605 set fullscreen to disabled by default
        private var _fullscreenOnly:Boolean = false;
        private var _hideDelay:Number = 4000;
        private var _hideDuration:Number = 800;
        private var _hideStyle:String = "move";
		private var _mouseOutDelay:Number = 500;

        public function set state(autoHide:String):void {
            _enabled = (autoHide && autoHide != "never") as Boolean;
            //#605 set to fullscreen if state is not always to work around various issues.
            _fullscreenOnly = (autoHide != "always" ? true : false);
        }

        /**
         * @return 'always' | 'fullscreen' | 'never'
         */
        public function get state():String {
            if (! _enabled) return 'never';
            return _fullscreenOnly ? 'fullscreen' : 'always';
        }

        [Value]
		public function get hideDelay():Number {
			return _hideDelay;
		}

        public function set hideDelay(hideDelay:Number):void {
            _hideDelay = hideDelay;
        }

        public function set delay(hideDelay:Number):void {
            _hideDelay = hideDelay;
        }

        public function set hideDuration(value:Number):void {
            _hideDuration = value;
        }

        public function set duration(value:Number):void {
            _hideDuration = value;
        }

        [Value]
        public function get hideStyle():String {
            return _hideStyle;
        }

        public function set hideStyle(value:String):void {
            _hideStyle = value;
        }


		public function set mouseOutDelay(value:Number):void {
            _mouseOutDelay = value;
        }

		[Value]
        public function get mouseOutDelay():Number {
            return _mouseOutDelay;
        }

        /**
         * Synonym for set hideStyle()
         * @param value
         * @return
         */
        public function setStyle(value:String):void {
            _hideStyle = value;
        }

        [Value]
        public function get hideDuration():Number {
            return _hideDuration;
        }

        [Value]
        public function get enabled():Boolean {
            return _enabled;
        }

        public function set enabled(value:Boolean):void {
            _enabled = value;
            _fullscreenOnly = !value;
        }

        [Value]
        public function get fullscreenOnly():Boolean {
            return _fullscreenOnly;
        }

        public function set fullscreenOnly(value:Boolean):void {
            _fullscreenOnly = value;
        }
    }
}