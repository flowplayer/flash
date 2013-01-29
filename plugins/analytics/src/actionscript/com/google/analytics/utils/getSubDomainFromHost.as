package com.google.analytics.utils
{
    public function getSubDomainFromHost( host:String ):String
    {
        var domain:String = getDomainFromHost( host );
        
        if( (domain != "") && (domain != host) )
        {
            return host.split( "."+domain ).join( "" );
        }
        
        return "";
    }
}