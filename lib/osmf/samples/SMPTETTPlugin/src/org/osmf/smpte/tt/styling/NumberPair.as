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
	import org.osmf.smpte.tt.utilities.StringUtils;
	import org.osmf.smpte.tt.enums.Unit;
	
	public class NumberPair
	{
		// A few TT types are pairs of lengths, this base class models the general concept.
		/*  lots more groups
		 *	/^((?P<v1>(\+|\-)?\d+(\.\d+)?)(?P<u1>(px|em|c|\%))?)( +((?P<v2>(\+|\-)?\d+(\.\d+)?)(?P<u2>(px|em|c|\%))?))?$/ 
		 */
		public static const matchPairRE:RegExp = /^(?:(?P<v1>(?P<s1>(?:\+|\-))?\d+(?:\.\d+)?)(?P<u1>(?:px|em|c|\%))?)(?: +(?:(?P<v2>(?P<s2>(?:\+|\-))?\d+(?:\.\d+)?)(?P<u2>(?:px|em|c|\%))?))?$/;
		public static const matchRowColRE:RegExp = /^((?P<cols>\d+)\ +(?P<rows>\d+))$/;
		
		private var _unitMeasureHorizontal:Unit;
		public function get unitMeasureHorizontal():Unit
		{
			return _unitMeasureHorizontal;
		}
		public function set unitMeasureHorizontal(p_unit:Unit):void
		{
			_unitMeasureHorizontal = p_unit;
		}
		
		private var _unitMeasureVertical:Unit;
		public function get unitMeasureVertical():Unit
		{
			return _unitMeasureVertical;
		}
		public function set unitMeasureVertical(p_unit:Unit):void
		{
			_unitMeasureVertical = p_unit;
		}
		
		private static var _cellColumns:int = 32;
		public static function get cellColumns():int
		{
			return _cellColumns;
		}
		protected static function set cellColumns(p_value:int):void
		{
			_cellColumns = p_value;
		}
		
		private static var _cellRows:int = 15;
		public static function get cellRows():int
		{
			return _cellRows;
		}
		protected static function set cellRows(p_value:int):void
		{
			_cellRows = p_value;
		}
		
		/**
		 * Set the number of cells up into which to divide the render canvas
		 *
		 *	@param p_expression
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function setCellSize(p_expression:String):void
		{
			p_expression = StringUtils.trim(p_expression);
			if (matchRowColRE.test(p_expression))
			{
				var m:Array = matchRowColRE.exec(p_expression);
				if(m.cols && m.cols!=''){
					_cellColumns = parseInt(m.cols);
				}
				if(m.rows && m.rows!=''){
					_cellRows = parseInt(m.rows);
				}
			}
		}
		
		private var _isRelativeFontHorizontal:Boolean = false;
		protected function get isRelativeFontHorizontal():Boolean
		{
			return _isRelativeFontHorizontal;
		}
		protected function set isRelativeFontHorizontal(p_bool:Boolean):void
		{
			_isRelativeFontHorizontal = p_bool;
		}
		
		private var _isRelativeFontVertical:Boolean = false;
		protected function get isRelativeFontVertical():Boolean
		{
			return _isRelativeFontVertical;
		}
		protected function set isRelativeFontVertical(p_bool:Boolean):void
		{
			_isRelativeFontVertical = p_bool;
		}
		
		private var _isRelativeHorizontal:Boolean = false;
		protected function get isRelativeHorizontal():Boolean
		{
			return _isRelativeHorizontal;
		}
		protected function set isRelativeHorizontal(p_bool:Boolean):void
		{
			_isRelativeHorizontal = p_bool;
		}
		
		private var _isRelativeVertical:Boolean = false;
		protected function get isRelativeVertical():Boolean
		{
			return _isRelativeVertical;
		}
		protected function set isRelativeVertical(p_bool:Boolean):void
		{
			_isRelativeVertical = p_bool;
		}
		
		private var _horizontalFontContext:Number = 1;
		protected function get horizontalFontContext():Number
		{
			return _horizontalFontContext;
		}
		protected function set horizontalFontContext(p_value:Number):void
		{
			_horizontalFontContext = p_value;
		}
		
		private var _verticalFontContext:Number = 1;
		protected function get verticalFontContext():Number
		{
			return _verticalFontContext;
		}
		protected function set verticalFontContext(p_value:Number):void
		{
			_verticalFontContext = p_value;
		}
		
		private var _horizontalContext:Number = 1;
		protected function get horizontalContext():Number
		{
			return _horizontalContext;
		}
		protected function set horizontalContext(p_value:Number):void
		{
			_horizontalContext = p_value;
		}
		
		private var _verticalContext:Number = 1;
		protected function get verticalContext():Number
		{
			return _verticalContext;
		}
		protected function set verticalContext(p_value:Number):void
		{
			_verticalContext = p_value;
		}
		
		private var _horizontalValue:Number = 1;
		protected function get horizontalValue():Number
		{
			return _horizontalValue;
		}
		protected function set horizontalValue(p_value:Number):void
		{
			_horizontalValue = p_value;
		}
		
		private var _verticalValue:Number = 1;
		protected function get verticalValue():Number
		{
			return _verticalValue;
		}
		protected function set verticalValue(p_value:Number):void
		{
			_verticalValue = p_value;
		}
		
		public function get first():Number
		{
			if (isRelativeFontHorizontal)
			{
				return _horizontalFontContext * _horizontalValue;
			}
			else if (isRelativeVertical)
			{
				return _horizontalContext * _horizontalValue;
			}
			else
			{
				return _horizontalValue;
			}
		}
		
		public function get second():Number
		{
			if (isRelativeFontVertical)
			{
				return _verticalFontContext * _verticalValue;
			}
			else if (isRelativeVertical)
			{
				return _verticalContext * _verticalValue;
			}
			else
			{
				return _verticalValue;
			}
		}
		
		/**
		 * Parse a string in a context
		 *
		 *	@param p_expression
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public function NumberPair(p_expression:*)
		{			
			if(p_expression is NumberPair)
			{
				numberPairFromSource(p_expression as NumberPair);
				return;
			}
			
			if(p_expression is String) 
			{
				
				parse(p_expression);
				
				
			}
		}
		
		protected function parse(p_expression:String):void
		{
			p_expression = StringUtils.trim(p_expression);
			if (p_expression == "0px 0px")
			{
				unitMeasureHorizontal = Unit.PIXEL;
				isRelativeFontVertical = isRelativeFontHorizontal = false;
				isRelativeVertical = isRelativeHorizontal = false;
				unitMeasureVertical = Unit.PIXEL;
				isRelativeFontVertical = false;
				isRelativeVertical = false;
				_horizontalValue = _verticalValue = 0;
				return;
			}
			
			if (matchPairRE.test(p_expression))
			{
				var value:Number;
				var m:Array = matchPairRE.exec(p_expression);
				if(m.v1 && m.v1!='')
				{
					
					value = parseFloat(m.v1);
					switch (m.u1)
					{
						case "px":
							// this is the default internal value.
							unitMeasureHorizontal = Unit.PIXEL;
							isRelativeFontVertical = isRelativeFontHorizontal = false;
							isRelativeVertical = isRelativeHorizontal = false;
							break;
						case "em":
							unitMeasureHorizontal = Unit.EM;
							isRelativeFontVertical = isRelativeFontHorizontal = true;
							isRelativeVertical = isRelativeHorizontal = false;
							break;
						case "c":
							unitMeasureHorizontal = Unit.CELL;				
							isRelativeFontVertical = isRelativeFontHorizontal = false;
							isRelativeVertical = isRelativeHorizontal = true;
							value = (m.v2 && m.v2!='') ? value / _cellColumns : value / _cellRows;
							break;
						case "%":
							unitMeasureHorizontal = Unit.PERCENT;
							isRelativeFontVertical = isRelativeFontHorizontal = true;
							isRelativeVertical = isRelativeHorizontal = false;
							value = (value / 100);
							break;
						default:
							if(!m.u1 || m.u1=="")
							{
								if(!m.s1 || m.s1=="")
								{
									unitMeasureHorizontal = Unit.PIXEL;
									isRelativeFontVertical = isRelativeFontHorizontal = false;
									isRelativeVertical = isRelativeHorizontal = false;
								} else
								{
									unitMeasureHorizontal = Unit.EM;
									isRelativeFontVertical = isRelativeFontHorizontal = true;
									isRelativeVertical = isRelativeHorizontal = false;
									value =(m.s1=="-") ? 1/Math.pow(1.2, Math.abs(value)) : Math.pow(1.2, Math.abs(value));	
								}
							}
							break;
					}
					unitMeasureVertical = unitMeasureHorizontal;
					_horizontalValue = _verticalValue = value;
				}	
				if (m.v2 && m.v2!='')
				{
					value = parseFloat(m.v2);
					switch (m.u2)
					{
						case "px":
							// this is the default internal value.
							unitMeasureVertical = Unit.PIXEL;
							isRelativeFontVertical = false;
							isRelativeVertical = false;
							break;
						case "em":
							unitMeasureVertical = Unit.EM;
							isRelativeFontVertical = true;
							isRelativeVertical = false;
							break;
						case "c":
							unitMeasureVertical = Unit.CELL;
							isRelativeFontVertical = false;
							isRelativeVertical = true;
							value = value / _cellRows;
							break;
						case "%":
							unitMeasureVertical = Unit.PERCENT;
							isRelativeFontVertical = true;
							isRelativeVertical = false;
							value = (value / 100);
							break;
						default:
							if(!m.u2 || m.u2=="")
							{
								if(!m.s2 || m.s2=="")
								{
									unitMeasureVertical = Unit.PIXEL;
									isRelativeFontVertical = isRelativeFontHorizontal = false;
									isRelativeVertical = isRelativeHorizontal = false;
								} else
								{
									unitMeasureVertical = Unit.EM;
									isRelativeFontVertical = isRelativeFontHorizontal = true;
									isRelativeVertical = isRelativeHorizontal = false;
									value =(m.s2=="-") ? 1/Math.pow(1.2, value) : Math.pow(1.2, value);	
								}
							}
							break;
					}
					_verticalValue = value;
				}
			}
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
			_horizontalContext = p_width;
			_verticalContext = p_height;
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
			_horizontalFontContext = p_width;
			_verticalFontContext = p_height;
		}
		
		private function numberPairFromSource(p_src:NumberPair):void
		{
			unitMeasureHorizontal = p_src.unitMeasureHorizontal;
			isRelativeFontVertical = p_src.isRelativeFontVertical;
			isRelativeFontHorizontal = p_src.isRelativeFontHorizontal;
			isRelativeVertical = p_src.isRelativeVertical;
			isRelativeHorizontal = p_src.isRelativeHorizontal;
			unitMeasureVertical = p_src.unitMeasureVertical;
			isRelativeFontVertical = p_src.isRelativeFontVertical;
			isRelativeVertical = p_src.isRelativeVertical;
			_horizontalValue = p_src.horizontalValue;
			_verticalValue = p_src.verticalValue;
		}
		
		/**
		 * @returns the orginal number pair expression
		 */
		public function toString():String {
			var expression:String = "";
			if(!isNaN(_horizontalValue)){
				var hv:Number = (_unitMeasureHorizontal == Unit.PERCENT)? _horizontalValue*100 : _horizontalValue;
				expression+=hv;
				if(_unitMeasureHorizontal!=null){
					expression+=_unitMeasureHorizontal.value;
				}
			}
			if(!isNaN(_verticalValue)){
				var vv:Number = (_unitMeasureVertical == Unit.PERCENT)? _verticalValue*100 : _verticalValue;
				expression+=" "+vv;
				if(_unitMeasureVertical!=null){
					expression+=_unitMeasureVertical.value;
				}
			}
			return expression;
		}
		
		public function isEmpty():Boolean
		{
			return !first && !second;
		}
	}
}