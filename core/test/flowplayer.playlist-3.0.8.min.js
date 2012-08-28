/*
 * flowplayer.playlist 3.0.8. Flowplayer JavaScript plugin.
 * 
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Author: Tero Piirainen, <info@flowplayer.org>
 * Copyright (c) 2008-2010 Flowplayer Ltd
 *
 * Dual licensed under MIT and GPL 2+ licenses
 * SEE: http://www.opensource.org/licenses
 * 
 * Date: 2010-05-04 05:33:23 +0000 (Tue, 04 May 2010)
 * Revision: 3405 
 */
(function(a){$f.addPlugin("playlist",function(d,q){var o=this;var b={playingClass:"playing",pausedClass:"paused",progressClass:"progress",template:'<a href="${url}">${title}</a>',loop:false,playOnClick:true,manual:false};a.extend(b,q);d=a(d);var j=o.getPlaylist().length<=1||b.manual;var k=null;function e(s){var r=n;a.each(s,function(t,u){if(!a.isFunction(u)){r=r.replace("${"+t+"}",u).replace("$%7B"+t+"%7D",u)}});return r}function i(){k=p().unbind("click.playlist").bind("click.playlist",function(){return h(a(this),k.index(this))})}function c(){d.empty();a.each(o.getPlaylist(),function(){d.append(e(this))});i()}function h(r,s){if(r.hasClass(b.playingClass)||r.hasClass(b.pausedClass)){o.toggle()}else{r.addClass(b.progressClass);o.play(s)}return false}function m(){if(j){k=p()}k.removeClass(b.playingClass);k.removeClass(b.pausedClass);k.removeClass(b.progressClass)}function f(r){return(j)?k.filter("[href="+r.originalUrl+"]"):k.eq(r.index)}function p(){var r=d.find("a");return r.length?r:d.children()}if(!j){var n=d.is(":empty")?b.template:d.html();c()}else{k=p();if(a.isFunction(k.live)){var l=a(d.selector+" a");if(!l.length){l=a(d.selector+" > *")}l.live("click",function(){var r=a(this);return h(r,r.attr("href"))})}else{k.click(function(){var r=a(this);return h(r,r.attr("href"))})}var g=o.getClip(0);if(!g.url&&b.playOnClick){g.update({url:k.eq(0).attr("href")})}}o.onBegin(function(r){m();f(r).addClass(b.playingClass)});o.onPause(function(r){f(r).removeClass(b.playingClass).addClass(b.pausedClass)});o.onResume(function(r){f(r).removeClass(b.pausedClass).addClass(b.playingClass)});if(!b.loop&&!j){o.onBeforeFinish(function(r){if(!r.isInStream&&r.index<k.length-1){return false}})}if(j&&b.loop){o.onBeforeFinish(function(s){var r=f(s);if(r.next().length){r.next().click()}else{k.eq(0).click()}return false})}o.onUnload(function(){m()});if(!j){o.onPlaylistReplace(function(){c()})}o.onClipAdd(function(s,r){k.eq(r).before(e(s));i()});return o})})(jQuery);