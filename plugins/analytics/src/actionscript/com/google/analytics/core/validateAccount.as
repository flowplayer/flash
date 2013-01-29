package com.google.analytics.core
{
    /**
     * Checks if the paramater is a valid GA account ID.
     */
    public function validateAccount( account:String ):Boolean
    {
        var rel:RegExp = /^UA-[0-9]*-[0-9]*$/;
        return rel.test(account);
    }
}