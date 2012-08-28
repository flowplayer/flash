/**
 * Copyright (c) 2009 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author     Alan Stearns - astearns@adobe.com
 * 			   Michael Labriola - labriola@digitalprimates.net
 * 			   David Wolever - david@wolever.net
 * @version
 *   
 **/

package org.flexunit.runners
{	
	import org.flexunit.internals.builders.AllDefaultPossibilitiesBuilder;
	import org.flexunit.runner.IDescription;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runner.notification.IRunNotifier;
	import org.flexunit.runners.model.FrameworkMethod;
	import org.flexunit.runners.model.IRunnerBuilder;
	import org.flexunit.token.AsyncTestToken;
	
	/**
	 * Based on <code>org.flexunit.runners.Parameterized</code> 
	 * @author cpillsbury
	 * @see org.flexunit.runners.Parameterized
	 * 
	 */	
	public class ParameterizedMediaRunner extends ParentRunner
	{
		protected var _runners:Array;
		
		//Blank constructor means the old 0/1 error
		public function ParameterizedMediaRunner(klass:Class) {
			super (klass);
			_runners = new Array();
			populateParametersList( klass );
		}
		
		protected function populateParametersList( klass : Class ) : void
		{
			var parametersList : Array = getParametersList( klass );
			
			// If there are no parameters, create a single runner for the class.
			if ( parametersList.length == 0 )
			{
				_runners.push( new MediaRunner( klass ) );
			} 
			// Otherwise, create an instance per resourceURI in the parameters.
			else
			{
				for (var i:int= 0; i < parametersList.length; i++)
				{
					_runners.push( new MediaRunner( klass, parametersList[ i ], i ) );
				}
			}
		}
				
		protected function getParametersList(klass:Class):Array {
			var allParams:Array = new Array();
			var frameworkMethod:FrameworkMethod;
			var methods:Array = getParametersMethods(klass);
			var data:Array;

			for ( var i:int=0; i<methods.length; i++ ) {
				frameworkMethod = methods[ i ];
				
				data = frameworkMethod.invokeExplosively(klass) as Array;
				allParams = allParams.concat( data );
			}
			
			return allParams;
		}
		
		protected function getParametersMethods(klass:Class):Array {
			// Looks for any static methods in the class that have a metadata tag
			// including the string "Parameters"
			var methods:Array = testClass.getMetaDataMethods("Parameters");
			return methods;
		}
		
		// begin Items copied from Suite
		override protected function get children():Array {
			return _runners;
		}

		override protected function describeChild( child:* ):IDescription {
			return IRunner( child ).description;
		}

		override protected function runChild( child:*, notifier:IRunNotifier, childRunnerToken:AsyncTestToken ):void {
			IRunner( child ).run( notifier, childRunnerToken );
		}
		// end Items copied from Suite
	}
}
