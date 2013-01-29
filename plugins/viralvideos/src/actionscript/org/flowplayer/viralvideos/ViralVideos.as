 /*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.viralvideos {
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.PlayerEvent;
import org.flowplayer.model.PlayerEventType;
import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.ui.dock.Dock;
    import org.flowplayer.ui.buttons.CloseButton;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.FlowStyleSheet;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.Styleable;
    import org.flowplayer.view.StyleableSprite;
    import org.flowplayer.viralvideos.config.Config;
    import org.flowplayer.viralvideos.icons.EmailIcon;
    import org.flowplayer.viralvideos.icons.EmbedIcon;
    import org.flowplayer.viralvideos.icons.ShareIcon;

    public class ViralVideos extends AbstractSprite implements Plugin, Styleable {

        private const TAB_HEIGHT:int = 25;
        public var _player:Flowplayer;
        private var _model:PluginModel;
        private var _config:Config;
        private var _playerEmbed:PlayerEmbed;
        private var _iconDock:Dock;

        private var _tabContainer:Sprite;
        private var _panelContainer:Sprite;

        private var _embedView:EmbedView;
        private var _emailView:EmailView;
        private var _shareView:ShareView;
        private var _emailMask:Sprite = new Sprite();
        private var _shareMask:Sprite = new Sprite();
        private var _embedMask:Sprite = new Sprite();

        public var _embedTab:Tab;
        public var _emailTab:Tab;
        public var _shareTab:Tab;

        private var _closeButton:CloseButton;
        private var _tabCSSProperties:Object;

        private var _controls:Object;

        public function onConfig(plugin:PluginModel):void {
            log.debug("onConfig()", plugin.config);
            _model = plugin;
            _config = new PropertyBinder(new Config(), null).copyProperties(_model.config) as Config;
        }

        private function arrangeView(view:StyleableSprite):void {
            if (view) {
                view.setSize(width, height);
                view.y = TAB_HEIGHT;
            }
        }

        private function arrangeCloseButton():void {
            _closeButton.width = width * .05;
            _closeButton.height = width * .05;
            _closeButton.x = width - _closeButton.width / 2;
            _closeButton.y = TAB_HEIGHT - _closeButton.height / 2;
            setChildIndex(_closeButton, numChildren - 1);
        }

        override protected function onResize():void {
            arrangeView(_emailView);
            arrangeView(_embedView);
            arrangeView(_shareView);
            arrangeCloseButton();
        }

        private function createPanelContainer():void {
            _panelContainer = new Sprite();
            addChild(_panelContainer);
        }

        private function createCloseButton(icon:DisplayObject = null):void {
            if (_closeButton) return;
            _closeButton = new CloseButton(_config.closeButton, _player.animationEngine);
            addChild(_closeButton);
            _closeButton.addEventListener(MouseEvent.CLICK, close);
        }

        private function createIconDock():void {
            if (_iconDock) return;
            _iconDock = Dock.getInstance(_player);
            _iconDock.config.scaleWidthAndHeight = true;
            var addIcon:Function = function(enabled:Boolean, iconClass:Class, clickCallback:Function):void {
                if (! enabled) return;
                var icon:DisplayObject = new iconClass(_config.iconButtons, _player.animationEngine);
                _iconDock.addIcon(icon);
                icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                    clickCallback();
                });
            };

            addIcon(_config.email, EmailIcon, function():void { fadeIn("Email"); });
            addIcon(_config.embed, EmbedIcon, function():void { fadeIn("Embed"); });
            addIcon(_config.share, ShareIcon, function():void { fadeIn("Share"); });
        }

        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad()");
            
            this.visible = false;
            _player = player;

            _controls = _player.pluginRegistry.getPlugin("controls");

            createPanelContainer();
            createIconDock();
            createCloseButton();

            _player.onLoad(onPlayerLoad);
            _model.dispatchOnLoad();
        }

        private function fadeIn(view:String):void {

            //fix for #221 now pauses video on display of overlays
            if (_config.pauseVideo) _player.pause();

            var event:String = "onBeforeShow" + view;
        	if (_model &&  !_model.dispatchBeforeEvent(PluginEventType.PLUGIN_EVENT, event)) {
				log.debug(event);
				return;
			}

            this.visible = true;
            this.alpha = 0;
            _player.setKeyboardShortcutsEnabled(false);
            setActiveTab(view);
            _player.animationEngine.fadeIn(this);
        }

        private function onPlayerLoad(event:PlayerEvent):void {
            log.debug("onPlayerLoad() ");
            _playerEmbed = new PlayerEmbed(_player, _model.name, stage, _config.embed, _config.share != null);
            _config.playerEmbed = _playerEmbed;

            createViews();
            initializeTabProperties();
            createTabs();

            _iconDock.addToPanel();
            _iconDock.onShow(onDockShow);

            hideViews();

            // show first view
            if ( _emailView ) {
                setActiveTab("Email", false);
            	_emailView.show();
			} else if ( _embedView ) {
				setActiveTab("Embed", false);
            	_embedView.show();
			} else if ( _shareView ) {
				setActiveTab("Share", false);
            	_shareView.show();
			}
        }

        private function onDockShow():Boolean {
            return ! this.visible || this.alpha == 0;
        }

        private function createViews():void {
            if (_config.email) {
                createEmailView();
            }
            if (_config.share) {
                createShareView();
            }
            if (_config.embed) {
                createEmbedView();
            }
        }

        private function initializeTabProperties():void {
            var gradient:Array = null;
            if (_config.canvas.hasOwnProperty("backgroundGradient")) {
                var gradArr:Array = FlowStyleSheet.decodeGradient(_config.canvas.backgroundGradient);
                gradient = [gradArr[0], gradArr[0]];
            }
            _tabCSSProperties = getViewCSSProperties();
			if ( ! _tabCSSProperties )
				_tabCSSProperties = {};
				
            var defaultTabProps:Object = { backgroundGradient: 'medium', border: 'none', borderRadius: 15 };
            for (var prop:String in defaultTabProps) {
                _tabCSSProperties[prop] = defaultTabProps[prop]; 
            }
            if (gradient) {
                _tabCSSProperties.backgroundGradient = gradient;
            }
        }

        public function getDefaultConfig():Object {
            return {
                top: "45%",
                left: "50%",
                opacity: 1,
                borderRadius: 15,
                border: 'none',
                width: "80%",
                height: "80%"
            };
        }

        //Javascript API functions

        private function createEmailView():void {
            _config.setEmail(true);
            _emailView = new EmailView(_model as DisplayPluginModel, _player, _config.email, _config.buttons, _config.canvas);
            //_emailView.setSize(stage.width, stage.height);
            _panelContainer.addChild(_emailView);
        }

        [External]
        public function email():void {
            showViews('Email');
        }

        private function createEmbedView():void {
            _embedView = new EmbedView(_model as DisplayPluginModel, _player, _config.embed, _config.buttons, _config.canvas);
            //_embedView.setSize(stage.width, stage.height);
            _panelContainer.addChild(_embedView);
            //get the embed code and return it to the embed code textfield
        }

        [External]
        public function embed():void {
            showViews('Embed');
        }


        private function createShareView():void {
            _shareView = new ShareView(_model as DisplayPluginModel, _player, _config.share, _config.canvas);
            //return the embed code to be used for some of the social networking site links like myspace
            _panelContainer.addChild(_shareView);
        }

        [External]
        public function share():void {
            showViews('Share');
        }

        [External]
        public function getEmbedCode(escaped:Boolean = false):String {
            return _playerEmbed.getEmbedCode(escaped);
        }

        [External]
        public function getPlayerConfig(escaped:Boolean = false):String {
            return _playerEmbed.getPlayerConfig(escaped);
        }

        [External]
        public function getPlayerSwfUrl():String {
            return _player.config.playerSwfUrl;
        }

        private function hideViews():void {
            if (_emailView) _emailView.visible = false;
            if (_embedView) _embedView.visible = false;
            if (_shareView) _shareView.visible = false;
        }

        public function showView(panel:String):void {
            displayButtons(false);
            hideViews();

            if (panel == "Email" && _emailView) {
                //#410 disable fullscreen for email tab
                enableFullscreen(false);
                _emailView.show();
            }

            if (panel == "Embed" && _embedView) {
                 //#410 disable fullscreen for email tab
                enableFullscreen(false);
                _embedView.show();
            }

            if (panel == "Share" && _shareView) _shareView.show();
        }

        private function onFullscreen(event:PlayerEvent):void {
            log.debug("preventing fullscreen");
            event.preventDefault();
        }

        //#410 enable / disable fullscreen
        private function enableFullscreen(enable:Boolean):void
        {
            // prevent fullscreen (disables fullscreen entry by screen doubleclick also)
            if (enable) {
                _player.unbind(onFullscreen, null, true);
            } else {
                _player.onBeforeFullscreen(onFullscreen);
            }

            //#606 check for controls first if disabled.
            if (!_controls) return;
            _controls.pluginObject.setEnabled({fullscreen: enable});
        }

        //#410 toggle fullscreen and hide dock buttons for email and embed tabs
        private function toggleFullscreen():void
        {
            if (_player.isFullscreen()) {
                _player.toggleFullscreen();
                _iconDock.visible = false;
                displayButtons(false);

            }
        }

        public function close(event:MouseEvent = null):void {
            _iconDock.visible = true;
            _player.animationEngine.fadeOut(this, 500, onFadeOut);
        }

        private function onFadeOut():void {

            displayButtons(true);
            _player.setKeyboardShortcutsEnabled(true);

            //fix for #221 now pause / resume video when showing / hiding overlays
            if (_config.pauseVideo) _player.resume();

            //#410 re-enable fullscreen if disabled
            enableFullscreen(true);

            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onClose");
        }

        public function setActiveTab(newTab:String, show:Boolean = true):void {
            log.debug("setActiveTab() " + newTab);

            if (_emailView) {
                _emailMask.height = TAB_HEIGHT;
                _emailTab.css({backgroundGradient: 'medium'})
            }
            if (_embedView) {
                _embedMask.height = TAB_HEIGHT;
                _embedTab.css({backgroundGradient: 'medium'})
            }
            if (_shareView) {
                _shareMask.height = TAB_HEIGHT;
                _shareTab.css({backgroundGradient: 'medium'})
            }

            if (newTab == "Email" && _emailView) {
                //#410 toggle out of fullscreen due to flash user input restrictions.
                toggleFullscreen();

                _emailMask.height = TAB_HEIGHT;
                _emailTab.css(_tabCSSProperties);
            }
            if (newTab == "Embed" && _embedView) {
                //#410 toggle out of fullscreen due to flash user input restrictions.
                toggleFullscreen();

                _embedMask.height = TAB_HEIGHT;
                _embedTab.css(_tabCSSProperties);
            }
            if (newTab == "Share" && _shareView) {
                _shareMask.height = TAB_HEIGHT;
                _shareTab.css(_tabCSSProperties);
            }

            if (show) {
                showView(newTab);
            }
            arrangeView(getView(newTab));

        }

        private function getViewCSSProperties():Object {
            if (_emailView) return _emailView.css();
            if (_embedView) return _embedView.css();
            if (_shareView) return _shareView.css();
            return null;
        }

        private function createViewIfNotExists(liveTab:String, viewName:String, view:DisplayObject, createFunc:Function):void {
            if (liveTab == viewName && ! view) {
                createFunc();
            }
        }

        private function showViews(liveTab:String):void {
            this.visible = true;
            this.alpha = 1;
            _player.setKeyboardShortcutsEnabled(false);
            createViewIfNotExists(liveTab, "Email", _emailView, createEmailView);
            createViewIfNotExists(liveTab, "Embed", _embedView, createEmbedView);
            createViewIfNotExists(liveTab, "Share", _shareView, createShareView);

            setActiveTab(liveTab);
        }

        private function getView(liveTab:String):StyleableSprite {
            if (liveTab == "Email") return _emailView;
            if (liveTab == "Embed") return _embedView;
            if (liveTab == "Share") return _shareView;
            return null;
        }

        private function createTab(xpos:int, mask:Sprite, tabTitle:String):Tab {
            var tab:Tab = new Tab(_model as DisplayPluginModel, _player, tabTitle, _tabCSSProperties);
            tab.setSize(tabWidth, TAB_HEIGHT * 2);
            tab.x = xpos;
            _tabContainer.addChild(tab);

            mask.graphics.beginFill(0xffffff, 1);
            mask.graphics.drawRect(0, 0, tabWidth + 2, TAB_HEIGHT * 2);
            mask.graphics.endFill();
            mask.x = xpos - 1;
            tab.mask = mask;
            _tabContainer.addChild(mask);
            return tab;
        }

        private function get tabWidth():Number {
            return width > 315 ? 100 : 80;
        }

        private function createTabs():void {
            log.debug("createTabs()");
            _tabContainer = new Sprite();
            addChild(_tabContainer);
            _tabContainer.x = 8;

            var tabXPos:int = 0;

            if (_config.email) {
                _emailTab = createTab(tabXPos, _emailMask, "Email");
                tabXPos += tabWidth + 2;
            }
            if (_config.embed) {
                _embedTab = createTab(tabXPos, _embedMask, "Embed")
                tabXPos += tabWidth + 2;
            }
            if (_config.share) {
                _shareTab = createTab(tabXPos, _shareMask, "Share")
            }
        }

        public function displayButtons(display:Boolean):void {
            //#60 use new helper methods to hide / show the dock when auto hide is enabled or not.
            if (display) {
                _iconDock.show();
            } else {
                log.debug("stopping auto hide and hiding buttons");
                _iconDock.hide();
            }
        }

        public function css(styleProps:Object = null):Object {
            return {};
        }

        public function animate(styleProps:Object):Object {
            return {};
        }

        public function onBeforeCss(styleProps:Object = null):void {
            _iconDock.cancelAnimation();
        }

        public function onBeforeAnimate(styleProps:Object):void {
            _iconDock.cancelAnimation();
        }
    }
}
