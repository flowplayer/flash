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

package org.osmf.qos
{
	import __AS3__.vec.Vector;
	
	import org.osmf.elements.compositeClasses.CompositionMode;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataSynthesizer;

	public class VideoQoSPluginMetadataSynthesizer extends MetadataSynthesizer
	{
		override public function synthesize
							( namespaceURL:String
							, targetParentMetadata:Metadata
							, metadatas:Vector.<Metadata>
							, mode:String
							, serialElementActiveChildMetadata:Metadata
							):Metadata
		{
			var result:VideoQoSPluginMetadata;
			
			if (mode == CompositionMode.SERIAL)
			{
				result = serialElementActiveChildMetadata as VideoQoSPluginMetadata;
			}
			else
			{
				result = new VideoQoSPluginMetadata();
				
				var keys:Array = [];
				for each (var metadata:Metadata in metadatas)
				{
					for each (var key:String in metadata.keys)
					{
						keys[key] ||= [];
						keys[key].push(metadata.getValue(key));
					}
				}
				
				for (key in keys)
				{
					result.addValue(key, keys[key].toString());
				}
			}
			
			return result;	
		}
	}
}