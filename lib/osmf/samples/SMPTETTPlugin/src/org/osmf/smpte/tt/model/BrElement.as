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
	import org.osmf.smpte.tt.formatting.FormattingObject;
	import org.osmf.smpte.tt.formatting.InlineContent;
	import org.osmf.smpte.tt.model.metadata.MetadataElement;
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.smpte.tt.timing.TreeType;
	
	public class BrElement extends AnonymousSpanElement
	{
		public function BrElement()
		{
			super("\n");
		}
		
		//{ region Formatting
		/**
		 * Return formatting object for br element
		 * 
		 * @param regionId
		 * @param tick
		 */
		public override function getFormattingObject(tick:TimeCode):FormattingObject
		{
			if (temporallyActive(tick))
			{
				return new InlineContent(this);
			}
			return null;
		}
		//} endregion
		
		//{ region validity
		/*
		<br
		style = IDREFS
		xml:id = ID
		xml:lang = string
		xml:space = (default|preserve)
		{any attribute in TT Metadata namespace ...}
		{any attribute in TT Style namespace ...}
		{any attribute not in default or any TT namespace ...}>
		Content: Metadata.class*, Animation.class*
		</br>
		*/
		/**
		 * Check validity of br element attributes
		 */
		protected override function validAttributes():void
		{
			validateAttributes(false, true, true, false, false, false);
		}
		
		/**
		 * check validity of br element content model
		 */
		protected override function validElements():void
		{
			var child:uint = 0;
			//{ region Check each of the children is individually valid
			for each (var element:TimedTextElementBase in children)
			{
				if (element is org.osmf.smpte.tt.model.MetadataElement
					|| element is org.osmf.smpte.tt.model.metadata.MetadataElement
					|| element is SetElement)
				{
					child++;
					element.valid();
				} else
				{
					error(element + " is not allowed in " + this + " at position " + (children.length-child));
					continue;
				}	
			}
			//} endregion
		}
		//} endregion
	}
}