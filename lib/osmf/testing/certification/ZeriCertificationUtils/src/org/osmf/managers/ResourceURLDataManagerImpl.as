package org.osmf.managers
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * <p>The <code>ResourceURLDataManagerImpl</code> class is the standard implementation of <code>ResourceURLDataManager</code>
	 *  meant to be used with a defined set of XML data, used for externally parameterizing <code>MediaCase</code> test scenarios.</p>
	 * 
	 * @see org.flexunit.runners.ParameterizedMediaRunner
	 * @see org.osmf.managers.ResourceURLDataManager
	 * 
	 * @author cpillsbury
	 * 
	 */
	public class ResourceURLDataManagerImpl extends EventDispatcher
	{
		
		//------------------------------------------------------------------------
		//
		//  Properties
		//
		//------------------------------------------------------------------------
		
		//----------------------------------
		//  xmlList
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the xmlList property.
		 */	
		protected var _xmlList : XMLList;
		
		/**
		 * Stores the <code>XMLList</code> that defines the well-defined data provider for <code>MediaCase</code> properties in
		 * parameterized testing.
		 * 
		 * @see org.flexunit.cases.MediaCase#resourceURI
		 * @see org.flexunit.cases.MediaCase#runTimeSec
		 */			
		public function get xmlList() : XMLList
		{
			return _xmlList;
		}
	
		public function set xmlList( value : XMLList ) : void
		{
			if ( value === _xmlList )
				return;
			
			_xmlList = value;
		}
		
		//------------------------------------------------------------------------
		//
		//  Methods
		//
		//------------------------------------------------------------------------
		
		/**
		 * gets the URI strings for a given test number from the <code>xmlList</code>. 
		 * @param testNumber - the test number, defined by the <code>id</code> attribute of the <code>testCase</code> node.
		 * @return An array of strings based on the values of the <code>uri</code> nodes in the particular <code>testCase</code>.
		 */		
		public function getURIsForTestNumber( testNumber : int ) : Array
		{
			if ( !_xmlList )
				return null;
			
			var urisXML : XMLList = _xmlList.testCase.( @id == testNumber ).uri;
			
			if ( !urisXML )
				return null;
			
			var urisArray : Array = [];
			
			for each ( var property : XML in urisXML )
			{
				urisArray.push( property.toString() );
			}
			
			return urisArray;
		}
		
		/**
		 * gets the run time for a given test number from the <code>xmlList</code>. 
		 * @param testNumber - the test number, defined by the <code>id</code> attribute of the <code>testCase</code> node.
		 * @return An number representing how long the play time should be, based on the <code>time</code> attribute in the 
		 * particular <code>testCase</code>.
		 */	
		public function getRunTimeForTestNumber( testNumber : int ) : Number
		{
			if ( !_xmlList )
				return NaN;
			
			var runTime : Number = _xmlList.testCase.( @id == testNumber ).@time;
			
			return runTime;
		}
		
		public function ResourceURLDataManagerImpl()
		{
			super();
		}
	}
}