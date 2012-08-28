/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 *Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.slowmotion {
	import org.flowplayer.util.Log;	
	import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

    /**
	 * @author api
	 */
	public class Config {
		private var log:Log = new Log(this);
       
		private var _normalLabel:String  	  = 'Normal';
		private var _slowForwardLabel:String  = 'Slow Forward ({speed}x)';
		private var _fastForwardLabel:String  = 'Fast Forward ({speed}x)';
		private var _slowBackwardLabel:String = 'Slow Backward ({speed}x)';
		private var _fastBackwardLabel:String = 'Fast Backward ({speed}x)';
		private var _speedIndicatorDelay:Number = 2000;
		
		private var _provider:String = 'rtmp';
		private var _speedIndicator:String = 'speedIndicator';
        private var _serverType:String = "fms";
		
		public function get normalLabel():String
		{
			return _normalLabel;
		}
		
		public function set normalLabel(label:String):void
		{
			_normalLabel = label;
		}
		
		public function get slowForwardLabel():String
		{
			return _slowForwardLabel;
		}
		
		public function set slowForwardLabel(label:String):void
		{
			_slowForwardLabel = label;
		}
		
		public function get fastForwardLabel():String
		{
			return _fastForwardLabel;
		}
		
		public function set fastForwardLabel(label:String):void
		{
			_fastForwardLabel = label;
		}
		
		public function get slowBackwardLabel():String
		{
			return _slowBackwardLabel;
		}
		
		public function set slowBackwardLabel(label:String):void
		{
			_slowBackwardLabel = label;
		}
		
		public function get fastBackwardLabel():String
		{
			return _fastBackwardLabel;
		}
		
		public function set fastBackwardLabel(label:String):void
		{
			_fastBackwardLabel = label;
		}
		
		public function get provider():String
		{
			return _provider;
		}
		
		public function set provider(provider:String):void
		{
			_provider = provider;
		}
		
		public function get speedIndicator():String
		{
			return _speedIndicator;
		}
		
		public function set speedIndicator(speedIndicator:String):void
		{
			_speedIndicator = speedIndicator;
		}
		
		public function get speedIndicatorDelay():Number
		{
			return _speedIndicatorDelay;
		}
		
		public function set speedIndicatorDelay(speedIndicatorDelay:Number):void
		{
			_speedIndicatorDelay = speedIndicatorDelay;
		}

        public function get serverType():String {
            return _serverType;
        }

        public function set serverType(value:String):void {
            _serverType = value;
        }
    }
}
