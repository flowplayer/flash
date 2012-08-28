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
package org.osmf.layout
{
	import org.flexunit.Assert;
	
	public class TestBinarySearch
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testBinarySearch():void
		{			
			Assert.assertTrue
			( throws
				( function():void
				{
					BinarySearch.search(null, function(..._):int{return 0}, null);
				}
				)
			);
			
			Assert.assertTrue
			( throws
				( function():void
				{
					BinarySearch.search(new Vector.<int>(), null, null);
				}
				)
			);
			
			var list:Vector.<int> = new Vector.<int>();
			
			Assert.assertEquals(0, BinarySearch.search(list, compare, 1));
			
			list.push(1);			// [1]
			
			Assert.assertEquals(0, BinarySearch.search(list, compare, 1));
			Assert.assertEquals(-1, BinarySearch.search(list, compare, 2));
			
			list.push(10);			// [1,10]
			list.push(15);			// [1,10,15]
			
			Assert.assertEquals(1, BinarySearch.search(list, compare, 10));
			Assert.assertEquals(2, BinarySearch.search(list, compare, 15));
			Assert.assertEquals(-2, BinarySearch.search(list, compare, 11));
			
			list.splice(2,0,11);	// [1,10,11,15]
			
			Assert.assertEquals(-1, BinarySearch.search(list, compare, 2));
			
			list.splice(1,0,2);		// [1,2,10,11,15]
			
			Assert.assertEquals(1, BinarySearch.search(list, compare, 2));
			
			list.splice(1,0,2);		// [1,2,2,10,11,15]
			
			Assert.assertEquals(-3, BinarySearch.search(list, compare, 3));
		}
		
		private function compare(x:int,y:int):int
		{
			return (x == y)
			? 0
				: x > y 
				? 1
				: -1;
		}
		
		private function throws(f:Function):Boolean
		{
			var result:Boolean;
			
			try
			{
				f();
			}
			catch(e:Error)
			{
				result = true;
			}
			
			return result;
		}
	}
}