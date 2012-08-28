/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>
 * Copyright (c) 2009, 2010 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.bitrateselect {

    import flash.events.EventDispatcher;
    import flash.net.NetStream;
    import flash.events.NetStatusEvent;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.util.Arrange;

    import org.flowplayer.ui.containers.*;
    import org.flowplayer.ui.dock.Dock;
    import org.flowplayer.ui.Notification;
    import org.flowplayer.ui.buttons.ToggleButton;
    import org.flowplayer.ui.buttons.ToggleButtonConfig;

    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.net.IStreamSelectionManager;
    import org.flowplayer.net.StreamSelectionManager;
    import org.flowplayer.net.StreamSwitchManager;

    import fp.HDSymbol;

    import org.flowplayer.bitrateselect.ui.HDToggleController;
    import org.flowplayer.bitrateselect.event.HDEvent;
    import org.flowplayer.bitrateselect.config.Config;

    public class BitrateSelectProvider extends EventDispatcher implements ClipURLResolver, Plugin  {
        private var log:Log = new Log(this);
        private var _config:Config;
        private var _model:PluginModel;
        private var _hdButton:ToggleButton;
        private var _hdEnabled:Boolean = false;
        private var _player:Flowplayer;
        private var _iconDock:Dock;
        private var _provider:StreamProvider;
        private var _resolveSuccessListener:Function;
        private var _netStream:NetStream;
        private var _clip:Clip;
        private var _start:Number = 0;
        private var _failureListener:Function;
        private var _streamSelectionManager:IStreamSelectionManager;
        private var _streamSwitchManager:StreamSwitchManager;
        private var _menuPlugin:Object;
        private var _menuItems:Array;
        private var _menuShowsBitratesFor:Clip;

        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;
        }

        public function onLoad(player:Flowplayer):void {
            log.info("onLoad()");

            _player = player;

            _player.playlist.onSwitch(function(event:ClipEvent):void {
                //#367 new httpstreaming logic switches automatically on startup, need to check for existence of the manual switch manager.
                if (!_streamSwitchManager) return;
                log.debug("new item is " + _streamSelectionManager.currentBitrateItem + ", current " + _streamSwitchManager.previousBitrateItem);
                Clip(event.target).setCustomProperty("bitrate", _streamSelectionManager.currentBitrateItem.bitrate);
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitchBegin", _streamSelectionManager.currentBitrateItem, _streamSwitchManager.previousBitrateItem);
            });

            _player.playlist.onSwitchFailed(function(event:ClipEvent):void {
                log.debug("Transition failed with error " + event.info2.toString());
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitchFailed", "Transition failed with error " + event.info2.toString());
            });

            _player.playlist.onSwitchComplete(function(event:ClipEvent):void {
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitch", _streamSelectionManager.currentBitrateItem);
            });

            //#418 add a filter for clip start events when bitrateselect is not configured as a resolver.
            _player.playlist.onStart(function(event:ClipEvent):void {
                var clip:Clip = event.target as Clip;
                init(clip.getNetStream(), clip);
                initSwitchManager();

                log.debug("onStart() hd available? " + hasHD);

                dispatchEvent(new HDEvent(HDEvent.HD_AVAILABILITY, hasHD));

                //#577 toggle splash on all hd notifications not just defaults and when the menu is not set.
                if (hasHD && !_config.menu) {
                    toggleSplash(_streamSelectionManager.currentBitrateItem);
                }

                Clip(event.target).setCustomProperty("bitrate", _streamSelectionManager.currentBitrateItem.bitrate);

                if (_config.menu) {
                    initBitrateMenu(clip);
                    if (_menuPlugin) {
                        _menuPlugin.enableItems(true, _menuItems);
                    }
                }

            }, applyForClip);

            if (_config.hdButton.docked) {
                createIconDock();	// we need to create the controller pretty early else it won't receive the HD_AVAILABILITY event
                _player.onLoad(function(event:PlayerEvent):void {
                    _iconDock.addToPanel();
                });
            }

            //#584 make the controls plugin name configurable.
            var controlbar:*;
            if (_config.hdButton.controls) {
                controlbar = player.pluginRegistry.plugins[_config.controlsPlugin];
                controlbar.pluginObject.addEventListener(WidgetContainerEvent.CONTAINER_READY, addHDButton);
            }

            //#563 if the menu plugin is configured disable the menu button on startup.
            if (_config.menu) {
                controlbar = player.pluginRegistry.plugins[_config.controlsPlugin];
                controlbar.pluginObject.addEventListener(WidgetContainerEvent.CONTAINER_READY, function(event:WidgetContainerEvent):void {
                    _menuPlugin = lookupMenu();
                    //disable the menu button widget
                    if (_menuPlugin) _menuPlugin.menuButtonController.view.enabled = false;
                });
            }

            _model.dispatchOnLoad();
        }


        //#488 regression with #r1764 filter onStart events to only work with bitrateselect configured clips. Problem when autobuffering with playlst splash images.
        private function applyForClip(clip:Clip):Boolean {
            log.debug("applyForClip(), clip.urlResolvers == " + clip.urlResolvers);
            if (clip.urlResolvers == null) return false;
            var apply:Boolean = clip.urlResolvers.indexOf(_model.name) >= 0;
            log.debug("applyForClip? " + apply);
            return apply;
        }

        private function addHDButton(event:WidgetContainerEvent):void {
            var container:WidgetContainer = event.container;
            var controller:HDToggleController = new HDToggleController(false, this);
            container.addWidget(controller, "volume", false);
        }

        private function createIconDock():void {
            if (_iconDock) return;
            _iconDock = Dock.getInstance(_player);
            _iconDock.config.scaleWidthAndHeight = true;
            var controller:HDToggleController = new HDToggleController(true, this);

            // dock should do that, v3.2.7 maybe :)
            _hdButton = controller.init(_player, _iconDock, new ToggleButtonConfig(_config.iconConfig, _config.iconConfig)) as ToggleButton;
            _iconDock.addIcon(_hdButton);
            _iconDock.addToPanel();
        }

        private function initBitrateMenu(clip:Clip):void {
            // is the menu already showing the bitrates for this clip
            if (_menuShowsBitratesFor == clip) {
                log.debug("initBitrateMenu(), already showing bitrates for this clip, returning");
                return;
            }

            var items:Vector.<BitrateItem> = Vector.<BitrateItem>(clip.getCustomProperty("bitrateItems"));
            if (! items) {
                log.debug("initBitrateMenu(), no bitrateItems available in clip, cannot initialize the menu");
            }

            if (! _menuPlugin) {
                _menuPlugin = lookupMenu();
                if (! _menuPlugin) return;
            }

            // remove items corresponding to the previous clip
            if (_menuItems) {
                _menuPlugin["removeItems"](_menuItems, false);
                log.debug("initBitrateMenu(), removed old items at indexes: " + _menuItems.toString() + ", items left in menu " + _menuPlugin["length"]);
            }

            _menuItems = [];


            for (var i:Number = items.length - 1; i >= 0; i--) {
                var item:BitrateItem = items[i];

                _menuItems.push(_menuPlugin["addItem"](
                        {
                            selectedCallback: function(menuItem:Object):void {
                                log.debug("switching to bitrate " + menuItem.getCustomProperty("bitrateItem").bitrate);
                                _streamSwitchManager.switchStream(menuItem.getCustomProperty("bitrateItem"));
                            },
                            //#586 set a default menu label to the bitrate with a k postfix if the bitrate label is not set.
                            label: item.label ? item.label : item.bitrate + "k",
                            enabled: false,
                            toggle: true,
                            //get the resolved mapped bitrate and set the selected item
                            selected: _streamSelectionManager.currentBitrateItem.bitrate == item.bitrate,
                            bitrateItem: item,
                            group: "bitrate"
                         }, items.indexOf(item) == 0));
            }
            log.debug("initBitrateMenu(), new menu item indexes: " + _menuItems.toString() + ", the menu has " + _menuPlugin["length"] + " items");
            _menuShowsBitratesFor = clip;

            _menuPlugin.menuButtonController.view.enabled = true;
        }

        private function lookupMenu():Object {
            log.debug("lookupMenu()");
            var model:PluginModel = _player.pluginRegistry.getPlugin(_config.menuPluginName) as PluginModel;
            if (! model) {
                _model.dispatchError(PluginError.INIT_FAILED, "cannot find menu plugin with name '" + _config.menuPluginName + "'");
                return null;
            }
            return model.pluginObject;
        }

        public function get hasHD():Boolean {
            //#563 fix when using bitrateselect with the bwcheck plugin
            return (_streamSelectionManager.bitrateResource is HDBitrateResource
                    && HDBitrateResource(_streamSelectionManager.bitrateResource).hasHD
            );
        }

        public function set hd(enable:Boolean):void {
            if (! hasHD) return;
            log.info("set HD, switching to " + (enable ? "HD" : "normal"));

            var newItem:BitrateItem = _player.playlist.current.getCustomProperty(enable ? "hdBitrateItem" : "sdBitrateItem") as BitrateItem;
            _streamSwitchManager.switchStream(newItem);

            setHDNotification(enable);
        }

        private function setHDNotification(enable:Boolean):void {
            _hdEnabled = enable;
            dispatchEvent(new HDEvent(HDEvent.HD_SWITCHED, _hdEnabled));
            if (_config.hdButton.splash) {
                displayHDNotification(enable);
            }

        }

        private function displayHDNotification(enable:Boolean):void {
            var symbol:HDSymbol = new HDSymbol();
            symbol.hdText.text = enable ? _config.hdButton.onLabel : _config.hdButton.offLabel;
            symbol.hdText.width = symbol.hdText.textWidth + 26;
            Arrange.center(symbol.hdText, symbol.width);
            Arrange.center(symbol.hdSymbol, symbol.width);
            var notification:Notification = Notification.createDisplayObjectNotification(_player, symbol);
            notification.show(_config.hdButton.splash).autoHide(1200);
        }

        private function alreadyResolved(clip:Clip):Boolean {
            return clip.getCustomProperty("bitrateResolvedUrl") != null;
        }

        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {

            if (!clip.getCustomProperty("bitrates") && !clip.getCustomProperty("bitrateItems")) {
                log.debug("Bitrates configuration not enabled for this clip");
                successListener(clip);
                return;
            }


            if (alreadyResolved(clip)) {
                log.debug("resolve(): bitrate already resolved for clip " + clip + ", will not detect again");
                successListener(clip);
                return;
            }

            _provider = provider;
            _resolveSuccessListener = successListener;

            init(provider.netStream, clip);

            var mappedBitrate:BitrateItem = _streamSelectionManager.getMappedBitrate(-1);
            _streamSelectionManager.changeStreamNames(mappedBitrate);

            _resolveSuccessListener(_clip);
        }

        private function init(netStream:NetStream, clip:Clip):void {
            log.debug("init(), netStream == " + netStream);

            _netStream = netStream;
            _clip = clip;
            _start = netStream ? netStream.time : 0;
            initStreamSelectionManager(clip);
        }

        private function initStreamSelectionManager(clip:Clip):void {
            log.debug("initStreamSelectionManager()");


            if (! clip.getCustomProperty("streamSelectionManager")) {
                _streamSelectionManager = new StreamSelectionManager(new HDBitrateResource(), _player, this);
                clip.setCustomProperty("streamSelectionManager", _streamSelectionManager);
            } else {
                _streamSelectionManager = clip.getCustomProperty("streamSelectionManager") as IStreamSelectionManager;
            }
        }

        private function initSwitchManager():void {
            _streamSwitchManager = new StreamSwitchManager(_netStream, _streamSelectionManager, _player);
        }

        private function toggleSplash(mappedBitrate:BitrateItem):void {
            setHDNotification(mappedBitrate.hd);
        }

        [External]
        public function get hd():Boolean {
            return _hdEnabled;
        }

        private function checkCurrentClip():Boolean {
            var clip:Clip = _player.playlist.current;
            if (_clip == clip) return true;

            if (clip.urlResolvers && clip.urlResolvers.indexOf(_model.name) < 0) {
                return false;
            }
            _clip = clip;
            return true;
        }

        [External]
        public function setBitrate(bitrate:Number):void {
            log.debug("set bitrate()", bitrate);
            if (! checkCurrentClip()) return;

            if (_player.isPlaying() || _player.isPaused() && _streamSwitchManager) {

                var bitrateItem:BitrateItem = _streamSelectionManager.getStream(bitrate) as BitrateItem;

                //#563 if the menu plugin is set, select the item in the list
                if (_menuPlugin) {
                    _menuPlugin.selectItemInGroup(bitrateItem.index, "bitrate");
                    _menuPlugin.visible = false;
                }

                _streamSwitchManager.switchStream(bitrateItem);
            }
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
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
