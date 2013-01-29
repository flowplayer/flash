package com.google.analytics
{
    import core.Logger;
    import core.log;
    
    public const log:Logger = core.log;
    
    /* note:
       we use the logd library
       http://code.google.com/p/maashaack/wiki/logd
       
       Within your IDE when you build locally
       for Flash Builder
       in Project Properties
       then ActionScript Compiler
       under "Additional compiler arguments":
       -locale en_US -load-config build/config-local.xml
       
       the Ant build will use
       build/config.xml to produce gaforflash.swc
       and
       build/config-debug.xml to produce gaforflash_d.swc
       
       We use conditional compilation
       see: http://livedocs.adobe.com/flex/3/html/help.html?content=compilers_21.html
       
       that means everything written within LOG::P{ ... }
       is not included in the final binary
       when LOG::P is set to false
    */
    LOG::P
    {
        var cfg:Object = { sep: " ", //char separator
                           mode: "clean", // "raw", "clean", "data", "short"
                           tag: true, //use tag
                           time: true  //use time
                         };
        log.config( cfg );
        log.level = log.VERBOSE;
    }
    
}