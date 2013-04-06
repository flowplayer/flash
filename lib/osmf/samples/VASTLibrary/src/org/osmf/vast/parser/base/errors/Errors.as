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
package org.osmf.vast.parser.base.errors {
		/**
	 * Defining the define error numbers.
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
public dynamic class Errors {
	protected var _parseErrorArray : Array;
	
		/**
	 * Do NOT change the numbers after release. Publishers will rely on these numbers
	 * Stand errors start at 0
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */		
	public const ERROR_BASE:Object = 			{id:0,	desc:"No error"};
	
	 
		/**
	 * Standard warnings start at 5000
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public const WARNING_BASE:Object = 			{id:5000,	desc:"No error"};
	
	 
		/**
	 * Tag format specific errors start at 10000. Change these in the subclass
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */		
	public const TAG_ERROR_BASE:Object = 		{id:10000,	desc:"No error"};
	
	
		/**
	 * Tag format specific warnings start at 15000. Change these in the subclass
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public const TAG_WARNING_BASE:Object = 		{id:15000,	desc:"No error"};
	

		/**
	 *Publisher-specific miscellaneous errors start at 20000
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */		
	public const PUB_ERROR_BASE:Object = 		{id:20000,	desc:"No error"};
	
	 
			/**
	 *Publisher-specific miscellaneous warnings start at 25000
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public const PUB_WARNING_BASE:Object = 		{id:25000,	desc:"No error"};
		
	public function Errors()
	{
		_parseErrorArray = new Array();
	}
	
	protected function defineError(error:Object) : void
	{
        _parseErrorArray[error.id] = error;
	}
	
}
}
