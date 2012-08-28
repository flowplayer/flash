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

    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.viral.assets.BeboIcon;

    public class DiggIcon extends AbstractIcon {

        public function DiggIcon(config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine, "Digg");
        }

        override protected function createIcon():DisplayObjectContainer {
            return new org.flowplayer.viral.assets.DiggIcon();
        }
    }
}