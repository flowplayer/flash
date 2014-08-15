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
	import flash.filters.GlowFilter;
	
	import org.osmf.smpte.tt.errors.SMPTETTException;
	
	public class TextOutline
	{
		private static const textOutlineRegExp:RegExp = /(?P<sign>[\+|\-])?(?P<value>rgb(?:a)?\((?:\d+)\s*,\s*(?:\d+)\s*,\s*(?:\d+)(?:\)|(?:\s*,\s*(?:\d+(?:.?\d+)*)\)))|#(?:[0-9A-Fa-f]{8}|[0-9A-Fa-f]{6})|transparent|black|silver|gray|white|maroon|red|purple|fuchsia|magenta|fuchsia|green|lime|olive|yellow|navy|blue|teal|aqua|cyan|aqua|[0-9]+(?:\.[0-9]*)?)(?P<units>%|px|em|c)?\s*?/gi;
		
		private var _color:uint;
		public function get color():uint
		{
			return _color;
		}
		public function set color(p_color:uint):void
		{
			_color = p_color;
		}
		
		private var _alpha:Number=1;
		public function get alpha():Number {
			return _alpha;
		}
		public function set alpha(p_alpha:Number):void {
			_alpha = p_alpha;
		}
		
		public function get width():Number
		{
			return _p.first;	
		}
		
		public function get blur():Number
		{
			return _p.second;
		}
		
		public function get filters():Vector.<GlowFilter>
		{
			var vector:Vector.<GlowFilter> = new Vector.<GlowFilter>();
			
			if(!isNaN(color) && color>=0){
				if(width){
					var t:Number = width;
					if(t<=1){
						t=1.1;
					}
					vector.push(new GlowFilter(color, alpha, t, t, 10000, 2));
				}
				if(blur){
					vector.push(new GlowFilter(color, alpha, blur, blur, 3, 3));
				}
			}
			return vector;
		}
		
		private var _colorDefined:Boolean = false;
		public function get colorDefined():Boolean
		{
			return _colorDefined;
		}
		public function set colorDefined(p_bool:Boolean):void
		{
			_colorDefined = p_bool;
		}
		
		private var _p:NumberPair;
		
		/**
		 * % sizes are not valid unless this has been set.
		 * 
		 * @param p_width
		 * @param p_height
		 * 
		 */		
		public function setContext(p_width:Number, p_height:Number):void
		{
			_p.setContext(p_width, p_height);
		}
		
		/**
		 * em sizes are not valid unless this has been set.
		 * 
		 * @param p_width
		 * @param p_height
		 * 
		 */		
		public function setFontContext(p_width:Number, p_height:Number):void
		{
			_p.setFontContext(p_width, p_height);
		}
		
		/**
		 * Create an absolute text outline
		 * 
		 * @param p_color
		 * @param p_width
		 * @param p_blur
		 * 
		 */		
		public function TextOutline(...p_args)
		{
			switch(p_args.length)
			{
				case 3:
					if( p_args[0] is Number
						&& p_args[1] is Number
						&& p_args[2] is Number)
					{
						color = p_args[0];
						_p = new NumberPair(p_args[1]+"px "+p_args[2]+"px");
						colorDefined = true;
					}
					break;
				case 1:
					if(p_args[0] is String)
					{	
						if (p_args[0] == "none")
						{
							color = 0x000000;
							_p = new NumberPair("0px");
							return;
						}
						
						var matches:Array = [],
							match:Object,
							expression:String = p_args[0];
						while(match = textOutlineRegExp.exec(expression))
						{
							matches.push(match);
						}
						if(matches.length>0){
							var colorExpression:ColorExpression;
							try
							{
								// treat first component as a color
								colorExpression = ColorExpression.parse(matches[0][0]);
								color = colorExpression.color;
								alpha = colorExpression.alpha;
								colorDefined = true;
							}catch(err:SMPTETTException){}
							
							if(matches.length==3)
							{
								_p = new NumberPair(matches[matches.length-2][0] + " " + matches[matches.length-1][0]);
							} else if(matches.length==2 && colorDefined)
							{										
								_p = new NumberPair(matches[1][0] + " 0px");
							} else if(matches.length==2 && !colorDefined)
							{
								_p = new NumberPair(matches[0][0] + " " + matches[1][0]);
							} else if(matches.length==1)
							{
								_p = new NumberPair(matches[0][0] + " 0px");
							} else {
								throw ( new SMPTETTException("invalid outline expression") );
							}
						}
					}
					break;
			}
		}
	}
}