/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.config {
    import flash.utils.describeType;

    import org.flowplayer.controls.buttons.SliderConfig;
    import org.flowplayer.controls.scrubber.ScrubberConfig;
    import org.flowplayer.controls.scrubber.ScrubberController;
    import org.flowplayer.controls.time.TimeViewConfig;
    import org.flowplayer.controls.time.TimeViewController;
    import org.flowplayer.controls.volume.VolumeController;
    import org.flowplayer.ui.AutoHideConfig;
    import org.flowplayer.ui.buttons.ToggleButtonConfig;
    import org.flowplayer.ui.buttons.TooltipButtonConfig;
    import org.flowplayer.ui.controllers.*;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.StyleSheetUtil;
    import org.flowplayer.view.Flowplayer;

    /**
	 * @author api
	 */
	public class Config {
		private var log:Log = new Log(this);
        private var _player:Flowplayer;
		private var _skin:String;
		private var _style:Object = {};
		private var _bgStyle:Object = {};
        private var _autoHide:AutoHideConfig;

		private var _availableWidgets:Array = [];

		private var _enabled:WidgetsEnabledStates = null;
		private var _visible:WidgetsVisibility = null;
		private var _tooltips:ToolTipsConfig = null;
        private var _spacing:WidgetsSpacing = null;

        public function Config() {
            _autoHide = new AutoHideConfig();
        }
		// base guy
		public function get style():Object {
			return _style;
		}

		public function clone():Config {
			var conf:Config = new Config();
			conf.setNewProps(_style);
			conf.availableWidgets = _availableWidgets;

			return conf;
		}

		public function set availableWidgets(widgetControllers:Array):void {
			_availableWidgets = widgetControllers;

			_visible  = new WidgetsVisibility(_style, widgetControllers);
			_tooltips = new ToolTipsConfig(_style['tooltips'], widgetControllers);
			_enabled  = new WidgetsEnabledStates(_style['enabled'], widgetControllers);
			_spacing  = new WidgetsSpacing(_style['spacing'], widgetControllers);
		}

		public function setNewProps(props:Object):void {
			log.debug("settin new props", props);
			handleAllProperty(props);

			_style = _setNewProps(props, _style);


			availableWidgets = _availableWidgets;
			_bgStyle = _style;
			
		}
		
		// some special code to handle setWidgets({all:true}) and setEnabled({all: true}) that must wipe out the existing values
		// instead of setting default values
		private function handleAllProperty(newProps:Object):void {
			var props:Object = null;
			if ( newProps['all'] != undefined )
				props = _style;
			else if ( newProps['enabled'] != undefined && newProps['enabled']['all'] != undefined )
				props = _style['enabled'];
				
			if ( ! props ) return;
				
			for ( var i:int = 0; i < _availableWidgets.length; i++ ) {

                //#505 if new properties does not contain a widget unset it.
                if (newProps[_availableWidgets[i]['name']] == undefined) {
				    log.debug("deleting "+_availableWidgets[i]['name']);
				    delete props[_availableWidgets[i]['name']];
                }

                //#505 if new properties does not contain a group widget, ie playlist group is next and previous buttons,  unset it.
				if ( _availableWidgets[i]['groupName'] && newProps[_availableWidgets[i]['groupName']] == undefined) {
					log.debug("deleting group "+_availableWidgets[i]['groupName']);
					delete props[_availableWidgets[i]['groupName']];
				}
			}
		}
		
		private function _setNewProps(newProps:Object, oldProps:Object):Object {
			var dest:Object = oldProps;

            if (needsRecursing(newProps) && ! needsRecursing(dest)) {
                dest = newProps;
                return dest;
            }

			for ( var name:String in newProps ) {
                if (! needsRecursing(newProps[name])) {
					dest[name] = newProps[name] == null ? false : newProps[name];
                    log.debug("copying in "+ newProps[name] + " in " + name + ", new value is now " + dest[name]);
                }
				else {
					log.debug("recursing in "+ name);
					dest[name] = oldProps[name] != undefined ? _setNewProps(newProps[name], oldProps[name]) : newProps[name];
				}
			}
			
			return dest;
		}

        private function needsRecursing(newVal:*):Boolean {
            return ! (newVal == null || newVal is Number || newVal is String || newVal is Boolean);
        }
			
		public function completeStyleProps(styleProps:Object):Object {
			for (var name:String in _style) {
			//	log.error("Merging back "+ name + " = "+ styleProps[name]);
				styleProps[name] = _style[name];
			}
			
			return styleProps;
		}
		
		
		public function get bgStyle():Object {
			return _bgStyle;
		}

		public function get margins():Array {
			return _style['margins'] || [0, 0, 0, 0];
		}
		
		private function fixBorder(prefix:String, defaultWidth:Number = 0, defaultColor:Number = 0x000000, defaultAlpha:Number = 1):String {
			
			var width:Number = StyleSheetUtil.borderWidth(prefix, _style, defaultWidth);
			var color:Array  = StyleSheetUtil.rgbValue(StyleSheetUtil.borderColor(prefix, _style, defaultColor));
			color.push(StyleSheetUtil.borderAlpha(prefix, _style, defaultAlpha));
			
			var str:String = width + 'px solid rgba(';
			for ( var i:int = 0; i < color.length; i++ ) str+= (i ? ', ' : '') + color[i];
			str += ')';
			
			//log.debug("Border for "+ prefix + " "+ str);
			
			return str;			
		}
	
		private function decodeGradient(value:Object, defVal:String = "medium"):Array {
			if (! value) return decodeGradient(defVal);
			if (value is Array) return value as Array;
			if (value == "none") return null;
			if (value == "high") return [.1, 0.5, .1];
			if (value == "medium") return [0, .25, 0];
			return decodeGradient(defVal);
		}



		public function get timeConfig():TimeViewConfig {
			var config:TimeViewConfig = new TimeViewConfig();
			config.setBackgroundColor(_style["timeBgColor"]);
			config.setBorder(fixBorder('timeBorder'));
			config.setBorderRadius(_style['timeBorderRadius'])
			config.setDurationColor(_style['durationColor']);
			config.setFontSize(_style['timeFontSize'] || 0);
			config.setHeightRatio(_style['timeBgHeightRatio']);
			config.setSeparator(_style['timeSeparator'] || "/");
			config.setTimeColor(_style['timeColor']);

			return config;
		}

		public function get scrubberConfig():ScrubberConfig {
			var config:ScrubberConfig = new ScrubberConfig();

			config.setBufferColor(_style['bufferColor']);
			config.setBufferGradient(decodeGradient(_style['bufferGradient']));
			config.setColor(_style['progressColor']);
			config.setBackgroundGradient(decodeGradient(_style['sliderGradient']));
			config.setBackgroundColor(_style['sliderColor']);
			config.setGradient(decodeGradient(_style['progressGradient']));
			config.setBufferGradient(decodeGradient(_style['bufferGradient']))
			config.setBarHeightRatio(_style['scrubberBarHeightRatio']);
            config.setDisabledColor(_style['disabledWidgetColor']);

			var draggerConfig:TooltipButtonConfig = buttonConfig;
			draggerConfig.setTooltipEnabled(tooltips.scrubber);	
			config.setDraggerButtonConfig(draggerConfig);
			
			config.setBorder(fixBorder('sliderBorder'));
			config.setBorderRadius(_style['scrubberBorderRadius']);
			config.setHeightRatio(_style['scrubberHeightRatio']);

			return config;
		}

		public function get volumeConfig():SliderConfig {
			var config:SliderConfig = new SliderConfig();

			config.setBarHeightRatio(_style['volumeBarHeightRatio']);
			
			var draggerConfig:TooltipButtonConfig = buttonConfig;
			draggerConfig.setTooltipEnabled(tooltips.volume);
					
			config.setDraggerButtonConfig(draggerConfig);
			
			config.setBackgroundColor(_style['volumeSliderColor']);
			config.setBackgroundGradient(decodeGradient(_style['volumeSliderGradient']));
            config.setDisabledColor(_style['disabledWidgetColor']);

 			config.setColor(_style['volumeColor'] || _style['volumeSliderColor']);
			config.setGradient(decodeGradient(_style['sliderGradient'] || _style['volumeSliderGradient'] ));
			
			config.setBorder(fixBorder('volumeBorder'));
			config.setBorderRadius(_style['volumeBorderRadius']);
			config.setHeightRatio(_style['volumeSliderHeightRatio']);
			return config;
		}

		public function get buttonConfig():TooltipButtonConfig {
			var config:TooltipButtonConfig = new TooltipButtonConfig();
            config.setColor(_style['buttonColor']);
            config.setDisabledColor(_style['disabledWidgetColor']);
            config.setOverColor(_style['buttonOverColor']);

            config.setOffColor(_style['buttonOffColor']);
            config.setOnColor(_style['buttonColor']);

			config.setTooltipColor(_style['tooltipColor']);
			config.setTooltipTextColor(_style['tooltipTextColor']);
			
			return config;
		}
	
		public function getButtonConfig(name:String = null):TooltipButtonConfig {
			var config:TooltipButtonConfig = buttonConfig;
			config.setTooltipEnabled(tooltips.buttons);
			config.setTooltipLabel(tooltips[name]);
			
			return config;
		}
	
	
		public function getWidgetConfiguration(controller:Object):Object {
			if ( controller is VolumeController ) {
				return volumeConfig;
			}
			else if ( controller is ScrubberController ) {
				return scrubberConfig;
			}
			else if ( controller is TimeViewController ) {
				return timeConfig;
			}
			// this needs to be before the AbstractButtonController
			else if ( controller is AbstractToggleButtonController ) {
				return new ToggleButtonConfig(
								getButtonConfig(controller.name), 
								getButtonConfig((controller as AbstractToggleButtonController).downName));
			}
			else if ( controller is AbstractButtonController ) {
				return getButtonConfig(controller.name);
			}
			else {
				log.warn("Unknown widget "+ controller);
			}
			
			return null;
		}
					
        [Value]
		public function get visible():WidgetsVisibility {
			return _visible;
		}
		
        [Value]
		public function get enabled():WidgetsEnabledStates {
			return _enabled;
		}
		
        [Value]
		public function get tooltips():ToolTipsConfig {
			return _tooltips;
		}

		[Value]
        public function get spacing():WidgetsSpacing {
			return _spacing;
        }
  
		 [Value]
			public function get skin():String {
				return _skin;
			}

			public function set skin(skin:String):void {
				_skin = skin;
			}

        [Value]
        public function get autoHide():AutoHideConfig {
            return _autoHide;
        }

        public function setAutoHide(value:Object):void {
            if (value is String) {
                _autoHide.state = value as String;
            }
            if (value is Boolean) {
                _autoHide.enabled = value as Boolean;
                _autoHide.fullscreenOnly = ! value;
            }
        }
		
		// some backward compatibility
		public function set hideDelay(value:Number):void
		{
			_autoHide.hideDelay = value;
		}
		
		public function get hideDelay():Number
		{
			return _autoHide.hideDelay;
		}
    }
}
