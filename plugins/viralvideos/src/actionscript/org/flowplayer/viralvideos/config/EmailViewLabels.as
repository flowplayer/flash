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
    public class EmailViewLabels {
        private var _title:String = "Email this video";
        private var _to:String = "Type in an email address";
        private var _toSmall:String = "(multiple addresses with commas)";
        private var _message:String = "Personal message";
        private var _optional:String = "(optional)";
        private var _subject:String = "Video you might be interested in";
        private var _template:String = "{0}\n\nVideo Link: <a href=\"{1}\">{1}</a>\n\n{2}";
        private var _from:String = "Your name";
        private var _fromAddress:String = "Your email address";
        private var _send:String = "Send email";
        private var _success:String = "Email sent";
        private var _required:String = "Please fill required fields!";
        private var _sending:String = "Sending email ..";


        public function get title():String {
            return _title;
        }

        public function set title(value:String):void {
            _title = value;
        }

        public function get to():String {
            return _to;
        }

        public function set to(value:String):void {
            _to = value;
        }

        public function get toSmall():String {
            return _toSmall;
        }

        public function set toSmall(value:String):void {
            _toSmall = value;
        }

        public function get message():String {
            return _message;
        }

        public function set message(value:String):void {
            _message = value;
        }

        public function get optional():String {
            return _optional;
        }

        public function set optional(value:String):void {
            _optional = value;
        }

        public function get subject():String {
            return _subject;
        }

        public function set subject(value:String):void {
            _subject = value;
        }

        public function get template():String {
            return _template;
        }

        public function set template(value:String):void {
            _template = value;
        }

        public function get from():String {
            return _from;
        }

        public function set from(value:String):void {
            _from = value;
        }

        public function get fromAddress():String {
            return _fromAddress;
        }

        public function set fromAddress(value:String):void {
            _fromAddress = value;
        }

        public function get send():String {
            return _send;
        }

        public function set send(value:String):void {
            _send = value;
        }

        public function get success():String {
            return _success;
        }

        public function set success(value:String):void {
            _success = value;
        }

        public function get required():String {
            return _required;
        }

        public function set required(value:String):void {
            _required = value;
        }

        public function get sending():String {
            return _sending;
        }

        public function set sending(value:String):void {
            _sending = value;
        }
    }
}