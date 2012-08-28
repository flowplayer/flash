package org.osmf.logging
{
	import flash.utils.Dictionary;
	
	/**
	 * <p>The <code>CollectionLoggerFactory</code> class is a simple custom logger factory, creating <code>CollectionLogger</code>s 
	 * when calling <code>Log.getLogger()</code>.  Meant to be assigned to the <code>Log.loggerFactory</code> property.  This is part
	 * of a set of classes that allows logging to be stored in a globally-accessible <code>ArrayCollection</code>.
	 * 
	 * @see org.osmf.logging.Log
	 * @see org.osmf.logging.CollectionLogger
	 * 
	 * @author cpillsbury
	 * 
	 */
	public class CollectionLoggerFactory extends LoggerFactory
	{
		protected var loggers:Dictionary;
		
		override public function getLogger( category : String ) : Logger
		{
			var logger : Logger = loggers[ category ];
			
			if ( !logger )
			{
				logger = new CollectionLogger(category);
				loggers[ category ] = logger;
			}
			
			return logger;
		}
		
		public function CollectionLoggerFactory()
		{
			super();
			loggers = new Dictionary( true );
		}
	}
}