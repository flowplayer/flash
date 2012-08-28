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
    import org.flowplayer.util.PropertyBinder;

    public class EmailConfig {
        private var _script:String;
        private var _tokenUrl:String;
        private var _token:String;
        private var _required:Array = ["to"];
//        private var _required:Array = ["name","email","to","message","subject"];
        private var _labels:EmailViewLabels = new EmailViewLabels();
        
        public function get script():String {
            return _script;
        }

        public function set script(value:String):void {
            _script = value;
        }

        public function get tokenUrl():String {
            return _tokenUrl;
        }

        public function set tokenUrl(value:String):void {
            _tokenUrl = value;
        }

        public function get token():String {
            return _token;
        }

        public function set token(value:String):void {
            _token = value;
        }

        public function get required():Array {
            return _required;
        }

        public function set required(value:Array):void {
            _required = value;
        }

        public function isRequired(field:String):Boolean {
            return _required.indexOf(field) >= 0;
        }

        public function get labels():EmailViewLabels {
            return _labels;
        }

        public function setLabels(value:Object):void {
            if (! value) return;
            new PropertyBinder(_labels).copyProperties(value);
        }
    }

}