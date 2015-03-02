/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template satisfy checks - extension of std.typecons (allSatisfy);
*/
module stribog.meta.satisfy;

public import std.typetuple : allSatisfy, anySatisfy;

import std.conv : text;

import stribog.meta.base;

/**
*   Same as std.typetuple.allSatisfy, but passes $(B i) arguments to the first template.
*/
template allSatisfyN(size_t i, alias F, T...)
{
    static assert(T.length % i == 0, text("Invalid count of arguments, expected ", i, " but got ", T.length));
    
    static if (T.length < i)
    {
        enum allSatisfyN = true;
    }
    else static if (T.length == i)
    {
        static if(__traits(compiles, F(T[0 .. i]))) {
        	enum allSatisfyN = F(T[0 .. i]);
        }
        else {
        	enum allSatisfyN = F!(T[0 .. i]);
    	}
    }
    else
    {
        static if(!F!(T[0 .. i]))
        	enum allSatisfyN = false;
    	else
    		enum allSatisfyN = allSatisfyN!(i, F, T[i  .. $]);
    }
}
/// Example
unittest
{
    template Test(T...)
    {
        enum Test = is(typeof(T[0]) == string) && is(typeof(T[1]) == bool);
    }

    static assert(allSatisfyN!(2, Test, "42", true, "108", false));
}

/// alias to allSatisfyN for 2 arguments
alias allSatisfy2(alias F, T...) = allSatisfyN!(2, F, T);
/// alias to allSatisfyN for 3 arguments
alias allSatisfy3(alias F, T...) = allSatisfyN!(3, F, T);
/// alias to allSatisfyN for 4 arguments
alias allSatisfy4(alias F, T...) = allSatisfyN!(4, F, T);
/// alias to allSatisfyN for 5 arguments
alias allSatisfy5(alias F, T...) = allSatisfyN!(5, F, T);
/// alias to allSatisfyN for 6 arguments
alias allSatisfy6(alias F, T...) = allSatisfyN!(6, F, T);
/// alias to allSatisfyN for 7 arguments
alias allSatisfy7(alias F, T...) = allSatisfyN!(7, F, T);
/// alias to allSatisfyN for 8 arguments
alias allSatisfy8(alias F, T...) = allSatisfyN!(8, F, T);
/// alias to allSatisfyN for 9 arguments
alias allSatisfy9(alias F, T...) = allSatisfyN!(9, F, T);

/**
*   Same as std.typetuple anySatisfy, but passes $(B i) arguments to $(B F).
*/
template anySatisfyN(size_t i, alias F, T...)
{
    static assert(T.length % i == 0, text("Invalid count of arguments, expected ", i, " but got ", T.length));
    
    static if (T.length < i)
    {
        enum anySatisfyN = true;
    }
    else static if (T.length == i)
    {
        static if(__traits(compiles, F(T[0 .. i]))) {
            enum anySatisfyN = F(T[0 .. i]);
        }
        else {
            enum anySatisfyN = F!(T[0 .. i]);
        }
    }
    else
    {
        static if(F!(T[0 .. i]))
        	enum anySatisfyN = true;
    	else
    		enum anySatisfyN = anySatisfyN!(i, F, T[i  .. $]);
    }
}
/// Example
unittest
{
    template Test(int a, int b, int c) {
        enum Test = a + b == c;
    }
    
    static assert(!anySatisfyN!(3, Test, 1, 1, 3, 5, 8, 11)); 
    static assert( anySatisfyN!(3, Test, 1, 1, 2, 5, 8, 11)); 
}

/// alias of anySatisfyN for 2 arguments
alias anySatisfy2(alias F, T...) = anySatisfyN!(2, F, T);
/// alias of anySatisfyN for 3 arguments
alias anySatisfy3(alias F, T...) = anySatisfyN!(3, F, T);
/// alias of anySatisfyN for 4 arguments
alias anySatisfy4(alias F, T...) = anySatisfyN!(4, F, T);
/// alias of anySatisfyN for 5 arguments
alias anySatisfy5(alias F, T...) = anySatisfyN!(5, F, T);
/// alias of anySatisfyN for 6 arguments
alias anySatisfy6(alias F, T...) = anySatisfyN!(6, F, T);
/// alias of anySatisfyN for 7 arguments
alias anySatisfy7(alias F, T...) = anySatisfyN!(7, F, T);
/// alias of anySatisfyN for 8 arguments
alias anySatisfy8(alias F, T...) = anySatisfyN!(8, F, T);
/// alias of anySatisfyN for 9 arguments
alias anySatisfy9(alias F, T...) = anySatisfyN!(9, F, T);