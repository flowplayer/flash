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
package org.osmf.smpte.tt.primitives
{	
	public class Size
	{	
		private static var _empty:Size;
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		/**
		 * Gets or sets the top value
		 */
		public function get width():Number
		{
			return _width;
		}
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		/**
		 * Gets or sets the right value
		 */
		public function get height():Number
		{
			return _height;
		}
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		public function Size(w:Number=0, h:Number=0)
		{
			_width = w;
			_height = h;
		}
		
		public static function get Empty():Size
		{
			return new Size(0,0);
		}
	}
}