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
package org.osmf.layout
{
	import flash.display.Sprite;

	/**
	 * TestSprite is a Sprite subclass that will always reflect its width
	 * and height to be its last set values (whereas a regular sprite
	 * returns the values reflecting its measured dimensions);
	 */	
	public class TesterSprite extends Sprite
	{
		public function TesterSprite()
		{
			super();
		}
		
		override public function set width(value:Number):void
		{
			_width = value;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set height(value:Number):void
		{
			_height = value;
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		private var _width:Number;
		private var _height:Number;
	}
}