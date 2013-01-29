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

package com.google.analytics.core
{
	import com.google.analytics.ecommerce.Transaction;
    
	public class Ecommerce
	{
		private var _trans:Array;
		
		public function Ecommerce()
		{
			_trans = new Array();
		}
		
        /**
        * Creates a transaction object with the given values. As with _addItem(), only
        * tracking for transactions is handled by this method. No additional ecommerce
        * functionality is provided. Therefore, if the transaction is a duplicate of
        * an existing transaction for that session, the old transaction values are
        * over-written with the new transaction values.
        * 
        * @private
        * @param {String} orderId Internal unique order id number for this transaction.
        * @param {String} affiliation Optional partner or store affiliation. (undefined if absent)
        * @param {String} total Total dollar amount of the transaction.
        * @param {String} tax Tax amount of the transaction.
        * @param {String} shipping Shipping charge for the transaction.
        * @param {String} city City to associate with transaction.
        * @param {String} state State to associate with transaction.
        * @param {String} country Country to associate with transaction.
        *
        * @return {_gat.GA_EComm_.Transactions_} The tranaction object that was modified.
        */
        public function addTransaction( id:String, affiliation:String, total:String, tax:String, shipping:String,
									    city:String, state:String, country:String ):Transaction
		{							   	
			var newTrans:Transaction = getTransaction( id );
			
			if ( newTrans == null ) 
			{
                //does not already exists, create a new one
				newTrans = new Transaction( id, affiliation, total, tax, shipping, city, state, country ); 	   	
				_trans.push( newTrans );			
			}
			else
			{
                //already exists, update properties
				newTrans.affiliation = affiliation;
				newTrans.total       = total;
				newTrans.tax         = tax;
				newTrans.shipping    = shipping;
				newTrans.city        = city;
				newTrans.state       = state;
				newTrans.country     = country;
			}
            
			return newTrans;
		}
	
		/**
 		* Takes an order Id, and returns the corresponding transaction object.  If the
 		* transaction is not found, return undefined.
 		*
 		* @private
 		* @param {String} orderId Internal unique order id number for this transaction.
 		*
 		* @return {_gat.GA_EComm_.Transactions_} Transaction object with the specified
 		*     order Id.
 		*/
		public function getTransaction( orderId:String ):Transaction
		{
			var i:uint;
			
			for( i=0; i<_trans.length; i++ )
			{
				if( _trans[i].id == orderId )
				{
                    //found
					return _trans[i];
				}		
			}
			
            //not found
			return null;
		}
		
		public function getTransFromArray( i:uint ):Transaction
		{
			return _trans[i];
		}
		
		public function getTransLength():Number
		{
			return _trans.length;
		}
		
	}
}