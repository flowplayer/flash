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
package org.flowplayer.ui.buttons {
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.GraphicsUtil;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.FlowStyleSheet;

    /**
     * A button that supports backgroundGradient, backgroundColor, border etc.
     */
    public class StyleableButton extends AbstractButton {
        private var _style:FlowStyleSheet;

        public function StyleableButton(style:FlowStyleSheet, config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine);
            _style = style;
        }

        override protected function onResize():void {
            drawBackground();
            Arrange.center(face, width, height);
        }

        private function drawBackground():void {
            graphics.clear();
            if (! _style.backgroundTransparent) {
                log.debug("drawing background color " + _style.backgroundColor + ", alpha " + _style.backgroundAlpha);
                graphics.beginFill(_style.backgroundColor, _style.backgroundAlpha);
                GraphicsUtil.drawRoundRectangle(graphics, 0, 0, width, height, _style.borderRadius);
                graphics.endFill();
            } else {
                log.debug("background color is transparent");
            }
            if (_style.backgroundGradient) {
                log.debug("adding gradient");
                GraphicsUtil.addGradient(this, 0,  _style.backgroundGradient, _style.borderRadius);
            } else {
                GraphicsUtil.removeGradient(this);
            }
        }
    }
}
