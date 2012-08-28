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
	import org.osmf.smpte.tt.formatting.BlockContainer;
	import org.osmf.smpte.tt.formatting.FormattingObject;
	import org.osmf.smpte.tt.model.metadata.MetadataElement;
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.smpte.tt.timing.TimeContainer;
	
	public class RegionElement extends TimedTextElementBase
	{
		public function RegionElement()
		{
			timeSemantics = TimeContainer.PAR;
		}
		
		//{ region Constants
		/**
		 * Name for region if none is specified
		 */
		public static const DEFAULT_REGION_NAME:String = "default region";
		//} endregion
		

		
		//{ region Formatting
		/**
		 * Return formatting object for region element
		 * 
		 * @param regionId
		 * @param tick
		 */
		public override function getFormattingObject(tick:TimeCode):FormattingObject
		{
			if (temporallyActive(tick))
			{
				return new BlockContainer(this);
			}
			else
			{
				return null;
			}
		}
		//} endregion
		
		//{ region Validity
		/*
		<region
		begin = <timeExpression>
		dur = <timeExpression>
		end = <timeExpression>
		style = IDREFS
		timeContainer = (par|seq)
		xml:id = ID
		xml:lang = string
		xml:space = (default|preserve)
		{any attribute in TT Style namespace ...}
		{any attribute not in default or any TT namespace ...}>
		Content: Metadata.class*, Animation.class*, style*
		</region>
		*/
		
		/**
		 * Check validity of region element attributes
		 */
		protected override function validAttributes():void
		{
			validateAttributes(false, true, true, true, false, true);
		}
		
		/**
		 * Check vlidity of region element content model
		 */
		protected override function validElements():void
		{
			var child:uint = 0;
			
			//{ region Allow arbitrary metadata
			while ((child < children.length)
				&& ((children[child] is org.osmf.smpte.tt.model.MetadataElement) 
					|| (children[child] is org.osmf.smpte.tt.model.metadata.MetadataElement)))
			{
				child++;
			}
			//} endregion
			
			//{ region Allow arbitrary set element (Animation class)
			while ((child < children.length)
				&& (children[child] is SetElement))
			{
				child++;
			}
			//} endregion
			
			//{ region Allow arbitrary style elements
			while ((child < children.length)
				&& (children[child] is StyleElement)
			)
			{
				var s:StyleElement = children[child] as StyleElement;
				//{ region copy nested style attributes over as if they were inline
				for each (var a:* in s.attributes)
				{
					// we should really check if its already defined, however
					// by adding at the start we ensure the later (inline)
					// style will override.
					this.attributes.unshift(a);
				}
				//} endregion
				child++;
			}
			//} endregion
			
			//{ region Ensure no other element is present
			if (children.length != child)
			{
				error(children[child] + " is not allowed in " + this+ " at position " + child);
			}
			//} endregion
			
			//{ region Check each of the children is individually valid
			for each (var element:TimedTextElementBase in children)
			{
				element.valid();
			}
			//} endregion
			
		}
		//} endregion
	}
}