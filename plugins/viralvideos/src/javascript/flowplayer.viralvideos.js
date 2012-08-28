/**
 * flowplayer.viralvideos 3.2.6. Flowplayer JavaScript plugin.
 * 
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Author: Dan Rossi, <electroteque@gmail.com>
 * Copyright (c) 2008-2010 Flowplayer Ltd
 *
 * Dual licensed under MIT and GPL 2+ licenses
 * SEE: http://www.opensource.org/licenses
 * 
 *
 *
 */ 
(function($) {
	
	$f.addPlugin("viralvideos", function(options) {


		// self points to current Player instance
		var self = this;	
		
		var opts = {
			pluginName: "viral",
			splashImage: ""
		};		
		
		$.extend(opts, options);
		wrap = $(wrap);		
		var manual = self.getPlaylist().length <= 1 || opts.manual; 
		var els = null;
        var hasLoaded = false;

	
		self.onBeforeBegin(function(clip) {
            //check if loaded once, cannot use onLoad as it won't get access to the methods yet
            if (hasLoaded) return;

            hasLoaded = true;

			var url = self.getPlugin(opts.pluginName).getPlayerSwfUrl() + "?config=" + self.getPlugin(opts.pluginName).getPlayerConfig(true);
			$('head').append("<meta name=\"video_type\" content=\"application/x-shockwave-flash\" />\n");
			$('head').append("<meta name=\"video_weight\" content=\""+self.getClip().weight+"\" />\n");
			$('head').append("<meta name=\"video_height\" content=\""+self.getClip().height+"\" />\n");
			$('head').append("<meta name=\"video_type\" content=\"application/x-shockwave-flash\" />\n");
            $('head').append("<meta property=\"og:type\" content=\"movie\" />\n");
            $('head').append("<meta property=\"og:video:type\" content=\"application/x-shockwave-flash\" />\n");
            $('head').append("<meta property=\"og:video:height\" content=\"384\" />\n");
            $('head').append("<meta property=\"og:video:width\" content=\"512\" />\n");
            $('head').append("<meta property=\"og:video\" content=\"" + url + "\" />\n");
			$('head').append("<link rel=\"video_src\" href=\"" + url + "\"/>\n");

			if (opts.splashImage) {
				$('head').append("<link rel=\"image_src\" href=\"" + opts.splashImage + "\"/>\n");
                $('head').append("<meta property=\"og:image\" content=\"" + opts.splashImage + "\" />\n");
            }
		});	

		return self;
		
	});
		
})(jQuery);		
