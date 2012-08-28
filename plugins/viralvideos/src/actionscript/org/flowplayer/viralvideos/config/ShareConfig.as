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
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;

    public class ShareConfig {
        private var _description:String = "A cool video";
		private var _body:String = "";
        private var _category:String = "";

        private var _facebook:Boolean = true;
        private var _twitter:Boolean = true;
        private var _myspace:Boolean = true;
        private var _livespaces:Boolean = true;
        private var _digg:Boolean = true;
        private var _orkut:Boolean = true;
        private var _stumbleupon:Boolean = true;
        private var _bebo:Boolean = true;
        private var _icons:ButtonConfig;
        private var _shareWindow:String = "_popup";
        private var _labels:ShareViewLabels = new ShareViewLabels();

        private var _popupDimensions:Object = {
            facebook: [620,440],
            myspace: [1024,650],
            twitter: [1024,650],
            bebo: [626,436],
            orkut: [1024,650],
            digg: [1024,650],
            stumbleupon: [1024,650],
            livespaces: [1024,650]
        };

        public function get icons():ButtonConfig {
            if (! _icons) {
                _icons = new ButtonConfig();
                _icons.setColor("rgba(20,20,20,0.5)");
                _icons.setOverColor("rgba(0,0,0,1)");
            }
            return _icons;
        }

        public function setIcons(config:Object):void {
            new PropertyBinder(icons).copyProperties(config);
        }

        public function get title():String {
            return _labels.title;
        }

        public function set title(value:String):void {
            _labels.title = value;
        }

        public function get popupDimensions():Object {
            return _popupDimensions;
        }

        public function set popupDimensions(value:Object):void {
            _popupDimensions = value;
        }

        public function get body():String {
            return _body;
        }

        public function set body(value:String):void {
            _body = value;
        }

        public function get category():String {
            return _category;
        }

        public function set category(value:String):void {
            _category = value;
        }

        public function get facebook():Boolean {
            return _facebook;
        }

        public function set facebook(value:Boolean):void {
            _facebook = value;
        }

        public function get twitter():Boolean {
            return _twitter;
        }

        public function set twitter(value:Boolean):void {
            _twitter = value;
        }

        public function get myspace():Boolean {
            return _myspace;
        }

        public function set myspace(value:Boolean):void {
            _myspace = value;
        }

        public function get livespaces():Boolean {
            return _livespaces;
        }

        public function set livespaces(value:Boolean):void {
            _livespaces = value;
        }

        public function get digg():Boolean {
            return _digg;
        }

        public function set digg(value:Boolean):void {
            _digg = value;
        }

        public function get orkut():Boolean {
            return _orkut;
        }

        public function set orkut(value:Boolean):void {
            _orkut = value;
        }

        public function get stumbleupon():Boolean {
            return _stumbleupon;
        }

        public function set stumbleupon(value:Boolean):void {
            _stumbleupon = value;
        }

        public function get bebo():Boolean {
            return _bebo;
        }

        public function set bebo(value:Boolean):void {
            _bebo = value;
        }

        public function get description():String {
            return _description;
        }

        public function set description(value:String):void {
            _description = value;
        }

        public function get shareWindow():String
        {
            return _shareWindow;
        }

        public function set shareWindow(value:String):void
        {
            _shareWindow = value;
        }

        public function get labels():ShareViewLabels {
            return _labels;
        }

        public function setLabels(value:Object):void {
            if (! value) return;
            new PropertyBinder(_labels).copyProperties(value);
        }
    }

}