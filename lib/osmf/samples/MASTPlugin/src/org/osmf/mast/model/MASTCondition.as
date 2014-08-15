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
*  Contributor(s): Akamai Technologies
*  
*****************************************************/
package org.osmf.mast.model
{
	import __AS3__.vec.Vector;
	
	import org.osmf.mast.types.MASTConditionOperator;
	import org.osmf.mast.types.MASTConditionType;
	
	/**
	 * Condition defined in a MAST document.
	 **/
	public class MASTCondition
	{	
		/**
		 * Constructor.
		 * 
		 * @param type Specifies the type of condition as defined by the constants in the MASTConditionType class.
		 * @param name The name of the property or event to be used in evaluation.
		 * @param value The value that a property will be evaluated against.
		 * @param operator The operator to use during evaluation as defined by the constants in the MASTConditionOperator class.
		 * @param childConditions Any child conditions present in the MAST document.
		 */
		public function MASTCondition(type:MASTConditionType, name:String, value:String=null, 
										operator:MASTConditionOperator=null, childConditions:Vector.<MASTCondition>=null)
		{
			// EVENT conditions don't take most other params.
			if (type == MASTConditionType.EVENT && ((name == null) || (name.length == 0)))
			{
				throw new ArgumentError();
			}
			// PROPERTY conditions do take most other params.
			else if (type == MASTConditionType.PROPERTY	&&	(((value == null) || (value.length == 0)) || operator == null))
			{
				throw new ArgumentError();
			}
			
			_type = type;
			_name = name;
			_value = value;
			_operator = operator;
			_childConditions = childConditions;
		}

		/**
		 * The type of condition as defined by the constants
		 * in the MASTConditionType class.
		 */
		public function get type():MASTConditionType
		{
			return _type;
		}

		public function get name():String
		{
			return _name;
		}

		/**
		 * The value that a property condition will be evaluated against.
		 */
		public function get value():Object
		{
			return _value;
		}

		/**
		 * The operator to use during evaluation as defined by the constants
		 * in the MASTConditionOperator class.
		 */
		public function get operator():MASTConditionOperator
		{
			return _operator;
		}

		public function get childConditions():Vector.<MASTCondition>
		{
			return _childConditions;
		}
		
		private var _type:MASTConditionType;
		private var _name:String;
		private var _value:String;
		private var _operator:MASTConditionOperator;
		private var _childConditions:Vector.<MASTCondition>;
	}
}
