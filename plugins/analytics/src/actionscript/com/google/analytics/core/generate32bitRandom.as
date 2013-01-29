package com.google.analytics.core
{
    /**
     * Generates a 32bit random number.
     * @return 32bit random number.
     */
    public function generate32bitRandom():int
    {
        return Math.round( Math.random() * 0x7fffffff );
    }
}