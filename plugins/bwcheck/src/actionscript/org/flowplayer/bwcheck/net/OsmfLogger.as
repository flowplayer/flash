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
package org.flowplayer.bwcheck.net {
    import org.flowplayer.util.Log;
    import org.osmf.logging.Logger;

    public class OsmfLogger extends Logger {
        private var _log:Log;

        public function OsmfLogger(category:String) {
            super(category);

            var pos:int = category.lastIndexOf(".");
            var name:String = category.substr(0, pos) + "::" + category.substr(pos + 1);

            _log = new Log(name);
        }

        override public function debug(message:String, ... rest):void {
            _log.debug.apply(_log, [message]);
            //            _log.debug.apply(_log, [message].concat(rest));
        }

        override public function info(message:String, ... rest):void {
            _log.info.apply(_log, [message]);
            //            _log.info.apply(_log, [message].concat(rest));
        }

        override public function warn(message:String, ... rest):void {
            _log.warn.apply(_log, [message]);
            //            _log.warn.apply(_log, [message].concat(rest));
        }

        override public function error(message:String, ... rest):void {
            _log.error.apply(_log, [message]);
            //            _log.error.apply(_log, [message].concat(rest));
        }

        override public function fatal(message:String, ... rest):void {
            _log.error.apply(_log, [message]);
            //            _log.error.apply(_log, [message].concat(rest));
        }
    }
}