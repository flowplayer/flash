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
package org.flowplayer.bitrateselect.config {
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.ui.buttons.TooltipButtonConfig;

    public class IconConfig {
        private var _buttons:TooltipButtonConfig;

        public function IconConfig() {
            _buttons = new TooltipButtonConfig();
            _buttons.setColor("rgba(20,20,20,0.5)");
            _buttons.setOverColor("rgba(0,0,0,1)");

            _buttons.setOnColor("rgba(255,255,255,1)");
            _buttons.setOffColor("rgba(130,130,130,1)");
            _buttons.setDisabledColor("rgba(33,33,33,1");
            _buttons.setEnabled(false);
        }

        public function get buttons():TooltipButtonConfig {
            return _buttons;
        }

        public function set buttons(value:TooltipButtonConfig):void {
            _buttons = value;
        }
    }
}