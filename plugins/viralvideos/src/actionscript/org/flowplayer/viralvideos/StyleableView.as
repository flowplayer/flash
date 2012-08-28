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
package org.flowplayer.viralvideos {
    import flash.events.FocusEvent;
    import flash.events.TimerEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.utils.Timer;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.util.StyleSheetUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    public class StyleableView extends StyleableSprite {
        protected const PADDING_X:int = 20;
        protected const PADDING_Y:int = 3;
        protected const PADDING_Y_TALL:int = 6;
        protected const MARGIN_Y:int = 10;
        protected const MARGIN_X:int = 10;
        protected const MARGIN_TOP:int = 10;

        private var _model:DisplayPluginModel;
        private var _player:Flowplayer;

        public function StyleableView(styleName:String, plugin:DisplayPluginModel, player:Flowplayer, style:Object) {
            super(styleName, player, player.createLoader());
            rootStyle = style;
            css(style);
            _player = player;
            _model = plugin;
        }

        protected function get model():DisplayPluginModel {
            return _model;
        }

        protected function get player():Flowplayer {
            return _player;
        }

        public function show():void {
            this.visible = true;
            this.alpha = 1;
        }

        protected function createLabelField():TextField {
            var field:TextField = player.createTextField();
            field.selectable = false;
            field.focusRect = false;
            field.tabEnabled = false;
            field.autoSize = TextFieldAutoSize.LEFT;
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.height = 15;
            field.styleSheet = style.styleSheet;
            return field;
        }

        protected function get inputFieldBackgroundColor():String {
            return style.getStyle(".input").backgroundColor as String;
        }

        protected function get inputFieldTextColor():String {
            return style.getStyle(".input").color as String;
        }

        protected function createInputField(selectTextOnFocus:Boolean = true):TextField {
            var field:TextField = player.createTextField();

            field.addEventListener(FocusEvent.FOCUS_IN, function(event:FocusEvent):void {
                var field:TextField = event.target as TextField;
//                field.borderColor = 0xCCFFCC;
                if (selectTextOnFocus) {
                    var text:String = field.text;
                    if (text && text.length > 0) {
                        field.setSelection(0, text.length);
                        field.scrollH = field.scrollV = 0;
                    }
                }
            });
            field.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void {
                var field:TextField = event.target as TextField;
//                field.borderColor = 0xffffff;
                if (selectTextOnFocus) {
                    field.setSelection(0, 0);
                }
            });

            field.type = TextFieldType.INPUT;
            field.alwaysShowSelection = true;
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.background = true;
            field.tabEnabled = true;
            field.textColor = 0;
            field.height = 20;
            field.backgroundColor = StyleSheetUtil.colorValue(inputFieldBackgroundColor);
            field.alpha = StyleSheetUtil.colorAlpha(inputFieldBackgroundColor);
            field.textColor = StyleSheetUtil.colorValue(inputFieldTextColor);
            return field;
        }

        protected function formatString(original:String, ...args):String {
            var replaceRegex:RegExp = /\{([0-9]+)\}/g;
            return original.replace(replaceRegex, function():String {
                if (args == null)
                {
                    return arguments[0];
                }
                else
                {
                    var resultIndex:uint = uint(between(arguments[0], '{', '}'));
                    return (resultIndex < args.length) ? args[resultIndex] : arguments[0];
                }
            });
        }

        public static function between(p_string:String, p_start:String, p_end:String):String {
            var str:String = '';
            if (p_string == null) { return str; }
            var startIdx:int = p_string.indexOf(p_start);
            if (startIdx != -1) {
                startIdx += p_start.length; // RM: should we support multiple chars? (or ++startIdx);
                var endIdx:int = p_string.indexOf(p_end, startIdx);
                if (endIdx != -1) { str = p_string.substr(startIdx, endIdx-startIdx); }
            }
            return str;
        }

        protected function createLabelReset(label:TextField):void {
            var timer:Timer = new Timer(5000, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void { label.htmlText = ""; } );
            timer.start();
        }
    }

}