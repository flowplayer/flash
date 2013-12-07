/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.mast.parser
{
	import __AS3__.vec.Vector;
	
	import flash.events.EventDispatcher;
	
	import org.osmf.mast.model.*;
	import org.osmf.mast.types.MASTConditionOperator;
	import org.osmf.mast.types.MASTConditionType;
	CONFIG::LOGGING
	{
	import org.osmf.logging.*;			
	}
	
	/**
	 * This class parses a MAST document into a
	 * MAST object model.
	 */
	public class MASTParser extends EventDispatcher
	{
		/**
		 * Constructor.
		 */
		public function MASTParser() 
		{
			super();
		}
				
		/**
		 * A synchronous method to parse the raw MAST XML data 
		 * into a MAST object model.
		 */
		public function parse(rawData:String):MASTDocument 
		{
			var xml:XML = new XML(rawData);
			var mastDocument:MASTDocument = new MASTDocument(xml.@version);

			try 
			{
				var children:XMLList = xml.*;

				for (var i:int = 0; i < children.length(); i++) 
				{
					var child:XML = children[i];
					
					switch (child.nodeKind()) 
					{
						case "element":
							switch (child.localName()) 
							{
								case "triggers":
									parseTriggers(child, mastDocument);
									break;
							}
							break;
					}
				}
			}
			catch (err:Error) 
			{
				CONFIG::LOGGING
				{
					logger.debug("parse() - Exception occurred : " + err.message);
				}
				
				throw err;
			}
			
			return mastDocument;
		}		

		private function parseTriggers(node:XML, mastDocument:MASTDocument):void 
		{
			var children:XMLList = node.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case "element":
						switch (child.localName()) 
						{
							case "trigger":
								{
									var trigger:MASTTrigger = new MASTTrigger(child.@id, child.@description);
									parseChildNodes(child, trigger);									
									mastDocument.addTrigger(trigger);
								}
								break;
						}
						break;
				}
			}
		}
		
		private function parseChildNodes(node:XML, trigger:MASTTrigger):void 
		{
			var children:XMLList = node.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case "element":
						switch (child.localName()) 
						{
							case "startConditions":
								var startConditions:Vector.<MASTCondition> = parseCondition(child, trigger);
								trigger.startConditions = startConditions;
								break;
							case "endConditions":
								var endConditions:Vector.<MASTCondition> = parseCondition(child, trigger);
								trigger.endConditions = endConditions;
								break;
							case "sources":
								
								var source:MASTSource = parseSources(child);
								trigger.addSource(source);
								break;
							
						}
						break;
				}
			}
		}
		
		/**
		 * Returns a vector of MASTCondition objects.
		 */
		private function parseCondition(node:XML, trigger:MASTTrigger):Vector.<MASTCondition> 
		{
			var condObjs:Vector.<MASTCondition> = new Vector.<MASTCondition>();
			
			var children:XMLList = node.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case "element":
						switch (child.localName()) 
						{
							case "condition":
							
								var type:MASTConditionType;
								var childType:String = child.@type;
								
								switch (childType)
								{
									case MASTConditionType.EVENT.type:
										type = MASTConditionType.EVENT;
										break;
									case MASTConditionType.PROPERTY.type:
										type = MASTConditionType.PROPERTY;
										break;
								}
								
								var childOperator:String = child.@operator;
								var operator:MASTConditionOperator = findConditionOperator(childOperator);
																																	
								// Look for child conditions
								var childConds:Vector.<MASTCondition> = parseCondition(child, trigger);
								var name:String = child.@name;
								var value:String = child.@value;
								var condObj:MASTCondition = new MASTCondition(type, name, value, operator, childConds);
								
								condObjs.push(condObj);
								break;
						}
						break;
				}
			}
			return condObjs;
		}
		
		private function findConditionOperator(operator:String):MASTConditionOperator
		{
			var operatorObj:MASTConditionOperator;
			
			switch (operator)
			{
				case MASTConditionOperator.EQ.operator:
					operatorObj = MASTConditionOperator.EQ;
					break;
				case MASTConditionOperator.GEQ.operator:
					operatorObj = MASTConditionOperator.GEQ;
					break;
				case MASTConditionOperator.GTR.operator:
					operatorObj = MASTConditionOperator.GTR;
					break;
				case MASTConditionOperator.LEQ.operator:
					operatorObj = MASTConditionOperator.LEQ;
					break;
				case MASTConditionOperator.LT.operator:
					operatorObj = MASTConditionOperator.LT;
					break;
				case MASTConditionOperator.MOD.operator:
					operatorObj = MASTConditionOperator.MOD;
					break;
				case MASTConditionOperator.NEQ.operator:
					operatorObj = MASTConditionOperator.NEQ;
					break;
			}
			
			return operatorObj;
		}
		
		private function parseSources(node:XML):MASTSource 
		{
			var sourceObj:MASTSource = null;
			var children:XMLList = node.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case "element":
						switch (child.localName()) 
						{
							case "source":
								sourceObj = new MASTSource(child.@uri, child.@format);
								
								parseSource(child, sourceObj)
								break;
						}
						break;
				}
			}
			
			return sourceObj;
		}
		
		private function parseSource(node:XML, sourceObj:MASTSource):void 
		{
			var children:XMLList = node.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case "element":
						switch (child.localName()) 
						{
							case "sources":
								var childSource:MASTSource = parseSources(child);
								
								if (childSource) 
								{
									sourceObj.addChildSource(childSource);
								}
								break;
							case "targets":
								var target:MASTTarget = parseTarget(child);
								
								if (target) 
								{
									sourceObj.addTarget(target);
								}
								break;
						}
				}
			}
		}
		
		private function parseTarget(node:XML):MASTTarget 
		{
			var targetObj:MASTTarget = null;
			var children:XMLList = node.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case "element":
						switch (child.localName()) 
						{
							case "target":
								targetObj = new MASTTarget(child.@type, child.@region);
								
								// Look for child targets
								var childTarget:MASTTarget = parseTarget(child);
								
								if (childTarget) 
								{
									targetObj.addChildTarget(childTarget);
								}
								break;
						}
						break;
				}
			}
			return targetObj;
		}
						
		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.mast.parser.MASTParser");	
		}		
	}
	
}
