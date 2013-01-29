/*
 * Copyright 2008 Adobe Systems Inc., 2008 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */
 
package com.google.analytics.ecommerce
{
	import com.google.analytics.log;
	import com.google.analytics.utils.Variables;
	
	import core.Logger;
	
	public class Item
	{
		private var _log:Logger;
        
		private var _id:String;
		private var _sku:String;
		private var _name:String;
		private var _category:String;
		private var _price:String;
		private var _quantity:String;

		
		/**
 		* @class Item object for e-commerce module.  This encapsulates all the
 		*     necessary logic for manipulating an item.
 		*
 		* @param {String} transId Id of transaction this item belongs to.
 		* @param {String} sku SKU code for item.
 		* @param {String} name Product name.
 		* @param {String} category Product category.
 		* @param {String} price Product price.
 		* @param {String} quantity Purchase quantity.
 		*
 		* @constructor
 		*/
		public function Item( id:String, sku:String, name:String, category:String, price:String, quantity:String )
		{
            LOG::P{ _log = log.tag( "Item" ); }
            LOG::P{ _log.v( "constructor()" ); }
            
			_id       = id;
			_sku      = sku;
			_name     = name;
			_category = category;
			_price    = price;
			_quantity = quantity;
		}	
		
        /** Id of transaction this item belongs to */
		public function get id():String { return _id; }
        /** @private */
        public function set id( value:String ):void { _id = value; }
        
        /** SKU code for item */
		public function get sku():String { return _sku; }
        /** @private */
        public function set sku( value:String ):void { _sku = value; }
        
        /** Product name */
		public function get name():String { return _name; }
        /** @private */
        public function set name( value:String ):void { _name = value; }
        
        /** Product category */
		public function get category():String { return _category; }
        /** @private */
        public function set category( value:String ):void { _category = value; }
        
        /** Product price */
		public function get price():String { return _price; }
        /** @private */
        public function set price( value:String ):void { _price = value; }
        
        /** Purchase quantity */
		public function get quantity():String { return _quantity; }
        /** @private */
		public function set quantity( value:String ):void { _quantity = value; }
        
		/**
		 * Converts this items object to gif parameters.
		 *
		 * @private
		 * @param {String} sessionId Session Id for this e-commerce transaction.
		 *
		 * @returns {String} GIF request parameters for this item.
		 */		
		public function toGifParams():Variables
		{
            LOG::P{ _log.v( "toGifParams()" ); }
            
			var vars:Variables = new Variables();
			    vars.URIencode = true;
			    vars.post = [ "utmt", "utmtid", "utmipc", "utmipn", "utmiva", "utmipr", "utmiqt" ];
			
			    vars.utmt   = "item";
			    vars.utmtid = _id;
			    vars.utmipc = _sku;
			    vars.utmipn = _name;
			    vars.utmiva = _category;
			    vars.utmipr = _price;
			    vars.utmiqt = _quantity;	 
			 
			return vars;
		}
        
	}
}				 