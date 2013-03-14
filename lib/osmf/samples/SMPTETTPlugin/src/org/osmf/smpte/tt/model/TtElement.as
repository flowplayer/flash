/***********************************************************
 * 
 * Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/
package org.osmf.smpte.tt.model
{
	import flash.sampler.NewObjectSample;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.formats.TextAlign;
	
	import org.osmf.smpte.tt.formatting.Animation;
	import org.osmf.smpte.tt.formatting.BlockContainer;
	import org.osmf.smpte.tt.formatting.Flow;
	import org.osmf.smpte.tt.formatting.FormattingObject;
	import org.osmf.smpte.tt.formatting.Root;
	import org.osmf.smpte.tt.styling.ColorExpression;
	import org.osmf.smpte.tt.styling.Colors;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.LineHeight;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.styling.PaddingThickness;
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.smpte.tt.utilities.DictionaryUtils;

	public class TtElement extends TimedTextElementBase
	{
		public function TtElement()
		{
			super();
			_parameters = new Dictionary();
			_styles = new Dictionary();
			_agents = new Dictionary();
			_regions = new Dictionary();
		}
		
		public var head:HeadElement;
		
		private var _regions:Dictionary;
		public function get regions():Dictionary
		{
			return _regions;
		}
		public function set regions(value:Dictionary):void
		{
			_regions = value;
		}
		
		private var _agents:Dictionary;
		public function get agents():Dictionary
		{
			return _agents;
		}
		public function set agents(value:Dictionary):void
		{
			_agents = value;
		}
		
		private var _styles:Dictionary;
		public function get styles():Dictionary
		{
			return _styles;
		}
		public function set styles(value:Dictionary):void
		{
			_styles = value;
		}
		
		private var _parameters:Dictionary;
		public function get parameters():Dictionary
		{
			return _parameters;
		}
		public function set parameters(value:Dictionary):void
		{
			_parameters = value;
		}
		
		private var _totalNodeCount:int = 0;
		public function get totalNodeCount():int
		{
			return _totalNodeCount;
		}
		public function set totalNodeCount(value:int):void
		{
			_totalNodeCount = value;
		}
		
		/**
		 * return the root formatting object
		 * @param regionId
		 * @param tick
		 */
		public override function getFormattingObject(tick:TimeCode):FormattingObject
		{
			// if there is no body. then empty regions would be pruned
			// see 9.3.3.  part 5. map each non-empty region element to 
			// an fo:block-container element...
			if (body == null) return null;
			if (!body.temporallyActive(tick)) return null;
			
			//region create single root and flow for the document.
			var root:Root = new Root(this)
			var flow:Flow = new Flow(null);
			flow.parent = root;
			root.children.push(flow);
			//endregion
			
			//region add a block container to the flow for each temporally active region
			for each (var region:RegionElement in regions)
			{
				if (region.temporallyActive(tick))
				{
					var blockContainer:BlockContainer = region.getFormattingObject(tick) as BlockContainer;
					//region apply animations on regions
					for each (var child:TimedTextElementBase in region.children)
					{
						{
							var fo:FormattingObject = SetElement(child).getFormattingObject(tick);
							if (fo is Animation)
							{
								blockContainer.animations.push(fo as Animation);
							}
						}
					}
					//endregion
					
					blockContainer.parent = flow;
					flow.children.push(blockContainer);
					
					/// region create a new subtree for the body element
					/// select it into this region by adding its children 
					/// to block container
					var block:FormattingObject = body.getFormattingObject(tick);
					if (block != null)
					{
						block.prune(region.id);  // deselect any content not for this region
						if (block.children.length > 0)
						{
							if (block.children[0].children.length > 0)
							{
								blockContainer.children.push(block);
								block.parent = blockContainer;
							}
						}
					}
					//endregion
				}
			}
			//endregion
			return root;
		}
		
		//{ region validity
		/*
		<tt
		tts:extent = string
		xml:id = ID
		xml:lang = string     (required)
		xml:space = (default|preserve) : default
		{any attribute in TT Parameter namespace ...}
		{any attribute not in default or any TT namespace ...}>
		Content: head?, body?
		</tt>
		*/
		
		/**
		 * Check tt element attribute validity
		 */
		protected override function validAttributes():void
		{
			validateAttributes(true, false, false, false, false, false);

			if (language == null)
			{
				error("TT element must specify xml:lang attribute ");
			}
		}
		
		/**
		 * Check tt element validity
		 */
		protected override function validElements():void
		{			
			var isValid:Boolean = true;
			// we need an extra check to validate the root attributes in order
			// to ensure parameters are parsed.
			validAttributes();
			//{ region check this elements model
			switch (children.length)
			{
				case 0:
					return;
					break;
				case 1:
					
					//{ region test if child element is head or body
					if (children[0] is HeadElement)
					{
						head = children[0] as HeadElement;
						isValid = true;
					}
					else if (children[0] is BodyElement)
					{
						body = children[0] as BodyElement;
						head = new HeadElement();
						children.length = 0;
						children.push(head);
						children.push(body);
						isValid = true;
					}
					else
					{
						isValid = false;
					}
					//} endregion
				
					break;
				case 2:

					//{ region Check first child is head, and second is body
					if (children[0] is HeadElement)
					{
						head = children[0] as HeadElement;
					}
					if (children[1] is BodyElement)
					{
						body = children[1] as BodyElement;
					}
					
					isValid = (body != null && head != null);
					//} endregion
				
					break;
				default:
					//{ region Cannot be valid
					isValid = false;
					//} endregion
					break;
			}
			//} endregion
			
			if (!isValid)
			{
				error("erroneous child in " + this);
			}
			
			//{ region now check each of the children is individually valid
			for each (var element:TimedTextElementBase in children)
			{
				element.valid(); 
			}
			//} endregion

			//{ region Add default region if none was specified
			if (isValid && DictionaryUtils.getLength(regions) < 1)
			{
				
				var defaultLayout:LayoutElement = new LayoutElement();
				defaultLayout.localName = "layout";
				defaultLayout.namespace = head.namespace;
				
				head.children.push(defaultLayout);
				defaultLayout.parent = head;
				var defaultRegion:RegionElement = new RegionElement();
				defaultRegion.id = RegionElement.DEFAULT_REGION_NAME;
				defaultRegion.setLocalStyle("backgroundColor",new ColorExpression(0,0.75));
				defaultRegion.setLocalStyle("color", Colors.White);
				defaultRegion.setLocalStyle("textAlign",TextAlign.CENTER);
				defaultRegion.setLocalStyle("fontFamily","_sans");
				defaultRegion.setLocalStyle("fontSize", FontSize.getFontSize("1c"));
				defaultRegion.setLocalStyle("extent", Extent.getExtent("100% 10%"));
				defaultRegion.setLocalStyle("origin", Origin.getOrigin("0% 90%"));
				defaultRegion.setLocalStyle("padding",new PaddingThickness("2px 10%"));
				defaultLayout.children.push(defaultRegion);
				defaultRegion.parent = defaultLayout;
				root.regions[defaultRegion.id] = defaultRegion;				
			}
			//} endregion
		}
		//} endregion
	}
}