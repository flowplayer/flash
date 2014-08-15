/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.examples.seeking
{
	import org.osmf.examples.loaderproxy.AsynchLoadingProxyElement;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.LoadTrait;
	
	/**
	 * A ProxyElement which preloads its proxied element up front.  The preload
	 * operation is defined as a load plus a play followed by a pause.  Extends
	 * AsynchLoadingProxyElement, which is a generic base class for proxies that
	 * need to incorporate custom logic into the load operation.
	 **/
	public class PreloadingProxyElement extends AsynchLoadingProxyElement
	{
		/**
		 * Constructor.
		 **/
		public function PreloadingProxyElement(proxiedElement:MediaElement)
		{
			super(proxiedElement);
		}

		/**
		 * @private
		 **/
		override protected function createAsynchLoadingProxyLoadTrait():LoadTrait
		{
			return new PreloadingLoadTrait(proxiedElement);
		}
	}
}