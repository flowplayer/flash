/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.ui.dock {
    import flash.display.DisplayObjectContainer;

    import fp.UpButton;

    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.ui.buttons.StyleableButton;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.FlowStyleSheet;

    public class UpButton extends StyleableButton {

        public function UpButton(style:FlowStyleSheet, config:ButtonConfig, animationEngine:AnimationEngine) {
            super(style, config, animationEngine);
        }

        override protected function createFace():DisplayObjectContainer {
            return new fp.UpButton();
        }
    }
}
