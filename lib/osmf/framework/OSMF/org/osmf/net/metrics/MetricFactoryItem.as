package org.osmf.net.metrics
{
	import org.osmf.utils.OSMFStrings;

	/**
	 * MediaFactoryItem is the encapsulation of all information needed to dynamically
	 * create and initialize a MetricBase from a MetricFactory.
	 * 
	 * @see MetricBase 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class MetricFactoryItem
	{
		/**
		 * Constructor.
		 * 
		 * @param id An identifier that represents this MetricFactoryItem.
		 * 
		 * @param metricElementCreationFunction Function which creates a new instance
		 * of the desired MetricBase.  The function must take no params, and
		 * return a MetricBase.
		 * 
		 * @throws ArgumentError If any argument is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MetricFactoryItem(type:String, metricCreationFunction:Function)
		{
			if (type == null || metricCreationFunction == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			_type = type;
			_metricCreationFunction = metricCreationFunction;
		}
		
		/**
		 *  The type of metric handled by this MetricFactoryItem.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get type():String
		{
			return _type;
		}
		
		/**
		 * Function which creates a new instance of the desired MetricBase.
		 * The function must return a MetricBase.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get metricCreationFunction():Function
		{
			return _metricCreationFunction;
		}
		
		private var _type:String;
		private var _metricCreationFunction:Function;
	}
}