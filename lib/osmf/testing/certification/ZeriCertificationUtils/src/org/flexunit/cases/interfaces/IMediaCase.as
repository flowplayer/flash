package org.flexunit.cases.interfaces
{
	import flash.events.IEventDispatcher;
	
	/**
	 * The IMediaCase interface defines the public API for Test Cases meant for testing OSMF stream interactions.
	 * For example, the <code>org.flexunit.runners.MediaRunner</code> class uses IMediaCase to reference expected properties
	 * and methods on its test cases in order to initialize and break down the test cases.
	 * @see org.flexunit.cases.MediaCase
	 * @see org.flexunit.runners.MediaRunner
	 * @author cpillsbury
	 * 
	 */
	public interface IMediaCase extends IEventDispatcher
	{
		/**
		 * The Resource URI, as a string (ex value: "http://host.domain.net/manifest.f4m" )
		 */		
		function get resourceURI() : String;
		function set resourceURI( value : String ) : void;
		
		/**
		 * The stream type of the resource (ex: "live")
		 * @see org.osmf.net.StreamType
		 */		
		function get streamType() : String;
		function set streamType( value : String ) : void;
		
		/**
		 * An optional real-language string description of the particular test case.
		 */		
		function get description() : String;
		function set description( value : String ) : void;
		
		/**
		 * The amount of time, in milliseconds, until a particular test case will fail by timeout.
		 */		
		function get testTimeoutMS() : int;
		function set testTimeoutMS( value : int ) : void;
		
		/**
		 * The amount of time, in seconds, a test should continuously play before any case-specific actions are taken.
		 * Note: This may be used differently on a test case by test case basis.
		 * Note: This does not define the total amount of time any given test will run, or even the amount of time
		 * A test should play until, only the amount of time of continuous play (without performing additional actions).
		 */
		function get runTimeSec() : Number;
		function set runTimeSec( value : Number ) : void;
		
		/**
		 * Create the resource stream object based on the <code>resourceURI</code> and <code>streamType</code> properties.
		 * Will get an error if these values are invalid.
		 * @see #resourceURI
		 * @see #streamType 
		 */		
		function createResource() : void;
		
		/**
		 * Creates the media element to be used by the test case, based on the resource stream object.
		 * Will get an error if the stream hasn't been created.
		 * @see #createResource()
		 */		
		function createMediaElement() : void;
		
		/**
		 * Applies the media test case's media element to the internal media player and sets up any additional 
		 * properties/event listeners needed.
		 * Will get an error if the media element hasn't been created.
		 * @see #createMediaElement()
		 */		
		function applyMediaElement() : void;
		
		/**
		 * loads the media element.
		 */		
		function load() : void;
		
		/**
		 * plays the media element. 
		 */		
		function play() : void;
		
		/**
		 * pauses the media element. 
		 */
		function pause() : void;
		
		/**
		 * seeks to time <code>time</code>, in <b>seconds</b>, on the media element. 
		 */
		function seek( time : Number ):void;
		
		/**
		 * stops the media element. 
		 */
		function stop() : void;
		
		/**
		 * unloads the media element. 
		 */
		function unload() : void;
		
		/**
		 * This method is where any test case-specific setup and execution should occur.  Meant primarily to be overridden
		 * by subclasses of a standard implementation, though one could have some default behavior defined in a
		 * base class implementing this interface.  The <code>MediaRunner</code> will call this after playback of the stream
		 * has begun.
		 * 
		 * @see org.flexunit.runners.MediaRunner#elementPlayingHandler()
		 */
		function executeTest() : void;
		
		/**
		 * Does any necessary uninitialization/tear down after a test case has completed.
		 */		
		function uninitializeCase() : void;
	}
}