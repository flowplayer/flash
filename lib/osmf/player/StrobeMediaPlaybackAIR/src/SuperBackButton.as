package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	public class SuperBackButton extends Sprite
	{
		
		[Embed(source="../assets/images/back.png")]
		private var BackGraphic:Class;
		
		private var _txBack:TextField;
		private var _bitmapBack:Bitmap;
		
		public function SuperBackButton()
		{
			_bitmapBack = new BackGraphic();
			_bitmapBack.x = 0;
			_bitmapBack.y = 0;
			addChild(_bitmapBack);
			
			this.buttonMode = true;
			this.useHandCursor = true;
			
			_txBack = new TextField();
			
			_txBack.defaultTextFormat = new TextFormat("PlaybackBlack", 24, 0xffffff);
			_txBack.embedFonts = true;
			_txBack.antiAliasType = AntiAliasType.ADVANCED;
			_txBack.mouseEnabled = false;
			_txBack.autoSize= TextFieldAutoSize.LEFT;
			_txBack.text = "Home";
			_txBack.x = _bitmapBack.x + _bitmapBack.width;
			_txBack.y = (_bitmapBack.height - _txBack.height) / 2;
			_txBack.selectable = false;
			addChild(_txBack);
			
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
		}
		
		private function onMouseOver(e:MouseEvent):void {
			_txBack.setTextFormat(new TextFormat("PlaybackBlack", 24, 0xcccccc, true));
		}
		
		private function onMouseOut(e:MouseEvent):void {
			_txBack.setTextFormat(new TextFormat("PlaybackBlack", 24, 0xffffff, true));
		}
	}
}