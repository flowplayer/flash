/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.info
{
    
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.ui.AutoHideConfig;
    import org.flowplayer.util.PropertyBinder;
    

    public class Config {

        private var _infoTarget:String;
        private static const BUTTON_DEFAULTS:Object = { width: 35, height: 20, right: 5, bottom: 35, name: "info_button", label: 'Info' };
        private var _button:Object = BUTTON_DEFAULTS;
        private var _icons:IconConfig = new IconConfig();
        private var _buttonConfig:ButtonConfig;
        private var _autoHide:AutoHideConfig;

        public function Config() {                      
            _autoHide = new AutoHideConfig();
            _autoHide.fullscreenOnly = false;
            _autoHide.hideStyle = "fade";
            _autoHide.delay = 2000;
            _autoHide.duration = 1000;
        }
        
        public function get infoTarget():String {
            return _infoTarget;
        }

        public function set infoTarget(infoTarget:String):void {
            _infoTarget = infoTarget;
        }
        
        public function get buttons():ButtonConfig {
            if (! _buttonConfig) {
                _buttonConfig = new ButtonConfig();
                _buttonConfig.setColor("rgba(140,142,140,1)");
                _buttonConfig.setOverColor("rgba(140,142,140,1)");
                _buttonConfig.setFontColor("rgb(255,255,255)");
            }
            return _buttonConfig;
        }
        
        public function set icons(config:Object):void {
            new PropertyBinder(_icons.displayProps).copyProperties(config);
            new PropertyBinder(_icons.buttons).copyProperties(config);
        }

        public function get iconDisplayProperties():DisplayProperties {
            return _icons.displayProps;
        }
        
        public function get iconButtons():ButtonConfig {
            return _icons.buttons;
        }
        
        public function get autoHide():AutoHideConfig {
            return _autoHide;
        }

        public function setAutoHide(value:Object):void {
            if (value is String) {
                _autoHide.state = value as String;
                return;
            }
            if (value is Boolean) {
                _autoHide.enabled = value as Boolean;
                _autoHide.fullscreenOnly = Boolean(! value);
                return;
            }
            new PropertyBinder(_autoHide).copyProperties(value);
        }

    }
}



