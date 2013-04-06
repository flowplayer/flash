package org.osmf.chrome.widgets
{
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.utils.Version;
	
	public class ContextMenuOverlay extends Widget
	{
		public function ContextMenuOverlay()
		{
			super();
			
			// Create a transparent overlay. This is a work-around for the
			// context menu otherwise not triggering MENU_ITEM_SELECT when being
			// invoked while over a Video object:
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, 100, 100);
			graphics.endFill();
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			var customItems:Array = [];
			
			// Setup a context menu:
			var customContextMenu:ContextMenu = new ContextMenu();
			customContextMenu.hideBuiltInItems();
			
			var menuItem:ContextMenuItem 
					= new ContextMenuItem
						( String(parseAttribute(xml, "menuItemLabel", ""))
						. replace("${version}", Version.version)
						);
			menuItemLink = parseAttribute(xml, "menuItemLink", null);
			menuItemWindow = parseAttribute(xml, "menuItemWindow", "_blank");
			
			if (menuItemLink != null)
			{			
				menuItem.addEventListener
						( ContextMenuEvent.MENU_ITEM_SELECT
						, onContextMenuItemSelect
						);
			}
			
			customItems.push(menuItem);
			
			if	( String(parseAttribute(xml, "addVersionDetails", "false"))
				. toLocaleLowerCase() == "true"
				)
			{
				menuItem
					= new ContextMenuItem
						( Capabilities.version
						, false
						, false
						);
				customItems.push(menuItem);
				
				if (Version.FLASH_10_1 == true)
				{
					menuItem
						= new ContextMenuItem
							( "FLASH_10_1"
							, false
							, false
							);
					customItems.push(menuItem);
				}
				
				if (Version.LOGGING == true)
				{
					menuItem
						= new ContextMenuItem
							( "LOGGING"
							, false
							, false
							);
					customItems.push(menuItem);
				}
			}
			
			customContextMenu.customItems = customItems;
			contextMenu = customContextMenu;
			
			addEventListener(Event.ADDED_TO_STAGE, onFirstAddedToStage);
		}
		
		private var menuItemLink:String;
		private var menuItemWindow:String;
		
		private function onFirstAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onFirstAddedToStage);
			
			parent.contextMenu = contextMenu;
		}
		
		private function onContextMenuItemSelect(event:Event):void
		{
			navigateToURL(new URLRequest(menuItemLink), menuItemWindow);
		}
	}
}