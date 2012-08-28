package org.flexunit.runner.interfaces
{
	import org.flexunit.runner.IDescription;
	
	/**
	 * <p>The <code>IMediaDescription</code> defines the public interface for the <code>MediaDescription</code> class</p>
	 * 
	 * @see org.flexunit.runner.MediaDescription
	 *  
	 * @author cpillsbury
	 * 
	 */	
	public interface IMediaDescription extends IDescription
	{
		/**
		 * The URI of the stream being tested.
		 */		
		function get resourceURI() : String;
		function set resourceURI( value : String ) : void;
		
		/**
		 * A common language description of the test. 
		 */		
		function get description() : String;
		function set description( value : String ) : void;
		
		/**
		 * The particular type of stream (ex: "live" or "dvr").
		 * @see org.osmf.net.StreamType
		 */
		function get streamType() : String;
		function set streamType( value : String ) : void;
		
		/**
		 * The current step of the test.
		 */		
		function get testStep() : int;
		function set testStep( value : int ) : void;
		
	}
}