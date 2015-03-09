/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template robins - extension of std.typecons;
*/
module stribog.meta.robin;

import stribog.meta.base;
import stribog.meta.map;
import stribog.meta.fold;

/**
*   Compile-time variant of std.range.robin for expression ExpressionLists.
*   
*   Template expects $(B StrictExpressionList) list as parameter and returns
*   new expression list where first element is from first expression ExpressionList,
*   second element is from second ExpressionList and so on, until one of input ExpressionLists
*   doesn't end.
*/
template staticRobin(SF...)
{
    // Calculating minimum length of all ExpressionLists
    private template minimum(T...)
    {
        enum length = T[1].expand.length;
        enum minimum = T[0] > length ? length : T[0];
    }
    
    enum minLength = staticFold!(minimum, size_t.max, SF);
    
    private template robin(ulong i)
    {        
        private template takeByIndex(alias T)
        {
            static if(!__traits(compiles, {enum takeByIndex = T.expand[i];}))
                alias takeByIndex = T.expand[i];
            else
                enum takeByIndex = T.expand[i];
        }
        
        static if(i >= minLength)
        {
            alias robin = ExpressionList!();
        }
        else
        {
            alias robin = ExpressionList!(staticMap!(takeByIndex, SF), robin!(i+1));
        }
    }
    
    alias staticRobin = robin!0; 
}
/// Example
unittest
{
    alias test = staticRobin!(StrictExpressionList!(int, int, int), StrictExpressionList!(float, float));
    static assert(is(test == ExpressionList!(int, float, int, float)));
    
    alias test2 = staticRobin!(StrictExpressionList!(1, 2), StrictExpressionList!(3, 4, 5), StrictExpressionList!(6, 7));
    static assert([test2]== [1, 3, 6, 2, 4, 7]);
}