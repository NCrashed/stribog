/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template maps - extension of std.typecons;
*/
module stribog.meta.map;

public import std.typetuple : staticMap;

import std.conv : text;

import stribog.meta.base;

template staticMapN(size_t i, alias F, T...)
{
    static assert(i != 0, "staticMapN: N is zero"); 
    static assert(T.length % i == 0, text("Wrong count of arguments, expected power of ", i, " but got ", T.length)); 
    
    static if (T.length < i)
    {
        alias staticMapN = ExpressionList!();
    }
    else static if(T.length == i)
    {
        alias staticMapN = ExpressionList!(F!(T[0 .. i]));
    }
    else
    {
        alias staticMapN = ExpressionList!(F!(T[0 .. i]), staticMapN!(i, F, T[i .. $]));
    }
}
/// Example
unittest
{
    template Test(bool a, bool b)
    {
        enum Test = a && b;
    }
    
    static assert([staticMapN!(2, Test, true, true, true, false)] == [true, false]);
    
    template Test3(alias T1, alias T2, alias T3)
    {
        alias Test3 = StrictExpressionList!(T3, T2, T1);
    } 
    
    template Dummy(T) {
    	enum toString = text("Dummy!", T.stringof);
    }
    
    static assert( staticEqual!( StrictExpressionList!(staticMapN!(3, Test3, Dummy!int, Dummy!float, Dummy!real)), StrictExpressionList!(StrictExpressionList!(Dummy!real, Dummy!float, Dummy!int) )) ); 
}

/// Alias of staticMapN for 2 arguments
alias staticMap2(alias F, T...) = staticMapN!(2, F, T);
/// Example
unittest
{
    template Test(T...)
    {
        enum Test = T[0] && T[1];
    }
    
    static assert([staticMap2!(Test, true, true, true, false)] == [true, false]);
}

/// Alias of staticMapN for 3 arguments
alias staticMap3(alias F, T...) = staticMapN!(3, F, T);
/// Alias of staticMapN for 4 arguments
alias staticMap4(alias F, T...) = staticMapN!(4, F, T);
/// Alias of staticMapN for 5 arguments
alias staticMap5(alias F, T...) = staticMapN!(5, F, T);
/// Alias of staticMapN for 6 arguments
alias staticMap6(alias F, T...) = staticMapN!(6, F, T);
/// Alias of staticMapN for 7 arguments
alias staticMap7(alias F, T...) = staticMapN!(7, F, T);
/// Alias of staticMapN for 8 arguments
alias staticMap8(alias F, T...) = staticMapN!(8, F, T);
/// Alias of staticMapN for 9 arguments
alias staticMap9(alias F, T...) = staticMapN!(9, F, T);