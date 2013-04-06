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
	import org.osmf.smpte.tt.formatting.Block;
	import org.osmf.smpte.tt.formatting.FormattingObject;
	import org.osmf.smpte.tt.model.metadata.MetadataElement;
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.smpte.tt.timing.TimeContainer;
	
	public class BodyElement extends TimedTextElementBase
	{
		public function BodyElement()
		{
			timeSemantics = TimeContainer.PAR;
		}
		
		//{ region Formatting
		/**
		 * Get formatting object for body element
		 * 
		 * @param regionId
		 * @param tick
		 */
		public override function getFormattingObject(tick:TimeCode):FormattingObject
		{
			
			var block:Block = null;
			
			if (temporallyActive(tick))
			{
				block = new Block(this);
				
				for each (var child:TimedTextElementBase in children)
				{
					var fo:FormattingObject;
					if (child is DivElement)
					{
						fo = DivElement(child).getFormattingObject(tick);
						if (fo != null)
						{
							fo.parent = block;
							block.children.push(fo);
						}
					}
					
					if (child is SetElement)
					{
						fo = SetElement(child).getFormattingObject(tick) as Animation;
						if (fo != null)
						{
							block.animations.push(fo);
						}
					}
				}
			}
			return block;
		}
		//} endregion
		
		//{ region Validity
		/*
		<body
		begin = <timeExpression>
		dur = <timeExpression>
		end = <timeExpression>
		region = IDREF
		style = IDREFS
		timeContainer = (par|seq)
		xml:id = ID
		xml:lang = string
		xml:space = (default|preserve)
		{any attribute in TT Metadata namespace ...}
		{any attribute in TT Style namespace ...}
		{any attribute not in default or any TT namespace ...}>
		Content: Metadata.class*, Animation.class*, div*
		</body>
		*/
		
		/**
		 * Validate body element attributes
		 */
		protected override function validAttributes():void
		{
			validateAttributes(false, true, true, true, true, true);
		}
		
		/**
		 * Validate body element content model
		 */
		protected override function validElements():void
		{
			var child:uint = 0;
			//{ region Check each of the children is individually valid
			for each (var element:TimedTextElementBase in children)
			{
				if (element is org.osmf.smpte.tt.model.MetadataElement 
					|| element is org.osmf.smpte.tt.model.metadata.MetadataElement
					|| element is SetElement
					|| element is DivElement)
				{
					child++;
					element.valid();
				}
				else
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