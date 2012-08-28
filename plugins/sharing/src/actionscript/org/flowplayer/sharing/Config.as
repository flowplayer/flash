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
    import flash.display.Stage;

    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.viralvideos.config.EmbedConfig;

    public class Config {
        private var _buttons:ButtonConfig;
        private var _email:Email;
        private var _embedCode:EmbedCode;
        private var _twitter:Twitter;
        private var _facebook:Facebook;

        public function Config(player:Flowplayer, pluginConfiguredName:String, stage:Stage) {
            _buttons = new ButtonConfig();
            _buttons.setColor("rgba(20,20,20,0.5)");
            _buttons.setOverColor("rgba(0,0,0,1)");

            _email = new Email(player);
            _embedCode = new EmbedCode(player, pluginConfiguredName, stage);
            _twitter = new Twitter(player);
            _facebook = new Facebook(player);
        }

        [Value]
        public function get buttons():ButtonConfig {
            return _buttons;
        }

        public function setButtons(config:Object):void {
            new PropertyBinder(_buttons).copyProperties(config);
        }

        public function setEmail(config:Object):void {
            if (! config) {
                _email = null;
                return;
            }
            new PropertyBinder(_email).copyProperties(config);
        }

        [Value]
        public function get email():Email {
            return _email;
        }

        public function setEmbed(config:Object):void {
            if (! config) {
                _embedCode = null;
                return;
            }
            new PropertyBinder(_embedCode).copyProperties(config);
            new PropertyBinder(_embedCode.config).copyProperties(config);
        }

        [Value]
        public function get embed():EmbedConfig {
            if (! _embedCode) return null;
            return _embedCode.config;
        }

        public function getEmbedCode():EmbedCode {
            return _embedCode;
        }

        [Value]
        public function get twitter():Twitter {
            return _twitter;
        }

        public function setTwitter(config:Object):void {
            if (! config) {
                _twitter = null;
                return;
            }
            new PropertyBinder(_twitter).copyProperties(config);
        }

        [Value]
        public function get facebook():Facebook {
            return _facebook;
        }

        public function setFacebook(config:Object):void {
            if (! config) {
                _facebook = null;
                return;
            }
            new PropertyBinder(_facebook).copyProperties(config);
        }
    }
}