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
*****************************************************/
package org.osmf.logging.flex
{
	import mx.logging.ILogger;
	
	import org.osmf.logging.Logger;
	
	public class FlexLoggerWrapper extends Logger
	{
		public function FlexLoggerWrapper(logger:ILogger)
		{
			super(logger.category);
			
			this.logger = logger;
		}

		/**
		 * @inheritDoc
		 */
		override public function debug(message:String, ...rest):void
		{
			var args:Array = rest.concat();
			args.unshift(message);
			logger.debug.apply(logger, args);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function info(message:String, ...rest):void
		{
			var args:Array = rest.concat();
			args.unshift(message);
			logger.info.apply(logger, args);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function warn(message:String, ...rest):void
		{
			var args:Array = rest.concat();
			args.unshift(message);
			logger.warn.apply(logger, args);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function error(message:String, ...rest):void
		{
			var args:Array = rest.concat();
			args.unshift(message);
			logger.error.apply(logger, args);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function fatal(message:String, ...rest):void
		{
			var args:Array = rest.concat();
			args.unshift(message);
			logger.fatal.apply(logger, args);
		}

		// Internals
		//
		
		private var logger:ILogger;
	}
}