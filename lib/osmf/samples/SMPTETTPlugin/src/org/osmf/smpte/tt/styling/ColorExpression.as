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
package org.osmf.smpte.tt.styling
{	
	import flash.utils.Dictionary;
	
	import org.osmf.smpte.tt.errors.SMPTETTException;
	import org.osmf.smpte.tt.utilities.StringUtils;

	public class ColorExpression
	{
		private static const hexRegExp:RegExp = /^\s*(?:#|0x)([\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f])([\dA-Fa-f][\dA-Fa-f])?\s*$/;
		private static const rgbaRegExp:RegExp = /^\s*rgb(a)?\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\)|(?:\s*,\s*(\d+(?:.?\d+)*)\)))\s*$/;
		
		private static var _cache:Dictionary = new Dictionary(); 
		
		private var _color:uint = 0x000000;
		public function get color():uint
		{
			return _color;
		}
		public function set color(p_color:uint):void
		{
			_color = p_color;
		}
		
		private var _alpha:Number = 1;
		public function get alpha():Number {
			return _alpha;
		}
		public function set alpha(p_alpha:Number):void {
			_alpha = p_alpha;
		}
		
		public function get argb():uint
		{
			//newAlpha has to be in the 0 to 255 range
			var a:uint = Math.round(_alpha*0xFF);
			var argb:uint = (a<<24) | _color;
			return argb;
		}
		public function set argb(value:uint):void
		{	
			_color = 0xFFFFFF & value;
			_alpha = parseInt(String((value>>24)&0xFF),10) / 0xFF; 
		}
		
		
		public static function parse(p_colorExpression:String):ColorExpression
		{
			var input:String = StringUtils.trim(p_colorExpression),
				m:Array,
				c:uint,
				a:Number=1,
				ce:ColorExpression;
			
			if (_cache[input])
			{
				return _cache[input]
			}
			
			try {
				if(hexRegExp.test(input))
				{
					m=hexRegExp.exec(input);
					c=parseInt(m[1],16);/* rgb */
					a=(m[2]) ? parseInt(m[2],16)/255 : 1;/* (alpha) ? alpha : 1 */
					ce = new ColorExpression(c,a);
				} else if(rgbaRegExp.test(input))
				{
					m=rgbaRegExp.exec(input);
					c=(parseInt(m[2]) << 16) + (parseInt(m[3]) << 8) + parseInt(m[4]);/* rgb */
					if(m[5])
					{
						if(parseInt(m[5])>1 && parseInt(m[5])<=255)
						{
							a = parseInt(m[5])/255; /* sRGB alpha */
						} else if(parseFloat(m[5])>=0 && parseFloat(m[5])<=1)
						{
							a = Math.max(0, Math.min(parseFloat(m[5]),1)); /* CSS-style alpha */
						}
					}
					ce = new ColorExpression(c,a);
				} else {
					ce = namedColor(input);
				}
			} catch(err:Error){
				throw(new SMPTETTException("Invalid colour format string: "+input));
			}
			
			_cache[input] = ce;
			return ce;
		}
		
		private static function namedColor(p_input:String):ColorExpression
		{
			var ce:ColorExpression;
			switch(p_input){
				case "transparent": 
					ce = new ColorExpression(0,0);
					break;
				case "black": 
					ce = new ColorExpression(0x000000,1);
					break;
				case "silver": 
					ce = new ColorExpression(0xc0c0c0,1);
					break;
				case "gray": 
					ce = new ColorExpression(0x808080,1);
					break;
				case "white":  
					ce = new ColorExpression(0xffffff,1);
					break;
				case "maroon": 
					ce = new ColorExpression(0x800000,1);
					break;
				case "red": 
					ce = new ColorExpression(0xff0000,1);
					break;
				case "purple": 
					ce = new ColorExpression(0x800080,1);
					break;
				case "fuchsia": 
					ce = new ColorExpression(0xff00ff,1);
					break;
				case "magenta": 
					ce = new ColorExpression(0xff00ff,1);
					break;
				case "green": 
					ce = new ColorExpression(0x008000,1);
					break;
				case "lime": 
					ce = new ColorExpression(0x00ff00,1);
					break;
				case "olive": 
					ce = new ColorExpression(0x808000,1);
					break;
				case "yellow": 
					ce = new ColorExpression(0xffff00,1);
					break;
				case "navy": 
					ce = new ColorExpression(0x000080,1);
					break;
				case "blue": 
					ce = new ColorExpression(0x0000ff,1);
					break;
				case "teal": 
					ce = new ColorExpression(0x008080,1);
					break;
				case "aqua": 
					ce = new ColorExpression(0xff00ff,1);
					break;
				case "cyan": 
					ce = new ColorExpression(0x00ffff,1);
					break;
			}
			if(ce) return ce; 
			throw(new SMPTETTException("named colour " + p_input + " not allowed"));
			return null;
		}
		
		public function toString():String
		{
			return "0x"+(((argb>>24) != 0)?Number(argb>>>24).toString(16):"")+Number(argb&0xFFFFFF).toString(16);
		}
		
		/**
		 * Test the color parser.
		 * 
		 * @return Boolean
		 * 
		 */		
		public static function UnitTests():Boolean
		{
			var reference:ColorExpression = new ColorExpression(0xff0000,1);
			var pass:Number = 1;
			
			var tests:Array = [
				"transparent",
				"red",
				"rgb(255,00,00)",
				"rgb(255,00,00,255)",
				"rgba(255,00,00,255)",
				"#ff0000",
				"#FF0000",
				"#ff0000ff",
				"#fF0000fF"
			];
			
			for(var i:uint=0; i<tests.length; i++){
				
				var ce:ColorExpression = ColorExpression.parse(tests[i]);
				var valid:Boolean = (ce.color == reference.color && ce.alpha == reference.alpha);
				
				// trace(tests[i] + "{color:"+ce.color+", alpha:"+ce.alpha+"} : " + valid);
				
				pass &= uint(valid);	
			}
			
			return Boolean(pass);
		}
		
		public function ColorExpression(p_color:uint=0,p_alpha:Number=1){
			_color = p_color;
			_alpha = p_alpha;			
		}
		
	}
}