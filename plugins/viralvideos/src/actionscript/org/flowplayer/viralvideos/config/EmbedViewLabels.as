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
package org.flowplayer.viralvideos.config {
    public class EmbedViewLabels {
        private var _title:String = "Copy and paste this code to your web page";
        private var _options:String = "Customize size and colors";
        private var _backgroundColor:String = "Background color";
        private var _buttonColor:String = "Button color";
        private var _size:String = "Size (pixels)";
        private var _copy:String = "Copy";

        public function EmbedViewLabels() {
        }

        public function get title():String {
            return _title;
        }

        public function set title(value:String):void {
            _title = value;
        }

        public function get options():String {
            return _options;
        }

        public function set options(value:String):void {
            _options = value;
        }

        public function get backgroundColor():String {
            return _backgroundColor;
        }

        public function set backgroundColor(value:String):void {
            _backgroundColor = value;
        }

        public function get buttonColor():String {
            return _buttonColor;
        }

        public function set buttonColor(value:String):void {
            _buttonColor = value;
        }

        public function get size():String {
            return _size;
        }

        public function set size(value:String):void {
            _size = value;
        }

        public function get copy():String {
            return _copy;
        }

        public function set copy(value:String):void {
            _copy = value;
        }
    }
}