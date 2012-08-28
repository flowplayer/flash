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
package org.flowplayer.ui.buttons {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    import flash.display.Sprite;
    import flash.text.TextField;

    import flash.text.TextFieldType;

    import flash.text.TextFormatAlign;

    import org.flowplayer.ui.assets.Button;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.TextUtil;
    import org.flowplayer.view.AnimationEngine;

    public class LabelButton extends AbstractButton {
        private var _label:String;
        private var _text:TextField;
        private var _overArea:Sprite;

        public function LabelButton(label:String, config:ButtonConfig, animationEngine:AnimationEngine) {
            _label = label;
            super(config, animationEngine);
        }

        override protected function onResize():void {
            face.width = width;
            face.height = height;
            _text.width = _text.textWidth + 10;
            _text.height = _text.textHeight + 6;
            Arrange.center(_text, width, height);
//            _text.y = height - _text.height;

            _overArea.graphics.clear();
            _overArea.graphics.beginFill(0,0);
            _overArea.graphics.drawRoundRect(0, 0, width, height, 15, 15);
            _overArea.graphics.endFill();
        }

        override protected function createFace():DisplayObjectContainer {
            return new Button();
        }

        override protected function childrenCreated():void {
            var text:TextField = TextUtil.createTextField(false, null, 12, true);
            text.selectable = false;
            text.type = TextFieldType.DYNAMIC;
            text.textColor = config.fontColor;
            text.defaultTextFormat.align = TextFormatAlign.CENTER;
            addChild(text);
            text.text = _label;
            _text = text;

            _overArea = new Sprite();
            addChild(_overArea);
        }

        override protected function doEnable(enabled:Boolean):void {
            registerEventListeners(enabled, _overArea);
        }
    }
}