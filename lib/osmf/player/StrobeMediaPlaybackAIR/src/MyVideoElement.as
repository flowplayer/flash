package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.text.*;
	
	public class MyVideoElement extends Sprite
	{
		
		private var _txtTime:TextField;
		private var _txtName:TextField;
		private var _txtDescription:TextField;
		private var _border:Sprite;
		private var _dropShadowFilter:DropShadowFilter;

		public var vidInfo:VideoInfo;
		public var completeWidth:Number;
		public var completeHeight:Number;
		public var thumbImage:Bitmap;
		
		public static const BORDER:Number = 7;
		
		public function MyVideoElement(vi:VideoInfo, w:Number = 214, h:Number = 214):void {
			super();
			
			vidInfo = vi;
			
			//turn on button mode+hand cursor
			this.buttonMode = true;
			this.useHandCursor = true;
			
			//mouseEnabled = true;
			completeWidth = w;
			completeHeight = h;
			
			//loader for thumb
			var ulThumb:Loader = new Loader();
			ulThumb.contentLoaderInfo.addEventListener(Event.COMPLETE, onThumbLoaded);
			ulThumb.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onThumbIOError);
			ulThumb.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onThumbSecurityError);
			ulThumb.load(new URLRequest(vidInfo.videoThumbnailPath));
			
			//display of name
			_txtName = new TextField();
			_txtName.embedFonts = true;
			_txtName.antiAliasType = AntiAliasType.ADVANCED;
			_txtName.selectable = false;
			_txtName.mouseEnabled = false;
			_txtName.multiline = false;
			_txtName.height = 24;
			_txtName.defaultTextFormat = new TextFormat("PlaybackBlack", 14, 0x0299FD, true, false);
			_txtName.text = vidInfo.videoName;
			addChild(_txtName);
			
			//description
			var descriptionFormat:TextFormat = new TextFormat("PlaybackLight", 10, 0x000000);
			descriptionFormat.leading = -2;
			_txtDescription = new TextField();
			_txtDescription.defaultTextFormat = descriptionFormat;
			_txtDescription.embedFonts = true;
			_txtDescription.antiAliasType = AntiAliasType.ADVANCED;
			_txtDescription.selectable = false;
			_txtDescription.multiline = true;
			_txtDescription.wordWrap = true;
			_txtDescription.mouseEnabled = false;
			_txtDescription.height = 34;
			_txtDescription.text = vidInfo.videoDescription;
			addChild(_txtDescription);
			
			_dropShadowFilter = new DropShadowFilter();
			_dropShadowFilter.distance = 1;
			_dropShadowFilter.angle = 45;
			_dropShadowFilter.color = 0x333333;
			_dropShadowFilter.alpha = 0.5;
			_dropShadowFilter.blurX = 12;
			_dropShadowFilter.blurY = 12;
			_dropShadowFilter.strength = 1;
			_dropShadowFilter.quality = BitmapFilterQuality.LOW;
			_dropShadowFilter.inner = false;
			_dropShadowFilter.knockout = false;
			_dropShadowFilter.hideObject = false;
			
			thumbImage = new Bitmap();
			thumbImage.width = completeWidth;
			thumbImage.height = completeHeight;
			thumbImage.x = 0;
			thumbImage.y = 0;
			
			_border = new Sprite();
			_border.mouseEnabled = false;
			addChild(_border);
			
			//display of time
			_txtTime = new TextField();
			_txtTime.embedFonts = true;
			_txtTime.antiAliasType = AntiAliasType.ADVANCED;
			_txtTime.selectable = false;
			_txtTime.mouseEnabled = false;
			_txtTime.background = true;
			_txtTime.backgroundColor = 0x5E5E5E;
			_txtTime.autoSize = TextFieldAutoSize.LEFT;
			_txtTime.defaultTextFormat = new TextFormat("PlaybackLight", 12, 0xffffff);
			_txtTime.text = formatSeconds(vidInfo.duration);
			addChild(_txtTime);	
			
			//events for mouse actions
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			update();
		}
		
		public function resize(w:Number, h:Number):void {
			completeWidth = w;
			completeHeight = h;
			resizeThumb(w, h);
			update();
		}
		
		private function update():void {
			_txtTime.y = completeHeight * 3 / 4 - _txtTime.height - 2 * BORDER;
			_txtTime.x = completeWidth - _txtTime.width - 2 * BORDER;
			_txtName.x = 0;
			_txtName.y = (completeHeight * 3 / 4) + BORDER;
			_txtName.width = completeWidth;
			_txtDescription.x = 0;
			_txtDescription.y = _txtName.y + _txtName.height - BORDER; 
			_txtDescription.width = completeWidth;
		}
		
		private function resizeThumb(newW:Number, newH:Number):void {
			if (thumbImage) {
				thumbImage.width = newW;	
				thumbImage.height = newW * 3 / 4;
			}
		}
		
		private function formatSeconds(n:Number):String {
			var sc:String = "00";
			if (Math.floor(n / 60) < 10) {
				sc = "0" + Math.floor(n / 60).toString();
			} else {
				sc = Math.floor(n / 60).toString();
			}
			
			var mn:String = "00";
			if ( n%60 < 10) {
				mn = "0" + (n%60).toString();
			} else {
				mn = (n%60).toString();
			}
			return sc + ":" + mn;
		}
		
		/* ----
		 * Handlers
		 * ----
		 */		
		private function onThumbLoaded(e:Event):void {
			var loader:Loader = Loader(e.target.loader);
			
			thumbImage = Bitmap(loader.content);
			thumbImage.filters = new Array(_dropShadowFilter);
			resizeThumb(completeWidth, completeHeight);
			addChild(thumbImage);
			
			//we bring the time on top
			addChild(_txtTime);
			addChild(_border);
		}
		
		private function onMouseOver(e:Event):void {
			if (thumbImage != null && contains(thumbImage)) {
				_border.graphics.clear();
				_border.graphics.beginFill(0xCBE7F9, 0.5);
				_border.graphics.lineStyle(BORDER, 0xCBE7F9, 1, true);
				_border.graphics.drawRect(0, 0, thumbImage.width, thumbImage.height);
				_border.graphics.endFill();
			}
		}
		
		private function onMouseOut(e:Event):void {
			_border.graphics.clear();
		}
		
		private function onThumbIOError(e:Event):void{
		}
		
		private function onThumbSecurityError(e:Event):void{
		}
	}
}