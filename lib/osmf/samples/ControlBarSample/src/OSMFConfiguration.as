/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package
{
	import flash.display.DisplayObjectContainer;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	
	/**
	 * The Configuration class defines an object that simplifies setting up
	 * an OSMF configuration. The class implements the boiler plate code
	 * that is required to setup commonly used framework building blocks:
	 * 
	 *    MediaPlayer (accessible from the player property)
	 *    MediaContainer (accessible from the container property)
	 *    DefaultMediaFactory (accessible from the factory property)
	 * 
	 * Furthermore, the object contains a 'view' property. When it is set,
	 * the object will add the constructed media container as a child to
	 * the designated DisplayObjectContainer.
	 * 
	 * Last, the object allows for 3 ways of controlling the configuration's
	 * principle media element.
	 * 
	 * At the highest level, a string can be passed to the url property. The
	 * configuration will construct a URL and URLResource.
	 * 
	 * At mid-level, a MediaResourceBase typed object can be passed to the
	 * resource propery.
	 * 
	 * When either the url or a resource property is set, the object will use
	 * its media factory to create a corresponding media element. The resulting
	 * element gets forwared to the internal player, and container instances.
	 * Alternatively, an existing media element can be assigned to the
	 * mediaElement property directly. This constitues the third, lowest level
	 * of controlling the configuration's principle media element.
	 */	
	public class OSMFConfiguration
	{
		/**
		 * Constructor
		 */		
		public function OSMFConfiguration()
		{
			_player = new MediaPlayer();
			_container = new MediaContainer();
		}
		
		/**
		 * Defines the url string that is used to construct the configuration's
		 * principle media element.
		 * 
		 * On a url being set, a URLResource gets constructed and set on the
		 * object's resource property.
		 */		
		public function set url(value:String):void
		{
			if (url != value)
			{
				resource = new URLResource(value);
			}
		}
		public function get url():String
		{
			return _resource is URLResource
						? URLResource(_resource).url
						: null;
		}
		
		/**
		 * Defines the resource that is used to construct the configuration's
		 * principle media element.
		 * 
		 * On a resource being set, the media factory is requested to create
		 * a media element for the resource. The resulting media element is set
		 * the configuration's mediaElement property.
		 */		
		public function set resource(value:MediaResourceBase):void
		{
			_resource = value;
			mediaElement = factory.createMediaElement(resource);
		}
		public function get resource():MediaResourceBase
		{
			return _resource;
		}
		
		/**
		 * Defines the DisplayObjectContainer that will hold the configuration's
		 * media container.
		 * 
		 * On a view being set, the configuration adds its media container to
		 * the designated view.
		 */		
		public function set view(value:DisplayObjectContainer):void
		{
			if (_view)
			{
				_view.removeChild(_container);
			}
			_view = value;
			if (_view)
			{
				_view.addChild(container);
			}
		}
		public function get view():DisplayObjectContainer
		{
			return _view;
		}
		
		/**
		 * Defines the configuration's current media element.
		 * 
		 * On a media element being set, the configuration forwards the
		 * value to its player and container objects.
		 */		
		public function set mediaElement(value:MediaElement):void
		{
			if (value != _mediaElement)
			{
				// Remove the current media element from the various
				// components that use it:
				if (_mediaElement)
				{
					_container.removeMediaElement(_mediaElement);
				}
				
				// Set the new media element:
				_mediaElement = value;
				
				// Add the newly set element to the various components
				// that use it:
				_player.media = _mediaElement;
				if (_mediaElement)
				{
					_resource = _mediaElement.resource;
					_container.addMediaElement(_mediaElement);
				}
			}
		}
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}
		
		/**
		 * Defines the configuration's container object.
		 */		
		public function get container():MediaContainer
		{
			return _container;
		}
		
		/**
		 * Defines the configuration's factory object.
		 */		
		public function get factory():MediaFactory
		{
			if (_factory == null)
			{
				_factory = constructFactory();
			}
			return _factory;
		}
		
		// Subclass stubs
		//
		
		/**
		 * Subclasses may override this method to construct an alternative
		 * media factory implementation to DefaultMediaFactory.
		 */		
		protected function constructFactory():MediaFactory
		{
			return new DefaultMediaFactory();
		}
		
		// Internals
		//
		
		private var _mediaElement:MediaElement;
		private var _player:MediaPlayer;
		private var _container:MediaContainer;
		private var _factory:MediaFactory;
		
		private var _resource:MediaResourceBase;
		private var _view:DisplayObjectContainer;
	}
}