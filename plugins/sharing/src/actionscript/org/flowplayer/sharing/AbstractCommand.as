/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.sharing {
    import org.flowplayer.util.Log;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    public class AbstractCommand {
        private var _player:Flowplayer;
        private var log:Log = new Log(this);

        public function AbstractCommand(player:Flowplayer) {
            _player = player;
        }

        public final function execute():void {
            log.debug("execute()");
            process();
        }

        protected function process():void {
        }

        protected function get player():Flowplayer {
            return _player;
        }

        protected function get pageUrl():String {
        	return player.currentClip.getCustomProperty("pageUrl")
        	? String(player.currentClip.getCustomProperty("pageUrl"))
        	: URLUtil.pageUrl;
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

        private function between(p_string:String, p_start:String, p_end:String):String {
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
    }
}