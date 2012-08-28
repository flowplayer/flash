package org.flexunit.flexui.data
{
	/**
	 * <p>The <code>MediaCaseRowData</code> is a value object meant to represent a <code>MediaTestCase</code> instance and
	 * is used with the UIListener for rendering said data.</p>
	 * 
	 * @author cpillsbury
	 * 
	 */	
	public class MediaCaseRowData extends TestFunctionRowData
	{
		protected var _testStep : int;
		
		public function get testStep():int
		{
			return _testStep;
		}
		
		public function set testStep(value:int):void
		{
			if ( value == _testStep )
				return;
			
			_testStep = value;
		}
		
		protected var _resourceURI : String;
		
		public function get resourceURI():String
		{
			return _resourceURI;
		}
		
		public function set resourceURI(value:String):void
		{
			if ( value == _resourceURI )
				return;
			
			_resourceURI = value;
		}
		
		protected var _description : String;
		
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String) : void
		{
			if ( value == _description )
				return;
			
			_description = value;
		}
		
		protected var _streamType : String;
		
		public function get streamType():String
		{
			return _streamType;
		}
		
		public function set streamType(value:String):void
		{
			if ( value == _streamType )
				return;
			
			_streamType = value;
		}
		
		override public function get assertionsMade() : Number
		{
			return NaN;
		}
		
		override public function get formattedAssertionsMade() : String
		{
			return "";
		}
		
		override public function get expectedResult() : String
		{
			// No-Op
			return "";
		}
		
		override public function set expectedResult( value : String ) : void
		{
			// No-Op
		}
		
		override public function get actualResult() : String
		{
			return error ? error.message : "";
		}
		
		override public function set actualResult( value : String ) : void
		{
			// No-Op
		}
		
		public function MediaCaseRowData()
		{
		}
	}
}