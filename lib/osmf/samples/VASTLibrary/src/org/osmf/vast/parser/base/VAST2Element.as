/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vast.parser.base
{
	/**
	 * Base class for all elements
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	public dynamic class VAST2Element extends Array
	{
		
		protected var _forxRef:Object; 		//Reference to the portion of the forx tree
		protected var _elementName:String; 	//Name of the element
		protected var _trackingData:VAST2TrackingData;
	
		/**
		 * @private
		 */	
		public function VAST2Element(forxData:Object, eName:String, trackingData:VAST2TrackingData)
		{
			_elementName = eName;
			//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + _elementName + " base class", "Instream", "VAST2Element"); 
			_forxRef = forxData;	// Set a reference to the portion of the forx tree
			_trackingData = trackingData;
		}
		

				
				
	protected function processUrlList(forxData:Object, trackingArray:Array):void
	{
			if (forxData != null) 
			{
				for(var i:uint = 0; i < forxData.length(); i++)
				{
					var urlObject:Object = new Object();
					if (forxData[i] != undefined)
						urlObject.url = forxData[i].text();
					trackingArray.push(urlObject);
				}
			}
	}
		

		/**
		 * @private
		 */	
		public function get forxRef() : Object {return _forxRef;}
		/**
		 * @private
		 */	
		public function get elementName() : String {return _elementName;}
		/**
		 * @private
		 */	
		public function get trackingData(): VAST2TrackingData {return _trackingData;}
		
		
	}

}
