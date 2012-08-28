/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.viralvideos {
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    /**
     * @author danielr
     */
    internal class Tab extends StyleableSprite {

        private var _player:Flowplayer;
        private var _plugin:DisplayPluginModel;
        public var _field:TextField
        private var _text:String;

        public function Tab(plugin:DisplayPluginModel, player:Flowplayer, text:String, style:Object) {
            super("viral-tab", player, player.createLoader());
            rootStyle = style;
            css(style);

            _plugin = plugin;
            _player = player;
            _text = text;
            createTextField(text);
            this.addEventListener(MouseEvent.CLICK, onThisClicked);
        }

        override protected function onResize():void {
            _field.width = _field.textWidth + 7;
            _field.height = _field.textHeight + 3;
            Arrange.center(_field, width);
            _field.y = 5;
        }

        public function get html():String {
            return _text;
        }

        private function createTextField(htmlText:String):void {
            log.debug("creating text field for text " + htmlText);
            if (_field) {
                removeChild(_field);
            }

            _field = _player.createTextField(10);
            _field.styleSheet = style.styleSheet;
            _field.htmlText = "<span class=\"title\">" + htmlText + "</span>";
            _field.selectable = false;
            _field.height = 20;
            _field.x = 5;

            _field.antiAliasType = AntiAliasType.ADVANCED;
            addChild(_field);
        }

        public function onThisClicked(event:MouseEvent):void {
            ViralVideos(_plugin.getDisplayObject()).setActiveTab(html);
        }

        public function closePanel():void {
            _player.animationEngine.fadeOut(this, 0, closePanel2);
        }

        public function closePanel2():void {
            ViralVideos(_plugin.getDisplayObject()).removeChild(this);
        }

    }
}
