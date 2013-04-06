package org.osmf.smpte.tt.parsing
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.smpte.tt.errors.SMPTETTException;
	import org.osmf.smpte.tt.events.ParseEvent;
	import org.osmf.smpte.tt.model.AnonymousSpanElement;
	import org.osmf.smpte.tt.model.BodyElement;
	import org.osmf.smpte.tt.model.HeadElement;
	import org.osmf.smpte.tt.model.PElement;
	import org.osmf.smpte.tt.model.SpanElement;
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.model.TtElement;
	import org.osmf.smpte.tt.model.metadata.ActorElement;
	import org.osmf.smpte.tt.model.metadata.AgentElement;
	import org.osmf.smpte.tt.model.metadata.CopyrightElement;
	import org.osmf.smpte.tt.model.metadata.DescElement;
	import org.osmf.smpte.tt.model.metadata.NameElement;
	import org.osmf.smpte.tt.model.metadata.TitleElement;
	import org.osmf.smpte.tt.model.parameter.ExtensionElement;
	import org.osmf.smpte.tt.model.parameter.FeatureElement;
	import org.osmf.smpte.tt.model.parameter.ParameterElement;
	import org.osmf.smpte.tt.timing.TimeExpression;
	import org.osmf.smpte.tt.timing.TreeType;
	import org.osmf.smpte.tt.utilities.AsyncThread;
	import org.osmf.smpte.tt.utilities.StringUtils;
	import org.osmf.smpte.tt.vocabulary.Namespaces;
	
	[Event(name="complete", type="org.osmf.smpte.tt.events.ParseEvent")]
	public class XMLToTTElementParser extends EventDispatcher
	{
		
		private static const MILLISECONDS_PER_FRAME_FOR_PARSING:int = 50; //Lower numbers take longer, but distrupt video playback less
		
		private  var asyncThread:AsyncThread
		private  var nodeRecursiveTracker:Dictionary
		private var rootNode:TimedTextElementBase
		
		public static function parse(timedTextData:XML):XMLToTTElementParser
		{
			var rtn:XMLToTTElementParser = new XMLToTTElementParser();
			return rtn.startParsing(timedTextData);
		}
		
		public function startParsing(timedTextData:XML):XMLToTTElementParser
		{
			initializeDefaults();
			
			asyncThread = AsyncThread.create(starterFunction,[]);
			asyncThread.addEventListener(Event.COMPLETE, onAsyncComplete);
			nodeRecursiveTracker = new Dictionary(true);
			
			rootNode = parseRecursive(timedTextData, null, false);
			asyncThread.runEachFrame(MILLISECONDS_PER_FRAME_FOR_PARSING);
			
			return this;
		}
		
		private function initializeDefaults():void
		{
			TimeExpression.initializeParameters();
			ParameterElement.initializeParameters();	
		}
		
		private function onAsyncComplete(event:Event):void
		{
			trace(this + " onAsyncComplete");
			dispatchEvent(new ParseEvent(ParseEvent.COMPLETE,false,false,rootNode));
		}
		
		private function starterFunction():void
		{
			trace(this + " Starting AsyncThread");
		}
		
		/**
		 *  Convert an XML object to the internal TimedText classes.
		 * 
		 * 	@param timedTextData Raw XML construct
		 *  @param root root element of the tree
		 *  @returns tt_element hierachy
		 */
		private function parseRecursive(xmlElement:XML, root:TtElement, preserveContext:Boolean):TimedTextElementBase
		{	
			
			var xmlElementNameSpace:Namespace = xmlElement.namespace();
			var xmlElementNameSpaceURI:String = xmlElementNameSpace.uri;
			
			if (xmlElementNameSpaceURI.length==0)
			{
				xmlElementNameSpace = Namespaces.TTML_NS;
				xmlElementNameSpaceURI = xmlElementNameSpace.uri;
				xmlElement.setNamespace(xmlElementNameSpace);
			}
			
			var parentNode:TimedTextElementBase = setParentNodeNamespace(root,xmlElementNameSpaceURI,xmlElementNameSpace,xmlElement);
			
			/// if node is still null, either we failed to implement the element
			/// or its an element in a foreign namespace, either way we bail.
			if (parentNode == null) return null;
			
			//{ region test if root element
			var newRoot:TtElement = (root == null) ? parentNode as TtElement : root;
			
			// null should only occur in the first call,
			if (newRoot == null)
			{
				error("tt not at root of document");
			}
			parentNode.root = newRoot;
			//} endregion
			
			var localPreserve:Boolean = preserveContext;  // record whether xml:space=preserve is in effect
			
			parentNode.setLocalStyle("preserve",localPreserve);
			
			//{ region process raw xml attributes into timed text equivalents
			parseAttributes(xmlElement,parentNode,xmlElementNameSpace,localPreserve);
			
			localPreserve = parentNode.getReferentStyle("preserve");
						
			//{ region process child elements
			var children:XMLList = xmlElement.children();
			var childNode:XML;
			for each (childNode in children)
			{
				incrementRecursiveNodeCount(newRoot, "child :")
				AsyncThread.queue(parseChild, [childNode, parentNode, newRoot, localPreserve]);
				// parseChild(childNode, parentNode, newRoot, localPreserve);
			}
			return parentNode;
		}
		
		protected function setParentNodeNamespace(root:TtElement, xmlElementNameSpaceURI:String, xmlElementNameSpace:Namespace, xmlElement:XML):TimedTextElementBase
		{
			if (root==null){
				if(xmlElementNameSpaceURI.match(Namespaces.TTML_NS_REGEXP))
				{
					Namespaces.useLegacyNamespace(xmlElementNameSpace);
				}
			}
			
			var element:String = xmlElement.localName();
			
			var nameSpace:String = namespaceFromTimedTextNamespace(xmlElementNameSpaceURI);
			
			var parentNode:TimedTextElementBase = null;
			
			if (!(!nameSpace || nameSpace.length==0))
			{
				// To meet naming conventions, have to manipulate the name.
				var conventionName:String = StringUtils.capitalize(element) + "Element";
				
				// if there is a namespace, then its a timed text element
				parentNode = TimedTextElementBase.getElementFromName(nameSpace + conventionName);
				parentNode.localName = element;
				parentNode.namespace = xmlElementNameSpace;
			}
			return parentNode;
		}
		
		
		private function incrementRecursiveNodeCount(rootNode:TimedTextElementBase, debugMsg:String =""):void
		{
			if (nodeRecursiveTracker[rootNode] == null)
			{
				nodeRecursiveTracker[rootNode] = 0;
			}
			nodeRecursiveTracker[rootNode]++;
			//trace("incrementRecursiveNodeCount " + rootNode + "("+ nodeRecursiveTracker[rootNode] +") >" + debugMsg);
		}
		
		private function decrementRecursiveNodeCount(rootNode:TimedTextElementBase,  debugMsg:String =""):void
		{
			nodeRecursiveTracker[rootNode]--
			//	trace("decrementRecursiveNodeCount " + rootNode + "("+ nodeRecursiveTracker[rootNode] +") >" + debugMsg);
		}
		
		private function namespaceFromTimedTextNamespace(p:String):String
		{
			var nsPrefix:String = "";
			switch (p)
			{   // got to be a better way to do this using reflection?
				case "http://www.w3.org/2006/02/ttaf1":
				case "http://www.w3.org/2006/04/ttaf1":
				case "http://www.w3.org/2006/10/ttaf1":
				case "http://www.w3.org/ns/ttml":
					nsPrefix = "org.osmf.smpte.tt.model.";
					break;
				case "http://www.w3.org/2006/02/ttaf1#metadata":
				case "http://www.w3.org/2006/04/ttaf1#metadata":
				case "http://www.w3.org/2006/10/ttaf1#metadata":
				case "http://www.w3.org/ns/ttml#metadata":
					nsPrefix = "org.osmf.smpte.tt.model.metadata.";
					break;
				case "http://www.w3.org/2006/02/ttaf1#style":
				case "http://www.w3.org/2006/02/ttaf1#styling":
				case "http://www.w3.org/2006/04/ttaf1#style":
				case "http://www.w3.org/2006/04/ttaf1#styling":
				case "http://www.w3.org/2006/10/ttaf1#style":
				case "http://www.w3.org/2006/10/ttaf1#styling":
				case "http://www.w3.org/ns/ttml#styling":
					nsPrefix = "org.osmf.smpte.tt.styling.";
					break;
				case "http://www.w3.org/2006/02/ttaf1#parameter":
				case "http://www.w3.org/2006/04/ttaf1#parameter":
				case "http://www.w3.org/2006/10/ttaf1#parameter":
				case "http://www.w3.org/ns/ttml#parameter":
				case "http://www.w3.org/ns/ttml/profile":
					nsPrefix = "org.osmf.smpte.tt.model.parameter.";
					break;
				default: 
					nsPrefix = "";
					break;
			}
			return nsPrefix;
		}
		
		protected function parseAttributes(xmlElement:XML, parentNode:TimedTextElementBase, xmlElementNameSpace:Namespace, localPreserve:Boolean):void
		{
			var attributes:XMLList = xmlElement.attributes();
			var xmlAttribute:XML
			var attribute:TimedTextAttributeBase
			for each (xmlAttribute in attributes)
			{
				incrementRecursiveNodeCount(parentNode.root, "Attribute: ")
				AsyncThread.queue(createAttributeElement, [xmlAttribute, parentNode, xmlElementNameSpace, localPreserve]);
				// createAttributeElement(xmlAttribute, parentNode, xmlElementNameSpace, localPreserve);
				localPreserve = parentNode.getReferentStyle("preserve");
			}
		}
		
		
		
		protected function createAttributeElement(xmlAttribute:XML, parentNode:TimedTextElementBase, xmlElementNameSpace:Namespace, localPreserve:Boolean):void
		{
			// copy the attribute identity
			var attribute:TimedTextAttributeBase = new TimedTextAttributeBase();
			attribute.parent = parentNode as TimedTextElementBase;;
			attribute.localName = xmlAttribute.localName();
			attribute.value = xmlAttribute;
			
			// not sure if it is absolutely correct to move 
			// empty namespace elements into tt namespace but seems
			// to work.
			attribute.namespace = (!xmlAttribute.namespace()) ? xmlElementNameSpace : xmlAttribute.namespace();
			
			if(!attribute.namespace.uri && attribute.parent.namespace) {
				attribute.namespace = attribute.parent.namespace;
			}
			
			// attach new attribute to current element
			parentNode.attributes.push(attribute);
			
			// check whether we are changing the space preserve behaviour
			if (attribute.isXmlAttribute() && attribute.localName == "space")
			{
				localPreserve = (attribute.value == "preserve");
				// record the type of preservation as a local style.
				parentNode.setLocalStyle("preserve", localPreserve);
			}
			
			decrementRecursiveNodeCount(parentNode.root ,"Attribute: ")
		}
		
		private function parseChild(xmlNode:XML, parentNode:TimedTextElementBase, newRoot:TtElement, localPreserve:Boolean):void
		{
			
			/*var xmlNode:XML 					= obj.xmlNode,
			parentNode:TimedTextElementBase = obj.parentNode,
			newRoot:TtElement				= obj.newRoot,
			localPreserve:Boolean 			= obj.localPreserve;*/
			
			localPreserve = parentNode.getReferentStyle("preserve");
			
			switch(xmlNode.nodeKind())
			{
				//text, comment, processing-instruction, attribute, or element.
				case "element":
					
					//{ region convert XML Element to Timed Text Element
					parseChildElementType(xmlNode,parentNode,newRoot,localPreserve);
					//} endregion
					break;
				
				case "text":
					
					//{ region convert XML Text into an anonymous span element
					parseChildTextType(xmlNode,parentNode,localPreserve);
					break;					
			}
			
			decrementRecursiveNodeCount(parentNode.root, "Child: ")
		}

		private function parseChildTextType(xmlNode:XML, parentNode:TimedTextElementBase, localPreserve:Boolean):void
		{
			if (isContentElement(parentNode))
			{
				//{ region elements that admit PCDATA as children get anonymous spans
				var text:AnonymousSpanElement;
				if (!localPreserve)
				{  // squeeze out all the redundant whitespace
					var normalized:String = normalizeWhitespace(xmlNode);
					text = new AnonymousSpanElement(normalized);
				}
				else
				{  
					// preserve the raw text as it came in
					text = new AnonymousSpanElement(xmlNode.toString());	
				}
				parentNode.children.push(text as TreeType);
				text.parent = parentNode;
				if(!isMetadataContentElement(parentNode) 
					&& !isParameterContentElement(parentNode))
				{
					parentNode.root.totalNodeCount++;
				}
			}
			else
			{
				//{ region test non content element for non-whitespace error.
				if (normalizeWhitespace(xmlNode) != " ")
				{
					error("Use of non whitespace in " + parentNode);
				}
			}
		}


		private function parseChildElementType(xmlNode:XML, parentNode:TimedTextElementBase, newRoot:TtElement, localPreserve:Boolean):void
		{
			var child:TimedTextElementBase = parseRecursive(xmlNode, newRoot, localPreserve);
			if (child != null)
			{
				parentNode.children.push(child as TreeType);
		
				if (child is BodyElement)
				{
					parentNode.body = child as BodyElement;
				}
				if (parentNode is TtElement)
				{
					var ttElement:TtElement = parentNode as TtElement;
					if (child is HeadElement)
					{
						ttElement.head = child as HeadElement;
					}
				}
		
				child.parent = parentNode;
				child.root = parentNode.root;
			}
		}

		
		/**
		 * Is it a content element for purposes of parenting anonymous span's?
		 * 
		 * @param node
		 */
		private function isContentElement(node:TimedTextElementBase):Boolean
		{
			if (node is PElement) return true;
			if (node is SpanElement) return true;
			if (isMetadataContentElement(node)) return true;
			if (isParameterContentElement(node)) return true;
			return false;
		}
		
		/**
		 * Metadata items that admit PCDATA as content
		 * 
		 * @param node
		 */
		private function isMetadataContentElement(node:TimedTextElementBase):Boolean
		{
			if (node is TitleElement) return true;
			if (node is NameElement) return true;
			if (node is DescElement) return true;
			if (node is CopyrightElement) return true;
			if (node is AgentElement) return true;
			if (node is ActorElement) return true;
			
			return false;
		}
		
		/**
		 * Parameter items that admit PCDATA as content
		 * 
		 * @param node
		 */
		private function isParameterContentElement(node:TimedTextElementBase):Boolean
		{
			if (node is ExtensionElement) return true;
			if (node is FeatureElement) return true;
			return false;
		}
		
		private static const WHITESPACE_REGEXP:RegExp =  /[\n\r\t]/g;
		private static const DOUBLESPACE_REGEXP:RegExp =  /\ {2}/g; 
		
		//{ region Helper Methods
		/** 
		 * convert newlines to space, and collpase runs of space to a single space
		 * 
		 * @param n
		 */
		private function normalizeWhitespace(n:XML):String
		{
			var normalized:String = n.normalize().toString().replace(WHITESPACE_REGEXP, " ");
			while (DOUBLESPACE_REGEXP.test(normalized))
			{
				normalized = normalized.replace(DOUBLESPACE_REGEXP, " ");
			}
			return normalized;
		}
		
		protected function error(message:String):void
		{
			trace("[ERROR] "+ " "+ message);
			/*try {
			throw new SMPTETTException(message);
			} catch (err:SMPTETTException){
			trace("[ERROR] "+ err +" "+ err.message);
			}*/
		}
	}
}