/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template replicates - extension of std.typecons;
*/
module stribog.meta.replicate;

import stribog.meta.base;
import stribog.meta.satisfy;

/**
*   Replicates first argument by times specified by second argument.
*/
template staticReplicate(TS...)
{
    static if(is(TS[0]))
        alias T = TS[0];
    else
        enum T = TS[0];
        
    enum n = TS[1];
    
    static if(n > 0)
    {
        alias staticReplicate = ExpressionList!(T, staticReplicate!(T, n-1));
    }
    else
    {
        alias staticReplicate = ExpressionList!();
    }
} 
/// Example
unittest
{    
    template isBool(T)
    {
        enum isBool = is(T == bool);
    }
    
    static assert(allSatisfy!(isBool, staticReplicate!(bool, 2))); 
    static assert([staticReplicate!("42", 3)] == ["42", "42", "42"]);
}