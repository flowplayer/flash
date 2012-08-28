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
    import flash.external.ExternalInterface;

    import flash.net.URLRequest;

    import flash.net.navigateToURL;

    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    public class AbstractShareCommand extends AbstractCommand {
        private var log:Log = new Log(this);
        private var _description:String = "A cool video";
        private var _shareWindow:String = "_popup";

        public function AbstractShareCommand(player:Flowplayer) {
            super(player);
        }

        override protected function process():void {
            var url:String = formatString(serviceUrl, encodeURIComponent(_description), pageUrl);
            player.pause();
            launchURL(url, popupDimensions);
        }

        protected function get popupDimensions():Array {
            throw new Error("this method needs to be overridden in subclasses");
            return null;
        }

        protected function get serviceUrl():String {
            throw new Error("this method needs to be overridden in subclasses");
            return null;
        }

        protected function launchURL(url:String, popUpDimensions:Array):void {
            log.debug("launchURL() " + url);
            URLUtil.openPage(url, shareWindow, popUpDimensions);
        }

        public function set description(value:String):void {
            _description = value;
        }

        public function set shareWindow(value:String):void {
            _shareWindow = value;
        }

        [Value]
        public function get description():String
        {
            return _description;
        }

        [Value]
        public function get shareWindow():String
        {
            return _shareWindow;
        }
    }
}