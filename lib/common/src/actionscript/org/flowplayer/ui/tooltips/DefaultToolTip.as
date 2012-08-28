

package org.flowplayer.ui.tooltips {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.text.*;
    import flash.utils.Timer;
    import org.flowplayer.ui.tooltips.ToolTip;
	import org.flowplayer.ui.buttons.TooltipButtonConfig;

    import org.flowplayer.view.Animation;
    import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.util.Log;

    /**
	 * Tooltip based on a class by Duncan Reid, www.hy-brid.com
	 */
	public class DefaultToolTip extends Sprite implements ToolTip {
		
        private var _stage:Stage;
		private var _parentObject:DisplayObject;
		private var _tf:TextField;  // title field
		private var _titleFormat:TextFormat;
		private var _contentFormat:TextFormat;
		private var _defaultWidth:Number = 60;
		private var _buffer:Number = 1;
		private var _align:String = "center";
		private var _cornerRadius:Number = 4;
		private var _autoSize:Boolean = true;
		private var _hookEnabled:Boolean = true;
		private var _delay:Number = 0;  //millilseconds
		private var _hookSize:Number = 5;
		private var _offSet:Number;
		private var _hookOffSet:Number;
		private var _timer:Timer;
		private var _animationEngine:AnimationEngine;
		private var _tween:Animation;
		private var _config:TooltipButtonConfig;
		private var log:Log = new Log(this);
		
		public function DefaultToolTip(config:TooltipButtonConfig, animationEngine:AnimationEngine):void {
			_config = config;
			_animationEngine = animationEngine;
			this.mouseEnabled = false;
			this.buttonMode = false;
			this.mouseChildren = false;
			_timer = new Timer(this._delay, 1);
            _timer.addEventListener("timer", timerHandler);
            initTitleFormat();
            initContentFormat();
		}
		
		public function set text(value:String):void {
			if (! _tf) return;
			_tf.htmlText = value ? value : "";
			setDefaultWidth();
			drawBG();
		}
		
		public function redraw(config:TooltipButtonConfig):void {
			_config = config;
			drawBG();
		}
		
		public function show(p:DisplayObject, title:String, positionToMouse:Boolean = false, content:String=null):void {
			if (_tween) {
				_tween.cancel();
				this.alpha = _config.tooltipAlpha;
			}
			if (this.parent == p.stage) {
				if (_tf && _tf.htmlText != "" && _tf.htmlText != title) {
					cleanUp();
				} else {
					return;
				}
			}
			this._stage = p.stage;
			this._parentObject = p;
			
			this.addCopy(title, content);
			this.setOffset();
			this.drawBG();
			this.bgGlow();
			
			//initialize coordinates
			var parentCoords:Point = new Point( _parentObject.x, _parentObject.y );
			var globalPoint:Point = p.localToGlobal(parentCoords);
			this.x = globalPoint.x + this._offSet;
			this.y = globalPoint.y - this.height - 5;
			
			this.alpha = 0;
			this._stage.addChild( this );

			if (positionToMouse) {
				follow(true);
			} else {
				position();
			}
            _timer.start();
		}
		
		public function hide():void {
			if (! this.parent) return;
			
			if (_tween) {
				_tween.cancel();
				this.alpha = _config.tooltipAlpha;
			}
			
			this.animate( false );
		}
		
		private function timerHandler( event:TimerEvent ):void {
			this.animate(true);
		}
		
		private function follow( value:Boolean ):void {
			if( value ){
				addEventListener( Event.ENTER_FRAME, this.eof );
			}else{
				removeEventListener( Event.ENTER_FRAME, this.eof );
			}
		}
		
		private function eof( event:Event ):void {
			this.position(true);
		}
		
		private function position(followMouse:Boolean = false):void {
			var speed:Number = 1;
			var parentCoords:Point = followMouse ? parentMousePos() :
				 new Point(_parentObject.width / 2, 0 );
			var globalPoint:Point = _parentObject.localToGlobal(parentCoords);

			var xp:Number = globalPoint.x + this._offSet;
			var yp:Number = globalPoint.y - this.height - _config.marginBottom;

			var overhangRight:Number = this._defaultWidth + xp;
			if( overhangRight > stage.stageWidth ){
				xp =  stage.stageWidth -  this._defaultWidth;
			} else if( xp < 0 ) {
				xp = 0;
			}
			if( (yp) < 0 ){
				yp = 0;
			}
			this.x += ( xp - this.x ) / speed;
			this.y += ( yp - this.y ) / speed;
//			log.debug(Arrange.describeBounds(this));
		}
		
		private function parentMousePos():Point {
			var x:Number = _parentObject.mouseX;
			if (x < 0) return new Point(0, 0);
			if (x > _parentObject.width) return new Point(_parentObject.width, 0); 
			return new Point(x, 0);
		}

		private function addCopy( title:String, content:String ):void {
			if (_tf) {
                removeChild(_tf);
            }
			var titleIsDevice:Boolean = this.isDeviceFont(  _titleFormat );
			
			this._tf = this.createField( titleIsDevice ); 
			this._tf.defaultTextFormat = this._titleFormat;
			this._tf.text = title;
			this._tf.alpha = _config.tooltipTextAlpha;
			if( this._autoSize ){
				setDefaultWidth();
				if (_parentObject.x + _parentObject.width / 2 + _defaultWidth / 2 > _parentObject.stage.stageWidth) {
					_align = "left";
				} else if (_parentObject.x + _parentObject.width / 2 - _defaultWidth / 2 < 0) {
					_align = "right";
				} else {
					_align = "center";
				}
			}else{
				this._tf.width = this._defaultWidth - ( _buffer * 2 );
			}
			
			this._tf.x = this._tf.y = this._buffer;
			this.textGlow( this._tf );
			addChild( this._tf );
		}
		
		private function setDefaultWidth():void {
			this._defaultWidth = this._tf.textWidth + 4 + ( _buffer * 2 );
		}

		private function createField( deviceFont:Boolean ):TextField {
			var tf:TextField = new TextField();
			tf.embedFonts = ! deviceFont;
			tf.gridFitType = "pixel";
			//tf.border = true;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.blendMode = BlendMode.LAYER;
			tf.selectable = false;
			if( ! this._autoSize ){
				tf.multiline = true;
				tf.wordWrap = true;
			}
			return tf;
		}
		
		private function drawBG():void {
			graphics.clear();
			
			_titleFormat.color = _config.tooltipTextColor;
			
			var bounds:Rectangle = this.getBounds( this );
			var fillType:String = GradientType.LINEAR;
		   	//var colors:Array = [0xFFFFFF, 0x9C9C9C];
		   	var alphas:Array = [_config.tooltipAlpha, _config.tooltipAlpha];
		   	var ratios:Array = [0x00, 0xFF];
		   	var matr:Matrix = new Matrix();
			var radians:Number = 90 * Math.PI / 180;
		  	matr.createGradientBox(this._defaultWidth, bounds.height + ( this._buffer * 2 ), radians, 0, 0);
		  	var spreadMethod:String = SpreadMethod.PAD;
		  	var colors:Array = [lighten(_config.tooltipColor), _config.tooltipColor];
		  	this.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
			if( this._hookEnabled ){
				var xp:Number = 0; var yp:Number = 0; 
				var w:Number = this._defaultWidth; 
				var h:Number = bounds.height + ( this._buffer * 2 );
				this.graphics.moveTo ( xp + this._cornerRadius, yp );
				this.graphics.lineTo ( xp + w - this._cornerRadius, yp );
				this.graphics.curveTo ( xp + w, yp, xp + w, yp + this._cornerRadius );
				this.graphics.lineTo ( xp + w, yp + h - this._cornerRadius );
				this.graphics.curveTo ( xp + w, yp + h, xp + w - this._cornerRadius, yp + h );
				
				//hook
				this.graphics.lineTo ( xp + this._hookOffSet + this._hookSize, yp + h );
				this.graphics.lineTo ( xp + this._hookOffSet , yp + h + this._hookSize );
				this.graphics.lineTo ( xp + this._hookOffSet - this._hookSize, yp + h );
				this.graphics.lineTo ( xp + this._cornerRadius, yp + h );
				
				this.graphics.curveTo ( xp, yp + h, xp, yp + h - this._cornerRadius );
				this.graphics.lineTo ( xp, yp + this._cornerRadius );
				this.graphics.curveTo ( xp, yp, xp + this._cornerRadius, yp );
				this.graphics.endFill();
			}else{
				this.graphics.drawRoundRect( 0, 0, this._defaultWidth, bounds.height + ( this._buffer * 2 ), this._cornerRadius, this._cornerRadius );
			}
		}
		
		private function lighten(color:Number):Number {
			var rgb:Array = [ (color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF ];
			var offset:Number = 60;
			rgb = [Math.min(rgb[0]+offset, 255), Math.min(rgb[1]+offset, 255), Math.min(rgb[2]+offset, 255)];
			return rgb[0] << 16 | rgb[1] << 8 | rgb[2];
		}
		
		private function animate( show:Boolean ):void {
			if (show){
				_animationEngine.fadeIn(this, 500);
				_timer.reset();
			} else {
				_timer.stop();
				_tween = _animationEngine.fadeOut(this, 500, onComplete);
			}
		}
		
		private function onComplete():void {
			if (_tween && _tween.canceled) {
				_tween = null;
				return;
			}
			_tween = null;
			this.cleanUp();
		}
		
		private function textGlow( field:TextField ):void {
			var color:Number = 0x000000;
            var alpha:Number = 0.35;
            var blurX:Number = 2;
            var blurY:Number = 2;
            var strength:Number = 1;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

           var filter:GlowFilter = new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
            var myFilters:Array = new Array();
            myFilters.push(filter);
        	field.filters = myFilters;
		}
		
		private function bgGlow():void {
			var color:Number = 0x000000;
            var alpha:Number = 0.20;
            var blurX:Number = 5;
            var blurY:Number = 5;
            var strength:Number = 1;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

           var filter:GlowFilter = new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
            var myFilters:Array = new Array();
            myFilters.push(filter);
            filters = myFilters;
		}
		
		private function initTitleFormat():void {
			_titleFormat = new TextFormat();
			_titleFormat.font = "_sans";
			_titleFormat.bold = true;
			_titleFormat.size = 10;
			_titleFormat.color = _config.tooltipTextColor;
		}
		
		private function initContentFormat():void {
			_contentFormat = new TextFormat();
			_contentFormat.font = "_sans";
			_contentFormat.bold = false;
			_contentFormat.size = 12;
			_contentFormat.color = 0x333333;
		}

		private function isDeviceFont( format:TextFormat ):Boolean {
			var font:String = format.font;
			var device:String = "_sans _serif _typewriter";
			return device.indexOf( font ) > -1;
		}
		
		private function setOffset():void {
			switch( this._align ){
				case "left":
					this._offSet = - _defaultWidth +  ( _buffer * 6 ) + this._hookSize; 
					this._hookOffSet = this._defaultWidth - ( _buffer * 6 ) - this._hookSize; 
				break;
				
				case "right":
					this._offSet = 0 - ( _buffer * 6 ) - this._hookSize;
					this._hookOffSet =  _buffer * 6 + this._hookSize;
				break;
				
				case "center":
					this._offSet = - ( _defaultWidth / 2 );
					this._hookOffSet =  ( _defaultWidth / 2 );
				break;
				
				default:
					this._offSet = - ( _defaultWidth / 2 );
					this._hookOffSet =  ( _defaultWidth / 2 );;
				break;
			}
		}
		
		private function cleanUp():void {
			this.follow( false );
			this.filters = [];
			
			if (_tf) {
				_tf.filters = [];
				removeChild(_tf);
				_tf = null;
			}
			this.graphics.clear();
			
			if (parent && this.parent == parent) {
				parent.removeChild( this );
			}
		}

        override public function get visible():Boolean {
            if (super.visible) return false;
            return this.alpha < _config.tooltipAlpha;
        }
    }
}
