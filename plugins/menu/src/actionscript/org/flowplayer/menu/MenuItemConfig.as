/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.menu {
    import org.flowplayer.menu.ui.MenuItem;
    import org.flowplayer.model.Extendable;
    import org.flowplayer.model.ExtendableHelper;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.util.ObjectConverter;

    public class MenuItemConfig extends ButtonConfig implements Extendable {
        private var _view:MenuItem;
        private var _label:String;
        private var _extension:ExtendableHelper = new ExtendableHelper();
        private var _height:Number = 30;
        private var _width:Number = 70;
        private var _selectedCallback:Function;
        private var _imageUrl:String;

        private var _toggle:Boolean;
        private var _selected:Boolean; // is this initially selected. For toggle items.
        private var _group:String; // you can group items, see the MenuConfig.itemsIn(group) method

        [Value]
        public function get label():String {
            return _label;
        }

        public function set label(value:String):void {
            _label = value;
        }

        public function set customProperties(props:Object):void {
            _extension.props = props;
        }

        public function get customProperties():Object {
            return _extension.props;
        }

        public function setCustomProperty(name:String, value:Object):void {
            _extension.setProp(name,  value);
        }

        public function getCustomProperty(name:String):Object {
            return _extension.getProp(name);
        }

        public function deleteCustomProperty(name:String):void {
            _extension.deleteProp(name);
        }

        [Value]
        public function get height():Number {
            return _height;
        }

        public function set height(value:Number):void {
            _height = value;
        }

        [Value]
        public function get width():Number {
            return _width;
        }

        public function set width(value:Number):void {
            _width = value;
        }

        public function set onSelected(value:Function):void {
            _selectedCallback = value;
        }

        public function fireCallback(model:PluginModel):void {
            if (_selectedCallback != null) {
                _selectedCallback(this);
            }
            model.dispatch(PluginEventType.PLUGIN_EVENT, "onSelect", new ObjectConverter(this).convert());
        }

        public function set selectedCallback(value:Function):void {
            _selectedCallback = value;
        }

        public function get toggle():Boolean {
            return _toggle;
        }

        public function set toggle(value:Boolean):void {
            _toggle = value;
        }

        public function get selected():Boolean {
            return _selected;
        }

        public function set selected(value:Boolean):void {
            _selected = value;
        }

        public function get group():String {
            return _group;
        }

        public function set group(value:String):void {
            _group = value;
        }

        public function get view():MenuItem {
            return _view;
        }

        public function set view(value:MenuItem):void {
            _view = value;
        }

        public function get imageUrl():String {
            return _imageUrl;
        }

        public function set imageUrl(value:String):void {
            _imageUrl = value;
        }
    }
}
