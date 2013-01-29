package com.google.analytics.utils
{
    import core.version;

    public function getVersionFromString( v:String, separator:String = "." ):version
    {
        var ver:version = new version();
        
        if( (v == "") || (v == null) )
        {
            return ver;
        }
        
        if( v.indexOf( separator ) > -1 )
        {
            var values:Array = v.split( separator );
            ver.major    = parseInt( values[0] );
            ver.minor    = parseInt( values[1] );
            ver.build    = parseInt( values[2] );
            ver.revision = parseInt( values[3] );
        }
        else
        {
            ver.major = parseInt( v );
        }
        
        return ver;
    }
}