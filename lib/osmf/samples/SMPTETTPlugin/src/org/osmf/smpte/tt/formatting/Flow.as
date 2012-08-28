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
package org.osmf.smpte.tt.formatting
{
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.rendering.IRenderObject;

	public class Flow extends FormattingObject
	{
		public function Flow(p_element:TimedTextElementBase)
		{
			element = p_element;
		}
		
		/**
		 * Return a formatting function for this element.
		 */
		public override function createFormatter():Function
		{
			
			var func:Function = function(renderObject:IRenderObject):void
			{
				computeRelativeStyles(renderObject);
				var regions:Vector.<BlockContainer>  = new Vector.<BlockContainer>;
				var child:*;
				for each (child in children)
				{
					var block:BlockContainer = child as BlockContainer;
					block.applyAnimations();
					regions.push(block);
				}
				regions.sort(ZOrdering.compare);
				for each (child in regions)
				{
					(child as BlockContainer).createFormatter()(renderObject);
					(child as BlockContainer).removeAppliedAnimations();
				}
				return;
			};
			return func;
		}
	}
}