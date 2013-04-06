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
package org.osmf.mast.types
{
	/**
	 * This class represents the valid operator values for a MAST
	 * document.
	 */
	public class MASTConditionOperator
	{
		public static const EQ:MASTConditionOperator 	= new MASTConditionOperator("EQ");
		public static const NEQ:MASTConditionOperator 	= new MASTConditionOperator("NEQ");
		public static const GTR:MASTConditionOperator 	= new MASTConditionOperator("GTR");
		public static const GEQ:MASTConditionOperator 	= new MASTConditionOperator("GEQ");
		public static const LT:MASTConditionOperator 	= new MASTConditionOperator("LT");
		public static const LEQ:MASTConditionOperator 	= new MASTConditionOperator("LEQ");
		public static const MOD:MASTConditionOperator 	= new MASTConditionOperator("MOD");
		
		/**
		 * @private
		 **/
		public function MASTConditionOperator(operator:String)
		{
			_operator = operator;
		}
		
		/**
		 * Returns string value of the operator.
		 */
		public function get operator():String
		{
			return _operator;
		}
		
		private var _operator:String;
	}
}
