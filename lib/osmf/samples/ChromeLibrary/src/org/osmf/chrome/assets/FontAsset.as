/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.chrome.assets
{
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class FontAsset extends SymbolAsset
	{
		public function FontAsset(font:Class, resource:FontResource)
		{
			super(font);
			
			_font = new font();
			Font.registerFont(font);
			
			this.resource = resource;
		}
		
		public function get font():Font
		{
			return _font;
		}
		
		public function get format():TextFormat
		{
			var result:TextFormat
				= new TextFormat
					( _font.fontName
					, resource.size
					, resource.color
					);
					
			result.align = TextFormatAlign.LEFT;
			
			return result;
		}
		
		private var _font:Font;
		private var resource:FontResource;
	}
}