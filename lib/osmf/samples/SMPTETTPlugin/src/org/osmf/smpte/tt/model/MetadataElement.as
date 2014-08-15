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
package org.osmf.smpte.tt.model
{
	import org.osmf.smpte.tt.model.metadata.MetadataElement;
	import org.osmf.smpte.tt.timing.TreeType;
	
	public class MetadataElement extends TimedTextElementBase 
	{
		public function MetadataElement()
		{
		}

		//{ region Validity
		/*
		<metadata
		xml:id = ID
		xml:lang = string
		xml:space = (default|preserve)
		{any attribute in TT Metadata namespace ...}
		{any attribute not in default or any TT namespace ...}>
		Content: {any element not in TT namespace}*
		</metadata>
		*/
		/**
		 * Check validity of metadata element attributes
		 */
		protected override function validAttributes():void
		{
			validateAttributes(false, true, false, false, false, false);
		}
		
		/**
		 * Check validity of metadata content model
		 */
		protected override function validElements():void
		{
			var child:uint = 0;
			var childElement:TreeType;
			//{ region Ensure the children are not tt elements.
			while (child < children.length)
			{
				childElement = children[child];
				if (childElement is org.osmf.smpte.tt.model.metadata.MetadataElement
					|| !(childElement is TimedTextElementBase))
				{
					child++;
				}
			}
			//} endregion
			
			//{ region Ensure no other elements are present
			if (children.length != child)
			{
				error(children[child] + " is not allowed in " + this + " at position " + child);
			}
			//} endregion
			
			// can't check the validity of other children as they are not TT
		}
		//} endregion
	}
}