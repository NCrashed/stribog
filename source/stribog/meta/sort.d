/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template sorting using merge sort algorithm
*/
module stribog.meta.sort;

import std.math;
import stribog.meta.base;

/**
*   Perfoms merge sort algorithm on expression list $(B T) using
*   function/template $(B F) that takes two elements and returns
*   boolean.
*/
template staticSort(alias F, T...)
{
    static if(T.length <= 1) {
        alias staticSort = T;
    } else {
        private template FWrapped(alias a, alias b) 
        {
            static if(__traits(compiles, F(T[0], T[1]))) {
                static assert(is(typeof(F(T[0], T[1])) == bool), "Predicate return type must be a boolean!");
                enum FWrapped = F(a, b);
            } else {
                static assert(is(typeof(F!(T[0], T[1])) == bool), "Predicate return type must be a boolean!");
                enum FWrapped = F!(a, b);
            }
        }
        
        private template merge(alias as, alias bs)
        {
            static if(as.expand.length == 0) {
                alias merge = bs;
            } else static if (bs.expand.length == 0) {
                alias merge = as;
            } else {                
                static if(FWrapped!(as.expand[0], bs.expand[0])) {
                    alias merge = StrictExpressionList!(bs.expand[0], merge!(as, StrictExpressionList!(bs.expand[1 .. $])).expand); 
                } else {
                    alias merge = StrictExpressionList!(as.expand[0], merge!(StrictExpressionList!(as.expand[1 .. $]), bs).expand); 
                } 
            }
        }
        
        private template mergePairs(xs...)
        {
            static if(xs.length < 2) {
                alias mergePairs = xs;
            } else {
                alias mergePairs = ExpressionList!(merge!(xs[0], xs[1]), mergePairs!(xs[2..$]));
            }
        }
        
        private template mergeAll(xs...)
        {
            static if(xs.length <= 1) {
                alias mergeAll = xs;
            } else {
                alias mergeAll = mergeAll!(mergePairs!xs);
            }
        }
        
        private template ascending(alias a, alias as, bs...)
        {
            static if (bs.length > 1 && !FWrapped!(a, bs[0])) {
                alias ascending = ascending!(bs[0], StrictExpressionList!(as.expand, a), bs[1..$]);
            } else {
                alias ascending = ExpressionList!(StrictExpressionList!(as.expand, a), sequences!bs);
            }
        }
        
        private template descending(alias a, alias as, bs...)
        {
            static if (bs.length > 1 && FWrapped!(a, bs[0])) {
                alias descending = descending!(bs[0], StrictExpressionList!(a, as.expand), bs[1..$]);
            } else {
                alias descending = ExpressionList!(StrictExpressionList!(a, as.expand), sequences!bs);
            }
        }
        
        private template sequences(U...)
        {
            static if (U.length < 2) {
                alias sequences = StrictExpressionList!U;
            } else static if(FWrapped!(U[0], U[1])) {
                alias sequences = descending!(U[1], StrictExpressionList!(U[0]), U[2 .. $]);
            } else {
                alias sequences = ascending!(U[1], StrictExpressionList!(U[0]), U[2 .. $]);
            }
        }
        
        private alias temp = mergeAll!(sequences!T)[0];
        alias staticSort = temp.expand;
    }
}
/// Example
unittest
{
    bool ascending(int a, int b)
    {
        return a > b;
    }
    
    bool descending(int a, int b)
    {
        return a < b;
    }
    
    template Ascending(int a, int b)
    {
        enum Ascending = a > b;
    }
    
    template Descending(int a, int b)
    {
        enum Descending = a < b;
    }
    
    static assert([staticSort!(ascending, 3, 1, 5, 2)] == [1, 2, 3, 5]);
    static assert([staticSort!(Ascending, 3, 1, 5, 2)] == [1, 2, 3, 5]);
    static assert([staticSort!(descending, 3, 1, 5, 2)] == [5, 3, 2, 1]);
    static assert([staticSort!(Descending, 3, 1, 5, 2)] == [5, 3, 2, 1]);
    
    import std.string;
    
    bool wordsCmp(string a, string b)
    {
        return toUpper(a) > toUpper(b);
    }
    
    alias words = ExpressionList!("aBc", "a", "abc", "b", "ABC", "c");
    alias sortedWords = staticSort!(wordsCmp, words);
    static assert([sortedWords] == [ "a", "aBc", "abc", "ABC", "b", "c" ]);
}