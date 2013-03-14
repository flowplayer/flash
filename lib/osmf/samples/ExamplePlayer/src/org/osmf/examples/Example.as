/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.examples
{
	import org.osmf.media.MediaElement;
	
	/**
	 * Encapsulation of an example MediaElement.
	 **/
	public class Example
	{
		/**
		 * Constructor.
		 **/
		public function Example(name:String, description:String, mediaElementCreatorFunc:Function, disposeFunc:Function = null, scaleModeOverride:String = null)
		{
			_name = name;
			_description = description;
			_mediaElementCreatorFunc = mediaElementCreatorFunc;
			this.disposeFunc = disposeFunc;
			_scaleModeOverride = scaleModeOverride;
		}
		
		/**
		 * A human-readable name for the example.
		 **/
		public function get name():String
		{
			return _name;
		}

		/**
		 * A description explaining what the example demonstrates.
		 **/
		public function get description():String
		{
			return _description;
		}
		
		/**
		 * The MediaElement that this example demonstrates.
		 **/
		public function get mediaElement():MediaElement
		{
			return _mediaElementCreatorFunc.apply(this) as MediaElement;
		}
		
		/**
		 * Optional override of the scale mode.
		 **/
		public function get scaleModeOverride():String
		{
			return _scaleModeOverride;
		}
		
		/**
		 * To be invoked when the example should clean-up.
		 */
		public function dispose():void
		{
			if (disposeFunc != null)
			{
				disposeFunc();
			}
		}
		
		private var _name:String;
		private var _description:String;
		private var _mediaElementCreatorFunc:Function;
		private var disposeFunc:Function;
		private var _scaleModeOverride:String;
	}
}