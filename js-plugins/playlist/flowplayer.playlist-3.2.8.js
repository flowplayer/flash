/*
 * flowplayer.playlist Flowplayer playlist plugin.
 *
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Author: Tero Piirainen, <info@flowplayer.org>
 * Copyright (c) 2008-2012 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 */

 (function($) {

        $f.addPlugin("playlist", function(wrap, options) {


                // self points to current Player instance
                var self = this;

                var opts = {
                        playingClass: 'playing',
                        pausedClass: 'paused',
                        progressClass:'progress',
                        stoppedClass:'stopped',
                        template: '<a href="${url}">${title}</a>',
                        loop: false,
                        continuousPlay: false,
                        playOnClick: true,
                        manual: false
                };

                $.extend(opts, options);


        //use continous play or loop option #361
        //opts.loop = opts.continuousPlay || opts.loop;

        wrap = $(wrap);

        //#444 detect a manual playlist by first checking there is elements available, and the first element may not be a dynamic template.
        //Allow the option for only one configured playlist clip for both manual and dynamic playlists.
        var els = getEls();
        var manual = opts.manual || (els.length > 0 && !wrap.html().match(/\$/));
        var template = null;


//{{{ "private" functions

                function toString(clip) {
                        var el = template;

                        $.each(clip, function(key, val) {
                                if (!$.isFunction(val)) {
                                        el = el.replace("$\{" +key+ "\}", val).replace("$%7B" +key+ "%7D", val);
                                }
                        });
                        return el;
                }

                // assign onClick event for each clip
                function bindClicks() {
                        els = getEls().unbind("click.playlist").bind("click.playlist", function() {
                                return play($(this), els.index(this));
                        });
                }

                function buildPlaylist() {
                        wrap.empty();

                        $.each(self.getPlaylist(), function() {
                                wrap.append(toString(this));
                        });

                        bindClicks();
                }


                function play(el, clip)  {
                        if (el.hasClass(opts.playingClass) || el.hasClass(opts.pausedClass)) {
                                self.toggle();
                        } else {
                                el.addClass(opts.progressClass);
                                self.play(clip);
                        }

                        return false;
                }


                function clearCSS() {
                        if (manual) { els = getEls(); }
                        els.removeClass(opts.playingClass);
                        els.removeClass(opts.pausedClass);
                        els.removeClass(opts.progressClass);
                        els.removeClass(opts.stoppedClass);
                }

                function getEl(clip) {
                        //fix for #366 need double quotes for selector
                        return (manual) ? els.filter("[href=\"" + clip.originalUrl + "\"]") : els.eq(clip.index);
                }

                function getEls() {
                        var els = wrap.find("a");
                        return els.length ? els : wrap.children();
                }
//}}}

                /* setup playlists with onClick handlers */

                // internal playlist
                if (!manual) {
                        //#472 - check empty container with children rather than :empty if there is whitespace
                        template = wrap.children().length <= 0 ? opts.template : wrap.html();
                        buildPlaylist();


                // manual playlist
                } else {
                        //#468 when adding new playlist items via the api with manual setups, requires a template to generate the items.
                        template = opts.template;
                        bindClicks(); // also returns els

                        //#368 configure manual playlists as flowplayer playlist items to repeat and transition correctly.
                        //#402 use encodeURI instead of escape to format urls correctly for playback.
                        var playlist = [];
                        $.each(els, function(key, value) {
                                playlist.push({url: encodeURI($(value).attr("href"))});
                        });


                        self.onLoad(function() {
                                self.setPlaylist(playlist);
                        });

                        //#368 this is required for the ipad plugin to function.
                        var clip = self.getClip(0);

                        if (!clip.url && opts.playOnClick) {
                                clip.update({url: encodeURI(els.eq(0).attr("href"))});
                        }
                }

                // onBegin
                self.onBegin(function(clip) {
                        clearCSS();
                        getEl(clip).addClass(opts.playingClass);
                });

                // onPause
                self.onPause(function(clip) {
                        getEl(clip).removeClass(opts.playingClass).addClass(opts.pausedClass);
                });

                // onResume
                self.onResume(function(clip) {
                        getEl(clip).removeClass(opts.pausedClass).addClass(opts.playingClass);
                });

                function stopPlaylist(clip) {
                    self.onBeforeFinish(function(clip) {
                        getEl(clip).removeClass(opts.playingClass);
                        getEl(clip).addClass(opts.stoppedClass);
                        if (!clip.isInStream && clip.index < els.length -1) {
                            return false;
			} else if (!clip.isInStream) {
			    // pause on last frame to mimic single clip behavior
			    // see onResume below
			    this.pause();
                        }
		    });

		    self.onResume(function(clip) {
			 // work around non-standard onBeforeFinish behavior
			 // for last clip in a playlist
			 if (!clip.isInStream && clip.index == els.length -1 && self.getTime() > clip.duration -1) {
			     self.play(clip.index);
			 }
		    });
                }

                function loopPlaylist(clip) {
                    self.onBeforeFinish(function(clip) {
                        if (!clip.isInStream && clip.index >= els.length -1) {
					        return false;
					    }
				    });
                }

		function stopOnLast(clip) {
		    self.onFinish(function(clip) {
			// reset css at end of last clip
			if (!clip.isInStream && clip.index == els.length -1) {
			    getEl(clip).removeClass(opts.playingClass);
			    getEl(clip).addClass(opts.stoppedClass);
			}
		    });
		}

                //402 if looping is off and continuous play is off stop the playlist.
                // if looping is enabled return to the start on playlist completion.

                if (!opts.loop && !opts.continuousPlay) {
                    stopPlaylist(clip);
                } else if (opts.loop) {
                    loopPlaylist(clip);
		} else { // continuousPlay
		    stopOnLast(clip);
		}

                // onUnload
                self.onUnload(function() {
                        clearCSS();
                });

                // onPlaylistReplace
                if (!manual) {
                        self.onPlaylistReplace(function() {
                                buildPlaylist();
                        });
                }

                // onClipAdd
                self.onClipAdd(function(clip, index) {
                    //#468 enable prepending playlist items again but append if not setting a custom index.
                    //if we have a template specified generate the playlist item
                    if (template) {
                        if (index < els.length) {
                            getEls().eq(index).before(toString(clip));
                        } else {
                            getEls().eq(index - 1).after(toString(clip));
                        }
                    }
                    bindClicks();
                });

                return self;

        });

})(jQuery);