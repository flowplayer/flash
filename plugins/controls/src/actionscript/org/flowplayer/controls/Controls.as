/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls {
    
	import org.flowplayer.view.StyleableSprite;
	import org.flowplayer.view.Flowplayer;
	
	import org.flowplayer.model.Plugin;
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.Playlist;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.DisplayPluginModel;
	
	import org.flowplayer.util.PropertyBinder;
	import org.flowplayer.util.Arrange
	
	import org.flowplayer.ui.containers.WidgetContainer;
	import org.flowplayer.ui.containers.WidgetContainerEvent;
	
	import org.flowplayer.ui.controllers.AbstractWidgetController;
	
	import org.flowplayer.ui.AutoHide;
	import org.flowplayer.ui.AutoHideConfig;
	
	import org.flowplayer.controls.config.Config;
	import org.flowplayer.controls.config.ToolTipsConfig;
	import org.flowplayer.controls.config.WidgetsVisibility;
	import org.flowplayer.controls.config.WidgetsEnabledStates;
	
	import flash.events.Event;
	import flash.system.Security;
	import flash.system.ApplicationDomain;
	
	import flash.utils.*;

    import flash.accessibility.Accessibility;

    /**
     * @author anssi
     */
    public class Controls extends StyleableSprite implements Plugin, WidgetContainer {

        private static const DEFAULT_HEIGHT:Number = 28;
    
        private var _config:Config;
        private var _controlBarMover:AutoHide;
        private var _player:Flowplayer;
        private var _pluginModel:PluginModel;
        private var _currentControlsConfig:Object;
        private var _previousConfig:Config;

		private var _controlbar:Controlbar;
		
        public function Controls() {
            log.debug("creating ControlBar");
			

          addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

		public function onConfig(model:PluginModel):void {
            log.info("received my plugin config ", model.config);
            _pluginModel = model;
            log.debug("-");
            _config = createConfig(model.config);
            log.debug("config created");
        }

        private function createConfig(config:Object):Config {
            var result:Config = new PropertyBinder(new Config()).copyProperties(config) as Config;
            new PropertyBinder(result.autoHide).copyProperties(config.autoHide);
            result.setNewProps(config);
            //#443 disable autohide for accessibility support
            if (Accessibility.active) result.autoHide.enabled = false;
            return result;
        }

		public function onLoad(player:Flowplayer):void {
			// with older versions of FP we are called twice
			if ( _player )	return;
		
			// log.info("received player API! autohide == " + _config.autoHide.state);
			_player = player;
			loader = _player.createLoader();
			rootStyle = _config.bgStyle;

			if (_config.skin) {
				initSkin();
			}
			addListeners(player.playlist);
			
			_controlbar = new Controlbar(_player, _config);
			var self:Controls = this;
			setTimeout(function():void {
				self.dispatchEvent(new WidgetContainerEvent(WidgetContainerEvent.CONTAINER_READY, self));
			}, 0);
			
			_pluginModel.dispatchOnLoad();
		}

		private function onAddedToStage(event:Event):void {

            createControlBarMover();
        
    		addChild(_controlbar);
			
			updateControlbar();
			
			height = DEFAULT_HEIGHT;
        }

        private function createControlBarMover():void {
            if (_config.autoHide.state != 'never' && ! _controlBarMover) {
                _controlBarMover = new AutoHide(DisplayPluginModel(_pluginModel), _config.autoHide, _player, stage, this);
            }
        }

        private function initSkin():void {
            // must allowDomain because otherwise the dynamically loaded buttons cannot access this controlbar
            Security.allowDomain("*");
            var skin:PluginModel = _player.pluginRegistry.getPlugin(_config.skin) as PluginModel;
            log.debug("using skin " + skin);
            SkinClasses.skinClasses = skin.pluginObject as ApplicationDomain;

            log.debug("skin has defaults", SkinClasses.defaults);
            Arrange.fixPositionSettings(_pluginModel as DisplayPluginModel, SkinClasses.defaults);
            new PropertyBinder(_pluginModel, "config").copyProperties(SkinClasses.defaults, false);
            _config = createConfig(_pluginModel.config);
        }

		private function updateControlbar(animation:Boolean = false):void {
			_controlbar.configure(_config, animation);
		}
		
		/**
         * Default properties for the controls.
         */
        public function getDefaultConfig():Object {
            if (! SkinClasses.defaults) return {
                backgroundColor: "none",
                backgroundGradient: "none",
                border: "0px"
            };
            return SkinClasses.defaults;
        }

		/* Public API */
		
		public function addWidget(	controller:AbstractWidgetController, after:String = null, 
									animated:Boolean = true, decorated:Boolean = true):void {
			if ( ! _controlbar ) {
				log.error("WidgetContainer not ready yet !");
				return;
			}
			_controlbar.addWidget(controller, after, animated, decorated);
		}
		

		/* External API */

        [External(convert="true")]
        public function get config():Config {
            return _config;
        }

        [External]
        public function setTooltips(props:Object):void {
           // initTooltipConfig(_config, props);
			_config.setNewProps({tooltips: props});
           	updateControlbar();
 		//	redraw(props);
        }

        [External(convert="true")]
        public function getTooltips():ToolTipsConfig {
            return _config.tooltips;
        }

        [External]
        public function setAutoHide(props:Object = null):void {
            log.debug("autoHide()");
            if (_controlBarMover)
                _controlBarMover.stop();

            if (props) {
                new PropertyBinder(_config.autoHide).copyProperties(props);
            }
            _pluginModel.config.autoHide = _config.autoHide.state;

            //#443 disable autohide for accessibility support
            if (Accessibility.active) _config.autoHide.enabled = false;

            createControlBarMover();

            //#605 fixes for autohide method when currently disabled.
            if (_controlBarMover) {
                _controlBarMover.start();
            }
        }

        [External(convert="true")]
        public function getAutoHide():AutoHideConfig {
            return _config.autoHide;
        }

        /**
         * Makes buttons and other widgets visible/hidden.
         * @param visibleWidgets the buttons visibilies, for example { all: true, volume: false, time: false }
         */
        [External]
        public function setWidgets(visibleWidgets:Object = null):Object {
            log.debug("widgets()");
            if (! visibleWidgets) return getWidgets();

			// TODO: check why we need this
            if (_controlbar.animationTimerRunning) return getWidgets();
            
			if ( _controlBarMover )
				_controlBarMover.show();

			_config.setNewProps(visibleWidgets);
			
			updateControlbar(true);

            return getWidgets();
        }


        [External(convert="true")]
        public function getWidgets():WidgetsVisibility {
            return _config.visible;
        }

        /*
         * This is here for backward compatibility. Lots of ad plugins use this.
         */
        [External]
        public function enable(enabledWidgets:Object):void {
            setEnabled(enabledWidgets);   
        }

        /**
         * Enables and disables buttons and other widgets.
         */
        [External]
        public function setEnabled(enabledWidgets:Object):void {
            log.debug("enable()");
           // setConfigBooleanStates("enabled", enabledWidgets);
            
			_config.setNewProps({enabled: enabledWidgets});
		

			updateControlbar();
			//enableWidgets();
			// TODO : check me
            //enableFullscreenButton(_player.playlist.current);
        }

        [External(convert="true")]
        public function getEnabled():WidgetsEnabledStates {
            return _config.enabled;
        }

		public function getWidget(name:String):AbstractWidgetController {
			return _controlbar.getWidget(name);
		}
		
		public function set centeredWidget(value:String):void {
			_controlbar.centeredWidget = value;
		}
		
		public function get centeredWidget():String {
			return _controlbar.centeredWidget;
		}

		
		
		/* Resize stuff */

		override public function onBeforeCss(styleProps:Object = null):void 
		{
			if ( _controlBarMover )
				_controlBarMover.cancelAnimation();	
		}

        /**
         * @inheritDoc
         */
        override public function css(styleProps:Object = null):Object {
            var result:Object = super.css(styleProps);

			if ( _controlBarMover ) {
                //#624 if there are alpha or opacity changes update the autohide original display properties.
                if (styleProps.alpha || styleProps.opacity) {
                    _controlBarMover.updateDisplayProperties();
                }
				_controlBarMover.show();
            }
	
		//	log.info("Result : ", result);
            var newStyleProps:Object = _config.completeStyleProps(result);
            if (! styleProps) return newStyleProps;
			  
		//	log.info("About to add ", styleProps);
			_config.setNewProps(styleProps);
		//	log.info("STYLE PROPS : ", _config.style);
			
			updateControlbar();
            return _config.style;
        }

        private function setAutoHideFullscreenOnly(config:Config, props:Object):void {
            if (props.hasOwnProperty("fullscreenOnly")) {
                _config.autoHide.fullscreenOnly = props.fullscreenOnly;
            } else if (config.autoHide.state == "never") {
                _config.autoHide.state = "fullscreen";
            }
        }

        /**
         * @inheritDoc
         */
        override public function animate(styleProps:Object):Object {
            var result:Object = super.animate(styleProps);
            return _config.completeStyleProps(result);
        }

        /**
         * Rearranges the buttons when size changes.
         */
        override protected function onResize():void {
            if (! _controlbar) return;
           _controlbar.setSize(width, height);
        }

        /**
         * Makes this visible when the superclass has been drawn.
         */
        override protected function onRedraw():void {
            log.debug("onRedraw, making controls visible");
            this.visible = true;
        }

        


        
		/* Specific clip controls configuration */

        private function addListeners(playlist:Playlist):void {
            playlist.onBegin(onPlayBegin);
           
            playlist.onStop(onPlayStopped);
            playlist.onBufferStop(onPlayStopped);
            playlist.onFinish(onPlayStopped);
        }

        private function onPlayBegin(event:ClipEvent):void {
            log.debug("onPlayBegin(): received " + event);
            var clip:Clip = event.target as Clip;
            handleClipConfig(clip);
        }

        private function handleClipConfig(clip:Clip):void {
            var controlsConfig:Object = clip.getCustomProperty("controls");

            if (controlsConfig) {
	
                if (controlsConfig == _currentControlsConfig) {
                    return;
                }

                log.info("onPlayBegin(): clip has controls configuration, reconfiguring", controlsConfig);
                _currentControlsConfig = controlsConfig;
				
				// reset config before applying a new one
				if ( _previousConfig )	_config = _previousConfig;

				_previousConfig = _config.clone();
				
				_config.setNewProps(controlsConfig);
				
				log.info("Got new config ", _config);
				
				rootStyle = _config.bgStyle;
				_player.css(_pluginModel.name, _config.style);
				
				updateControlbar(true);
				
            } else if (_currentControlsConfig) {
                log.debug("onPlayBegin(): reverting to original configuration", _previousConfig.style);
                _config = _previousConfig;

				rootStyle = _config.bgStyle;
				_player.css(_pluginModel.name, _config.style);

				updateControlbar(true);
            }

        }


      
        private function onPlayStopped(event:ClipEvent):void {
            log.debug("received " + event);

            var clip:Clip = event.target as Clip;
            if (clip.isMidroll) {
                handleClipConfig(clip.parent);
            }
        }
    }
}
