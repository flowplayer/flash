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
package org.osmf.captioning.loader
{
	import org.osmf.captioning.model.CaptioningDocument;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	
	public class CaptioningLoadTrait extends LoadTrait
	{
		public function CaptioningLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
		}

		public function get document():CaptioningDocument
		{
			return _document;
		}
		
		public function set document(value:CaptioningDocument):void
		{
			_document = value;
		}

		private var _document:CaptioningDocument;
	}
}