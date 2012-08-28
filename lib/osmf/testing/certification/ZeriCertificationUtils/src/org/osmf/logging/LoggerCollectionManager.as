package org.osmf.logging
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	/**
	 * <p>The <code>LoggerCollectionManager</code> class is a simple manager meant to be used with the <code>CollectionLogger</code> 
	 * class.  Allows global access to an <code>ArrayCollection</code> that stores each log statement. of a set of classes that allows 
	 * logging to be stored in a globally-accessible <code>ArrayCollection</code>.
	 * 
	 * @see org.osmf.logging.CollectionLogger
	 * 
	 * @author cpillsbury
	 * 
	 */
	public class LoggerCollectionManager extends EventDispatcher
	{
		
		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
     	 * Storage for the loggerCollection property. 
		 */		
		protected static var _loggerCollection : ArrayCollection = createCollection();
			
		[Bindable("collectionChanged")]
		/**
		 * The <code>ArrayCollection</code> that stores all of the log statements.
		 */	
		public static function get loggerCollection() : ArrayCollection
		{
			return _loggerCollection;
		}
			
		[Bindable("lastCollectionItemChanged")]
		/**
		 * The last item (log String line) stored in the <code>loggerCollection</code>. 
		 */
		public static function get lastLoggerCollectionItem() : Object
		{
			if ( !_loggerCollection || _loggerCollection.length <= 0 )
				return null;
			
			return _loggerCollection.getItemAt( _loggerCollection.length - 1 );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Adds an item (log String line) to the <code>loggerCollection</code>.
		 */
		public static function addLoggerCollectionItem( item : Object ) : int
		{
			if ( !_loggerCollection || !item )
				return -1;
			
			_loggerCollection.addItem( item );
			return _loggerCollection.getItemIndex( item );
		}
		
		/**
		 * Creates a new <code>ArrayCollection</code> to be used as the <code>loggerCollection</code>.
		 */
		protected static function createCollection() : ArrayCollection
		{
			var collection : ArrayCollection = new ArrayCollection();
			return collection;
		}
	}
}