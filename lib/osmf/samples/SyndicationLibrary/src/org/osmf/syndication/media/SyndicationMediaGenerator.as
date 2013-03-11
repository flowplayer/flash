/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.syndication.media
{
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;
	import org.osmf.syndication.model.Entry;
	
	/**
	 * A utility class for creating MediaElement objects
	 * given a syndication Entry object.
	 * 
	 * The class will use the MediaFactory supplied. If no
	 * MediaFactory is supplied it will use the DefaultMediaFactory 
	 * class.
	 **/
	public class SyndicationMediaGenerator
	{
		/**
		 * Constructor.
		 * 
		 * @param mediaFactory The MediaFactory to use for creating MediaElement objects.
		 **/
		public function SyndicationMediaGenerator(mediaFactory:MediaFactory=null)
		{
			_mediaFactory = mediaFactory;
			if (_mediaFactory == null)
			{
				_mediaFactory = new DefaultMediaFactory();
			}
		}
		
		/**
		 * Creates a MediaElement using the entry supplied.
		 * The default behavior is to use the enclosure property of
		 * the Entry object. Extend this class and
		 * override this method to provide custom behavior.
		 * 
		 * @param entry The Entry object to use for creating the MediaElement.
		 **/
		public function createMediaElement(entry:Entry):MediaElement
		{
			var mediaElement:MediaElement;
			mediaElement = _mediaFactory.createMediaElement(new URLResource(entry.enclosure.url));
			return mediaElement;
		}
		
		/**
		 * The MediaFactory this class is using.
		 **/
		public function get mediaFactory():MediaFactory
		{
			return _mediaFactory;
		}

		private var _mediaFactory:MediaFactory;
	}
}
