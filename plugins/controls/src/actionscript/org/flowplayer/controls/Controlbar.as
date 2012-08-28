/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */


package org.flowplayer.controls {
   
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.view.StyleableSprite;
	import org.flowplayer.view.Flowplayer;
		
	import org.flowplayer.util.Arrange;	
		
	import org.flowplayer.ui.buttons.ConfigurableWidget;
	import org.flowplayer.ui.buttons.ToggleButtonConfig;
	import org.flowplayer.ui.buttons.WidgetDecorator;
	import org.flowplayer.ui.buttons.ButtonDecorator;
	
	import org.flowplayer.ui.controllers.AbstractWidgetController;
	import org.flowplayer.ui.controllers.AbstractButtonController;
	
	import org.flowplayer.controls.config.Config;
	import org.flowplayer.controls.controllers.*;
	import org.flowplayer.controls.time.TimeViewController;
	import org.flowplayer.controls.scrubber.ScrubberController;
	import org.flowplayer.controls.volume.VolumeController;
	
	import flash.utils.*
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	
    public class Controlbar extends StyleableSprite {
		
		private var _widgetControllers:Dictionary;		

        private var _config:Config;
        private var _immediatePositioning:Boolean = true;
        private var _animationTimer:Timer;
        private var _player:Flowplayer;
		
		// #71, need to have a filled sprite who takes all the space to get events to work
		private var _bgFill:Sprite;
		
		
		private var _widgetsOrder:Array = [];
		// private const SCRUBBER:String = "scrubber";
		private var _centeredWidget:String = "scrubber";
		
		
        public function Controlbar(player:Flowplayer, config:Config) {
			_player = player;
			_config = config;
		
            this.visible = false;
			_widgetControllers = new Dictionary();

            loader = _player.createLoader();
            rootStyle = _config.bgStyle;
			_bgFill = new Sprite();
			addChild(_bgFill);

            createChildren();
        }
	
		public function addWidget(	controller:AbstractWidgetController, after:String = null, 
									animated:Boolean = true, decorated:Boolean = true):void 
		{
			var index:int = _widgetsOrder.indexOf(after) + 1;
				
			_widgetsOrder.splice(index, 0, controller.name);
			addController(controller, decorated);
			updateAvailableWidgets();
			
			configure(_config, animated);
		}
		
	
		private function addController(controller:AbstractWidgetController, decorate:Boolean = true):void {	
			
			controller.init(_player, this, _config.getWidgetConfiguration(controller));
			if ( decorate )
				decorateWidget(controller);
			
			controller.view.visible = false;
			
			_widgetControllers[controller.name] = controller;
		}

		private function decorateWidget(controller:AbstractWidgetController):void {
			if ( controller is AbstractButtonController )
				controller.decorator = new ButtonDecorator( SkinClasses.getDisplayObject("fp.ButtonTopEdge"), 
															SkinClasses.getDisplayObject("fp.ButtonRightEdge"), 
															SkinClasses.getDisplayObject("fp.ButtonBottomEdge"), 
															SkinClasses.getDisplayObject("fp.ButtonLeftEdge"));

		}
		
		public function getWidget(name:String):AbstractWidgetController {
			return _widgetControllers[name];
		}

        private function createChildren():void {
            //log.info("creating createChildren ", _config);

			// call addWidget in reverse order so we add widgets at the beginning
			addWidget(new ToggleFullScreenButtonController(), null, false);
			addWidget(new VolumeController(), null, false);
			addWidget(new ToggleMuteButtonController(), null, false);
			addWidget(new TimeViewController(), null, false);
			addWidget(new ScrubberController(), null, false);
			addWidget(new NextButtonController(), null, false);
			addWidget(new PrevButtonController(), null, false);
			addWidget(new TogglePlayButtonController(), null, false);
			addWidget(new StopButtonController(), null, false);

			// now that we have registered all our controllers, clear config cache
			updateAvailableWidgets();
        }

		private function updateAvailableWidgets():void {
			var widgets:Array = [];
			for ( var i:String in _widgetControllers )
				widgets.push(_widgetControllers[i]);
								
			_config.availableWidgets = widgets;
		}

		public function configure(config:Config, animation:Boolean = false):void {
			_config = config;
            rootStyle = config.bgStyle;
			
			immediatePositioning = ! animation;
			
			for ( var i:String in _widgetControllers ) {
				var widgetConfig:Object = _config.getWidgetConfiguration(_widgetControllers[i]);
			//	log.info("Got config for widget " + i, widgetConfig);
				_widgetControllers[i].configure(widgetConfig);
			}
			
			enableWidgets();
			
			updateWidgetsVisibility();
			
			onResize();

			immediatePositioning = true;
		}
		
		public function get config():Config {
			return _config;
		}
	
		/** Visibility stuff **/
		
		private function enableWidgets():void {
			for ( var i:String in _widgetControllers ) {
				_widgetControllers[i].view.enabled = _config.enabled[i];
			}
        }
		
		private function updateWidgetsVisibility():void {
			
			for ( var name:String in _widgetControllers ) {
				var view:ConfigurableWidget = _widgetControllers[name].view;
				var show:Boolean = _config.visible[name];
				
				//	log.debug("Getting visibility for " + name + " "+ show);
				
				// remove it
				if ( contains(view) && ! show ) {
					log.debug("Removing "+ name)
					removeChildAnimate(view);
				} else if ( ! contains(view) && show ) {
					// add it
					log.debug("Adding "+ name);
					resetView(view);
					addChild(view);
				}
			}

		}
		
		private function resetView(view:DisplayObject):void {
			
			log.info("resetView " + (view as ConfigurableWidget).name);
			
			_player.animationEngine.cancel(view);
			view.visible = false;
			view.x = view.y = 0;
			view.scaleX = view.scaleY = 1;
			view.alpha = 1;
		}

        private function removeChildAnimate(child:DisplayObject):DisplayObject {
            if (! _player || _immediatePositioning) {
                removeChild(child);
				resetView(child);
                return child;
            }

            _player.animationEngine.fadeOut(child, 1000, function():void {
                removeChild(child);
				resetView(child);
            });
            return child;
        }


		/* Widgets positionning stuff */
		
		 /**
         * Rearranges the buttons when size changes.
         */
        override protected function onResize():void {
            log.debug("arranging, width is " + width);

			_bgFill.graphics.clear();
			_bgFill.graphics.beginFill(0, 0);
			_bgFill.graphics.drawRect(0, 0, width, height);
			_bgFill.graphics.endFill();


			rearrangeWidgets();

			// TODO: Check me
			//_volumeSlider.initializeVolume();
            log.debug("arranged to x " + this.x + ", y " + this.y);
        }

        /**
         * Makes this visible when the superclass has been drawn.
         */
        override protected function onRedraw():void {
            log.debug("onRedraw, making controls visible");
            this.visible = true;
        }
		
		// not sure why we need this guy ?
		public function get animationTimerRunning():Boolean {
			return _animationTimer && _animationTimer.running;
		}


        private function set immediatePositioning(enable:Boolean):void {
            _immediatePositioning = enable;
            if (! enable) return;

			// not sure to know what this is about
            _animationTimer = new Timer(500, 1);
            _animationTimer.start();
        }
		
		
		private function rearrangeWidgets():void {
			
			var leftWidgets:Array = _widgetsOrder.slice(0, _widgetsOrder.indexOf(_centeredWidget));
			var rightWidgets:Array = _widgetsOrder.slice(_widgetsOrder.indexOf(_centeredWidget) + 1);
			
			if ( _config.visible[_centeredWidget] ) {
				var leftEdge:Number  = arrangeWidgets(leftWidgets);
				var rightEdge:Number = arrangeWidgets(rightWidgets, true);
				
			//	arrangeScrubber(leftEdge, rightEdge);
				arrangeWidget(leftEdge, rightEdge);
			} else {
				arrangeWidgets(_widgetsOrder);
			}
			
		}
		
		private function arrangeWidgets(widgets:Array, reverse:Boolean = false):Number {
			widgets = reverse ? widgets.reverse() : widgets;
			var x:Number = reverse ? width : margins[3];
			
			for ( var i:int = 0; i < widgets.length; i++ ) {
				var widget:AbstractWidgetController = _widgetControllers[widgets[i]];			
				
				if ( ! _config.visible[widget.name] ) 
					continue;
				
				if ( widget.view is WidgetDecorator ) {
					(widget.view as WidgetDecorator).spaceAfterWidget = getSpaceAfterWidget(widget.name);
				}
				
				// some exception
				if ( widget.name == 'volume' )
					arrangeVolumeControl(widget.view)
				else
					arrangeYCentered(widget.view);
				
				var newX:Number = x + (widget.view.width) * (reverse ? -1 : 1);
				
				arrangeX(widget.view, reverse ? newX : x);
				
				x = newX;
			}
			
			return x;
		}

        private function arrangeVolumeControl(view:AbstractSprite):void {
			view.setSize(getVolumeSliderWidth(), height - margins[0] - margins[2])
            view.y = margins[0];
        }
		
		private function get margins():Array {
            return _config.margins;
        }
		
		private function arrangeWidget(leftEdge:Number, rightEdge:Number):Number {
			var view:WidgetDecorator = _widgetControllers[_centeredWidget].view as WidgetDecorator;
			
			view.spaceAfterWidget = getScrubberRightEdgeWidth(nextVisibleWidget(_centeredWidget)) + getSpaceAfterWidget(_centeredWidget);
			
		//	log.error("Space after scrubber = "+view.spaceAfterWidget);
			
            arrangeX(view, leftEdge);

			var scrubberWidth:Number = rightEdge - leftEdge;
			
            if (! _player || _immediatePositioning) {
                view.width = scrubberWidth;
            } else {
			//	_player.animationEngine.cancel(view);
                _player.animationEngine.animateProperty(view, "width", scrubberWidth);
            }
            view.height = height - margins[0] - margins[2];
            view.y = _height - margins[2] - view.height;
            return rightEdge  - scrubberWidth;
        }
		
		private function nextVisibleWidget(afterWidget:String):ConfigurableWidget {
			var widgets:Array = _widgetsOrder.slice(_widgetsOrder.indexOf(afterWidget) +1);
			for ( var i:int = 0; i < widgets.length; i++ )
				if ( _config.visible[widgets[i]] )
					return _widgetControllers[widgets[i]].view;
			
			return null;
		}
		
		private function arrangeX(clip:DisplayObject, pos:Number):void {
			var a:AbstractSprite = clip as AbstractSprite
			
			
			log.info("  ");
            
            log.info("arrangeX " + a.name + " x:" + pos + " currentX : "+ clip.x +" alpha: "+ clip.alpha + " parent "+ clip.parent);
			log.info("Has animation running "+ _player.animationEngine.hasAnimationRunning(clip));
            clip.visible = true;
            if (! _player || _immediatePositioning) {
                clip.x = pos;
				clip.alpha = 1;
				log.info("Immediate Positionning " + a.name + " x:" + pos + " currentX : "+ clip.x +" alpha: "+ clip.alpha + " parent "+ clip.parent);
	            
                return;
            }

            if (clip.x == 0) {
                // we are arranging a newly created widget, fade it in
               // clip.x = pos;
                
				var currentAlpha:Number = clip.alpha;
	            clip.alpha = 0;

				log.info("Animating alpha " + a.name + " x:" + pos + " currentX : "+ clip.x +" alpha: "+ clip.alpha + " parent "+ clip.parent);
	            _player.animationEngine.animateProperty(clip, "alpha", currentAlpha);
            }
            // rearrange a previously arrange widget
			log.info("Animating X " + a.name + " x:" + pos + " currentX : "+ clip.x +" alpha: "+ clip.alpha + " parent "+ clip.parent);

            _player.animationEngine.animateProperty(clip, "x", pos);
        }

      	public function set centeredWidget(value:String):void {
			_centeredWidget = value;
			rearrangeWidgets();
		}
		
		public function get centeredWidget():String {
			return _centeredWidget;
		}

		private function arrangeYCentered(view:AbstractSprite):void {
			view.y = margins[0];
			
			var h:Number = height - margins[0] - margins[2];
			var w:Number =  h / view.height * view.width;
			view.setSize(w, h); 

			Arrange.center(view, 0, height);
		}

		private function getSpaceAfterWidget(name:String):int {
			if (nextVisibleWidget(name) == null) return _config.margins[1];
			return _config.spacing[name];
		}

		private function getScrubberRightEdgeWidth(nextWidgetToRight:DisplayObjectContainer):int {
			return SkinClasses.getScrubberRightEdgeWidth(nextWidgetToRight);
		}

		private function getVolumeSliderWidth():int {
			return SkinClasses.getVolumeSliderWidth();
		}
    }
}
