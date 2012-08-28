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
package org.osmf.smpte.tt.utilities
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;
	
	/**
	 *  @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")] 
	
	public class AsyncThread extends EventDispatcher
	{
		private var _shape:Shape;
		public function get shape():Shape
		{
			if(!_shape) _shape = new Shape();
			return _shape;             
		}
		
		private var _isComplete:Boolean = true;
		[Bindable("complete")]
		public function get isComplete():Boolean
		{
			return _isComplete;             
		}
		
		private var _stack:Array = [[]];
		
		private function get currentQueue():Array
		{
			if ( _stack.length == 0 )
				return null;
			
			return _stack[ _stack.length - 1 ] as Array;
		}

		public function AsyncThread()
		{
		}
		
		private function queue( func:Function, args:Array = null ):void
		{
			currentQueue.push( [ func, args ] );
			_isComplete = false;
		}
		
		public function step():void
		{
			if ( _isComplete ) return;
			
			while ( currentQueue.length == 0 )
			{
				_stack.pop();
				if ( currentQueue == null )     
				{
					_isComplete = true;
					dispatchEvent( new Event( Event.COMPLETE ) );
					shape.removeEventListener( Event.ENTER_FRAME, shape_enterFrame );
					return;
				}               
			}
			
			var entry:Array = currentQueue.shift() as Array;                
			// append to the stack so any calls made when executing this entry are stored in their own queue
			_stack.push( [] );
			
			//////////////// execute //////////////////
			var func:Function = entry[ 0 ] as Function;
			var args:Array = [];
			
			if (entry[1] && entry[1] is Array) args = ( entry[1] as Array );
			
			_threadStack.push( this );
			func.apply( null, args );
			_threadStack.pop();
		}
		
		private var _endTime:int;
		/**
		 * 
		 * Will execute this thread for the amount of time specified, if no argument is passed it will run to completion
		 * 
		 * @param elapsed the time, in milliseconds, that this thread is given to run. defaults to -1 ( no limit )
		 * 
		 */             
		public function run( elapsed:int = -1 ):void
		{
			_endTime = getTimer() + elapsed;
			while ( ( elapsed == -1 ) 
				|| ( getTimer() < _endTime ) )
			{
				step();
				if ( _isComplete ) break;
			}
		}
		
		/**
		 * 
		 * A common use case.
		 * Will add an enter frame listener and try to run( elapsed ) on each frame.
		 * 
		 * @param elapsed
		 * 
		 */             
		public function runEachFrame( elapsed:int = 100 ):void
		{
			_elapsedPerFrame = elapsed;
			shape.addEventListener( Event.ENTER_FRAME, shape_enterFrame );                  
		}
		
		private var _elapsedPerFrame:int;
		
		private function shape_enterFrame( event:Event ):void
		{
			run( _elapsedPerFrame );
		}
		
		private static var _threadStack:Array = [];
		/**
		 * 
		 * 
		 * Creates a thread instance, starting at the given function.
		 * You can then call thread.step() to execute the first step and any
		 * other nested steps that get queued as well.
		 * 
		 * 
		 * @param func
		 * @param args
		 * @return 
		 * 
		 */             
		public static function create( func:Function, args:Array = null ):AsyncThread
		{
			var thread:AsyncThread = new AsyncThread( );
			thread.queue( func, args );
			return thread;
		}
		
		/**
		 * 
		 * Even though this function is static, it operates on the current active runner thread.
		 * It is only meant to be called from within functions that are designed to work with async
		 * threads.
		 * 
		 * @param func
		 * @param args
		 * 
		 */             
		public static function queue( func:Function, args:Array = null ):void
		{
			if ( _threadStack.length > 0 )
			{
				// append call to the current ( topmost ) runner's queue
				( _threadStack[ _threadStack.length - 1 ] as AsyncThread ).queue( func, args );           
			}
			else
			{
				throw new Error( "There is no active AsyncThread. You cannot queue a method call." );   
			}
		}
	}
}