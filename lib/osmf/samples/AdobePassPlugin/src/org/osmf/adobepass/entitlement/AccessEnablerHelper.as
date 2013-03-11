package org.osmf.adobepass.entitlement
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	import org.osmf.adobepass.events.AuthenticationEvent;
	import org.osmf.adobepass.events.TokenEvent;
	import org.osmf.adobepass.events.TrackingEvent;
	import org.osmf.utils.URL;

	/**
	 * This is a helper class that loads access enabler and
	 * and exercises the entitlement API over localconnection.
	 *
	 * The singleton pattern is used in order to support OSMF
	 * players that can play compositions. In this event we do not want
	 * to load the AccessEnabler for each MediaElement instance.
	 */
	public class AccessEnablerHelper extends Sprite
	{
		public static var instance:AccessEnablerHelper;
		private var providerDialogURL:String;

		public static function getInstance(settings:Object = null):AccessEnablerHelper
		{
			if (instance == null)
			{
				instance = new AccessEnablerHelper(settings, new SingletonEnforcer());
				
			}
			return instance;
		}

		public function AccessEnablerHelper(settings:Object, enforcer:SingletonEnforcer)
		{
			if (settings != null)
			{
				if (settings.size != null && settings.size is Point)
				{
					accessSwfMaxSize = settings.size;
				}

				if (settings.accessEnablerURL != null)
				{
					accessEnablerURL = settings.accessEnablerURL;
				}

				// Allow the access swf such that the Selection dialog can be displayed.
				Security.allowDomain(accessEnablerURL);
				Security.allowInsecureDomain(accessEnablerURL);			
				
				if (settings.requestorID != null)
				{
					requestorID = settings.requestorID;
				}

				if (settings.resourceID != null)
				{
					resourceID = settings.resourceID;
				}

				if (settings.parent != null)
				{
					settings.parent.addChild(this);
				}

				if (settings.externalCreateIFrame != null)
				{
					useExternalCreateIframe = (settings.externalCreateIFrame == "true");
				}

				if (settings.providerDialogURL != null
						&& settings.providerDialogURL.substr(settings.providerDialogURL.length - 4) == ".swf")
				{
					providerDialogURL = settings.providerDialogURL;
				}

			}

			var u:URL = new URL(accessEnablerURL);
			accessEnablerDomain = u.host;

		}

		/**
		 * This function triggers the entitlement workflow needed
		 * to get authorization for a resource
		 *
		 * Will load the access enabler if needed and setup the localconection communication
		 *
		 */
		public function checkAccess():void
		{
			if (uniqueName == null && !accessSwfLoaded)
			{
				var currentTime:Number = new Date().time;
				uniqueName = currentTime.toString();
				callbackID += uniqueName;
				listenerID += uniqueName;
				
				/* 	The tve access swf makes callbacks into the parent swf. Hence, enable SWF to swf access in a 
				 cross-domain scenario. The code below allows opening a connection that will permit access swf
				 to invoke it. */
				try
				{
					conn = new LocalConnection();
					conn.addEventListener(StatusEvent.STATUS, onConnStatus);
					conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onReceivedError);
					conn.client = this;
					conn.allowDomain(accessEnablerDomain);
					conn.connect(callbackID);
					trace("[AccessEnablerProxy] listening on " + callbackID + "(" + accessEnablerDomain + ")");
				}
				catch(e:Error)
				{
					trace("[AccessEnablerProxy] error opening localconnection: ", e.getStackTrace());
				}

				/* Load the access swf */
				if ((conn != null))
				{
					trace("[AccessEnablerProxy] - loading entitlement swf...");
					accessSwfLoader = new Loader();
					var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
					accessSwfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
					accessSwfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					accessSwfLoader.load(new URLRequest(accessEnablerURL + "?uniquename=" + uniqueName), context);
				}
			}
			else
			{
				trace("[AccessEnablerProxy] - entitlement swf already loaded");
				getAuthorization();
			}
		}

		private function onConnStatus(event:StatusEvent):void
		{}

		private function onReceivedError(event:SecurityErrorEvent):void
		{}

		/**
		 * After loading the access enabler, add it to the stage
		 * and center it.
		 *
		 * @param event
		 */
		private function onLoadComplete(event:Event):void
		{
			try
			{
				if (accessSwfLoaded)
				{
					resizeAccessSwf();
				}
				addChild(accessSwfLoader);
			}
			catch (e:Error)
			{
				trace("[AccessEnablerProxy] - INVALID PARENT! Access Enabler would not be able to display it's GUI");
				trace(e.getStackTrace());
			}
			dispatchEvent(event.clone());
		}

		private function onIOError(event:IOErrorEvent):void
		{
			trace("[AccessEnablerProxy] - ERROR LOADING ENABLEMENT SWF");
		}

		/**
		 * This will try to center the AccessEnabler on the stage
		 */
		private function resizeAccessSwf():void
		{
			// if the accessSwfSize is set this will center the ProviderDialog
			accessSwfSize = new Point(accessSwfLoader.contentLoaderInfo.width, accessSwfLoader.contentLoaderInfo.height);
			if ((accessSwfMaxSize.x > accessSwfSize.x) && (accessSwfMaxSize.y > accessSwfSize.y))
			{
				accessSwfLoader.x = (accessSwfMaxSize.x - accessSwfSize.x) / 2;
				accessSwfLoader.y = (accessSwfMaxSize.y - accessSwfSize.y) / 2;
			}
		}

		/**
		 *  Invokes getAuthorization for a given resource.
		 *
		 * @private
		 */
		private function getAuthorization():void
		{
			try
			{
				conn.send(listenerID, "getAuthorization", resourceID);
				trace("[AccessEnablerProxy] - getAuth sent");
			}
			catch(e:Error)
			{}
		}

		/**
		 * Invokes setRequestor() and previously sets a
		 * custom provider dialog url if needed
		 *
		 */
		private function registerClient():void
		{
			try
			{
				if (providerDialogURL)
				{
					conn.send(listenerID, "setProviderDialogURL", providerDialogURL);
				}
				conn.send(listenerID, "setRequestor", requestorID);
				trace("[AccessEnablerProxy] registerclient sent");
			}
			catch(e:Error)
			{
				trace("[AccessEnablerProxy] registerclient error: " + e.getStackTrace());
			}
		}

		/**
		 * Callback invoked by access swf to indicate it can receive API calls
		 *
		 * when receiving this we will try to call
		 * setRequestor() and getAuthorization()
		 *
		 */
		public function swfLoaded():void
		{
			trace("[AccessEnablerProxy] swfLoaded()");
			if (!accessSwfLoaded)
			{
				registerClient();
			}
			getAuthorization();
			accessSwfLoaded = true;
		}

		/**
		 * Callback invoked by access swf indicating the desired dimensions of the swf.
		 *
		 * We simply center the swf on stage when receiving it
		 *
		 * @param width
		 * @param height
		 */
		public function setMovieDimensions(width:int, height:int):void
		{
			resizeAccessSwf();
		}

		/**
		 * Callback invoked by access swf to indicate
		 * a token failure
		 *
		 * @param resourceID The original resource id for the requested token
		 * @param errorCode error code
		 *
		 */
		public function tokenRequestFailed(resourceID:String, errorCode:String, k:*):void
		{
			dispatchEvent(new TokenEvent(TokenEvent.TOKEN_REQUEST_FAILED));
		}

		/**
		 * Callback invoked by access swf to indicate
		 * a token aquisition success
		 *
		 * @param String resourceID the original resource id for the requested token
		 * @param String The token representation
		 *
		 */
		public function setToken(resourceID:String, token:String):void
		{
			dispatchEvent(new TokenEvent(TokenEvent.TOKEN_REQUEST_SUCCESS, token));
		}

		/**
		 * Callback invoked by access swf to indicate
		 * authentication status
		 *
		 * @param String authentication status
		 * @param String error code
		 *
		 */
		public function setAuthenticationStatus(authenticated:uint, errorCode:String):void
		{
			trace("[AccessEnablerProxy] setauthenticationstatus: " + authenticated + "," + errorCode);

			dispatchEvent(
					new AuthenticationEvent(
							authenticated == 1 ? AuthenticationEvent.AUTHN_SUCCESS : AuthenticationEvent.AUTHN_FAILED
							, errorCode
							));
		}

		/**
		 * Callback invoked by access swf to indicate
		 * that "mvpdframe" iframe needs to be displayed
		 *
		 * @param String the requested width
		 * @param String the requested height
		 *
		 */
		public function createIFrame(width:uint, height:uint):void
		{
			if (useExternalCreateIframe)
			{
				ExternalInterface.call("createIFrame", width, height);
			}
			else
			{
				var jsCode:String = CREATE_IFRAME_CODE
						.replace("{w}", width)
						.replace("{h}", height)
						.replace("{whalf}", width / 2);
				ExternalInterface.call("eval", jsCode);
			}
		}

		public function sendTrackingData(type:String, data:Array):void
		{				
			trace(type, data);
			dispatchEvent(new TrackingEvent(TrackingEvent.TRACKING, false, false, type, data));
		}

		/**
		 * LocalConnection object that opens invocations into this swf by cross domain swfs.
		 * Used by tve access swf to make callbacks.
		 */
		private var conn:LocalConnection;

		/** The loader object used to load tve access swf. */
		private var accessSwfLoader:Loader = null;

		/**  The domain that hosts the tve access swf. */
		private var accessEnablerDomain:String;

		/** The default URL that serves the tve access swf */
		private var accessEnablerURL:String = "http://entitlement.auth.adobe.com/entitlement/AccessEnabler.swf";

		/** Connection name used to make calls to tve access swf. */
		private var listenerID:String = "_accessEnabler";

		/** Connection name for client's LocalConnection. This name will be used by tve
		 access swf to make callbacks into client swf. */
		private var callbackID:String = "_accessEnablerClient";

		private var resourceID:String;
		private var requestorID:String;

		private var uniqueName:String = null;
		private var accessSwfLoaded:Boolean = false;
		private var accessSwfMaxSize:Point = new Point(0, 0);
		private var accessSwfSize:Point = new Point(0, 0);
		private var useExternalCreateIframe:Boolean;

		private static const CREATE_IFRAME_CODE:String
				= "ifrm = document.getElementById('mvpdframe');" +
				"ifrm.style.width=\"{w}px\";" +
				"ifrm.style.height=\"{h}px\";" +
				"ifrm.style.frameborder=\"2\";" +
				"ifrm.style.border=\"1\";" +
				"ifrm.style.position=\"absolute\";" +
				"ifrm.style.top=\"50px\";" +
				"ifrm.style.left=\"50%\";" +
			//				"ifrm.style.zIndex=\"300\";" +
				"ifrm.style.marginLeft=\"-{whalf}px\";" +
				"ifrm.style.display=\"block\";";
	}
}

internal class SingletonEnforcer
{
}
