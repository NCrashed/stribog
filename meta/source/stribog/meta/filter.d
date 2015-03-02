/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template filters - extension of std.typecons;
*/
module stribog.meta.filter;

import std.conv : text;

import stribog.meta.base;

/**
*   Performs filtering of expression tuple $(B T) one by one by function or template $(B F). If $(B F)
*   returns $(B true) the resulted element goes to returned expression tuple, else it is discarded.
*/
template staticFilter(alias F, T...)
{
    static if(T.length == 0)
    {
        alias staticFilter = ExpressionList!();
    }
    else
    {
        static if(__traits(compiles, F(T[0]))  && F(T[0]) 
               || __traits(compiles, F!(T[0])) && F!(T[0])) 
        {
            alias staticFilter = ExpressionList!(T[0], staticFilter!(F, T[1 .. $]));
        }
        else
        {
            alias staticFilter = ExpressionList!(staticFilter!(F, T[1 .. $]));
        }
    }
}
/// Example
unittest
{
    import std.conv;
    
    bool testFunc(int val)
    { 
        return val <= 15;
    }
    
    template testTemplate(int val)
    {
        enum testTemplate = val <= 15;
    }
    
    static assert(staticFilter!(testFunc, ExpressionList!(42, 108, 15, 2)) == ExpressionList!(15, 2));
    static assert(staticFilter!(testTemplate, ExpressionList!(42, 108, 15, 2)) == ExpressionList!(15, 2));
}

/**
*   Performs filtering of expression tuple $(B T) passing $(B i) elements to function or template $(B F). If $(B F)
*   returns $(B true) the resulted elements go to returned expression tuple, else it is discarded.
*/
template staticFilterN(size_t i, alias F, T...)
{
    static assert(i != 0, "staticFilterN: N is zero");
    static assert(T.length % i == 0, text("Wrong size of ExpressionList in filter, expected ", i, " but got ", T.length));
    
    static if(T.length < i)
    {
        alias staticFilterN = ExpressionList!();
    }
    else
    {
        static if(__traits(compiles, F(T[0 .. i]))  && F(T[0 .. i]) 
               || __traits(compiles, F!(T[0 .. i])) && F!(T[0 .. i])) 
        {
            alias staticFilterN = ExpressionList!(T[0 .. i], staticFilterN!(i, F, T[i .. $]));
        } 
        else
        {
            alias staticFilterN = ExpressionList!(staticFilterN!(i, F, T[i .. $]));
        }
    }
}
/// Example
unittest
{
    template isNineSumm(int a, int b, int c) { enum isNineSumm = a + b + c == 9; }
    static assert( staticEqual!( StrictExpressionList!(staticFilterN!(3, isNineSumm, 3, 3, 3, 1, 1, 1, 2, 4, 3)), StrictExpressionList!(ExpressionList!(3, 3, 3, 2, 4, 3)) ) );
}

/// Alias of staticFilterN for 2 arguments
alias staticFilter2(alias F, T...) = staticFilterN!(2, F, T);
/// Alias of staticFilterN for 3 arguments
alias staticFilter3(alias F, T...) = staticFilterN!(3, F, T);
/// Alias of staticFilterN for 4 arguments
alias staticFilter4(alias F, T...) = staticFilterN!(4, F, T);
/// Alias of staticFilterN for 5 arguments
alias staticFilter5(alias F, T...) = staticFilterN!(5, F, T);
/// Alias of staticFilterN for 6 arguments
alias staticFilter6(alias F, T...) = staticFilterN!(6, F, T);
/// Alias of staticFilterN for 7 arguments
alias staticFilter7(alias F, T...) = staticFilterN!(7, F, T);
/// Alias of staticFilterN for 8 arguments
alias staticFilter8(alias F, T...) = staticFilterN!(8, F, T);
/// Alias of staticFilterN for 9 arguments
alias staticFilter9(alias F, T...) = staticFilterN!(9, F, T);

/**
*   Performs filtering of expression tuple $(B T) passing $(B i) elements to function or template $(B F). If $(B F)
*   returns $(B true) the first element go to returned expression tuple and "window" is moved over T by 1 element.
*   Last i-1 elements goes to resulted tuple without checks.
*/
template staticFilterLookaheadN(size_t i, alias F, T...)
{
    static assert(i != 0, "staticFilterLookaheadN: N is zero");
     
    static if(T.length < i)
    {
        alias staticFilterLookaheadN = ExpressionList!(T);
    }
    else
    {
        static if(__traits(compiles, F(T[0 .. i]))  && F(T[0 .. i]) 
               || __traits(compiles, F!(T[0 .. i])) && F!(T[0 .. i])) 
        {
            alias staticFilterLookaheadN = ExpressionList!(T[0], staticFilterLookaheadN!(i, F, T[1 .. $]));
        } 
        else
        {
            alias staticFilterLookaheadN = ExpressionList!(staticFilterLookaheadN!(i, F, T[1 .. $]));
        }
    }
}
/// Example
unittest
{
    template isFibonachi(int a, int b, int c) { enum isFibonachi = a == b + c; }
    static assert( staticEqual!( StrictExpressionList!(staticFilterLookaheadN!(3, isFibonachi, 9, 5, 3, 2, 1, 1)), StrictExpressionList!(ExpressionList!(5, 3, 2, 1, 1)) ) );
}

/// Alias of staticFilterLookaheadN for 1 argument
alias staticFilterLookahead(alias F, T...) = staticFilterLookaheadN!(1, F, T);
/// Alias of staticFilterLookaheadN for 2 arguments
alias staticFilterLookahead2(alias F, T...) = staticFilterLookaheadN!(2, F, T);
/// Alias of staticFilterLookaheadN for 3 arguments
alias staticFilterLookahead3(alias F, T...) = staticFilterLookaheadN!(3, F, T);
/// Alias of staticFilterLookaheadN for 4 arguments
alias staticFilterLookahead4(alias F, T...) = staticFilterLookaheadN!(4, F, T);
/// Alias of staticFilterLookaheadN for 5 arguments
alias staticFilterLookahead5(alias F, T...) = staticFilterLookaheadN!(5, F, T);
/// Alias of staticFilterLookaheadN for 6 arguments
alias staticFilterLookahead6(alias F, T...) = staticFilterLookaheadN!(6, F, T);
/// Alias of staticFilterLookaheadN for 7 arguments
alias staticFilterLookahead7(alias F, T...) = staticFilterLookaheadN!(7, F, T);
/// Alias of staticFilterLookaheadN for 8 arguments
alias staticFilterLookahead8(alias F, T...) = staticFilterLookaheadN!(8, F, T);
/// Alias of staticFilterLookaheadN for 9 arguments
alias staticFilterLookahead9(alias F, T...) = staticFilterLookaheadN!(9, F, T);

/**
*   Performs filtering of expression tuple $(B T) passing $(B i) elements to function or template $(B F). If $(B F)
*   returns $(B true) the last element go to returned expression tuple and "window" is moved behind T by 1 element.
*   First i-1 elements goes to resulted tuple without checks.
*   
*   Filtering starts from last element.
*/
template staticFilterLookbehindN(size_t i, alias F, T...) 
{
    static assert(i != 0, "staticFilterLookbehindN: N is zero");
     
    static if(T.length < i)
    {
        alias staticFilterLookbehindN = ExpressionList!(T);
    }
    else
    {
        static if(__traits(compiles, F(T[$-i .. $]))  && F(T[$-i .. $]) 
               || __traits(compiles, F!(T[$-i .. $])) && F!(T[$-i .. $])) 
        {
            alias staticFilterLookbehindN = ExpressionList!(staticFilterLookbehindN!(i, F, T[0 .. $-1]), T[$-1]);
        } 
        else
        {
            alias staticFilterLookbehindN = ExpressionList!(staticFilterLookbehindN!(i, F, T[0 .. $-1]));
        }
    }
}
/// Example
unittest
{
    template isFibonachi(int a, int b, int c) { enum isFibonachi = a + b == c; }
    static assert( staticEqual!( StrictExpressionList!(staticFilterLookbehindN!(3, isFibonachi, 1, 1, 2, 3, 5, 9)), StrictExpressionList!(ExpressionList!(1, 1, 2, 3, 5)) ) );
}

/// Alias of staticFilterLookbehindN for 1 argument
alias staticFilterLookbehind(alias F, T...) = staticFilterLookbehindN!(1, F, T);
/// Alias of staticFilterLookbehindN for 2 arguments
alias staticFilterLookbehind2(alias F, T...) = staticFilterLookbehindN!(2, F, T);
/// Alias of staticFilterLookbehindN for 3 arguments
alias staticFilterLookbehind3(alias F, T...) = staticFilterLookbehindN!(3, F, T);
/// Alias of staticFilterLookbehindN for 4 arguments
alias staticFilterLookbehind4(alias F, T...) = staticFilterLookbehindN!(4, F, T);
/// Alias of staticFilterLookbehindN for 5 arguments
alias staticFilterLookbehind5(alias F, T...) = staticFilterLookbehindN!(5, F, T);
/// Alias of staticFilterLookbehindN for 6 arguments
alias staticFilterLookbehind6(alias F, T...) = staticFilterLookbehindN!(6, F, T);
/// Alias of staticFilterLookbehindN for 7 arguments
alias staticFilterLookbehind7(alias F, T...) = staticFilterLookbehindN!(7, F, T);
/// Alias of staticFilterLookbehindN for 8 arguments
alias staticFilterLookbehind8(alias F, T...) = staticFilterLookbehindN!(8, F, T);
/// Alias of staticFilterLookbehindN for 9 arguments
alias staticFilterLookbehind9(alias F, T...) = staticFilterLookbehindN!(9, F, T);