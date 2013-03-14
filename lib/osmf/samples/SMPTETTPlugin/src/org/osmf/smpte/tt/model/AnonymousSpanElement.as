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
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.smpte.tt.timing.TimeTree;
	
	public class AnonymousSpanElement extends SpanElement 
	{	
		public function AnonymousSpanElement(p_text:String)
		{
			text = p_text;
		}
		
		public var text:String;
		
		/** 
		 * Return the formatting object for anonymous span element
		 * 
		 * @param regionId
		 * @param tick
		 */
		public override function getFormattingObject(tick:TimeCode):FormattingObject
		{
			if (this.temporallyActive(tick))
			{
				return new InlineContent(this);
			}
			return null;
		}
		
		public override function writeElement(writer:XML, isRoot:Boolean = false):void
		{
			writer.appendChild(text);
		}
	}
}