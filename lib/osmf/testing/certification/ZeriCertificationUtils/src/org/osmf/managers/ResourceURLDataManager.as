package org.osmf.managers
{	
	/**
	 * <p>The <code>ResourceURLDataManager</code> class is a simple manager meant to be used with a defined set of XML data, used
	 * for externally parameterizing <code>MediaCase</code> test scenarios, allowing for externally-defined urls and play times</p>
	 * 
	 * @see org.flexunit.runners.ParameterizedMediaRunner
	 * @see org.osmf.managers.ResourceURLDataManagerImpl
	 * 
	 * @author cpillsbury
	 * 
	 */
	public class ResourceURLDataManager
	{
		private static var _impl : ResourceURLDataManagerImpl;
		
		public static function get impl() : ResourceURLDataManagerImpl
		{
			if ( !_impl )
				_impl = new ResourceURLDataManagerImpl();
			
			return _impl;
		}
		
		public static function set impl( value : ResourceURLDataManagerImpl ) : void
		{
			if ( value === _impl )
				return;
			
			_impl = value;
		}
		
		/**
		 * @copy org.osmf.managers.ResourceURLDataManagerImpl#xmlList
		 */		
		public static function get xmlList() : XMLList
		{
			return impl.xmlList;
		}
		
		public static function set xmlList( value : XMLList ) : void
		{
			impl.xmlList = value;
		}
		
		/**
		 * @copy org.osmf.managers.ResourceURLDataManagerImpl#getURIsForTestNumber()
		 */		
		public static function getURIsForTestNumber( testNumber : int ) : Array
		{
			return impl.getURIsForTestNumber( testNumber );
		}
		
		/**
		 * @copy org.osmf.managers.ResourceURLDataManagerImpl#getRunTimeForTestNumber()
		 */	
		public static function getRunTimeForTestNumber( testNumber : int ) : Number
		{
			return impl.getRunTimeForTestNumber( testNumber );
		}	
	}
}