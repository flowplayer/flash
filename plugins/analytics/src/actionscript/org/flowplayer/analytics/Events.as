/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.analytics {

    public class Events {
        private var _start:String = "Start";
        private var _stop:String = "Stop";
        private var _finish:String = "Stop";
        private var _unload:String = "Stop";

        private var _pause:String = "Pause";
        private var _resume:String = "Resume";
        private var _seek:String = "Seek";
        private var _mute:String = "Mute";
        private var _unmute:String = "Unmute";
        private var _fullscreen:String = "Full Screen";
        private var _fullscreenExit:String = "Full Screen Exit";

        private var _all:Boolean = false;

        [Value]
        public function get start():String {
            return _start;
        }

        public function setStart(value:Object):void {
            _start = decodeValue(value);
        }

        private function decodeValue(value:Object):String {
            if (value is String && value == "false") {
                return null;
            }
            if (value is Boolean && ! Boolean(value)) {
                return null;
            }
            return value as String;
        }

        [Value]
        public function get stop():String {
            return _stop;
        }

        public function setStop(value:Object):void {
            _stop = decodeValue(value);
        }

        [Value]
        public function get finish():String {
            return _finish;
        }

        public function setFinish(value:Object):void {
            _finish = decodeValue(value);
        }

        [Value]
        public function get pause():String {
            return _pause;
        }

        [Value]
        public function get trackPause():Boolean {
            return _all && _pause != null;
        }

        public function setPause(value:Object):void {
            _pause = decodeValue(value);
        }

        [Value]
        public function get resume():String {
            return _resume;
        }

        [Value]
        public function get trackResume():Boolean {
            return _all && _resume != null;
        }

        public function setResume(value:Object):void {
            _resume = decodeValue(value);
        }

        [Value]
        public function get seek():String {
            return _seek;
        }

        [Value]
        public function get trackSeek():Boolean {
            return _all && _seek != null;
        }

        public function setSeek(value:Object):void {
            _seek = decodeValue(value);
        }

        [Value]
        public function get mute():String {
            return _mute;
        }

        [Value]
        public function get trackMute():Boolean {
            return _all && _mute != null;
        }

        public function setMute(value:Object):void {
            _mute = decodeValue(value);
        }

        [Value]
        public function get unmute():String {
            return _unmute;
        }

        [Value]
        public function get trackUnmute():Boolean {
            return _all && _unmute != null;
        }

        public function setUnmute(value:Object):void {
            _unmute = decodeValue(value);
        }

        [Value]
        public function get fullscreen():String {
            return _fullscreen;
        }

        [Value]
        public function get trackFullscreen():Boolean {
            return _all && _fullscreen != null;
        }

        public function setFullscreen(value:Object):void {
            _fullscreen = decodeValue(value);
        }

        [Value]
        public function get fullscreenExit():String {
            return _fullscreenExit;
        }

        [Value]
        public function get trackFullscreenExit():Boolean {
            return _all && _fullscreenExit != null;
        }

        public function setFullscreenExit(value:Object):void {
            _fullscreenExit = decodeValue(value);
        }

        [Value]
        public function get all():Boolean {
            return _all;
        }

        public function set all(value:Boolean):void {
            _all = value;
        }

        public function get unload():String {
            return _unload;
        }

        public function set unload(value:String):void {
            _unload = value;
        }
    }

}