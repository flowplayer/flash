package com.google.analytics.utils
{
    public function getDomainFromHost( host:String ):String
    {
        if( (host != "") && (host.indexOf(".") > -1) )
        {
            var parts:Array = host.split( "." );
            
            switch( parts.length )
            {
                //domain.com
                case 2 :
                {
                    return host;
                }
                
                //domain.co.uk
                //www.domain.com
                case 3 :
                {
                    if( parts[1] == "co" )
                    {
                        return host;
                    }
                    parts.shift();
                    return parts.join( "." );
                }
                
                //www.domain.co.uk
                case 4:
                {
                    parts.shift();
                    return parts.join( "." );
                }
            }
            
        }
        
        return "";
    }
}