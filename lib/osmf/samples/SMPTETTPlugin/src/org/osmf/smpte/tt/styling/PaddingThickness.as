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
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.smpte.tt.enums.Unit;
	import org.osmf.smpte.tt.errors.SMPTETTException;

	public class PaddingThickness
	{
		private static var _cache:Dictionary = new Dictionary();
		public static function getPaddingThickness(value:*):PaddingThickness
		{
			if (_cache[value] !== undefined)
			{
				return _cache[value];
			}
			else
			{
				var paddingThickness:PaddingThickness = new PaddingThickness(value);
				_cache[value] = paddingThickness;
				return paddingThickness;
			}
		}
		
		/* MORE GROUPS
		/(?P<sign>[\+|\-]?)(?P<value>[0-9]+(?:\.[0-9]*)?)(?P<units>%|px|em|c)?\s*?/gi;
		*/
		private static const paddingRegExp:RegExp = /(?:[\+|\-]?)(?:[0-9]+(?:\.[0-9]*)?)(?:%|px|em|c)?\s*?/gi;
		
		public var p1:NumberPair;
		public var p2:NumberPair;
		
		public function get widthBefore():Number
		{
			return p1.first;	
		}
		public function get widthBeforeUnit():Unit
		{
			return p1.unitMeasureHorizontal;	
		}
		public function get widthAfter():Number
		{
			return p1.second;	
		}
		public function get widthAfterUnit():Unit
		{
			return p1.unitMeasureVertical;	
		}
		public function get widthStart():Number
		{
			return p2.first;	
		}
		public function get widthStartUnit():Unit
		{
			return p2.unitMeasureHorizontal;	
		}
		public function get widthEnd():Number
		{
			return p2.second;	
		}
		public function get widthEndUnit():Unit
		{
			return p2.unitMeasureVertical;	
		}
		
		/**
		 * % sizes are not valid unless this has been set.
		 *
		 *	@param p_width
		 *	@param p_height
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public function setContext(p_width:Number, p_height:Number):void
		{
			p1.setContext(p_height,p_height);
			p2.setContext(p_width,p_width);
		}
		
		/**
		 * em sizes are not valid unless this has been set.
		 *
		 *	@param p_width
		 *	@param p_height
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public function setFontContext(p_width:Number, p_height:Number):void
		{
			p1.setFontContext(p_height,p_height);
			p2.setFontContext(p_width,p_width);
		}
		
		/**
		 * Parse a padding thickness expression
		 *
		 *	@param p_expression
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public function PaddingThickness(p_expression:String)
		{
			var matches:Array = [],
				match:Object;
			while(match = PaddingThickness.paddingRegExp.exec(p_expression)){
				matches.push(match)
			}
			if(matches.length==4)
			{
				// If four <length> specifications are provided, then they apply to before, end, after, and start edges, respectively.
				p1 = new NumberPair(matches[0] + " " + matches[2]);
				p2 = new NumberPair(matches[3] + " " + matches[1]);
			} else if(matches.length == 3)
			{
				// If three <length> specifications are provided, then the first applies to the
				// before edge, the second applies to the start and end edges, and the third 
				// applies to the after edge
				p1 = new NumberPair(matches[0] + " " + matches[2]);
				p2 = new NumberPair(matches[1] + " " + matches[1]);
			} else if(matches.length == 2)
			{
				// If the value consists of two <length> specifications, then the first applies 
				// to the before and after edges, and the second applies to the start and end edges
				p1 = new NumberPair(matches[0] + " " + matches[0]);
				p2 = new NumberPair(matches[1] + " " + matches[1]);
			} else if(matches.length == 1)
			{
				p1 = new NumberPair(matches[0] + " " + matches[0]);
				p2 = new NumberPair(matches[0] + " " + matches[0]);
			} else {
				throw new org.osmf.smpte.tt.errors.SMPTETTException("Invalid padding expression");
			}	
		}
		
		public function isEmpty():Boolean
		{
			return(p1.isEmpty() && p2.isEmpty());
		}
		
		public function toString():String
		{
			var expression:String = "["+( typeof this) +" "+flash.utils.getQualifiedClassName(this)+"] ";
			if(p1.isEmpty() && p2.isEmpty())
			{
				return expression;
			} else
			{
				return expression+p1.toString()+" "+p2.toString();
			}
		}
	}
}