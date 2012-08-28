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
package org.flowplayer.ui {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.*;

    import org.flowplayer.util.StyleSheetUtil;
    import org.flowplayer.util.TextUtil;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.AnimationEngine;

    public class MenuItem extends AbstractSprite {

        private var _value:String;
        private var _txt:TextField;
        private var _animations:AnimationEngine;
        private var _textColor:String;
        private var _backgroundColor:String;

        public function MenuItem(animations:AnimationEngine, caption:String, value:String, backgroundColor:String, textColor:String):void {
            _value = value;
            _animations = animations;
            _backgroundColor = backgroundColor;
            _textColor = textColor;

            buttonMode = true;
            createTextField(caption);

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        }

        private function drawBackground(color:String):void {
            graphics.beginFill(StyleSheetUtil.colorValue(color), StyleSheetUtil.colorAlpha(color));
            graphics.drawRect(0, 0, width, height);
        }

        override protected function onResize():void {
            graphics.clear();
            drawBackground(_backgroundColor);

            _txt.x = 5;
            _txt.y = 2;
            _txt.width = width - 10;
            _txt.height = height - 4;            
        }

        private function createTextField(caption:String):void {
            _txt = TextUtil.createTextField(false, null, 10);
            _txt.mouseEnabled = false;
            _txt.text = caption;
//            _txt.defaultTextFormat.color = 0xFFFFFF;
            _txt.textColor = StyleSheetUtil.colorValue(_textColor);
            addChild(_txt);
        }

        private function setTextColor(color:String):void {
            var format:TextFormat = _txt.defaultTextFormat;
            format.color = StyleSheetUtil.colorValue(color);
            _txt.setTextFormat(format, 0, _txt.text.length);
        }

        private function mouseOver(e:MouseEvent):void {
            drawBackground(_textColor);
            setTextColor(_backgroundColor);
        }

        private function mouseOut(e:MouseEvent):void {
            drawBackground(_backgroundColor);
            setTextColor(_textColor);
        }

        private function addedToStage(e:Event):void {
            this.y = (this.parent.getChildIndex(this) + 1) * this.height;
        }

        public function get caption():String {
            return _txt.text;
        }

        public function get value():String {
            return _value;
        }
    }
}