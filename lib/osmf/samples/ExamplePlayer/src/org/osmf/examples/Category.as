package org.osmf.examples
{
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;

	public class Category extends ArrayCollection
	{
		public function Category(name:String)
		{
			_name = name;			
		}
		
		public function get name():String
		{
			return _name;
		}
				
		public function get children():ArrayCollection
		{
			return this;
		}
		
		private var _name:String;
	}
}