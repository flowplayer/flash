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
package org.osmf.net.drm
{
	import flash.utils.ByteArray;
	
	import flexunit.framework.Assert;
	
	public class TestDRMServices
	{
		[Test(description="Using a null or an empty token")]
		public function convertEmptyTokens():void
		{
			CONFIG::FLASH_10_1
			{
				var token:ByteArray = null;
				
				token = DRMServices.convertToken(null);
				Assert.assertEquals(token, null);
				
				token = DRMServices.convertToken("");
				Assert.assertEquals(token, null);
			}
		}
		
		[Test(description="Using a byte array token. Conversion shouldn't happen.")]
		public function convertByteArrayTokens():void
		{
			CONFIG::FLASH_10_1
			{
				var token:ByteArray = null;
				
				var originalToken:ByteArray = new ByteArray();
				token = DRMServices.convertToken(originalToken);
				Assert.assertEquals(token, originalToken);
				
				originalToken.writeUTFBytes(DEFAULT_TOKEN_DATA);
				token = DRMServices.convertToken(originalToken);
				Assert.assertEquals(token, originalToken);
			}
		}
		
		[Test(description="Using a string as token. The string content should be serialized as a byte array.")]
		public function convertStringToken():void
		{
			CONFIG::FLASH_10_1
			{
				var token:ByteArray = null;
				
				token = DRMServices.convertToken(DEFAULT_TOKEN_DATA);
				Assert.assertNotNull(token);
				Assert.assertEquals(token.bytesAvailable, DEFAULT_TOKEN_DATA_LEN);
				Assert.assertEquals(token.length, DEFAULT_TOKEN_DATA_LEN);
				Assert.assertEquals(token.toString(), DEFAULT_TOKEN_DATA);
				
				token = DRMServices.convertToken(LONGER_TOKEN_DATA);
				Assert.assertNotNull(token);
				Assert.assertEquals(token.bytesAvailable, LONGER_TOKEN_DATA_LEN);
				Assert.assertEquals(token.length, LONGER_TOKEN_DATA_LEN);
				Assert.assertEquals(token.toString(), LONGER_TOKEN_DATA);
			}
		}
		
		/// Internals
		private static const DEFAULT_TOKEN_DATA:String = "1234";
		private static const DEFAULT_TOKEN_DATA_LEN:int = 4;
		private static const LONGER_TOKEN_DATA:String = "0123456789";
		private static const LONGER_TOKEN_DATA_LEN:int = 10;
	}
}