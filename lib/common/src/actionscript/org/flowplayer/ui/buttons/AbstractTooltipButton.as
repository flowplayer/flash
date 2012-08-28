/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.ui.buttons {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;

    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.ui.tooltips.ToolTip;
    import org.flowplayer.ui.tooltips.NullToolTip;
    import org.flowplayer.ui.tooltips.DefaultToolTip;

    public class AbstractTooltipButton extends AbstractButton {
        protected var _tooltip:ToolTip;

        public function AbstractTooltipButton(config:TooltipButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine);
        }

        override protected function onAddedToStage(event:Event):void {
            toggleTooltip();
            super.onAddedToStage(event);
        }

        private function toggleTooltip():void {
            if (tooltipLabel) {
                if (_tooltip && _tooltip is DefaultToolTip) return;
                log.debug("enabling tooltip");
                _tooltip = new DefaultToolTip(_config as TooltipButtonConfig, _animationEngine);
            } else {
                log.debug("tooltip disabled");
                _tooltip = new NullToolTip();
            }
        }

        override public function configure(config:Object):void {
            super.configure(config)
            toggleTooltip();
            _tooltip.redraw(config as TooltipButtonConfig);
        }

        override protected function onMouseOut(event:MouseEvent = null):void {
            super.onMouseOut(event);
            toggleTooltip();
            hideTooltip();
        }

        override protected function onMouseOver(event:MouseEvent):void {
            super.onMouseOver(event);
            showTooltip();
        }

        public function hideTooltip():void {
            _tooltip.hide();
        }

        public function showTooltip():void {
            if (! tooltipLabel || ! tooltipEnabled) {
                hideTooltip();
                return; // not sure about this TODO : check
            }
            toggleTooltip();
            _tooltip.show(this, tooltipLabel);
        }

        protected function get tooltipEnabled():Boolean {
            return  (_config as TooltipButtonConfig).tooltipEnabled;
        }

        public function get tooltipLabel():String {
            return (_config as TooltipButtonConfig).tooltipLabel;
        }

        override protected function onClicked(event:MouseEvent):void {
            super.onClicked(event);
            dispatchEvent(new ButtonEvent(ButtonEvent.CLICK));
            // showTooltip();
        }
    }
}
