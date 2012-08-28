package org.flexunit.runner
{
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.runner.interfaces.IMediaDescription;
	
	/**
	 * <p>The <code>MediaDescription</code> is a test description with additional properties that are Media Test Case specific.</p>
	 * 
	 * @see org.flexunit.runner.Description
	 * @see org.flexunit.runner.interfaces.IMediaDescription
	 * @see org.flexunit.runners.MediaRunner#description
	 *  
	 * @author cpillsbury
	 * 
	 */	
	public class MediaDescription extends Description implements IMediaDescription
	{
		public static function createMediaTestDescription( testClassOrInstance:Class, parameterCount : int, resourceURI:String, 
														   description:String="", streamType:String="liveOrRecorded", testStep : int = 0,
														   metadata:Array=null ):IMediaDescription
		{
			var mediaDescription : MediaDescription;
			var displayName : String = getQualifiedClassName( testClassOrInstance) + "_" + parameterCount;
			
			mediaDescription = new MediaDescription( displayName, metadata, false, description, resourceURI, streamType, testStep );
			return mediaDescription;
		}
		
		//------------------------------------------------------------------------
		//
		//  Properties: IMediaDescription
		//
		//------------------------------------------------------------------------
		
		//----------------------------------
		//  resourceURI
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the testStep property.
		 */	
		protected var _testStep : int;
		
		/**
		 * @copy org.flexunit.runner.interfaces.IMediaDescription#testStep
		 */	
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
		
		//----------------------------------
		//  resourceURI
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the resourceURI property.
		 */	
		protected var _resourceURI : String;
		
		/**
		 * @copy org.flexunit.runner.interfaces.IMediaDescription#resourceURI
		 */	
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
		
		//----------------------------------
		//  description
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the description property.
		 */	
		protected var _description : String;
		
		/**
		 * @copy org.flexunit.runner.interfaces.IMediaDescription#description
		 */	
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
		
		//----------------------------------
		//  streamType
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the streamType property.
		 */	
		protected var _streamType : String;
		
		
		/**
		 * @copy org.flexunit.runner.interfaces.IMediaDescription#streamType
		 */	
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
		
		public function MediaDescription(displayName:String, metadata:Array, isInstance:Boolean=false, 
										 description:String="", resourceURI:String="", streamType:String="", testStep:int=0)
		{
			super(displayName, metadata, isInstance);
			this.description = description;
			this.resourceURI = resourceURI;
			this.streamType = streamType;
			this.testStep = testStep;
		}
	}
}