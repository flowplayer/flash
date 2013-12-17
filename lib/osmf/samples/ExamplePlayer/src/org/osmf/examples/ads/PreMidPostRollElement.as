/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.examples.ads
{
	import org.osmf.elements.SerialElement;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;

	public class PreMidPostRollElement extends SerialElement
	{
		public function PreMidPostRollElement
							( preRoll:MediaElement
							, contentPart1:MediaElement
							, midRoll:MediaElement
							, contentPart2:MediaElement
							, postRoll:MediaElement
							)
		{
			super();
			
			addChild(new AdProxy(preRoll));
			addChild(contentPart1);
			addChild(new AdProxy(midRoll));
			addChild(contentPart2);
			addChild(new AdProxy(postRoll));
			
			var layoutMetadata:LayoutMetadata = new LayoutMetadata();
			layoutMetadata.width = 640;
			layoutMetadata.height = 360;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.scaleMode = ScaleMode.LETTERBOX;
			
			metadata.addValue(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);
		}
	}
}