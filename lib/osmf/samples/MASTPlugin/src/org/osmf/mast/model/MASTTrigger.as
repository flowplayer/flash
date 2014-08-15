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
	
	/**
	 * Trigger defined in a MAST document.
	 **/
	public class MASTTrigger
	{
		/**
		 * Constructor.
		 *
		 * @param id A reference for this trigger.
		 * @param description User provided description, for reference purposes only
		 */
		public function MASTTrigger( id:String, description:String)
		{
			_id = id;
			_description = description;
		}

		/**
		 * Reference for this trigger.
		 */
		public function get id():String
		{
			return _id;
		}

		/**
		 * Description for this trigger.
		 */
		public function get description():String
		{
			return _description;
		}

		/**
		 * Collection of start conditions for this trigger.
		 */
		public function get startConditions():Vector.<MASTCondition>
		{
			return _startConditions;
		}

		public function set startConditions(value:Vector.<MASTCondition>):void
		{
			if (_startConditions == null)
			{
				_startConditions = new Vector.<MASTCondition>();
			}
			
			_startConditions = _startConditions.concat(value);
		}

		/**
		 * Collection of end conditions for this trigger.
		 */
		public function get endConditions():Vector.<MASTCondition>
		{
			return _endConditions;
		}

		/**
		 * Adds an end condition to the collection of end collections.
		 */
		public function set endConditions(value:Vector.<MASTCondition>):void
		{
			if (_endConditions == null)
			{
				_endConditions = new Vector.<MASTCondition>();
			}

			_endConditions = _endConditions.concat(value);
		}

		/**
		 * Collection of MAST sources for this trigger.
		 */
		public function get sources():Vector.<MASTSource>
		{
			return _sources;
		}
		
		
		/**
		 * Adds a source to the collection of sources.
		 */
		public function addSource(value:MASTSource):void
		{
			if (_sources == null)
			{
				_sources = new Vector.<MASTSource>();
			}
			
			_sources.push(value);
		}
		
		private var _id:String;
		private var _description:String;
		private var _startConditions:Vector.<MASTCondition>;
		private var _endConditions:Vector.<MASTCondition>;
		private var _sources:Vector.<MASTSource>;
	}
}
