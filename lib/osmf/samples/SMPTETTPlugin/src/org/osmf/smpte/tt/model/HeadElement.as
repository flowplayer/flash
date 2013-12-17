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
	import org.osmf.smpte.tt.model.parameter.ProfileElement;
	import org.osmf.smpte.tt.timing.TimeTree;
	import org.osmf.smpte.tt.timing.TreeType;
	import org.osmf.smpte.tt.vocabulary.Styling;
	
	public class HeadElement extends TimedTextElementBase
	{
		public function HeadElement()
		{
		}
		
		//{ region validity
		/*
		<head
		xml:id = ID
		xml:lang = string
		xml:space = (default|preserve)>
		Content: Metadata.class*,  Parameters.class*, styling?, layout?
		* 
		* what does lang mean here? 
		* why are foreign and metadata attributes not allowed?
		</head>
		*/
		/// <summary>
		/// Check the attributes of the timed text head element
		/// </summary>
		protected override function validAttributes():void
		{
			validateAttributes(false, false, false, false, false, false);
		}
		
		/// <summary>
		/// Check the validity of the timed text head element
		/// </summary>
		protected override function validElements():void
		{
			var isValid:Boolean = true;
			var child:uint = 0;
			
			var childElement:TreeType;
			//{ region allow artibtrary metadata
			while (child < children.length
				&& (children[child] is org.osmf.smpte.tt.model.MetadataElement 
					|| children[child] is org.osmf.smpte.tt.model.metadata.MetadataElement
					|| children[child] is ProfileElement))
			{
				child++;
			}
			//} endregion
			
			//{ region Allow an optional styling and optional layout element
			if (child < children.length)
			{
				if (children[child] is StylingElement)
				{
					if (children.length == (child + 1))
					{
						isValid = true;
					}
					else
					{
						isValid = (children[child + 1] is LayoutElement) && (children.length == (child + 2));
					}
				}
				else if (children[child] is LayoutElement)
				{
					isValid = (children.length == (child + 1));
				}
				else
				{
					error(children[child] + " is not allowed in " + this + " at position " + child);
				}
			}
			//} endregion
			
			if (!isValid)
			{
				error(children[child] + " is not allowed in " + this + " at position " + child);
			}
			
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