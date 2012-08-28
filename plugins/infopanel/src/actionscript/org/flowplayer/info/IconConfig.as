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
package org.flowplayer.info {
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.ui.ButtonConfig;

    public class IconConfig {
        private var _buttons:ButtonConfig;
        private var _displayProps:DisplayProperties;

        public function IconConfig() {
            _displayProps = new DisplayPropertiesImpl()
            _displayProps = new DisplayPropertiesImpl(null, "info-icons", false);
            _displayProps.bottom = 35;
            _displayProps.right = 5;
            _displayProps.width = 50;
            _displayProps.height = 30;



            _buttons = new ButtonConfig();
            _buttons.setColor("rgba(20,20,20,0.5)");
            _buttons.setOverColor("rgba(0,0,0,1)");        
            _buttons.setToggleOnColor("#CCCCCC"); 
        }

        public function get buttons():ButtonConfig {
            return _buttons;
        }

        public function set buttons(value:ButtonConfig):void {
            _buttons = value;
        }

        public function get displayProps():DisplayProperties {
            return _displayProps;
        }

        public function set displayProps(value:DisplayProperties):void {
            _displayProps = value;
        }
    }
}