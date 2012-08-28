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
    import flash.events.Event;

    public class DropdownMenuEvent extends Event {
        public static const CHANGE:String = "change";
        private var _caption:String;
        private var _value:String;

        public function DropdownMenuEvent(type:String, caption:String, value:String):void {
            super(type);
            _caption = caption;
            _value = value;
        }

        public function get caption():String {
            return _caption;
        }

        public function get value():String {
            return _value;
        }

    }
}