/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.smil {
import flash.events.NetStatusEvent;

import org.flowplayer.controller.ClipURLResolver;
import org.flowplayer.controller.ConnectionProvider;
import org.flowplayer.controller.ResourceLoader;
import org.flowplayer.controller.StreamProvider;
import org.flowplayer.controller.StreamProvider;
import org.flowplayer.model.Clip;
import org.flowplayer.model.Clip;
import org.flowplayer.model.Plugin;
import org.flowplayer.model.PluginError;
import org.flowplayer.model.PluginModel;
import org.flowplayer.util.Log;
import org.flowplayer.util.PropertyBinder;
import org.flowplayer.view.Flowplayer;

public class SmilResolver implements ClipURLResolver, Plugin {
    private var log:Log = new Log(this);
    private var _failureListener:Function;
    private var _player:Flowplayer;
    private var _model:PluginModel;
    private var _config:Config;
    private var _connectionClient:Object;
    private var _successListener:Function;
    private var _streamName:String;
    private var _objectEncoding:uint;
    private var _clip:Clip;
    private var _rtmpConnectionProvider:ConnectionProvider;

    private var xmlns:Namespace = new Namespace("http://www.w3.org/XML/1998/namespace");

    public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
        log.debug("resolve(), resolving " + clip.url);
        _successListener = successListener;
        _clip = clip;

        loadSmil(_clip.url, onSmilLoaded);
    }

    [External]
    public function resolveSmil(smilUrl:String, callback:Function):void {
        log.debug("resolveSmil()");
        loadSmil(smilUrl, function(smilContent:String):void {
             var result:SmilItem = parseSmil(smilContent);
             log.debug("resolveSmil(), resolved to netConnectionUrl " + result.baseUrl + " streamName " + result.streamName);
            callback(result);
        });
    }

    private function loadSmil(smilUrl:String, loadedCallback:Function):void {
        log.debug("connect(), loading SMIL file from " + smilUrl);
        var loader:ResourceLoader = _player.createLoader();
        loader.load(smilUrl, function(loader:ResourceLoader):void {
            log.debug("SMIL file received");
            loadedCallback(String(loader.getContent()));
        }, true);
    }

    private function onSmilLoaded(smilContent:String):void {
        updateClip(_clip, smilContent);
         _successListener(_clip);
    }


    public function set onFailure(listener:Function):void {
        _failureListener = listener;
    }

    public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
        return true;
    }

    public function set connectionClient(client:Object):void {
        _connectionClient = client;
    }

    public function onConfig(model:PluginModel):void {
        _model = model;
        _config = new PropertyBinder(new Config()).copyProperties(_model.config) as Config;

    }

    public function onLoad(player:Flowplayer):void {
        log.debug("onLoad");
        _player = player;
        _model.dispatchOnLoad();
    }

    public function getDefaultConfig():Object {
        return null;
    }

    private function updateClip(clip:Clip, smilContent:String):void {

        var item:SmilItem = parseSmil(smilContent);
        //log.debug("Got result : ", result);
        clip.setCustomProperty("netConnectionUrl", item.baseUrl);
        clip.setCustomProperty("netConnectionUrls", item.servers);

        clip.baseUrl = null;

        if (item.bitrates is Array) {
            clip.setCustomProperty("bitrates", item.bitrates);
        } else {
            clip.setResolvedUrl(this, item.streamName);
        }

        log.debug("updated clip ", clip);
    }

    private function parseSmil(smilContent:String):SmilItem {
        var smil:XML = new XML(smilContent);
        var smilItem:SmilItem = new SmilItem();

        var result:Array = [];


        var servers:XMLList = smil.head.paramGroup.(@xmlns::id == "cluster");

        //Check for cluster configuration inside a paramGroup tag
        if (servers.length() >= 1) {
            log.debug("Got Clustered Servers");

            smilItem.servers = [];

		    for each (var server:XML in servers.param)
	        {
                smilItem.servers.push(new String(server.@value));
		    }
		}

        smilItem.baseUrl = new String(smil.head.meta.@base);

        if (smil.body.child("switch").length()) {
            log.debug("Got switch tag");
            var item:XML;

            smilItem.bitrates = [];

            for each(item in  smil.body.child("switch").video) {
                var bitrateItem:Object = new Object();
                bitrateItem.url = String(item.@src);
                bitrateItem.bitrate = Number(item.attribute("system-bitrate")) / 1000;

                //add optional properties
                if (item.hasOwnProperty("@width")) bitrateItem.width = Number(item.@width);
                if (item.hasOwnProperty("@height")) bitrateItem.height = Number(item.@height);
                if (item.hasOwnProperty("@hd")) bitrateItem.hd = Boolean(item.@hd);
                //refactor normal to sd #240
                if (item.hasOwnProperty("@sd")) bitrateItem.sd = Boolean(item.@sd);
                if (item.hasOwnProperty("@isDefault")) bitrateItem.isDefault = Boolean(item.@isDefault);
                if (item.hasOwnProperty("@label")) bitrateItem.label = String(item.@label);
                smilItem.bitrates.push(bitrateItem);
            }

        } else {
            smilItem.streamName = new String(smil.body.video.@src);
        }

        return smilItem;
    }
}

}