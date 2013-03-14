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
	import org.osmf.smpte.tt.styling.Extent;

	public class Root extends FormattingObject
	{
		public function Root(p_element:TimedTextElementBase)
		{
			element = p_element;
		}
		
		/**
		 * Retun a formatting function for this element.
		 */
		public override function createFormatter():Function
		{
			var func:Function = function(renderObject:IRenderObject):void
				{
					computeRelativeStyles(renderObject);
					var e:Extent = new Extent(renderObject.width(), renderObject.height());               
					element.setLocalStyle("extent", e);
					
					renderObject.clear(colorStyleProperty);
					
					for each (var child:* in children)
					{
						var fmt:FormattingObject = child as FormattingObject;
						fmt.createFormatter()(renderObject);
					}
					return;
				};
			return func;
		}
	}
}