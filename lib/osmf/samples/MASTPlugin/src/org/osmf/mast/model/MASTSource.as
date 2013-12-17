/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*  Contributor(s): Akamai Technologies
* 
*****************************************************/
package org.osmf.mast.model
{
	import __AS3__.vec.Vector;
	
	/**
	 * The MASTSource class represents a source element in a MAST 
	 * document.
	 */
	public class MASTSource
	{
		/**
		 * Constructor.
		 * 
		 * @param url The source document to act upon when triggered
		 * @param format The format of the source document, i.e., "vast"
		 * @param targets A vector of targets specified in the source element
		 * @param altReference The ID of the source to act upon when triggered
		 * @param sources The Child sources
		 */
		public function MASTSource(url:String, format:String, targets:Vector.<MASTTarget>=null, 
									altReference:String=null, sources:Vector.<MASTSource>=null)
		{
			_url = url;
			_format = format;
			_targets = targets;
			_altReference = altReference;
			_sources = sources;
		}
		
		/**
		 *  The URL to retrieve a source from, for example a link to a VAST document
		 */
		public function get url():String
		{
			return _url;
		}

		/**
		 * This is used to key the source against a resource already known by the
		 * player. To prevent collisions it can be keyed with the URL when possible.
		 */
		public function get altReference():String
		{
			return _altReference;
		}

		/**
		 * The format this source is in, to be used to determine a handler for the 
		 * payload. Examples would be 'vast', 'uif', etc.
		 */
		public function get format():String
		{
			return _format;
		}

		/**
		 * Child sources of this source.
		 */
		public function get sources():Vector.<MASTSource>
		{
			return _sources;
		}

		/**
		 * Child targets of this source.
		 */
		public function get targets():Vector.<MASTTarget>
		{
			return _targets;
		}
		
		/**
		 * Adds a child source to this source.
		 */
		public function addChildSource(value:MASTSource):void 
		{
			if (_sources == null)
			{
				_sources = new Vector.<MASTSource>();
			}
			
			_sources.push(value);
		}
		
		/**
		 * Adds a child target to this source.
		 */
		public function addTarget(val:MASTTarget):void 
		{
			if (_targets == null)
			{
				_targets = new Vector.<MASTTarget>();
			}
			
			_targets.push(val);
		}		
		
		private var _url:String;
		private var _altReference:String;
		private var _format:String;
		private var _sources:Vector.<MASTSource>;
		private var _targets:Vector.<MASTTarget>;

	}
}
