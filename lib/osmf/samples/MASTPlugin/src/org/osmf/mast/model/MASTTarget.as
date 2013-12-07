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
	 * Represents a target object in a MAST document.
	 */
	public class MASTTarget
	{
		/**
		 * Constructor.
		 * 
		 * @param id The type of target, can be used for keying particular payload items to a target.
		 * @param regionName A named region / container or other target that can be used by a player.
		 */
		public function MASTTarget(id:String, regionName:String)
		{
			_id = id;
			_regionName = regionName;
		
		}
		
		/**
		 * The type of target, can be used for keying particular payload items to a target.
		 */
		public function get id():String
		{
			return _id;
		}

		/**
		 * A named region / container or other target that can be used by a player.
		 */
		public function get regionName():String
		{
			return _regionName;
		}

		/**
		 * Child targets for this target.
		 */
		public function get targets():Vector.<MASTTarget>
		{
			return _targets;
		}
		
		/**
		 * Adds a child target to this target.
		 */
		public function addChildTarget(value:MASTTarget):void
		{
			if (_targets == null)
			{
				_targets = new Vector.<MASTTarget>();
			}
			
			_targets.push(value);
		}
		
		private var _id:String;
		private var _regionName:String;
		private var _targets:Vector.<MASTTarget>;
	}
}
