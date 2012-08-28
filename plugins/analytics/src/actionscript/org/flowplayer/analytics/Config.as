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
    import org.flowplayer.util.PropertyBinder;

    public class Config {
        private var _debug:Boolean = false;
        private var _mode:String = "AS3";
        private var _accountId:String; // required
        private var _events:Events = new Events();

        // possible values are "video", "audio", "image"
        private var _clipTypes:Array = [ "video", "audio" ];

        [Value]
        public function get mode():String {
            return _mode;
        }

        public function set mode(value:String):void {
            _mode = value;
        }

        [Value]
        public function get accountId():String {
            return _accountId;
        }

        public function set accountId(value:String):void {
            _accountId = value;
        }

        [Value]
        public function get events():Events {
            return _events;
        }

        public function setEvents(value:Object):void {
            _events = Events(new PropertyBinder(_events).copyProperties(value));
        }

        [Value]
        public function get debug():Boolean {
            return _debug;
        }

        public function set debug(value:Boolean):void {
            _debug = value;
        }

        public function get clipTypes():Array {
            return _clipTypes;
        }

        public function set clipTypes(value:Array):void {
            _clipTypes = value;
        }
    }
}