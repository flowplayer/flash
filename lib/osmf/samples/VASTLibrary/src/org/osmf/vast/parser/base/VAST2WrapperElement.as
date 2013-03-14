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
	 * Internal wrapper tag parser and data object
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	public dynamic class VAST2WrapperElement extends VAST2Element
	{
		/* All these variables are references or arrays of references */
		private var _AdSystem:String;
		private var _VASTAdTagURL:String;
		/* Not really sure what the following are for since the destination tag should really be where the companion ads are */
		private var _CompanionAdImpression:Array;
		private var _CompanionAdTagURL:Array;
		private var _CompanionAdTagCode:String;
		private var _NonLinearImpression:Array;
		private var _NonLinearAdTagURL:Array;
		private var _NonLinearAdTagCode:String;		
		private var _Creatives:VAST2CreativeElement;		
		
		/**
		 * @private
		 */	
		public function VAST2WrapperElement(forxData:Object = null, trackingData:VAST2TrackingData = null)	
		{
			super(forxData, "VAST2WrapperElement", trackingData);
			//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " created", "Instream", elementName); 
			
			_AdSystem= new String();
			_VASTAdTagURL = new String();
			_CompanionAdImpression = new Array();
			_CompanionAdTagURL = new Array();
			_CompanionAdTagCode = new String();
			_NonLinearImpression = new Array();
			_NonLinearAdTagURL = new Array();
			_NonLinearAdTagCode = new String();	
			_Creatives = new VAST2CreativeElement(forxData, _trackingData);
			
			if ( forxData == null || trackingData == null)
			{
				//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " is just a temporary placeholder.", "Instream", elementName); 	
				return;		// Just a placeholder object to prevent null reference errors
			}
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

				if(_forxRef.VASTAdTagURI != undefined) {
					_VASTAdTagURL = _forxRef.VASTAdTagURI;
				}
				
				processUrlList(_forxRef.Impression,_trackingData.impressionArray);
				processUrlList(_forxRef.Error,_trackingData.errorArray);
				
				
				if(_forxRef.Creatives != undefined && _forxRef.Creatives.Creative != undefined) 
				{
					for(i = 0; i < _forxRef.Creatives.Creative.length(); i++) 
					{
						if(_forxRef.Creatives.Creative[i] != undefined) 
						{
							var creative:VAST2CreativeElement = new VAST2CreativeElement(_forxRef.Creatives.Creative[i], _trackingData);
							creative.parseXMLData();
							_Creatives.push(creative)
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
		public function get VASTAdTagURL():String {return _VASTAdTagURL;}
		/**
		 * @private
		 */	
		public function get CompanionImpression():Array {return _CompanionAdImpression;}
		/**
		 * @private
		 */	
		public function get CompanionAdTagURL():Array {return _CompanionAdTagURL;}
		/**
		 * @private
		 */	
		public function get CompanionAdTagCode():String {return _CompanionAdTagCode;}
		/**
		 * @private
		 */	
		public function get NonLinearImpression():Array {return _NonLinearImpression;}
		/**
		 * @private
		 */	
		public function get NonLinearAdTagURL():Array {return _NonLinearAdTagURL;}
		/**
		 * @private
		 */	
		public function get NonLinearAdTagCode():String {return _NonLinearAdTagCode;}		
		
		
	}
}
