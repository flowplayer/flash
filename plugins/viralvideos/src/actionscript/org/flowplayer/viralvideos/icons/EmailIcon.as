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
package org.flowplayer.viralvideos.icons {
    import flash.display.DisplayObjectContainer;
    import org.flowplayer.viral.assets.EmailIcon;
    import org.flowplayer.ui.buttons.AbstractButton;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;

    import org.flowplayer.util.AccessibilityUtil;

    public class EmailIcon extends AbstractButton {

        public function EmailIcon(config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine);
        }

        override protected function createFace():DisplayObjectContainer {
            name = "email";
            AccessibilityUtil.setAccessible(this, name);
            return new org.flowplayer.viral.assets.EmailIcon();
        }
    }
}