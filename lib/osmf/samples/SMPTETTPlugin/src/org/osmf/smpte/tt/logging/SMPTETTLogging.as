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
package org.osmf.smpte.tt.logging
{	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
	}
	public class SMPTETTLogging
	{
		public static function debugLog(msg:String):void
		{
			CONFIG::LOGGING
			{
				if (logger != null)
				{					
					logger.debug(msg);
				}
			}
		}
		
		CONFIG::LOGGING
		{	
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.smpte.tt.SMPTETTPlugin");		
		}
	}
}