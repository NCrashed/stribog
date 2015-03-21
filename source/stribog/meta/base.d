/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Definition of expression lists - the base of meta-programming facilities of the library.
*/
module stribog.meta.base;

/**
*   Simple expression list wrapper.
*
*   See_Also: Expression list at dlang.org documentation.
*/
template ExpressionList(T...)
{
    alias ExpressionList = T;
    
    /// Pretty printing
    template toString() {
        private template innerToString(U...) {
            static if(U.length == 0) {
                enum innerToString = "";
            }
            else static if(U.length == 1) {
                enum innerToString = staticToString!(U[0]);
            }
            else {
                enum innerToString = staticToString!(U[0]) ~ ", " ~ innerToString!(U[1 .. $]);
            }
        }
        
        static if(T.length == 0) {
            enum toString = "StrictExpressionList!()";
        }
        else static if(T.length == 1) {
            enum toString = "StrictExpressionList!(" ~ staticToString!(T[0]) ~ ")";
        } 
        else {
            enum toString = "StrictExpressionList!(" ~ innerToString!T ~ ")";
        }
    }
}
/// Example
unittest
{
    static assert([ExpressionList!(1, 2, 3)] == [1, 2, 3]);
}

/**
*   Sometimes we don't want to auto expand expression ExpressionLists.
*   That can be used to pass several lists into templates without
*   breaking their boundaries.
*/
template StrictExpressionList(T...)
{
    /// Explicit expand
    alias expand = T;
    
    /// Pretty printing
    template toString() {
        private template innerToString(U...) {
            static if(U.length == 0) {
                enum innerToString = "";
            }
            else static if(U.length == 1) {
                enum innerToString = staticToString!(U[0]);
            }
            else {
                enum innerToString = staticToString!(U[0]) ~ ", " ~ innerToString!(U[1 .. $]);
            }
        }
        
        static if(T.length == 0) {
            enum toString = "StrictExpressionList!()";
        }
        else static if(T.length == 1) {
            enum toString = "StrictExpressionList!(" ~ staticToString!(T[0]) ~ ")";
        } 
        else {
        	enum toString = "StrictExpressionList!(" ~ innerToString!T ~ ")";
    	}
    }
}
/// Example
unittest
{
    template Test(alias T1, alias T2)
    {
        static assert([T1.expand] == [1, 2]);
        static assert([T2.expand] == [3, 4]);
        enum Test = true;
    }
    
    static assert(Test!(StrictExpressionList!(1, 2), StrictExpressionList!(3, 4)));
}

/**
*   Checks two expression lists to be equal. 
*   $(B ET1) and $(B ET2) should be wrapped to $(B StrictExpressionList).
*
*   Types are checked via $(B is) operator. Values are compared via $(B ==) operator.
*   Templates are checked via special inner template-member $(B opEquals) or via
*   ($B stringof) conversion (if no one from pair does not define $(B opEquals)). 
*/
template staticEqual(alias ET1, alias ET2)
{
    alias T1 = ET1.expand;
    alias T2 = ET2.expand;
    
    static if(T1.length == 0 || T2.length == 0) // length isn't equal thus not equal
    {
        enum staticEqual = T1.length == T2.length;
    }
    else
    {
        static if(is(T1[0]) && is(T2[0])) // is types
        {
            enum staticEqual = is(T1[0] == T2[0]) && 
                staticEqual!(StrictExpressionList!(T1[1 .. $]), StrictExpressionList!(T2[1 .. $]));
        } else static if(!is(T1[0]) && !is(T2[0])) // isn't types
        {
            static if(is(typeof(T1[0]) == void) && is(typeof(T2[0]) == void)) // check if both are templates
            {
                static if(__traits(compiles, T1[0].opEquals!(T2[0]))) // first has opEquals
                	enum staticEqual = T1[0].opEquals!(T2[0]) &&
                		staticEqual!(StrictExpressionList!(T1[1 .. $]), StrictExpressionList!(T2[1 .. $]));
        		else static if(__traits(compiles, T2[0].opEquals!(T1[0]))) // second has opEquals
                    enum staticEqual = T2[0].opEquals!(T1[0]) &&
                        staticEqual!(StrictExpressionList!(T1[1 .. $]), StrictExpressionList!(T2[1 .. $]));
                else // compare via strings
                	enum staticEqual = T1[0].stringof == (T2[0].stringof) &&
                		staticEqual!(StrictExpressionList!(T1[1 .. $]), StrictExpressionList!(T2[1 .. $]));
    		}
    		else // are values
    		{
                enum staticEqual = T1[0] == T2[0] &&  
                    staticEqual!(StrictExpressionList!(T1[1 .. $]), StrictExpressionList!(T2[1 .. $]));
            }
        } else // different kinds (one is type, another is template or value)
        {
            enum staticEqual = false;
        }
    }
}
/// Example
unittest
{
    // trivial cases
    static assert(staticEqual!(StrictExpressionList!(1, 2, 3), StrictExpressionList!(1, 2, 3)));
    static assert(staticEqual!(StrictExpressionList!(int, float, 3), StrictExpressionList!(int, float, 3)));
    static assert(!staticEqual!(StrictExpressionList!(int, float, 4), StrictExpressionList!(int, float, 3)));
    static assert(!staticEqual!(StrictExpressionList!(void, float, 4), StrictExpressionList!(int, float, 4)));
    static assert(!staticEqual!(StrictExpressionList!(1, 2, 3), StrictExpressionList!(1, void, 3)));
    static assert(!staticEqual!(StrictExpressionList!(float), StrictExpressionList!()));
    static assert(staticEqual!(StrictExpressionList!(), StrictExpressionList!()));
    
    // compare templates
    template Dummy(T) {
    }
    static assert(staticEqual!(StrictExpressionList!(Dummy!int), StrictExpressionList!(Dummy!int)));
    static assert(!staticEqual!(StrictExpressionList!(Dummy!int), StrictExpressionList!(Dummy!float)));
    
    // compare templates via opEquals
    template DummyStrange(_T, U) {
        alias T = _T; // re-export to outside
        template opEquals(alias S) {
            static if(__traits(compiles, S.T)) enum opEquals = is(T == S.T);
            else enum opEquals = false;
        }
    }
    static assert(staticEqual!(StrictExpressionList!(DummyStrange!(int, float)), StrictExpressionList!(DummyStrange!(int, ubyte))));
    static assert(!staticEqual!(StrictExpressionList!(DummyStrange!(int, float)), StrictExpressionList!(DummyStrange!(bool, float))));
}

/**
*   Converts to string template $(B T). 
*
*   If $(B T) defines inner template (or naked enum) $(B toString), then the member is used,
*   otherwise $(B T.stringof) is printed.
*
*   The template is helpful while debugging. DMD generates ugly mangled names for
*   templates after several transformations.
*/
template staticToString(T...)
{
    private template convertOne(alias U)
    {
        static if(__traits(compiles, U.staticToStringImpl!())) {
            enum convertOne = U.staticToStringImpl!();
        }
        else static if(__traits(compiles, U.staticToStringImpl)) { // special case for naked enum
            enum convertOne = U.staticToStringImpl;
        }
        else {
            enum convertOne = U.stringof;
        }
    }
    
    static if(T.length == 0) {
        enum staticToString = "";
    }
    else static if(T.length == 1) {
        enum staticToString = convertOne!(T[0]);
    } 
    else {
        enum staticToString = convertOne!(T[0]) ~ ", " ~ staticToString!(T[1 .. $]);
    }
}
/// Example
unittest
{
    template Dummy(T) {}
    static assert(staticToString!(Dummy!int) == "Dummy!int");
    
    template DummyCustom1(T) {
        template staticToStringImpl() {
            enum staticToStringImpl = T.stringof;
        }
    }
    static assert(staticToString!(DummyCustom1!int) == "int");
    
    template DummyCustom2(T) {
        enum staticToStringImpl = T.stringof;
    }
    static assert(staticToString!(DummyCustom2!int) == "int");
}