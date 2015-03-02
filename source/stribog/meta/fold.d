/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template folds - extension of std.typecons;
*/
module stribog.meta.fold;

import stribog.meta.base;

/**
*   Static version of std.algorithm.reduce (or fold). Expects that $(B F)
*   takes accumulator as first argument and a value as second argument.
*
*   First value of $(B T) have to be a initial value of accumulator.
*/
template staticFold(alias F, T...)
{
    static if(T.length == 0) // invalid input
    {
        alias staticFold = ExpressionList!(); 
    }
    else static if(T.length == 1)
    {
        static if(is(typeof(T[0])) && !is(typeof(T[0]) == void))
            enum staticFold = T[0];
        else
            alias staticFold = T[0];
    }
    else 
    {
        alias staticFold = staticFold!(F, F!(T[0], T[1]), T[2 .. $]);
    }
}
/// Example
unittest
{
    template summ(T...)
    {
        enum summ = T[0] + T[1];
    }
    
    static assert(staticFold!(summ, 0, 1, 2, 3, 4) == 10);
    
    template preferString(T...)
    {
        static if(is(T[0] == string))
            alias preferString = T[0];
        else
            alias preferString = T[1];
    }
    
    static assert(is(staticFold!(preferString, void, int, string, bool) == string));
    static assert(is(staticFold!(preferString, void, int, double, bool) == bool));
}