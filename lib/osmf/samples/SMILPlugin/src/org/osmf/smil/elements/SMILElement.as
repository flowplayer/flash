/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.smil.elements
{
	import org.osmf.elements.LoadFromDocumentElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.smil.loader.SMILLoader;

	public class SMILElement extends LoadFromDocumentElement
	{
		public function SMILElement(resource:MediaResourceBase = null, loader:SMILLoader = null)
		{
			if (loader == null)
			{
				loader = new SMILLoader();
			}
			super(resource, loader);		
		}
		
	}
}