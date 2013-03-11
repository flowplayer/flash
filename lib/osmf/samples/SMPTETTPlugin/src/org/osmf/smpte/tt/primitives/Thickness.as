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
	public class Thickness
	{
		private static var _empty:Thickness;
		
		private var _top:Number = 0;
		private var _right:Number = 0;
		private var _bottom:Number = 0;
		private var _left:Number = 0;
		
		/**
		 * Gets or sets the top value
		 */
		public function get top():Number
		{
			return _top;
		}
		public function set top(value:Number):void
		{
			_top = value;
		}
		
		/**
		 * Gets or sets the right value
		 */
		public function get right():Number
		{
			return _right;
		}
		public function set right(value:Number):void
		{
			_right = value;
		}
		
		/**
		 * Gets or sets the bottom value
		 */
		public function get bottom():Number
		{
			return _bottom;
		}
		public function set bottom(value:Number):void
		{
			_bottom = value;
		}
		
		/**
		 * Gets or sets the left value
		 */
		public function get left():Number
		{
			return _left;
		}
		public function set left(value:Number):void
		{
			_left = value;
		}

		public function Thickness(top:Number=0, right:Number=0, bottom:Number=0, left:Number=0)
		{
			_top = top;
			_right = right;
			_bottom = bottom;
			_left = left;
		}
		
		public static function get Empty():Thickness
		{
			return new Thickness();
		}
	}
}