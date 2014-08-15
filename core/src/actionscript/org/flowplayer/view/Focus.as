/*
* Copyright (c) 2008 Michael A. Jordan
* Copyright (c) 2009 Adobe Systems, Inc.
* All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
* 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* 3. Neither the name of the copyright holders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
* 
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*

This code is based on Adobe's SWFFocus class. 
The original SWFFocus class is designed to resolve the accessibility issue in browsers other than Internet Explorer
when users can't access player controls by keyboard alone. This accessibility issue can be viewed in 2 parts:

1. User can't access player's controls, tabbing skips over the player.
2. Once user has a focus on player's controls, he can tab through player's controls, but he is 'trapped' inside the player and can't 
shift focus back to the html page elements.

Task #1 is not working in several browsers including Chrome and Opera on Windows. This issue is resolved by javascript code and does not require changes
in the AS. 

Task #2 is resolved by this class and is using the same idea as Adobe's SWFFocus class uses - it injects javascript code into html page embedding the player.
The code monitors objects receiving the focus and once the user has made a full circle (the first object received a focus again) it injects the javascript
that shifts focus to the designated "next" html element on the page embedding the player. 

Code modified by: Gita Ligure
GLigure@Books24x7.com
November 12th, 2013

*/
package org.flowplayer.view
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import org.flowplayer.util.Log;
	
	public class Focus extends EventDispatcher 
	{
		private var log:Log = new Log(this);
		
		private static var _availability:Boolean = ExternalInterface.available;
		private static var _dispatcher:EventDispatcher = new EventDispatcher();
		private static var _instance:Focus = new Focus( SingletonLock );
		private static var _initialized:Boolean = false;
		private var _stage:Stage;

		private var _firstRoundTabbing:Boolean = true;
		private var _ignoreNextEvents:Boolean = false;
		
		private var _firstTabbedObject:InteractiveObject;
		
		private var _idNext:String;
		
		/**
		 *
		 *  Constructor
		*/
		public function Focus( lock:Class )
		{
			if ( lock != SingletonLock )   
			{   
				throw new Error( "Invalid Singleton access. Use Focus.init." );   
			}
		}
		
		/**
		 *  
		 *  Initiates swffocus object, and sets callbacks
		 */
		public static function init(stageRef:Stage):void 
		{
			var swffocus:Focus = _instance;
			if (stageRef && swffocus._stage != stageRef && !_initialized)
			{
				swffocus._stage = stageRef;
				_initialized =  swffocus._initialize();
			}
		}
		
		/**
		 *  @private  
		 *  Set event handles and inject JavaScript code
		 */
		private function _initialize():Boolean 
		{
			log.info("Initializing Focus ");
			if (_availability && Capabilities.playerType.toLowerCase() == "plugin" && !Focus._initialized) 
			{
                try {
                    ExternalInterface.addCallback("setNextFocusId", _instance.setNextFocusId);
                } catch (e:Error) {
                    log.debug("Focus._initialize(): Unable to add JS callback.");
                }
				_stage.addEventListener(FocusEvent.FOCUS_IN, stage_focusInHandler, false, 0, true);
				_stage.addEventListener(FocusEvent.FOCUS_OUT, stage_focusOutHandler, false, 0, true);
			}
			return true;
		}
		
		/**
		 *  @private compares with a stored first object tabbed into 
		 *  and if they match, calls javascript to set focus to a next 
		 *  html element on the page
		 */
		private function stage_focusOutHandler(e:FocusEvent):void 
		{
			if (_ignoreNextEvents != true)
			{
				if (!_firstRoundTabbing)
				{
					if (_firstTabbedObject && e.relatedObject)
					{
						if (_firstTabbedObject.name == e.relatedObject.name) // make sure objects not null
						{
							log.info("IT'S A MATCH First object Stored: " + _firstTabbedObject.name + " related object " + e.relatedObject.name);
							// reset for next round
							_firstTabbedObject = null;
							_firstRoundTabbing = true;
							_ignoreNextEvents = true;
							
							if (_idNext)
							{
								log.info("Should set focus on element " + _idNext);
								ExternalInterface.call("function(){var elem = document.getElementById('" +_idNext + "'); if (elem) elem.focus();}");
							}
						}
					}
				}
				else
				{
					_firstRoundTabbing = false;
				}
			}
			else
				_ignoreNextEvents = false;
		}
		
		/**
		 *  @private stores the first target focus;
		 */
		private function stage_focusInHandler(e:FocusEvent):void 
		{
			if (_ignoreNextEvents != true)
			{
				if (_firstRoundTabbing)
				{
					log.info("Will store " + e.target + " as a first Tabbed object ");
					if (e.currentTarget) _firstTabbedObject = InteractiveObject(e.target);
				}
			}
			
		}
		
		/**
		 *  
		 *  Callback function for JavaScript, used to set IDs of next and previous 
		 *  elements in the HTML tab order.
		 *  
		 */
		public function setNextFocusId(idNext:String):void 
		{
			if (idNext)
				_idNext = idNext;
		}
		
	}
	
}


/**  
 * This is a private class declared outside of the package  
 * that is only accessible to classes inside of the Focus.as  
 * file.  Because of that, no outside code is able to get a  
 * reference to this class to pass to the constructor, which  
 * enables us to prevent outside instantiation.  
 */  
class SingletonLock
{   
} // end class  
