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
	 * Internal InLine element parser and data object
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	public dynamic class VAST2InLineElement extends VAST2Element
	{
		/* All these variables are references or arrays of references */
		private var _AdSystem:String;
		private var _AdTitle:String;
		private var _Description:String;
		private var _Survey:Array;
		private var _Error:Array;
		private var _Impression:Array;
		private var _Extensions:XML;
		private var _Creatives:VAST2CreativeElement;
	
		/**
		 * @private
		 */	
		public function VAST2InLineElement(forxData:Object = null, _trackingData:VAST2TrackingData = null)	
		{
			
			super(forxData,"VAST2InLineElement", _trackingData);
			//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " created", "Instream", elementName); 	
			
			_AdSystem = new String();
			_AdTitle = new String();
			_Description = new String();
			_Survey = new Array();
			_Error = new Array();
			_Impression = new Array();
			_Extensions = new XML();
			_Creatives = new VAST2CreativeElement(forxData, _trackingData);

			if ( forxData == null || _trackingData == null)
			{
				//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " is just a temporary placeholder.", "Instream", elementName); 	
				return;		// Just a placeholder object to prevent null reference errors
			}

			// Continue here

				
			
		}
		
		/**
		 * @private
		 */	
		public function parseXMLData() : void
		{
				var i:Number;
				var j:Number;
				
				if (_forxRef == null || _trackingData == null)
					return;
				
				_AdSystem = _forxRef.AdSystem;
				_AdTitle = _forxRef.AdTitle;
				_Description = _forxRef.Description;
				//UIFDebugMessage.getInstance()._debugMessage(2, "AdTitle: " + _AdTitle);
				//UIFDebugMessage.getInstance()._debugMessage(3, "Description: " + _Description); 

				processUrlList(_forxRef.Impression,_trackingData.impressionArray);
				processUrlList(_forxRef.Error,_trackingData.errorArray);
				processUrlList(_forxRef.Survey,_trackingData.surveyArray);
				
				_Extensions = _forxRef.Extensions[0];
				
				/* For now, prevent more than one nonlinear element for two reasons:
						 1) Main reason - we have not determined how to give the player the choice on which nonlinear element to use. 
						  This is more of a sequencing questions and warrants further discussion with publishers. It doesn't seem there
						  will be high demand for this based on network test samples on the IAB site
						 2) We are also sharing the same trackingData for all creatives, and this will only work for having one of linear and
						  nonlinear creatives, but not more than one because trackers will be fired for the wrong creative. */
				var linearExists:Boolean = false;
				var nonlinearExists:Boolean = false;

				if(_forxRef.Creatives != undefined && _forxRef.Creatives.Creative != undefined) 
				{
					for(i = 0; i < _forxRef.Creatives.Creative.length(); i++) 
					{
						var itr:XML = _forxRef.Creatives.Creative[i];
						if(itr != null) 
						{
							if (!((itr.Linear != undefined && itr.Linear[0] == "Linear") && linearExists == true))
							if (!((itr.NonLinearAds != undefined && itr.NonLinearAds[0] == "NonLinearAds") && nonlinearExists == true)) // see note above
							{
								var creative:VAST2CreativeElement = new VAST2CreativeElement(itr, _trackingData);
								creative.parseXMLData();
								_Creatives.push(creative);
								if (itr.Linear) // see note above 
									linearExists = true;
								else if (itr.NonLinearAds) // see note above. Else if because of xsd says it's xs:choice. Giving <Linear> preference
									nonlinearExists = true;
							}
						}
					}
				}
				
		}
		
		/**
		 * @private
		 */	
		public function get AdSystem():String {return _AdSystem;}	
		/**
		 * @private
		 */	
		public function get AdTitle():String {return _AdTitle;}
		/**
		 * @private
		 */	
		public function get Description():String {return _Description;}
		/**
		 * @private
		 */	
		public function get Survey():Array {return _Survey;}
		/**
		 * @private
		 */	
		public function get Error():Array {return _Error;}
		/**
		 * @private
		 */	
		public function get Impression():Array {return _Impression;}
		/**
		 * @private
		 */	
		public function get Extensions():XML/*Array*/ {return _Extensions;}
		/**
		 * @private
		 */	
		public function get Creatives():VAST2CreativeElement {return _Creatives;}

		
	}
}
