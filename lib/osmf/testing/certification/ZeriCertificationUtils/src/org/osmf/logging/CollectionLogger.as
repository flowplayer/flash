package org.osmf.logging
{
	/**
	 * <p>The <code>CollectionLogger</code> is a custom <code>Logger</code> that applies all log statements to an array collection
	 * that can than be globally referenced through a manager class.</p>
	 * 
	 * <p>Standard use case will involve setting the <code>Log</code> class' <code>loggerFactory</code> to an instance of 
	 * <code>CollectionLoggerFactory</code>, which will automatically create instances of <code>CollectionLogger</code> when
	 * getting a new logger instance from <code>Log</code>.</p>
	 * 
	 * <p>Based on <code>TraceLogger</code></code>
	 * 
	 * @see org.osmf.logging.LogCollectionManager
	 * @see org.osmf.logging.CollectionLoggerFactory
	 * @see org.osmf.logging.TraceLogger
	 * @author cpillsbury
	 * 
	 */	
	public class CollectionLogger extends Logger
	{
		public static const LEVEL_DEBUG : String = "DEBUG";
		public static const LEVEL_WARN : String = "WARN";
		public static const LEVEL_INFO : String = "INFO";
		public static const LEVEL_ERROR : String = "ERROR";
		public static const LEVEL_FATAL : String = "FATAL";
		
		/**
		 * @private
		 */
		override public function debug(message:String, ...rest):void
		{
			logMessage(LEVEL_DEBUG, message, rest);
		}
		
		/**
		 * @private
		 */
		override public function info(message:String, ...rest):void
		{
			logMessage(LEVEL_INFO, message, rest);
		}
		
		/**
		 * @private
		 */
		override public function warn(message:String, ...rest):void
		{
			logMessage(LEVEL_WARN, message, rest);
		}
		
		/**
		 * @private
		 */
		override public function error(message:String, ...rest):void
		{
			logMessage(LEVEL_ERROR, message, rest);
		}
		
		/**
		 * @private
		 */
		override public function fatal(message:String, ...rest):void
		{
			logMessage(LEVEL_FATAL, message, rest);
		}
		
		/**
		 * This function does the actual logging - adding the message
		 * to the <code>LoggerCollectionManager</code>'s array collection. 
		 * It also applies the parameters, if any, to the message string.
		 * 
		 * @see org.osmf.logging.LogCollectionManager#addLoggerCollectionItem()
		 * @see org.osmf.logging.TraceLogger#logMessage()
		 */
		protected function logMessage(level:String, message:String, params:Array):void
		{
			var msg:String = "";
			
			// add datetime
			msg += new Date().toLocaleString() + " [" + level + "] ";
			
			// add category and params
			msg += "[" + category + "] " + applyParams(message, params);
			
			// adds the message to the LoggerCollectionManager's array collection.
			LoggerCollectionManager.addLoggerCollectionItem( msg );
		}
		
		/**
		 * @copy org.osmf.logging.TraceLogger#applyParams()
		 */
		protected function applyParams(message:String, params:Array):String
		{
			var result:String = message;
			var numParams:int = params.length;
			
			for (var i:int = 0; i < numParams; i++)
			{
				result = result.replace(new RegExp("\\{" + i + "\\}", "g"), params[i]);
			}
			
			return result;
		}
		
		public function CollectionLogger(category:String)
		{
			super( category );
		}
	}
}