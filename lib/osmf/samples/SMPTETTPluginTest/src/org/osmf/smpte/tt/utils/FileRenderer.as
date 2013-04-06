/***********************************************************
* 
* Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
*
* *********************************************************
* The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
* (the "License"); you may not use this file except in
* compliance with the License. 
*
* Software distributed under the License is distributed on an "AS IS"
* basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
* License for the specific language governing rights and limitations
* under the License.
*
*
* The Initial Developer of the Original Code is Adobe Systems Incorporated.
* Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
* Incorporated. All Rights Reserved.
**********************************************************/
package org.osmf.smpte.tt.utils
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.TextArea;
	import spark.components.TextArea;
	
	public class FileRenderer
	{
		public function FileRenderer(target:*, url:String)
		{
			_target = target;	
			_loader = new URLLoader();
			setupListeners();
			
			_loader.load(new URLRequest(url));
		}
		
        private function setupListeners(setup:Boolean=true):void 
        {
        	if (setup)
        	{
	            _loader.addEventListener(Event.COMPLETE, completeHandler);
	            _loader.addEventListener(Event.OPEN, openHandler);
	            _loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
	            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	            _loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
	            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	        }
	        else
	        {
	            _loader.removeEventListener(Event.COMPLETE, completeHandler);
	            _loader.removeEventListener(Event.OPEN, openHandler);
	            _loader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
	            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	            _loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
	            _loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	        }
        }

        private function completeHandler(event:Event):void 
        {
        	setupListeners(false);
            var loader:URLLoader = URLLoader(event.target);
            //trace("completeHandler: " + loader.data);
            if(_target.hasOwnProperty("text"))
				_target.text = loader.data;
        }

        private function openHandler(event:Event):void {
           // trace("openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
           // trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
          //  trace("securityErrorHandler: " + event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
          //  trace("httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
          //  trace("ioErrorHandler: " + event);
        }
		
		private var _target:*;
		private var _loader:URLLoader;
	}
}
