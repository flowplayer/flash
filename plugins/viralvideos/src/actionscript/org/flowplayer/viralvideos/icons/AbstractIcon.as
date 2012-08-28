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
    import flash.text.TextField;

    import org.flowplayer.ui.buttons.AbstractButton;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.TextUtil;
    import org.flowplayer.util.AccessibilityUtil;
    import org.flowplayer.view.AnimationEngine;

    public class AbstractIcon extends AbstractButton {
        private var _labelText:String;
        private var _label:TextField;

        public function AbstractIcon(config:ButtonConfig, animationEngine:AnimationEngine, label:String = null) {
            _labelText = label;
            name = label;
            super(config, animationEngine);
        }

        override protected function onResize():void {
            face.height = face.width = height - (_label ? _label.height : 0);
            face.x = int((width / 2) - (face.width / 2));

            if (_label) {
                _label.width = _label.textWidth + 5;
                _label.y = height - _label.height;
                log.debug("label arranged to Y pos " + _label.y);
                Arrange.center(_label, width);
                _label.x = _label.x - 5;
            }
        }

        override protected final function createFace():DisplayObjectContainer {
            var icon:DisplayObjectContainer = createIcon();
            addChild(icon);
            if (_label) {
                createLabel(icon, _labelText);
            }
            //#443 enable accessibility support icons
            AccessibilityUtil.setAccessible(this, name);
            return icon;
        }

        protected function createIcon():DisplayObjectContainer {
            return null;
        }

        private function createLabel(icon:DisplayObjectContainer, label:String):void {
            _label = TextUtil.createTextField(false, null, 10);
            _label.text = label;
            _label.height = 15;
            addChild(_label);

            _label.y = icon.height;
        }
//
//        public function get contentWidth():Number {
//            return face.width;
//        }
//
//        public function get contentHeight():Number {
//            return face.height;
//        }
    }
}