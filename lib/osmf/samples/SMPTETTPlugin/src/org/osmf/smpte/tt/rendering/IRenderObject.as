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
package org.osmf.smpte.tt.rendering
{
	import flash.geom.Rectangle;
	
	import org.osmf.smpte.tt.informatics.MetadataInformation;
	import org.osmf.smpte.tt.styling.ColorExpression;
	import org.osmf.smpte.tt.styling.Font;
	import org.osmf.smpte.tt.styling.TextDecorationAttributeValue;
	import org.osmf.smpte.tt.styling.TextOutline;
	import org.osmf.smpte.tt.vocabulary.Metadata;

	public interface IRenderObject
	{
		function open():void;
		function close():void;
		
		/**
		 * clear the drawing surface to the specified color.
		 */
		function clear(color:ColorExpression):void;
		
		/**
		 * Set the drawing opacity
		 * @param name level
		 */
		function setOpacity(level:Number):void;
		
		/**
		 * Draw a line in the specified colour from x to y
		 */
		function drawLine(color:ColorExpression, startX:Number, startY:Number, endX:Number, endY:Number):void;
		
		/**
		 * Draw a rectangle outline with specified pen, filled with specified brush
		 * from top left (x1,y1) to bottom right (x2,y2)
		 *
		 * @param x1 top left x coordinate
		 * @param y1 top left y coordinate
		 * @param x2 bottom right x coordinate
		 * @param y2 bottom right y coordinate
		 */
		function drawRectangle(color:ColorExpression, startX:Number, startY:Number, endX:Number, endY:Number):void;
		
		/**
		 * Draws a series of glyphs identified by the specified text and font.
		 */
		function drawText(text:String, font:Font, fill:ColorExpression, decoration:TextDecorationAttributeValue, startX:Number, startY:Number, data:MetadataInformation):void;
		
		function drawOutlineText(text:String, font:Font, fill:ColorExpression, outline:TextOutline, startX:Number, startY:Number, data:MetadataInformation):void;
		
		function computeTextExtent(text:String, font:Font):Rectangle;
		
		/**
		 * Set clipping rectangle.
		 * 
		 * @param rect clipping rectangle
		 */
		function pushClip(rectangle:Rectangle):void;
		
		/**
		 * Unset clipping rectangle
		 */
		function popClip():void;
		
		function pushScroll(horizontalDistance:Number, verticalDistance:Number):void;
		
		function width():Number;
		function height():Number;
	}
}