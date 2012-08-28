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
package org.flowplayer.sharing {
    import flash.net.URLRequest;

    import flash.net.navigateToURL;

    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    public class Email extends AbstractCommand {

        private var _subject:String = "Video you might be interested in";
        private var _message:String = "";
        private var _template:String = "{0} \n\n Video Link: <a href=\"{1}\">{2}</a>";


        public function Email(player:Flowplayer) {
            super(player);
        }

        override protected function process():void {
            var request:URLRequest = new URLRequest(formatString("mailto:{0}?subject={1}&body={2}", "", encodeURI(_subject), encodeURI(formatString(_template, _message, pageUrl, pageUrl))));            
            navigateToURL(request, "_self");
        }

        public function set subject(value:String):void {
            _subject = value;
        }

        public function set message(value:String):void {
            _message = value;
        }

        public function set template(value:String):void {
            _template = value;
        }

        [Value]
        public function get subject():String
        {
            return _subject;
        }

        [Value]
        public function get message():String
        {
            return _message;
        }

        [Value]
        public function get template():String
        {
            return _template;
        }
    }
}