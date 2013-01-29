package com.google.analytics.core
{
    /**
     * Generate hash for input string. This is a global method, since it does not need 
     * to access any instance variables, and it is being used everywhere in the GATC module.
     * @param input Input string to generate hash value on.
     * @return Hash value of input string. If input string is undefined, or empty, return hash value of 1.
     */
    public function generateHash( input:String ):int
    {
        var hash:int      = 1; // hash buffer
        var leftMost7:int = 0; // left-most 7 bits
        var pos:int;           // character position in string
        var current:int;       // current character in string
        
        // if input is undef or empty, hash value is 1
        if(input != null && input != "")
        {
            hash = 0;
            
            // hash function
            for( pos = input.length - 1 ; pos >= 0 ; pos-- )
            {
                current   = input.charCodeAt(pos);
                hash      = ((hash << 6) & 0xfffffff) + current + (current << 14);
                leftMost7 = hash & 0xfe00000;
                
                if(leftMost7 != 0)
                {
                    hash ^= leftMost7 >> 21;
                }
            }
        }
        
        return hash;
    }
}