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
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    import fp.DownButton;

    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.ui.buttons.StyleableButton;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.FlowStyleSheet;

    public class DownButton extends StyleableButton {

        public function DownButton(style:FlowStyleSheet, config:ButtonConfig, animationEngine:AnimationEngine) {
            super(style, config, animationEngine);
            log.debug("DownBuggon, backgroundColor == " + (style ? style.backgroundColor : style))
        }

        override protected function createFace():DisplayObjectContainer {
            return new fp.DownButton();
        }
    }
}
