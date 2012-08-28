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
package org.flowplayer.ui.dock {
    import org.flowplayer.ui.*;
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayPluginModelImpl;
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.FlowStyleSheet;

    import spark.components.Button;

    public class DockConfig {
        private var _model:DisplayPluginModel;
        private var _autoHide:AutoHideConfig;
        private var _horizontal:Boolean = false;
        private var _scrollable:Boolean = false;
        private var _gap:Number = 5;
        private var _buttons:Object;
        private var _scaleWidthAndHeight:Boolean = false;

        public function DockConfig():void {
            _autoHide = new AutoHideConfig();
            _autoHide.fullscreenOnly = false;
            _autoHide.hideStyle = "fade";
            _autoHide.delay = 2000;
            _autoHide.duration = 1000;

            _model = new DisplayPluginModelImpl(null, Dock.DOCK_PLUGIN_NAME, false);
            _model.top = "15";
            _model.right = "15";
            _model.width = "10%";
            _model.height = "30%";

            _buttons = {
                border: "0px",
                backgroundColor: "transparent",
                borderRadius: "0",
                disabledColor: "#333333"
            };
        }

        public function get model():DisplayPluginModel {
            return _model;
        }

        public function set model(value:DisplayPluginModel):void {
            _model = value;
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

        public function get horizontal():Boolean {
            return _horizontal;
        }

        public function set horizontal(value:Boolean):void {
            _horizontal = value;
        }

        public function get gap():Number {
            return _gap;
        }

        public function set gap(value:Number):void {
            _gap = value;
        }

        public function get scrollable():Boolean {
            return _scrollable;
        }

        public function set scrollable(value:Boolean):void {
            _scrollable = value;
        }

        public function setButtons(value:Object):void {
            for (var prop:String in value) {
                _buttons[prop] = value[prop];
            }
        }

        /**
         * style for the UP scroll button
         */
        public function get upButtonStyle():FlowStyleSheet {
            var sheet:FlowStyleSheet = new FlowStyleSheet("#upbutton");
            sheet.rootStyle = _buttons;
            if (! _buttons.backgroundGradient) {
                sheet.addToRootStyle({backgroundGradient: [.10, .21, .6]});
            }
            return sheet;
        }

        /**
         * style for the DOWN scroll button
         */
        public function get downButtonStyle():FlowStyleSheet {
            var sheet:FlowStyleSheet = new FlowStyleSheet("#downbutton");
            sheet.rootStyle = _buttons;
            if (! _buttons.backgroundGradient) {
                sheet.addToRootStyle({backgroundGradient: [.6, .21, .10]});
            }
            return sheet;
        }

        /**
         * config for the UP scroll button
         */
        public function get upButtonConfig():ButtonConfig {
            return new PropertyBinder(new ButtonConfig()).copyProperties(_buttons) as ButtonConfig;
        }

        /**
         * config for the DOWN scroll button
         */
        public function get downButtonConfig():ButtonConfig {
            return new PropertyBinder(new ButtonConfig()).copyProperties(_buttons) as ButtonConfig;
        }

        public function get scaleWidthAndHeight():Boolean {
            return _scaleWidthAndHeight;
        }

        public function set scaleWidthAndHeight(value:Boolean):void {
            _scaleWidthAndHeight = value;
        }
    }
}