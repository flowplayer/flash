/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.buttons {
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import org.flowplayer.ui.buttons.ConfigurableWidget;
    import org.flowplayer.ui.tooltips.DefaultToolTip;
    import org.flowplayer.ui.tooltips.NullToolTip;
    import org.flowplayer.ui.tooltips.ToolTip;
    import org.flowplayer.util.GraphicsUtil;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.Flowplayer;

    /**
	 * @author api
	 */
	public class AbstractSlider extends ConfigurableWidget {
		public static const DRAG_EVENT:String = "onDrag";
		
		protected var _dragger:DraggerButton;
		private var _dragTimer:Timer;
		private var _previousDragEventPos:Number;
		protected var _config:SliderConfig;
		private var _animationEngine:AnimationEngine;
		private var _currentPos:Number;
		private var _tooltip:ToolTip;
		private var _tooltipTextFunc:Function;
        private var _controlbar:DisplayObject;
        private var _mouseOver:Boolean;
		private var _border:Sprite;
		protected var _player:Flowplayer;
        private var _mouseDown:Boolean;
		
        public function AbstractSlider(config:SliderConfig, player:Flowplayer, controlbar:DisplayObject) {
            _config = config;
			_player = player;
            _animationEngine = player.animationEngine;
            _controlbar = controlbar;
            _dragTimer = new Timer(20);
            createDragger();
            toggleTooltip();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
            addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
            addEventListener(MouseEvent.MOUSE_DOWN, setMouseDown);
        }

        private function setMouseDown(event:MouseEvent):void {
            _mouseDown = true;
            stage.addEventListener(MouseEvent.MOUSE_UP, setMouseUp);
        }

        private function setMouseUp(event:MouseEvent):void {
            log.debug("setMouseUp()");
            this.removeEventListener(MouseEvent.MOUSE_UP, setMouseUp);
            _mouseDown = false;
            if (! _mouseOver) {
                log.debug("setMouseUp() hiding tooltip");
                hideTooltip();
            }
        }

        private function onMouseMove(event:MouseEvent):void {
            if (! _mouseOver) return;
            _tooltip.text = tooltipText;
        }

        private function get tooltipText():String {
            if (_tooltipTextFunc == null) return null;
            return _tooltipTextFunc(valueFromScrubberPos);
        }

        protected function clampPos(val:Number, min:Number = 0, max:Number = 100):Number {
            return Math.max(min, Math.min(max, val))
        }

        protected function get valueFromScrubberPos():Number {
            //#349 if we click to seek to zero the calculation includes dragger dimensions so is negative, correct this to zero
            //bound position between 0 and 100
            return clampPos(((mouseX - _dragger.width / 2) / (width - _dragger.width)) * 100);
        }

        protected function onMouseOut(event:MouseEvent = null):void {
//            log.debug("onMouseOut");
            _mouseOver = false;
            if (_mouseDown) return;
            hideTooltip();
            removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        protected function onMouseOver(event:MouseEvent):void {
//            log.debug("onMouseOver");
            _mouseOver = true;
            if (_mouseDown) return;
            showTooltip();
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }


        protected function hideTooltip():void {
            _tooltip.hide();
        }

        protected function showTooltip():void {
            if (tooltipText) {
                _tooltip.show(this, tooltipText, true);
            }
        }

		private function toggleTooltip():void {
			if (isToolTipEnabled()) {
				if (_tooltip && _tooltip is DefaultToolTip) return;
				log.debug("enabling tooltip");
				_tooltip = new DefaultToolTip(_config.draggerButtonConfig, _animationEngine);
			} else {
				log.debug("tooltip disabled");
				_tooltip = new NullToolTip();
			}
		}
		
		protected function isToolTipEnabled():Boolean {
			return false;
		}

		override public function configure(config:Object):void {
			_config = config as SliderConfig;
			_dragger.configure(_config.draggerButtonConfig);
            drawBackground();
			drawBorder();
			toggleTooltip();
			_tooltip.redraw(_config.draggerButtonConfig);
		}

		override public function set enabled(value:Boolean) :void {
			log.debug("setting enabled to " + value);
			var func:String = value ? "addEventListener" : "removeEventListener";

			this[func](MouseEvent.MOUSE_UP, _onMouseUp);

			// we might not already been added to stage when this is called
			if ( stage ) {
				stage[func](MouseEvent.MOUSE_UP, onMouseUpStage);
				stage[func](Event.MOUSE_LEAVE, onMouseLeaveStage);
			}
			
			toggleClickListeners(value);

            //#483 move up button mode config to detect enabled state, toggle slider enabled / disabled colour correctly.
            _dragger.buttonMode = value;
            if (! enabled) {
                _dragger.alpha = 0.5;
            } else {
                // #
                removeChild(_dragger);
                createDragger();
            }
            _dragger[func](MouseEvent.MOUSE_UP, _onMouseUp);
            _dragger[func](MouseEvent.MOUSE_DOWN, _onMouseDown);
        }

        protected function drawSlider():void {
                 // overridden in subclasses
        }

        protected function enableDragging(value:Boolean):void {
            var func:String = value ? "addEventListener" : "removeEventListener";
            _dragTimer[func](TimerEvent.TIMER, dragging);
        }

        override public function get enabled():Boolean {
            return _dragger.buttonMode;
        }
		
		private function onAddedToStage(event:Event):void {
			enabled = true;
            //#483 only run the stage event once to prevent re-enabling unnecessarily.
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function toggleClickListeners(add:Boolean):void {
		//	log.error("toggleClickListeners", add);
			var targets:Array = getClickTargets(add);
			for (var i:Number = 0; i < targets.length; i++) {
				if (add) {
					EventDispatcher(targets[i]).addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
				} else {
					EventDispatcher(targets[i]).removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
				}
				if (targets[i].hasOwnProperty("buttonMode")) {
					targets[i]["buttonMode"] = add;
				}
			}
		}
		
		protected function getClickTargets(enabled:Boolean):Array {
			return [this];
		}

		protected function createDragger():void {
 			_dragger = new DraggerButton(_config.draggerButtonConfig, _animationEngine);
			_dragger.buttonMode = true;
			_dragger.x = 0;
			addChild(_dragger);
		}
		
		private function onMouseUpStage(event:MouseEvent):void {
			if (_dragTimer.running) {
				_onMouseUp();
			}
            _dragTimer.stop();
		}
		
		private function onMouseLeaveStage(event:Event):void {
			_tooltip.hide();
			if (_dragTimer.running) {
				_onMouseUp();
			}
            _dragTimer.stop();
		}
		
		private function _onMouseUp(event:MouseEvent = null):void {
            _dragTimer.stop();
            onMouseUp(event);
			if (event && event.target != this) return;
			
			if (! canDragTo(mouseX) /*&& _dragger.x >= 0*/) return;
						
			updateCurrentPosFromDragger();

			if (! dispatchOnDrag) {
				dispatchDragEvent();
			}
		}

        protected function onMouseUp(event:MouseEvent):void {
        }
        
		protected function canDragTo(xPos:Number):Boolean {
			return true;
		}

		private function updateCurrentPosFromDragger():void {
			_currentPos = (_dragger.x / (width - _dragger.width)) * 100;
		}

		protected final function get isDragging():Boolean {
			return _dragTimer.running;
		}

		private function _onMouseDown(event:MouseEvent):void {
		//	log.error("_onMouseDown");
			if (! event.target == this) return;
            onMouseDown(event);
			_dragTimer.start();
		}

        protected function onMouseDown(event:MouseEvent):void {
        }

		private function dragging(event:TimerEvent = null):void {
			var pos:Number = mouseX - _dragger.width / 2;
            if (pos < 0) {
                pos = 0;
            }
            if (pos > maxDrag) {
                pos = maxDrag;
            }

            _dragger.x = pos;

			// do not dispatch several times from almost the same pos
			if (Math.abs(_previousDragEventPos - _dragger.x) < 1) return;
			_previousDragEventPos = _dragger.x;
			
			if (dispatchOnDrag) {
				updateCurrentPosFromDragger();
				dispatchDragEvent();
			}
            onDragging();
		}

        protected function onDragging():void {
        }

		private function dispatchDragEvent():void {
			log.debug("dispatching drag event");
			onDispatchDrag();
			dispatchEvent(new Event(DRAG_EVENT));
		}
		
		protected function get dispatchOnDrag():Boolean {
			return true;
		}

		protected function onDispatchDrag():void {
			// can be overridden in subclasses
		}

		protected function get maxDrag():Number {
			return width - _dragger.width;
		}
		
		/**
		 * Gets the curent value of the slider.
		 * @return the value that is between 0 and 100
		 */
		public function get value():Number {
			return _currentPos;
		}

		/**
		 * Sets the slider's current value.
		 * @param value the value between 0 and 100
		 */
		public final function set value(value:Number):void {
			if (value > 100) {
				value = 100;
			}
			_currentPos = value;
            onSetValue();
		}

        protected function onSetValue():void {
        }

		protected function get allowSetValue():Boolean {
			// can be overridden in sucbclasses
			return true;
		}

		protected override function onResize():void {
			super.onResize();
			
			_dragger.setSize(height, height);	// TODO : calculate real width

			drawBackground();
			drawBorder();
			onSetValue();
        }

		private function drawBackground():void {
			graphics.clear();
			graphics.beginFill(backgroundColor, backgroundAlpha);
			graphics.drawRoundRect(0, height/2 - barHeight/2, width, barHeight, barCornerRadius, barCornerRadius);
            graphics.endFill();
                                                                                                                     
            if (sliderGradient) {
                GraphicsUtil.addGradient(this, 1, sliderGradient, barCornerRadius, 0, height/2 - barHeight/2, barHeight);
            }
        }

		private function drawBorder():void {
			
			if (_border && _border.parent == this) {
				removeChild(_border);
			}
			if (! borderWidth > 0) return;
			_border = new Sprite();
			addChild(_border);
			swapChildren(_border, _dragger);
			log.info("border weight is " + borderWidth + ", color is "+ String(borderColor) + ", alpha "+ String(borderAlpha));		
			_border.graphics.lineStyle(borderWidth, borderColor, borderAlpha);
			GraphicsUtil.drawRoundRectangle(_border.graphics, 0, height/2 - barHeight/2, width, barHeight, barCornerRadius);
		}

		protected function drawBar(bar:Sprite, color:Number, alpha:Number, gradientAlphas:Array, leftEdge:Number, rightEdge:Number):void {
			bar.graphics.clear();
			if (leftEdge > rightEdge) return;
			bar.scaleX = 1;
			
			bar.graphics.beginFill(color, alpha);
			bar.graphics.drawRoundRect(leftEdge, height/2 - barHeight/2, rightEdge - leftEdge, barHeight, barCornerRadius, barCornerRadius);
			bar.graphics.endFill();
			
			if (gradientAlphas) {
				GraphicsUtil.addGradient(bar, 0, gradientAlphas, barCornerRadius, leftEdge,  height/2 - barHeight/2 , barHeight);
			} else {
				GraphicsUtil.removeGradient(bar);
			}
		}
  
		protected function get barHeight():Number {
			return  Math.ceil(height * _config.barHeightRatio);
		}

		protected function get sliderGradient():Array {
			return _config.backgroundGradient;
		}

		protected function get backgroundColor():Number {
			return _config.backgroundColor;
		}

		protected function get backgroundAlpha():Number {
			return _config.backgroundAlpha;
		}

		protected function get borderWidth():Number {
			return _config.borderWidth;
		}

		protected function get borderColor():Number {
			return _config.borderColor;
		}

		protected function get borderAlpha():Number {
			return _config.borderAlpha;
		}

		protected function get barCornerRadius():Number {
			if (isNaN(_config.borderRadius)) return barHeight/1.5;
			return _config.borderRadius;
		}

        protected final function get animationEngine():AnimationEngine {
            return _animationEngine;
        }

		public function set tooltipTextFunc(tooltipTextFunc:Function):void {
			_tooltipTextFunc=tooltipTextFunc;
		}

        protected function get mouseDown():Boolean {
            return _mouseDown;
        }
    }
}
