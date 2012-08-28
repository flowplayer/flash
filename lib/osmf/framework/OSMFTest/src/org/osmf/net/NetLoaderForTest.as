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
package org.osmf.net
{
	/**
	 * The solo purpose of having this class is to allow the setting of reconnectStreams.
	 */
	public class NetLoaderForTest extends NetLoader
	{
		public function NetLoaderForTest(factory:NetConnectionFactoryBase=null, reconnectStreams:Boolean=true)
		{
			super(factory);
			
			CONFIG::FLASH_10_1	
			{
				super.setReconnectStreams(reconnectStreams);
			}
		}
		
	}
}