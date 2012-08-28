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
package org.osmf.smpte.tt.utilities
{
	public class VectorUtils
	{
		/**
		 * Converts vector to an array
		 * @param       vector:*        vector to be converted
		 * @return      Array           converted array
		 */
		public static function toArray(vector:*):Array
		{
			var n:int = vector.length; var a:Array = [];
			for(var i:int = 0; i < n; i++) a[i] = vector[i];
			return a;
		}
		
		/**
		 * Converts vector to an array and sorts it by a certain fieldName, options
		 * for more info @see Array.sortOn
		 * 
		 * @param       vector:*                the source vector
		 * @param       fieldName:Object        a string that identifies a field to be used as the sort value
		 * @param       options:Object          one or more numbers or names of defined constants
		 */
		public static function sortOn(vector:*, fieldName:Object, options:Object = null):Array
		{
			return toArray(vector).sortOn(fieldName, options);
		}
		
		/**
		 * Remove an item from a vector
		 * 
		 * @param       vector:*               the source vector
		 * @param       item:Object            a string that identifies a field to be used as the sort value
		 * @returns                            the new length of the vector array
		 */
		public static function removeItem(vector:*, item:*):uint
		{
			var i:int = vector.indexOf(item);
			var f:uint = 0;
			var _fixed:Boolean = vector.fixed;
			
			vector.fixed = false;
			
			while (i != -1)
			{
				vector.splice(i, 1);
				i = vector.indexOf(item, i);
				f++;
			}
			
			vector.fixed = _fixed;
			
			return f;
		}

	}
}