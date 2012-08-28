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
package org.flowplayer.sharing {
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.system.System;

    import org.flowplayer.ui.Notification;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.viralvideos.PlayerEmbed;
    import org.flowplayer.viralvideos.config.EmbedConfig;

    public class EmbedCode extends AbstractCommand {
        private var _embed:PlayerEmbed;
        private var _config:EmbedConfig;
        private var _notification:String = "Embed code copied to clipboard! You can now paste it to your site or blog.";

        public function EmbedCode(player:Flowplayer, pluginConfiguredName:String, stage:Stage) {
            super(player);
            _config = new EmbedConfig();
            _embed = new PlayerEmbed(player, pluginConfiguredName, stage, _config, true);
        }

        override protected function process():void {
            System.setClipboard(_embed.getEmbedCode(true));
            var notification:Notification = Notification.createTextNotification(player, _notification);
            notification.setSize(Math.min(player.panel.width - 20, 240), 50);
            notification.show().autoHide();
        }

        public function get config():EmbedConfig {
            return _config;
        }

        public function set notification(value:String):void {
            _notification = value;
        }

        public function get notification():String {
            return _notification;
        }
    }
}