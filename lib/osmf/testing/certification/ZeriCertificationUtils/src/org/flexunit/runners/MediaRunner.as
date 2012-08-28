package org.flexunit.runners
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.cases.interfaces.IMediaCase;
	import org.flexunit.events.MediaCaseErrorEvent;
	import org.flexunit.internals.namespaces.classInternal;
	import org.flexunit.internals.runners.model.EachTestNotifier;
	import org.flexunit.runner.Description;
	import org.flexunit.runner.IDescription;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runner.MediaDescription;
	import org.flexunit.runner.interfaces.IMediaDescription;
	import org.flexunit.runner.notification.IRunNotifier;
	import org.flexunit.runners.model.FrameworkMethod;
	import org.flexunit.runners.model.TestClass;
	import org.flexunit.token.IAsyncTestToken;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.net.StreamType;
	import org.osmf.traits.LoadState;
	
	/**
	 * <p>The <code>MediaRunner</code> class is a custom runner for the FlexUnit 4.x Framework, implementing the <code>IRunner</code> 
	 * interface and calling expected methods and properties defined on the <code>IMediaCase</code> interface for
	 * a particular test</p>
	 * 
	 * <p><b>Classes/Test Cases using <code>MediaRunner</code> as their runner should:</b></p>
	 * <ul>
	 * <li>Implement <code>IMediaCase</code></li>
	 * <li>Dispatch the expected events for notification when the actions taken by a method call are complete, as well
	 * as methods to notify when the test has completed successfully and any failture events.</li>
	 * </ul>
	 * 
	 * @see org.flexunit.cases.interfaces.IMediaCase
	 * @see org.flexunit.cases.MediaCase
	 * @see org.flexunit.events.MediaCaseErrorEvent
	 * 
	 * @author cpillsbury
	 * 
	 */	
	public class MediaRunner implements IRunner
	{
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		protected var currentTestStep : int = 0;
		
		// ******
		protected var testTimer : Timer;
		
		protected var timeoutTimer : Timer;
		
		protected var previousToken : IAsyncTestToken;

		/**
		 * @private
		 */
		protected var testNotifier : EachTestNotifier;
		
		/**
		 * @private
		 * If <code>MediaRunner</code> is instantiated by <code>ParameterizedMediaRunner</code>,
		 * this property represents the index of the parameter used for the test's run.
		 * 
		 * @see org.flexunit.runners.ParameterizedMediaRunner
		 */
		protected var parameterCount : int;
		
		/**
		 * @private
		 * Returns a <code>TestClass</code> object wrapping the class to be executed.
		 */
		protected var testClass:TestClass;
		
		//------------------------------------------------------------------------
		//
		//  Properties
		//
		//------------------------------------------------------------------------
		
		//----------------------------------
		//  currentResourceURI
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the currentResourceURI property.
		 */	
		protected var _currentResourceURI : String;
		
		/**
		 * The resourceURI used to run the media test case scenario.
		 */		
		public function get currentResourceURI() : String
		{
			return _currentResourceURI;
		}
		
		public function set currentResourceURI( value : String ) : void
		{
			if ( value == _currentResourceURI )
				return;
			
			_currentResourceURI = value;
		}
		
		//----------------------------------
		//  mediaCaseInstance
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the mediaCaseInstance property.
		 */	
		protected var _mediaCaseInstance : IMediaCase;
		
		/**
		 * @private
		 * The actual instantiation of the media test case scenario.
		 * 
		 * @see #run()
		 */	
		protected function get mediaCaseInstance() : IMediaCase
		{
			return _mediaCaseInstance;
		}
		
		protected function set mediaCaseInstance( value : IMediaCase ) : void
		{
			if ( value === _mediaCaseInstance )
				return;
			
			_mediaCaseInstance = value;
		}
		
		protected var cachedTestDescription : String = "";
		
		protected function get testDescription() : String
		{
			if ( !cachedTestDescription )
			{
				var methods : Array = testClass.getMetaDataMethods("Description");
				
				if ( methods && methods.length >= 0 )
				{
					var frameworkMethod : FrameworkMethod = methods[ 0 ];
					cachedTestDescription = frameworkMethod.invokeExplosively( testClass.asClass ) as String;
				}
			}
			return cachedTestDescription;
		}
		
		//------------------------------------------------------------------------
		//
		//  Properties: IRunner
		//
		//------------------------------------------------------------------------
		
		//----------------------------------
		//  description
		//----------------------------------
		
		/**
		 * @private
		 * Cached Storage for the description property.
		 */
		protected var cachedDescription:IMediaDescription;
		
		/**
		 * Retruns an <code>IDescription</code> of the test class that the runner is running.  Used with the UIListener.
		 */
		public function get description():IDescription {
			
			if( !cachedDescription )
			{
				// TODO: figure out a way to apply description & streamType (which is per-instance defined)
				var description:IMediaDescription = MediaDescription.createMediaTestDescription( testClass.asClass, 
					parameterCount, currentResourceURI, testDescription, StreamType.LIVE_OR_RECORDED, currentTestStep, testClass.metadata ); 
				cachedDescription = description;
			}
			
			trace( "MediaRunner::get description - " + cachedDescription );
			return cachedDescription;
		}
		
		//------------------------------------------------------------------------
		//
		//  Methods: IRunner
		//
		//------------------------------------------------------------------------
		
		/**
		 * Called by the Flex Unit framework to begin running a test case.
		 * 
		 * @param notifier the IRunNotifier, used for notification of test status (ie: started, finished, failed, etc).
		 * @param previousToken Used by the Flex Unit framework to tokenize test running as a chain.
		 * 
		 * @see org.flexunit.runner.IRunner#run()
		 */		
		public function run(notifier:IRunNotifier, previousToken:IAsyncTestToken):void
		{
			trace( "\n\n******************* TEST RUN STARTED *******************\n\n" );
			trace( "MediaRunner::run( " + notifier + ", " + previousToken + " )" );
			this.testNotifier = new EachTestNotifier( notifier, description );
			this.previousToken = previousToken;
			var caseFailError : Error;
			
			// ******** TODO: Maybe remove testTimer?
			testTimer = new Timer( 1000 );
			//testTimer.addEventListener( TimerEvent.TIMER, testTimerHandler, false, 0, true  );
			testTimer.addEventListener( TimerEvent.TIMER, testTimerHandler, false, 0, false );
			testTimer.start();
			
			testNotifier.fireTestStarted();
			
			try {
				mediaCaseInstance = createTest() as IMediaCase;
			}
			catch ( error : Error ) {
				caseFailError = error;
			}
			
			if ( mediaCaseInstance )
			{
				try {
					setupTimer();
					
					addMediaCaseListeners( mediaCaseInstance );
					initializeMediaCase( mediaCaseInstance );
				}
				catch ( error : Error ) {
					caseFailError = error;
				}
			}
			else if ( !caseFailError )
			{
				caseFailError = new Error( "test case does not implement IMediaCase" );
			}
			
			if ( caseFailError )
			{
				mediaCaseFailed( caseFailError );
			}
		}
		
		//------------------------------------------------------------------------
		//
		//  Methods: Set up and Tear down
		//
		//------------------------------------------------------------------------
				
		/**
		 * @private
		 * Creates and returns a new instance of the test case class 
		 * based on the <code>testClass</code> class.
		 * 
		 * @see #testClass
		 * @see #run()
		 */		
		protected function createTest():Object {
			var args:Array = new Array(currentResourceURI);
			
			if ( args && args.length > 0 )
				return testClass.klassInfo.constructor.newInstanceApply( args );
			else
				return testClass.klassInfo.constructor.newInstance();
		}
		
		/**
		 * @private
		 * Creates the <code>testClass</code> based on the test case class.
		 * @param klass Class type for the test case.
		 * 
		 */		
		protected function createTestClass( klass : Class ) : void
		{
			this.testClass = new TestClass( klass );
		}
		
		/**
		 * @private
		 * Adds necessary listeners for the <code>IMediaCase</code> test case scenario.  These events are used to
		 * determine various points in a test case run, plus success or failure of the test.
		 * 
		 * @param mediaCase The media case instance being tested.
		 * 
		 * @see org.flexunit.events.MediaCaseErrorEvent
		 */		
		protected function addMediaCaseListeners( mediaCase : IMediaCase ) : void
		{
			trace( "MediaRunner::addMediaCaseListeners()" );
			mediaCaseInstance.addEventListener( "elementLoaded", elementLoadedHandler, false, 0, true );
			mediaCaseInstance.addEventListener( MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE, canLoadHandler, false, 0, true );
			mediaCaseInstance.addEventListener( MediaCaseErrorEvent.SUCCESS, successHandler, false, 0, true );
			mediaCaseInstance.addEventListener( MediaCaseErrorEvent.STEP_SUCCESS, stepSuccessHandler, false, 0, true );
			mediaCaseInstance.addEventListener( MediaCaseErrorEvent.FAILURE, failureHandler, false, 0, true );
			mediaCaseInstance.addEventListener( MediaCaseErrorEvent.TIMEOUT, failureHandler, false, 0, true );
		}
		
		/**
		 * @private
		 * Removes necessary listeners for the <code>IMediaCase</code> test case scenario.  These events are used to
		 * determine various points in a test case run, plus success or failure of the test.
		 * 
		 * @param mediaCase The media case instance being tested.
		 * 
		 * @see org.flexunit.events.MediaCaseErrorEvent
		 */	
		protected function removeMediaCaseListeners( mediaCase : IMediaCase ) : void
		{
			trace( "MediaRunner::removeMediaCaseListeners()" );
			mediaCaseInstance.removeEventListener( "elementLoaded", elementLoadedHandler );
			mediaCaseInstance.removeEventListener( MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE, canLoadHandler );
			mediaCaseInstance.removeEventListener( MediaCaseErrorEvent.SUCCESS, successHandler );
			mediaCaseInstance.removeEventListener( MediaCaseErrorEvent.STEP_SUCCESS, stepSuccessHandler );
			mediaCaseInstance.removeEventListener( MediaCaseErrorEvent.FAILURE, failureHandler );
			mediaCaseInstance.removeEventListener( MediaCaseErrorEvent.TIMEOUT, failureHandler );
		}
		
		/**
		 * @private
		 * Sets up the timeout timer with a time based on the <code>mediaCaseInstance</code>'s <code>testTimeoutMS</code> 
		 * value.
		 * 
		 * @see org.flexunit.cases.interfaces.IMediaCase#testTimeoutMS
		 */		
		protected function setupTimer() : void
		{
			var testTimeoutMS : int = mediaCaseInstance.testTimeoutMS;
			
			if ( testTimeoutMS && testTimeoutMS > 0 )
			{
				timeoutTimer = new Timer( testTimeoutMS, 1 );
				timeoutTimer.addEventListener( TimerEvent.TIMER_COMPLETE, timeoutHandler, false, 0, true );
				timeoutTimer.start();
			}
			
		}
		
		/**
		 * @private
		 * Sets up the timeout timer with a time based on the <code>mediaCaseInstance</code>'s <code>testTimeoutMS</code> 
		 * value.
		 * 
		 * @see org.flexunit.cases.interfaces.IMediaCase#testTimeoutMS
		 */		
		protected function cleanupTimer() : void
		{
			if ( !timeoutTimer )
				return;
			
			timeoutTimer.stop();
			
			timeoutTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, timeoutHandler );
			timeoutTimer = null;
			
			// ******** TODO: Maybe remove testTimer?
			testTimer.stop();
			
			testTimer.removeEventListener( TimerEvent.TIMER, testTimerHandler );
			testTimer = null;
		}
		
		/**
		 * @private
		 * Should be called when testing has completed, whether as a success or failure.
		 * Cleans up the <code>mediaCaseInstance</code> by calling its <code>uninitializeCase()</code> method,
		 * which should have any internal tear down functionality defined within.
		 */		
		protected function cleanupMediaCase() : void
		{
			if ( mediaCaseInstance )
			{
				mediaCaseInstance.uninitializeCase();
				removeMediaCaseListeners( mediaCaseInstance );
			}
			
			mediaCaseInstance = null;
		}
		
		/**
		 * @private
		 * Step 1 in any <code>MediaRunner</code> test sequence.  Called from <code>run()</code>.
		 * @param mediaCase The current mediaCase instance.
		 * 
		 * @see #run()
		 */		
		protected function initializeMediaCase( mediaCase : IMediaCase ) : void
		{
			trace( "MediaRunner::initializeMediaCase( " + mediaCase + " )" );
			mediaCaseInstance.createResource();
			mediaCaseInstance.createMediaElement();
			mediaCaseInstance.applyMediaElement();
		}
		
		/**
		 * @private
		 * Called when a test has completed successfully (defined by when the <code>mediaCaseInstance</code> 
		 * fires a <code>MediaCaseErrorEvent.SUCCESS</code> event then completes final actions, such as stopping and
		 * unloading the media element).
		 */	
		protected function testCompleteSuccess() : void
		{
			trace( "MediaRunner::testCompleteSuccess()" );
			try
			{
				cleanupMediaCase();
			}
			catch ( error : Error )
			{
				mediaCaseFailed( error );
			}
			
			cleanupTimer();
			
			trace( "\n\n******************* TEST RUN SUCCEEDED *******************\n\n" );
			
			testNotifier.fireTestFinished();
			previousToken.sendResult();
			mediaCaseInstance = null;
		}
		
		/**
		 * @private
		 * Called when a test has failed for some reason, either by a) an error thrown that has been caught, 
		 * b) the <code>mediaCaseInstance</code> firing a <code>MediaCaseErrorEvent.FAILURE</code> event, 
		 * or c) a timeout when the test has run longer than the time defined by <code>mediaCaseInstance.testTimeoutMS</code>.
		 */	
		protected function mediaCaseFailed( error : Error ) : void
		{
			// TODO: determine why testNotifier.addFailure() and previousToken.sendResult() both cause a "testFailure()" to fire (Conv. w/Mike)
			trace( "MediaRunner::mediaCaseFailed( " + error + " )" );
			trace( "\n\n******************* TEST RUN FAILED *******************\n\n" );
			cleanupTimer();
			cleanupMediaCase();
			testNotifier.addFailure( error );
			testNotifier.fireTestFinished();
			previousToken.sendResult();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers: Event-driven test steps
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Step 2 in any <code>MediaRunner</code> test sequence.  Once <code>initializeMediaCase()</code> has 
		 * applied the media element on the <code>mediaCaseInstance</code>, wait for a <code>MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE</code> 
		 * to fire so that we can load the element.
		 * 
		 * @see #initializeMediaCase()
		 */		
		protected function canLoadHandler( event : MediaPlayerCapabilityChangeEvent ) : void
		{
			trace( "MediaRunner::canLoadHandler( " + event + " )" );
			if ( event.type == MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE && event.enabled )
			{
				try
				{
					// Assume loading counts as first test step in any test scenario.
					currentTestStep++;
					mediaCaseInstance.load();
				}
				catch ( error : Error )
				{
					mediaCaseFailed( error );
				}
			}
		}
		
		/**
		 * @private
		 * Step 3 in any <code>MediaRunner</code> test sequence.  Once we've called <code>load()</code> on the <code>mediaCaseInstance</code>, 
		 * wait for an <code>elementLoaded</code> to fire so that we know we are ready to start playing.
		 * 
		 * @see #canLoadHandler()
		 */		
		public function elementLoadedHandler( event : Event ) : void
		{
			trace( "MediaRunner::elementLoadedHandler( " + event + " )" );
			mediaCaseInstance.addEventListener( "elementPlaying", elementPlayingHandler, false, 0, true );
			try
			{
				mediaCaseInstance.play();
			}
			catch ( error : Error )
			{
				mediaCaseFailed( error );
			}
		}
		
		/**
		 * @private
		 * Step 4 in any <code>MediaRunner</code> test sequence.  Once we've called <code>play()</code> on the <code>mediaCaseInstance</code>, 
		 * wait for an <code>elementPlaying</code> to fire so that we know we are ready to start specific test scenario testing.
		 * 
		 * @see #elementLoadedHandler()
		 */		
		public function elementPlayingHandler( event : Event ) : void
		{
			trace( "MediaRunner::elementPlayingHandler( " + event + " )" );
			try
			{
				// This is where the test scenario-specific behavior should be set up (ex: define wait times for pauses/playbacks,
				// define number of streams to switch through for adaptive bitrate streams, etc.)
				mediaCaseInstance.executeTest();
			}
			catch ( error : Error )
			{
				mediaCaseFailed( error );
			}
		}
		
		/**
		 * @private
		 * Step 5 in any <code>MediaRunner</code> test sequence.  Once we've called <code>executeTest()</code> on the <code>mediaCaseInstance</code>, 
		 * wait for a <code>MediaCaseErrorEvent.SUCCESS</code> to fire so that we know all test scenario specific behavior has executed successfully. 
		 * Once this happens, we can begin tear down by first stopping the element's stream. 
		 * Note: we expect each test case to define the criteria under which this event will fire.
		 * 
		 * @see #elementPlayingHandler()
		 */	
		protected function successHandler( event : MediaCaseErrorEvent ) : void
		{
			trace( "MediaRunner::successHandler( " + event + " )" );
			mediaCaseInstance.addEventListener( "elementStopped", elementStoppedHandler, false, 0, true );
			mediaCaseInstance.stop();
		}
		
		/**
		 * @private
		 * Step 6 in any <code>MediaRunner</code> test sequence.  Once we've successfully executed all test scenario specific processes 
		 * on the <code>mediaCaseInstance</code>, the runner must perform some additional actions in order to ensure the elements are 
		 * appropriately torn down.  Step one of this is to stop the stream.  Once this occurs, we can then call <code>mediaCaseInstance.unload()</code>.
		 * 
		 * @see #successHandler()
		 */	
		public function elementStoppedHandler( event : Event ) : void
		{
			trace( "MediaRunner::elementStoppedHandler( " + event + " )" );
			try
			{
				mediaCaseInstance.addEventListener( "elementUnloaded", elementUnoadedHandler, false, 0, true );
				mediaCaseInstance.unload();
			}
			catch ( error : Error )
			{
				mediaCaseFailed( error );
			}
		}
		
		/**
		 * @private
		 * Step 7 in any <code>MediaRunner</code> test sequence.  Once we've successfully executed all test scenario specific processes 
		 * on the <code>mediaCaseInstance</code>, the runner must perform some additional actions in order to ensure the elements are 
		 * appropriately torn down.  Step two of this is to unload the media element.  Once this occurs, we may consider this test
		 * an actual success.
		 * 
		 * @see #successHandler()
		 */
		protected function elementUnoadedHandler( event : Event ) : void
		{
			trace( "MediaRunner::elementUnoadedHandler( " + event + " )" );
			testCompleteSuccess();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Catches any <code>MediaCaseErrorEvent.FAILURE</code> events and determines the best error to use for
		 * test failure.
		 * 
		 * @see #mediaCaseFailed()
		 */		
		protected function failureHandler( event : MediaCaseErrorEvent ) : void
		{
			trace( "MediaRunner::failureHandler( " + event + " )" );
			// TODO: determine whether or not there is pertinent info in the "triggerEvent" (ie: LOAD_ERROR for state in LoadEvent )
			var error : Error;
			
			if ( event.error )
			{
					error = event.error;
			}
			else if ( event.text )
			{
				var errorID : int = event.id;
				error = new Error( event.text, errorID );
			}
			else
			{
				error = new Error( "The test case failed." )
			}
			//else if ( event.triggerEvent )
				
			
			mediaCaseFailed( error );
		}
		
		/**
		 * @private
		 * Notifies runner that a step in the test case has completed and the currentTestStep should be incremented.  Used
		 * for feedback on failures so user can better know at what point the test scenario failed.
		 */	
		protected function stepSuccessHandler( event : MediaCaseErrorEvent ) : void
		{
			trace( "MediaRunner::stepSuccessHandler( " + event + " )" );
			currentTestStep++;
		}
		
		/**
		 * @private
		 * Called when the test has timed out, based on the <code>mediaCaseInstance</code>'s <code>testTimeoutMS</code> 
		 * value.
		 * 
		 * @see #mediaCaseFailed()
		 */	
		protected function timeoutHandler( event : TimerEvent ) : void
		{
			var errorMsg : String = "Test timed out after " + ( event.target as Timer ).delay + " ms."; 
			mediaCaseFailed( new Error( errorMsg ) );
		}
		
		// ********
		protected function testTimerHandler( event : TimerEvent ) : void
		{
			/*var timer : Timer = ( event.target as Timer );
			var time : int = Math.round( ( timer.currentCount * timer.delay ) / 1000 );
			trace( "MediaRunner::testTimerHandler( " + event + " )" );
			trace( "\ttime - " + time );
			trace( "\trunner's uri - " + currentResourceURI );
			if ( !mediaCaseInstance )
				trace( "\tno media case instance!" );
			else
				trace( "\tmedia case's uri - " + mediaCaseInstance.resourceURI );*/
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 * @param klass Particular test case Class 
		 * @param currentResourceURI optional resource uri string to use for the test case instance.
		 * @param i index of the seed data (currentResourceURI) if this runner was instantiated by 
		 * <code>ParameterizedMediaRunner</code>.
		 * 
		 * @see org.flexunit.runners.ParameterizedMediaRunner
		 */		
		public function MediaRunner( klass:Class, currentResourceURI : String = "", i : int = -1 )
		{
			this.currentResourceURI = currentResourceURI;
			this.parameterCount = i;
			
			trace( "MediaRunner::MediaRunner( " + klass + " )" );
			createTestClass( klass );
		}
	}
}