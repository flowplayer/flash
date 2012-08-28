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
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import org.flowplayer.util.Arrange;
    import org.flowplayer.view.Flowplayer;

    /**
     * A notification message that is shown in the player area. Usage example:
     * 
     * new Notification(player, "Hello world!").show().autoHide();
     */
    internal class TextNotification extends Notification {
        private var _field:TextField;

        public function TextNotification(player:Flowplayer, message:String) {
            super(player);
            super.rootStyle = { backgroundGradient: [ 0.1, 0.2 ], border: 'none' };
            createTextField(player, message);
            this.width = 100;
        }

        private function createTextField(player:Flowplayer, message:String):void {
            _field = player.createTextField(12, true);
            _field.autoSize = TextFieldAutoSize.CENTER;
            _field.wordWrap = true;
            _field.multiline = true;
            _field.antiAliasType = AntiAliasType.ADVANCED;

            var newFormat:TextFormat = new TextFormat();
            newFormat.align = TextFormatAlign.CENTER;
            _field.defaultTextFormat = newFormat;

            _field.htmlText = message;
            _field.height = _field.textHeight + 4;
            addChild(_field);
            setSize(_field.width + 20, _field.height + 20);
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + "x" + height);
            _field.width = width - 20;
            _field.x = 0;
            Arrange.center(_field, width, height);
            
        }

    }


}