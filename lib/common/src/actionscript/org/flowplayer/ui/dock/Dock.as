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
package org.flowplayer.ui.dock {
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.ui.*;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;

    import flash.accessibility.Accessibility;

    public class Dock extends AbstractSprite {
        private static const SCROLLBUTTON_HEIGHT:Number = 20;
//        private static var log:Log = new Log("org.flowplayer.ui::Dock");
        public static const DOCK_PLUGIN_NAME:String = "dock";
        private var _icons:Array = [];
        private static var _player:Flowplayer;
        private var _config:DockConfig;
        private var _autoHide:AutoHide;
        private var _mask:Sprite;
        private var _iconStrip:Sprite;
        private var _upScroll:UpButton;
        private var _downScroll:DownButton;
        private var _topIndex:int = 0;
        private var _isPlugin:Boolean;

        /**
         * Creates a new dock.
         * @param player
         * @param config
         * @param pluginName the name used when binding the dock to the plugin registry
         */
        public function Dock(player:Flowplayer, config:DockConfig, pluginName:String = null) {
            _iconStrip = new Sprite();
            addChild(_iconStrip);
            _player = player;

            if (pluginName) {
                _isPlugin = true;
                if (player.config.configObject.hasOwnProperty("plugins") && player.config.configObject["plugins"].hasOwnProperty(pluginName)) {
                    var dockConfigObj:Object = player.config.configObject["plugins"][pluginName];
                    _config = new PropertyBinder(config || new DockConfig()).copyProperties(dockConfigObj, true) as DockConfig;
                    new PropertyBinder(_config.model).copyProperties(dockConfigObj);
                    
                } else {
                    _config = config || new DockConfig();
                }
                _config.model.setDisplayObject(this);
                _config.model.name = pluginName;
                player.pluginRegistry.registerDisplayPlugin(_config.model, this);
            } else {
                _config = config || new DockConfig();
            }
            if (_config.scrollable) {
                addMask();
            }
            if (_config.scrollable) {
                createScrollButtons();
                _iconStrip.y = SCROLLBUTTON_HEIGHT;
            }
        }

        /**
         * Gets an instance of the Dock. If an instance already exists in the specified player, this instance is returned.
         * If there is not an existing instance already created a new one is created and registered to the PluginRegistry
         * under name "dock".
         * @param player
         */
        public static function getInstance(player:Flowplayer, config:DockConfig = null):Dock {
            var plugin:DisplayProperties = player.pluginRegistry.getPlugin(DOCK_PLUGIN_NAME) as DisplayProperties;
            if (! plugin) {
                return new Dock(player, config, DOCK_PLUGIN_NAME);
            }
            return plugin.getDisplayObject() as Dock;
        }

        /**
         * Adds an icon to the dock.
         * @param icon
         * @param id
         */
        public function addIcon(icon:DisplayObject, id:String = null):void {
            _icons.push(icon);
            _iconStrip.addChild(icon);
            onResize();
        }

        /**
         * Removes the specified icon from the dock.
         * @param icon
         */
        public function removeIcon(icon:DisplayObject):void {
            _icons.splice(_icons.indexOf(icon), 1);
            _iconStrip.removeChild(icon);
            onResize();
        }

        /**
         * Gets the icons that have been added to this dock.
         */
        public function get icons():Array {
            return _icons;
        }

        public function addToPanel():void {
            log.debug("addToPanel()");
            _player.panel.addView(this, null, _config.model);

            //#479 check if autoHide is configured as false as well as an object.
            if (_autoHide || !_config.autoHide || !_config.autoHide.enabled) return;

            log.debug("addToPanel(), creating autoHide with config", _config.autoHide);
            createAutoHide();
        }

        public function startAutoHide():void {
            createAutoHide();
            _autoHide.start();
        }

        private function createAutoHide():void {
            if (! _autoHide) {
                //#443 disable autohide for accessibility support
                if (Accessibility.active) _config.autoHide.enabled = false;
                _autoHide = new AutoHide(_config.model, _config.autoHide, _player, stage, this);
            }
        }

        public function stopAutoHide(leaveVisible:Boolean = true):void {
            createAutoHide();
            _autoHide.stop(leaveVisible);
        }

        //#60 add helper methods to hide / show the dock when autohide is enabled or not.
        [External]
        public function show():void {
            if (_config.autoHide.enabled)
                startAutoHide()
            else
                _player.animationEngine.fadeIn(this);
        }

        [External]
        public function hide():void {
            if (_config.autoHide.enabled)
                stopAutoHide(false);
            else
                _player.animationEngine.fadeOut(this);
        }


        public function cancelAnimation():void {
            _autoHide.cancelAnimation();
        }

        private function resizeIcons():void {
            _icons.forEach(function(iconObj:Object, index:int, array:Array):void {
                var icon:DisplayObject = iconObj as DisplayObject;
                var scaleFactor:Number = icon.height/icon.width;
                if (_config.horizontal) {
                    icon.height = height;
                    if (_config.scaleWidthAndHeight) {
                        icon.width  = height * scaleFactor;
                    }
                }
                else {
                    icon.width  = width;
                    if (_config.scaleWidthAndHeight) {
                        icon.height = width / scaleFactor;
                    }
                }
                log.debug("resizeIcons() icon " + index + ": " + Arrange.describeBounds(icon));
            }, this);
        }

        private function arrangeIcons():void {
            var nextPos:Number = 0;
            _icons.forEach(function(iconObj:Object, index:int, array:Array):void {
                var icon:DisplayObject = iconObj as DisplayObject;
                log.debug("arrangeIcons() icon " + index + ": " + Arrange.describeBounds(icon) + " gap " + _config.gap);
                if (_config.horizontal) {
                    icon.x = nextPos;
                    icon.y = 0;
                    nextPos += icon.width + _config.gap;
                } else {
                    icon.y = nextPos;
                    icon.x = 0;
                    nextPos += icon.height + _config.gap;
                }
            }, this);
        }

        override protected function onResize():void {
            if (_icons.length == 0) return;

            resizeIcons();
            arrangeIcons();

            if (_config.scrollable) {
                _upScroll.width = _downScroll.width = width;
                _upScroll.height = _downScroll.height = SCROLLBUTTON_HEIGHT;

                _upScroll.y = 0;
                _downScroll.y = height - _downScroll.height;
            } else {
                // set the managed size based on the last icon's position and size

                var lastIcon:DisplayObject = _icons[_icons.length - 1];
                if (_config.horizontal) {
                    _width = lastIcon.x + lastIcon.width;
                    _config.model.width = _width;
                } else {
                    _height = lastIcon.y + lastIcon.height;
                    _config.model.height = _height;
                    log.debug("setting height to " + _height)
                }

                if (_isPlugin) {
                    _player.pluginRegistry.update(_config.model);
                }
            }
            if (_config.scrollable) {
                redrawMask();
            }
        }

        public function onShow(callback:Function):void {
            if (!_autoHide) return;
            _autoHide.onShow(callback);
        }

        public function onHide(callback:Function):void {
            //#479 check if autoHide is enabled
            if (! _autoHide) return;
            _autoHide.onHide(callback);
        }

        public function get config():DockConfig {
            return _config;
        }

        private function createScrollButtons():void {
            _upScroll = new UpButton(_config.upButtonStyle, _config.upButtonConfig, _player.animationEngine);
            _upScroll.enabled = false;
            addChild(_upScroll);
            _downScroll = new DownButton(_config.downButtonStyle, _config.downButtonConfig, _player.animationEngine);
            addChild(_downScroll);

            _upScroll.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                if (! _upScroll.enabled) return;

                if (_iconStrip.y < SCROLLBUTTON_HEIGHT) {
                    var increment:Number = DisplayObject(_icons[_topIndex--]).height;
                    if (_iconStrip.y + increment >= SCROLLBUTTON_HEIGHT) {
                        _topIndex = 0;
                        _upScroll.enabled = false;
                    }
                    _downScroll.enabled = true;
                    _player.animationEngine.animateProperty(_iconStrip, "y", Math.min(SCROLLBUTTON_HEIGHT, _iconStrip.y + increment));
                }
            });
            _downScroll.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                if (! _downScroll.enabled) return;

                var minY:Number = -_iconStrip.height+(height-SCROLLBUTTON_HEIGHT);
                if (_iconStrip.y > minY) {
                    var decrement:Number = DisplayObject(_icons[_topIndex++]).height;
                    if (_iconStrip.y - decrement <= minY) {
                        _downScroll.enabled = false;
                    }
                    _upScroll.enabled = true;
                    _player.animationEngine.animateProperty(_iconStrip, "y", Math.max(minY, _iconStrip.y - decrement));
                }
            });
        }

        private function addMask():void {
            log.debug("addMask()");
            if (_mask) return;
            _mask = addChild(new Sprite()) as Sprite;
            this.blendMode = BlendMode.LAYER;
            _mask.blendMode = BlendMode.ERASE;
            _icons.forEach(function(iconObj:Object, index:int, array:Array):void {
                var icon:DisplayObject = iconObj as DisplayObject;
//                icon.mask = mask;
            });
            _iconStrip.mask = _mask;
        }

        private function redrawMask():void {
            var graf:Graphics = _mask.graphics;
            graf.clear();

            graf.beginFill(0, 1);

            if (_config.scrollable) {
                graf.drawRect(0, SCROLLBUTTON_HEIGHT, width, height-2*SCROLLBUTTON_HEIGHT);
            } else {
                graf.lineTo(width-5, 0);
                graf.curveTo(width, 0, width, 5);
                graf.lineTo(width,  height-5);
                graf.curveTo(width,  height, width-5, height);
                graf.lineTo(5, height);
                graf.curveTo(0, height,  0, height-5);
                graf.lineTo(0, 5);
                graf.curveTo(0, 0, 5, 0);
            }

//            graf.moveTo(0, -500);
//            graf.lineTo(0, 5);
//            graf.curveTo(0, 0, 5, 0);
//            graf.lineTo(width-5, 0);
//            graf.curveTo(width, 0, width, 5);
//            graf.lineTo(width, -500);
//            graf.lineTo(0, -500);
//
//            graf.moveTo(0, height-5);
//            graf.curveTo(0, height, 5, height);
//            graf.lineTo(width-5, height);
//            graf.curveTo(width, height, width, height-5);
//            graf.lineTo(width, height+500);
//            graf.lineTo(0, height+500);
//            graf.lineTo(0, height-5);

            graf.endFill();
        }
    }
}
