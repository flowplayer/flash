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
	 * Internal creative element parser and data object
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	public dynamic class VAST2CreativeElement extends VAST2Element
	{
	
		private var _id:String;
		private var _sequence:String;
		private var _AdID:String;
		private var _Linear:VAST2LinearElement;
		private var _CompanionAds:Array;
		private var _NonLinearAds:Array;
		
		/**
		 * @private
		 */	
		public function VAST2CreativeElement(forxData:Object, trackingData:VAST2TrackingData)	
		{
			super(forxData,"VAST2CreativeElement",trackingData);
			//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " created", "Instream", elementName); 
			
			_Linear = new VAST2LinearElement(forxData, trackingData);
			_CompanionAds = new Array();
			_NonLinearAds = new Array();
			
			if ( forxData == null || _trackingData == null)
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
				/* Use else if below because VAST 2 xsd has xs:choice. Use first element in creative */
				if(_forxRef.Linear != undefined && _forxRef.Linear[0].name() == "Linear") 
				{
					_Linear = new VAST2LinearElement(_forxRef.Linear[0], _trackingData);
					_Linear.parseXMLData();
				}
				else if(_forxRef.NonLinearAds != undefined && _forxRef.NonLinearAds[0].name() == "NonLinearAds") 
				{
					for(i = 0; i < _forxRef.NonLinearAds.NonLinear.length(); i++) 
					{
						if(_forxRef.NonLinearAds.NonLinear[i] != undefined) 
						{
							var nonlinear:VAST2NonLinearElement = new VAST2NonLinearElement(_forxRef.NonLinearAds.NonLinear[i], _trackingData);
							nonlinear.parseXMLData();
							_NonLinearAds.push(nonlinear);
						}
						/* For now, prevent more than one nonlinear element for two reasons:
						 1) Main reason - we have not determined how to give the player the choice on which nonlinear element to use. 
						  This is more of a sequencing questions and warrants further discussion with publishers. It doesn't seem there
						  will be high demand for this based on network test samples on the IAB site
						 2) We are also sharing the same trackingData for all creatives, and this will only work for having one of linear and
						  nonlinear creatives, but not more than one because trackers will be fired for the wrong creative. */
						i = _forxRef.NonLinearAds.NonLinear.length(); 
					}
					// Less code (and faster) than doing a switch inside the for trackingEvents loop
					var eventMap:Array = new Array();
					eventMap["start"] = _trackingData.trkStartEventNonLinear;
					eventMap["midpoint"] = _trackingData.trkMidPointEventNonLinear;
					eventMap["firstQuartile"] = _trackingData.trkFirstQuartileEventNonLinear;
					eventMap["thirdQuartile"] = _trackingData.trkThirdQuartileEventNonLinear;
					eventMap["complete"] = _trackingData.trkCompleteEventNonLinear;
					eventMap["mute"] = _trackingData.trkMuteEventNonLinear;
					eventMap["pause"] = _trackingData.trkPauseEventNonLinear;
					eventMap["replay"] = _trackingData.trkReplayEventNonLinear;
					eventMap["fullscreen"] = _trackingData.trkFullScreenEventNonLinear;
					eventMap["close"] = _trackingData.trkCloseEventNonLinear;				
					eventMap["creativeView"] = _trackingData.trkCreativeViewEventNonLinear;
					eventMap["unmute"] = _trackingData.trkUnmuteEventNonLinear; 
					eventMap["rewind"] = _trackingData.trkRewindEventNonLinear;
					eventMap["resume"] = _trackingData.trkResumeEventNonLinear;
					eventMap["expand"] = _trackingData.trkExpandEventNonLinear;
					eventMap["collapse"] = _trackingData.trkCollapseEventNonLinear;
					eventMap["acceptInvitation"] = _trackingData.trkAcceptInvitationEventNonLinear;					
					eventMap["stop"] = new Array(); // Prevent breaking		
					eventMap["replay"] = new Array(); // Prevent breaking			
		
					for (i = 0; i < _forxRef.NonLinearAds.TrackingEvents.Tracking.length(); i++) 
					{
							
						if(_forxRef.NonLinearAds.TrackingEvents.Tracking[i] != undefined) 
						{
							var Tracking : Object = new Object();
							Tracking.event = _forxRef.NonLinearAds.TrackingEvents.Tracking[i].@event;
							Tracking.url = _forxRef.NonLinearAds.TrackingEvents.Tracking[i].text();
							if (eventMap[String(Tracking.event)] != undefined)
								eventMap[String(Tracking.event)].push(Tracking);
						}
					}

				}
				else if(_forxRef.CompanionAds != undefined && _forxRef.CompanionAds[0].name() == "CompanionAds" && _forxRef.CompanionAds.Companion != undefined) 
				{
					for(i = 0; i < _forxRef.CompanionAds.Companion.length(); i++) 
					{
						if(_forxRef.CompanionAds.Companion[i] != undefined) 
						{
							var companion:VAST2CompanionElement = new VAST2CompanionElement(_forxRef.CompanionAds.Companion[i]);
							companion.parseXMLData();
							_CompanionAds.push(companion);
						}
					}
				}

					

		}
		
		/**
		 * @private
		 */	
		public function get Linear():VAST2LinearElement {return _Linear;}
		/**
		 * @private
		 */	
		public function get CompanionAds():Array {return _CompanionAds;}
		/**
		 * @private
		 */	
		public function get NonLinearAds():Array {return _NonLinearAds;}

		
	}
}
