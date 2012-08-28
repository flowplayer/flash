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
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.geom.Matrix;
    import flash.text.TextField;
    import flash.text.TextFormat;

    import org.flowplayer.util.StyleSheetUtil;
    import org.flowplayer.util.TextUtil;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.AnimationEngine;

    public class DropdownMenu extends AbstractSprite {
        private var _container:Sprite;
        private var _txt:TextField;
        private var _button:SimpleButton;
        private var _value:String;
        private var _bgShape:Shape;
        private var _animations:AnimationEngine;
        private var _backgroundColor:String;
        private var _textColor:String;

        public function DropdownMenu(animations:AnimationEngine, backgroundColor:String, textColor:String):void {
            _animations = animations;
            _backgroundColor = backgroundColor;
            _textColor = textColor;
            createContainer();
            createButton();
            drawBackgroundShape(width, height);
            createTextField();

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        }

        public function addItem(caption:String, value:String):void {
            var menuItem:MenuItem = new MenuItem(_animations, caption, value, _backgroundColor, _textColor);
            menuItem.height = 20;
            menuItem.addEventListener(MouseEvent.CLICK, menuItemClick);
            _container.addChild(menuItem);
        }

        private function createButton():void {
            _button = new SimpleButton();
            _button.addEventListener(MouseEvent.CLICK, open);
            addChild(_button);
        }

        private function createContainer():void {
            _container = new Sprite();
            _container.y = height;
            _container.alpha = 0;
            _container.visible = false;
            addChild(_container);
        }

        override protected function onResize():void {
            drawBackgroundShape(width, height);

            _txt.x = 5;
            _txt.y = 3;
            _txt.width = width - 10;
            _txt.height = height - 6;
            setChildIndex(_txt, numChildren - 1);

//            _container.width = width - 6;
            _container.x = 3;

            for(var i:int=0; i < _container.numChildren; i++){
                var child:MenuItem = _container.getChildAt(i) as MenuItem;
                child.setSize(width-6, 20);
            }
        }

        private function createTextField():void {
            var txtFormat:TextFormat = new TextFormat();
            txtFormat.bold = true;
            txtFormat.size = 10;
            txtFormat.font = "Verdana";
            txtFormat.color = StyleSheetUtil.colorValue(_textColor);

            _txt = TextUtil.createTextField(false, null, 10, true);
            _txt.defaultTextFormat = txtFormat;
            _txt.mouseEnabled = false;
            _txt.text = "Select color";
            addChild(_txt);
        }

        private function open(e:MouseEvent):void {
            if (_container.alpha == 0) {
                _container.visible = true;
                _container.alpha = 0;
                _animations.fadeIn(_container);
            }
            else {
                close();
            }
        }

        private function close():void {
            if (_container.alpha > 0) {
                _animations.fadeOut(_container, 500, hideContainer);
            }
        }

        private function hideContainer():void {
            _container.visible = false;
        }

        private function stageMouseDown(e:MouseEvent):void {
            close();
        }

        private function stageMouseLeave(e:Event):void {
            close();
        }

        private function addedToStage(e:Event):void {
            stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);
            stage.addEventListener(Event.MOUSE_LEAVE, stageMouseLeave);
        }

        private function removedFromStage(e:Event):void {
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);
        }

        private function menuItemClick(e:MouseEvent):void {
            if (e.currentTarget.value != _value && e.currentTarget.caption != _txt.text) {
                dispatchEvent(new DropdownMenuEvent(DropdownMenuEvent.CHANGE, e.currentTarget.caption, e.currentTarget.value));
                _value = e.currentTarget.value;
                _txt.text = e.currentTarget.caption;
            }
        }

        private function drawBackgroundShape(width:int, height:int):void {
            if (_bgShape) {
                removeChild(_bgShape);
            }
            _bgShape = new Shape();
            _bgShape.graphics.lineStyle(0, StyleSheetUtil.colorValue(_textColor), 0.5);
            _bgShape.graphics.beginFill(StyleSheetUtil.colorValue(_backgroundColor), StyleSheetUtil.colorAlpha(_backgroundColor));
            _bgShape.graphics.drawRect(0, 0, width, height);
            addChild(_bgShape);
            _button.hitTestState = _bgShape;
        }

        public function get caption():String {
            return _txt.text;
        }

        public function get value():String {
            return _value;
        }
    }
}