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
package org.osmf.utils
{
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaError;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DRMTrait;

	public class DynamicDRMTrait extends DRMTrait
	{
		public function DynamicDRMTrait()
		{
			super();
		}
				
		override public function authenticate(username:String=null, password:String=null):void
		{
			invokeDrmStateChange(DRMState.AUTHENTICATING, null, null);
			if (username == null)
			{				
				invokeDrmStateChange(DRMState.AUTHENTICATION_ERROR, null, null);
			}
			else
			{				
				invokeDrmStateChange(DRMState.AUTHENTICATION_COMPLETE, null, null);
			}
		}

		override public function authenticateWithToken(token:Object):void
		{		
			invokeDrmStateChange(DRMState.AUTHENTICATING, token, null);
			if (token == null)
			{				
				invokeDrmStateChange(DRMState.AUTHENTICATION_ERROR, null, null);
			}
			else
			{				
				invokeDrmStateChange(DRMState.AUTHENTICATION_COMPLETE, token, null);
			}
		}
		
		public function invokeDrmStateChange(state:String,  token:Object, error:MediaError, start:Date = null, end:Date = null, period:Number = NaN, serverURL:String = null):void
		{		
			setStartDate(start);
			setEndDate(end);
			setPeriod(period);
			setDrmState(state);	
			dispatchEvent(new DRMEvent(DRMEvent.DRM_STATE_CHANGE, state,false, false, start, end, period,  serverURL, token, error));
		}
				
		
	}
}