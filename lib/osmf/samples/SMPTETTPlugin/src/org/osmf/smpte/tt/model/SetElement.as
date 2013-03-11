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
	import org.osmf.smpte.tt.formatting.Animation;
	import org.osmf.smpte.tt.formatting.FormattingObject;
	import org.osmf.smpte.tt.model.metadata.MetadataElement;
	import org.osmf.smpte.tt.timing.TimeCode;
	
	public class SetElement extends TimedTextElementBase
	{
		public function SetElement()
		{
		}
		
		//{ region Formatting
		/**
		 * Return the formatting object for set element
		 * 
		 * @param regionId
		 * @param tick
		 */
		public override function getFormattingObject(tick:TimeCode):FormattingObject
		{
			
			if (temporallyActive(tick))
			{
				var animation:Animation = new Animation(this);
				return animation;
			}
			else
			{
				return null;
			}
		}
		//} endregion
		
		//{ region Validity
		/*
		<set
		begin = <timeExpression>
		dur = <timeExpression>
		end = <timeExpression>
		xml:id = ID
		xml:lang = string
		xml:space = (default|preserve)
		{a single attribute in TT Style or TT Style Extension namespace}
		{any attribute not in default or any TT namespace ...}>
		Content: Metadata.class*
		</set>
		*/
		/**
		 *  Check validity of set element attributes
		 */
		protected override function validAttributes():void
		{
			validateAttributes(false, false, true, true, false, false);
		}
		
		/**
		 *  Check validity of set element content model
		 */
		protected override function validElements():void
		{
			var child:uint = 0;
			//{ region Check each of the children is individually valid
			for each (var element:TimedTextElementBase in children)
			{
				if (element is org.osmf.smpte.tt.model.MetadataElement 
					|| element is org.osmf.smpte.tt.model.metadata.MetadataElement)
				{
					child++;
					element.valid();
				} else 
				{
					error(element + " is not allowed in " + this + " at position " + (children.length-child));
				}
			}
			//} endregion
		}
		//} endregion
	}
}