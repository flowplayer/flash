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
	public class DictionaryUtils
	{
		import flash.utils.Dictionary;
			
		/**
		 * Check whether the given dictionary contains the given key.
		 *
		 * @param dictionary the dictionary to check for a key
		 * @param key the key to look up in the dictionary
		 * @return <code>true</code> if the dictionary contains the given key, <code>false</code> if not
		 */
		public static function containsKey(d:Dictionary, key:Object):Boolean {
			var result:Boolean = false;
			
			for (var k:* in d) {
				if (key === k) {
					result = true;
					break;
				}
			}
			return result;
		}
		
		/**
		 * Check whether the given dictionary contains the given value.
		 *
		 * @param dictionary the dictionary to check for a value
		 * @param value the value to look up in the dictionary
		 * @return <code>true</code> if the dictionary contains the given value, <code>false</code> if not
		 */
		public static function containsValue(d:Dictionary, value:Object):Boolean {
			var result:Boolean = false;
			
			for each (var i:* in d) {
				if (i === value) {
					result = true;
					break;
				}
			}
			return result;
		}
		
		/**
		 *       Returns an Array of all keys within the specified dictionary.   
		 * 
		 *       @param d The Dictionary instance whose keys will be returned.
		 * 
		 *       @return Array of keys contained within the Dictionary
		 *
		 *       @langversion ActionScript 3.0
		 *       @playerversion Flash 9.0
		 *       @tiptext
		 */                                      
		public static function getKeys(d:Dictionary):Array
		{
			var a:Array = new Array();
			
			for (var key:* in d)
			{
				a.push(key);
			}
			
			return a;
		}
		
		/**
		 *       Returns an Array of all values within the specified dictionary.         
		 * 
		 *       @param d The Dictionary instance whose values will be returned.
		 * 
		 *       @return Array of values contained within the Dictionary
		 *
		 *       @langversion ActionScript 3.0
		 *       @playerversion Flash 9.0
		 *       @tiptext
		 */                                      
		public static function getValues(d:Dictionary):Array
		{
			var a:Array = new Array();
			
			for each (var value:* in d)
			{
				a.push(value);
			}
			
			return a;
		}
		
		/**
		 *       Returns an Array of all values within the specified dictionary.         
		 * 
		 *       @param d The Dictionary instance whose values will be returned.
		 * 
		 *       @return Array of values contained within the Dictionary
		 *
		 *       @langversion ActionScript 3.0
		 *       @playerversion Flash 9.0
		 *       @tiptext
		 */                                      
		public static function getLength(d:Dictionary):uint
		{
			var len:uint = 0;
			
			for (var key:* in d)
			{
				len++
			}
			
			return len;
		}
		
		/**
		 *       Clears the Dictionary by deleting all key=>value pairs.        
		 * 
		 *       @param d The Dictionary instance to clear.
		 *
		 *       @langversion ActionScript 3.0
		 *       @playerversion Flash 9.0
		 *       @tiptext
		 */ 
		public static function clear(d:Dictionary):void
		{
			for (var key:* in d)
			{
				delete d[key];
			}
		}
	}
}