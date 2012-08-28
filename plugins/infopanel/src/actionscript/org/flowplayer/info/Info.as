/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Copyright 2009 Joel Hulen, loading of captions files from URLs without a file extension
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.info {
    import flash.events.MouseEvent;

    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.layout.LayoutEvent;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
 
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.Styleable;
    import org.flowplayer.ui.AutoHide;
 
    
    import org.flowplayer.info.ui.InfoButton;
    
    
    public class Info extends AbstractSprite implements Plugin, Styleable {
        private var _player:Flowplayer;
        private var _model:PluginModel;
        private var _infoView:*;
        private var _config:Config;
        private var _viewModel:DisplayPluginModel;
        private var _autoHide:AutoHide;
        private var _button:InfoButton;
        private var _initialized:Boolean;



        /**
         * Sets the plugin model. This gets called before the plugin
         * has been added to the display list and before the player is set.
         * @param plugin
         */
        public function onConfig(plugin:PluginModel):void {

            _model = plugin;
            _config = new PropertyBinder(new Config(), null).copyProperties(plugin.config) as Config;
           
        }

        /**
         * Sets the Flowplayer interface. The interface is immediately ready to use, all
         * other plugins have been loaded an initialized also.
         * @param player
         */
        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad");
            _initialized = false;
            _player = player;

            if (! _config.infoTarget) {
                throw Error("No infoTarget defined in the configuration");
            }
            _viewModel = _player.pluginRegistry.getPlugin(_config.infoTarget) as DisplayPluginModel;
            _infoView = _viewModel.getDisplayObject();
            
            createInfoButton();
            
            _player.onLoad(onPlayerLoad);
            _model.dispatchOnLoad();
        }
        
        private function createInfoButton():void {
        	if (_config.iconButtons) {
                var props:DisplayProperties = _config.iconDisplayProperties;
                props.setDisplayObject(this);
            
                _button = new InfoButton(_config.iconButtons, _player.animationEngine);
                _player.addToPanel(_button, props);
                
                _button.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
        

                    _player.togglePlugin(_config.infoTarget);
                   
                });
            }
        }

        private function onPlayerLoad(event:PlayerEvent):void {
            _player.togglePlugin(_config.infoTarget);
            _autoHide = new AutoHide(null, _config.autoHide, _player, stage, _button);
            _autoHide.onShow(onButtonsShow);
            _autoHide.start();
        }
        
        private function onButtonsShow():Boolean {
        	return true;
        }

        
        private function onPlayerResized(event:LayoutEvent):void {
            log.debug("onPlayerResized");
            _button.x = _infoView.x + _infoView.width + 3;
            _button.y = _infoView.y;
        }

        /**
         * Sets style properties.
         */
        public function css(styleProps:Object = null):Object {
            var result:Object = _infoView.css(styleProps);
            return result;
        }
        
        public override function set alpha(value:Number):void {
            super.alpha = value;
            if (!_infoView) return;
            _infoView.alpha = value;
        }

        public function getDefaultConfig():Object {
            return { bottom: 25, width: '80%'};
        }

        public function animate(styleProps:Object):Object {
            return _infoView.animate(styleProps);
        }

        public function onBeforeCss(styleProps:Object = null):void {
            _autoHide.cancelAnimation();
        }

        public function onBeforeAnimate(styleProps:Object):void {
            _autoHide.cancelAnimation();
        }
    }
}
