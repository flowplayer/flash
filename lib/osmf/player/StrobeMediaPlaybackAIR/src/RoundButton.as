package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class RoundButton extends Sprite
	{
		
		[Embed(source="../assets/images/off.png")]
		private var OffGraphic:Class;
		
		[Embed(source="../assets/images/on.png")]
		private var OnGraphic:Class;
		
		private var _bitmapOff:Bitmap;
		private var _bitmapOn:Bitmap;
		
		public var pageNumber:Number = 1;
		public var activated:Boolean = false;
		
		public function RoundButton() {
			_bitmapOff = new OffGraphic();
			_bitmapOn = new OnGraphic();
			
			deactivate();
		}
		
		public function activate():void {
			activated = true;
			
			this.buttonMode = true;
			this.useHandCursor = true;
			
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			setOff();
		}
		
		public function deactivate():void {
			activated = false;
			
			this.buttonMode = false;
			this.useHandCursor = false;
			
			this.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			
			setOn();
		}
		
		private function onMouseOver(e:MouseEvent):void {
			setOn();
		}
		
		private function onMouseOut(e:MouseEvent):void {
			setOff();
		}
		
		public function setOn():void {
			if (contains(_bitmapOn)) {
				removeChild(_bitmapOn);
			}
			
			addChild(_bitmapOn);
		}
		
		public function setOff():void {
			if (contains(_bitmapOn)) {
				removeChild(_bitmapOn);
			}
			addChild(_bitmapOff);
		}
	}
}