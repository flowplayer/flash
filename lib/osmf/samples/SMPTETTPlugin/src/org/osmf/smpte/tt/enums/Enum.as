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
package org.osmf.smpte.tt.enums
{	
	import flash.utils.*;

	public class Enum
	{
		public function get name():String { return _name; }
		public function get index():int { return _index; }
		
		public function toString():String { return name; }
		
		public static function getConstants(i_type:Class):Array
		{
			var constants:EnumConstants = _enumDb[getQualifiedClassName(i_type)];
			if (constants == null)
				return null;
			return constants.byIndex.slice();
		}
		
		public static function parseConstant(
			i_type:Class,
			i_constantName:String,
			i_caseSensitive:Boolean = false):Enum
		{
			var constants:EnumConstants = _enumDb[getQualifiedClassName(i_type)];
			if (constants == null)
				return null;
			
			var constant:Enum = constants.byName[i_constantName.toLowerCase()];
			if (i_caseSensitive && (constant != null) && (i_constantName != constant.name))
				return null;
			
			return constant;
		}
				
		public function Enum()
		{
			var typeName:String = getQualifiedClassName(this);
			
			if (_enumDb[typeName] != null)
			{
				throw new Error("Enum constants can only be constructed as static consts in their own enum class (bad type='" + typeName + "')");
			}
			
			var constants:Array = _pendingDb[typeName];
			if (constants == null)
				_pendingDb[typeName] = constants = [];
			
			_index = constants.length;
			constants.push(this);
		}
		
		protected static function initEnum(i_type:Class):void
		{
			var typeName:String = getQualifiedClassName(i_type);
			
			if (_enumDb[typeName] != null)
			{
				throw new Error("Can't initialize enum twice (type='" + typeName + "')");
			}
			
			var constants:Array = _pendingDb[typeName];
			if (constants == null)
			{
				throw new Error("Can't have an enum without any constants (type='" +typeName + "')");
			}
			
			var type:XML = flash.utils.describeType(i_type);
			for each (var constant:XML in type.constant)
			{
				var enumConstant:Enum = i_type[constant.@name];
				
				var enumConstantType:* = Object(enumConstant).constructor;
				if (enumConstantType != i_type)
				{
					throw new Error("Constant type '" + enumConstantType + "' does not match its enum class '" + i_type + "'");
				}
				
				enumConstant._name = constant.@name;
			}
			
			_pendingDb[typeName] = null;
			_enumDb[typeName] = new EnumConstants(constants);
		}
		
		private var _name:String = null;
		private var _index:int = -1;
		
		private static var _pendingDb:Object = {};
		private static var _enumDb:Object = {};
	}
}

class EnumConstants
{
	import org.osmf.smpte.tt.enums.Enum;
	public function EnumConstants(i_byIndex:Array)
	{
		byIndex = i_byIndex;
		
		for (var i:int = 0; i < byIndex.length; ++i)
		{
			var enumConstant:Enum = byIndex[i];
			byName[enumConstant.name.toLowerCase()] = enumConstant;
		}
	}
	
	public var byIndex:Array;
	public var byName:Object = {};
}
