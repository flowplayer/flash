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

    public class IconConfig {
        private var _buttons:ButtonConfig;

        public function IconConfig() {
            _buttons = new ButtonConfig();
            _buttons.setColor("rgba(20,20,20,0.5)");
            _buttons.setOverColor("rgba(0,0,0,1)");        }

        public function get buttons():ButtonConfig {
            return _buttons;
        }

        public function set buttons(value:ButtonConfig):void {
            _buttons = value;
        }
    }
}