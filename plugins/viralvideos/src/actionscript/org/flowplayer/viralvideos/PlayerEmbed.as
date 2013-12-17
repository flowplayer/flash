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
    import com.adobe.serialization.json.JSONforFP;

    import flash.display.Stage;
    import flash.net.URLVariables;
    import flash.utils.ByteArray;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;
    import org.flowplayer.viralvideos.config.Config;
    import org.flowplayer.viralvideos.config.EmbedConfig;
    import org.flowplayer.viralvideos.config.ShareConfig;

    public class PlayerEmbed {
        private var log:Log = new Log(this);
        private var _player:Flowplayer;
        private var _stage:Stage;
        private var _viralPluginConfiguredName:String;
        private var _playerConfig:Object;
        private var _height:int;
        private var _width:int;
        private var _controls:StyleableSprite;
        private var _controlsOriginalOptions:Object;
        private var _controlsModel:DisplayPluginModel;
        private var _controlsOptions:Object;
        private var _autoHide:Boolean;
        private var _embedConfig:EmbedConfig;
        private var _shareEnabled:Boolean;

        public function PlayerEmbed(player:Flowplayer, viralPluginConfiguredName:String, stage:Stage, embedConfig:EmbedConfig, shareEnabled:Boolean) {
            _player = player;
            _viralPluginConfiguredName = viralPluginConfiguredName;
            _stage = stage;
            _embedConfig = embedConfig;
            _shareEnabled = shareEnabled;
            initializeConfig(stage);
            lookupControls();
        }

        private function createOptions():void {
            if (! _controlsOptions) {
                _controlsOptions = {};
            }
        }

        public function set backgroundColor(color:String):void {
            if (!_controls) return;
            log.debug("set backgroundColor " + color);
            createOptions();
            _controlsOptions.backgroundColor = color;
            _controls.css(_controlsOptions);
        }

        public function get backgroundColor():String {
            if (! _controlsOptions) return null;
            return _controlsOptions.backgroundColor;
        }

        public function set buttonColor(color:String):void {
            if (!_controls) return;
            log.debug("set buttonColor " + color);
            createOptions();
            _controlsOptions.buttonColor = color;
            _controlsOptions.buttonOverColor = color;
            _controls.css(_controlsOptions);
        }

        public function get buttonColor():String {
            if (! _controlsOptions) return null;
            return _controlsOptions.buttonColor;
        }

        public function applyControlsOptions(value:Boolean = true):void {
            if (!_controls) return;
            _controls.css(value ? _controlsOptions : _controlsOriginalOptions);
            if (_autoHide) {
                _controls["setAutoHide"](! value);
            }
        }

        private function lookupControls():void {
            log.debug("lookupControls() ");
            var controlsModel:DisplayPluginModel = _player.pluginRegistry.getPlugin("controls") as DisplayPluginModel;
            if (! controlsModel) return;
            log.debug("lookupControls() " + controlsModel + ", disp " + controlsModel.getDisplayObject());
            _controlsModel = controlsModel;
            _controls = controlsModel.getDisplayObject() as StyleableSprite;
            _controlsOriginalOptions = {};
            var props:Object = _controls.css();
            _controlsOriginalOptions = { backgroundColor: props.backgroundColor, buttonColor: props.buttonColor, buttonOverColor: props.buttonOverColor };
            _autoHide = controls["getAutoHide"]()["state"] == "always";
        }

        private function initializeConfig(stage:Stage):void {
            var configObj:* = stage.loaderInfo.parameters["config"];

            if (configObj && String(configObj).indexOf("{") > 0 && ! configObj.hasOwnProperty("url")) {
                // a regular configuration object
                _playerConfig = JSONforFP.decode(configObj);
            } else {
                // had an external config file configured using 'url', use the loaded config object
                //_playerConfig = _player.config.configObject;
                _playerConfig = _player.config.configObject;
            }

            log.debug("initializeConfig() ", _playerConfig);
        }

        private function fixPluginsURLs(config:Object):void {
            for (var pluginName:String in config.plugins) {
                var pluginObj:Object = _player.pluginRegistry.getPlugin(pluginName);
                if (pluginObj && pluginObj is PluginModel) {
                    var pluginModel:PluginModel = PluginModel(pluginObj);
                    log.debug("fixPluginsURL(), plugin's original URL is " + pluginModel.url);
                    if (! hasCompleteUrl(pluginModel) && pluginModel.url) {

                        var plugin:Object = pluginModel.pluginObject;
                        if (! pluginModel.isBuiltIn && plugin.hasOwnProperty("loaderInfo")) {
                            var pluginUrl:String = plugin.loaderInfo.url;
                            if (pluginUrl) {
                                config.plugins[pluginName]["url"] = pluginUrl;
                            }
                        } else if (pluginModel.isBuiltIn) {
                            delete config.plugins[pluginName]["url"];
                        }
                    }
                }
            }
        }

        private function hasCompleteUrl(pluginModel:PluginModel):Boolean {
            return pluginModel && pluginModel.url &&
                    (pluginModel.url.indexOf("file:") == 0
                            || pluginModel.url.indexOf("http:") == 0
                            || pluginModel.url.indexOf("https:") == 0);
        }

        private function updateConfig(config:Object):Object {
            config.playerId = null;

            var copier:ByteArray = new ByteArray();
            copier.writeObject(config);
            copier.position = 0;
            var updatedConfig:Object = (copier.readObject());

            if (_controlsOptions) {
                if (! updatedConfig.plugins["controls"]) {
                    updatedConfig.plugins["controls"] = _controlsOptions;
                } else {
                    for (var prop:String in _controlsOptions) {
                        updatedConfig.plugins["controls"][prop] = _controlsOptions[prop];
                    }
                }
            }

            fixPluginsURLs(updatedConfig);
            fixPageUrl(updatedConfig);

            var clip:Object = getSharedClip(updatedConfig);
            if (! clip) return updatedConfig;

            /*
             * Following clip updates only affect the 1st clip in playlist, or the current clip
             * if _embedConfig.shareCurrentPlaylistItem == true
             */
            if (_embedConfig.isAutoPlayOverriden) {
                clip.autoPlay = _embedConfig.autoPlay;
            }
            if (_embedConfig.isAutoBufferingOverriden) {
                clip.autoBuffering = _embedConfig.autoBuffering;
            }
            if (_embedConfig.linkUrl) {
                clip.linkUrl = _embedConfig.linkUrl;
            }

            return updatedConfig;
        }

        private function fixPageUrl(config:Object):void {
            if (! config.clip) {
                config.clip = {};
            }
            if (! config.clip.pageUrl) {
                config.clip.pageUrl = URLUtil.pageUrl;
            }
        }

        private function getSharedClip(config:Object):Object {
            if (config.playlist is String) {
                // RSS or SMIL playlist
                return null;
            }

            if (_embedConfig.shareCurrentPlaylistItem) {
                log.debug("Sharing just current playlist item");
                delete config.playlist;

                if (! config.clip) {
                    config.clip = {};
                }
                var clip:Object = config.clip;
                clip.url = _player.currentClip.url;
                return clip;
            }

            if (config.playlist) {
                return config.playlist[0];
            }
            return _player.playlist.current;
        }

        public function getPlayerConfig(escaped:Boolean = false):String {
            var configStr:String = _embedConfig.configUrl;
            if (! configStr) {
                var conf:Object = updateConfig(_playerConfig);
                configStr = escaped ? escape(JSONforFP.encode(conf)) : JSONforFP.encode(conf);
            }

            return configStr;
        }

        public function getEmbedCode(escaped:Boolean = false):String {

            var configStr:String = getPlayerConfig(escaped);
            //#34 parse share config params from the player urls before generating the embed code.
            var playerSwfURL:String = formatURL(_player.config.playerSwfUrl);
            var code:String =
                    '<object name="player" id="_fp_' + Math.random() + '" width="' + width + '" height="' + height + '"' +
                            '    data="' + playerSwfURL + '"  type="application/x-shockwave-flash">' +
                            '    <param value="true" name="allowfullscreen"/>' +
                            '    <param value="always" name="allowscriptaccess"/>' +
                            '    <param value="' + _embedConfig.wmode + '" name="wmode"/>' +
                            '    <param value="high" name="quality"/>' +
                            '    <param name="movie" value="' + playerSwfURL + '" />' +
                            '    <param value="config=' + configStr + '" name="flashvars"/>';

            if (_embedConfig.fallbackUrls.length > 0) {
                code += '     <video controls width="' + width + '" height="' + height + '"';
                if (_embedConfig.fallbackPoster != null) {
                    code += ' poster="' + _embedConfig.fallbackPoster + '" ';
                }
                code += '>' + "\n";
                for (var i:uint = 0; i < _embedConfig.fallbackUrls.length; i++) {
                    code += '<source src="' + _embedConfig.fallbackUrls[i] + '" />';
                }
                code += '     </video>' + "\n";
            }

            code += '</object>';
            return code;
        }

        /**
         * #34 parse share config params from the player urls before generating the embed code.
         * @param url
         * @return
         */
        private function formatURL(url:String):String
        {
            var parts:Array = url.split("?");
            if (!parts[1]) return url;
			var vars:URLVariables = new URLVariables(parts[1]);
			delete(vars.config);
            return parts[0] + "?" + vars.toString();
        }

        public function get width():int {
            if (_width > 0) return _width;
            return _embedConfig.width ? _embedConfig.width :_stage.stageWidth;
        }

        public function get height():int {
            if (_height > 0) return _height;
            return _embedConfig.height ? _embedConfig.height : _stage.stageHeight;
        }

        public function get controls():StyleableSprite {
            return _controls;
        }

        public function set height(value:int):void {
            log.debug("set height " + value);
            _height = value;
        }

        public function set width(value:int):void {
            log.debug("set width " + value);
            _width = value;
        }
    }
}