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
package org.osmf.smpte.tt.captions
{
	import flashx.textLayout.formats.TextAlign;
	
	import org.osmf.smpte.tt.enums.Unit;
	import org.osmf.smpte.tt.styling.Colors;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.timing.TimeSpan;
	
	public class CaptionRegion extends TimedTextElement
	{
		public function CaptionRegion(start:Number, end:Number, id:String=null)
		{
			super(start, end, id);			
			applyDefaultStyle();			
		}
		
		private function applyDefaultStyle():void
		{	
			captionElementType = TimedTextElementType.Region;
			style.backgroundColor = Colors.Black.color;
			style.backgroundAlpha = Colors.Transparent.alpha;
			/*
			var origin:org.osmf.smpte.tt.styling.Origin = new org.osmf.smpte.tt.styling.Origin("10% 80%");
			style.origin = origin;
			
			var extent:org.osmf.smpte.tt.styling.Extent = new org.osmf.smpte.tt.styling.Extent("80% 10%");
			style.extent = extent;
			*/
		}
	}
}