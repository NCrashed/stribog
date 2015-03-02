/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template for detecting overloads - extension of std.traits;
*/
module stribog.meta.overload;

import std.traits : isCallable, staticIndexOf, ReturnType, hasMember, ParameterTypeTuple;

import stribog.meta.base;
import stribog.meta.satisfy;
import stribog.meta.map;

/**
*   Variant of std.traits.hasMember that checks also by member type
*   to handle overloads.
*   
*   $(B T) is a type to be checked. $(B ElemType) is a member type, and 
*   $(B ElemName) is a member name. Template returns $(B true) if $(B T) has
*   element (field or method) of type $(B ElemType) with name $(B ElemName).
*
*   Template returns $(B false) for non aggregates.
*/
template hasOverload(T, ElemType, string ElemName)
{
    static if(is(T == class) || is(T == struct) || is(T == interface) || is(T == union))
    {
        static if(isCallable!ElemType)
        {
            alias retType = ReturnType!ElemType;
            alias paramExpressionList = ParameterTypeTuple!ElemType;
            
            private template extractType(alias F)
            {
                alias extractType = typeof(F);
            }
            
            static if(hasMember!(T, ElemName))
                alias overloads = staticMap!(extractType, __traits(getOverloads, T, ElemName));
            else
                alias overloads = ExpressionList!();
            
            /// TODO: at next realease check overloads by attributes
            //pragma(msg, __traits(getFunctionAttributes, sum));
            
            private template checkType(F)
            {
                static if(is(ReturnType!F == retType))
                {
                    enum checkType = staticEqual!(StrictExpressionList!(ParameterTypeTuple!F), StrictExpressionList!(paramExpressionList));
                } else
                {
                    enum checkType = false;
                }
            }
            
            enum hasOverload = anySatisfy!(checkType, overloads);
        }
        else
        {
            enum hasOverload = staticIndexOf!(ElemName, __traits(allMembers, T)) != -1 &&
                is(typeof(__traits(getMember, T, ElemName)) == ElemType);
        }
    }
    else
    {
        enum hasOverload = false;
    }
}
/// Example
unittest
{
    struct A
    {
        bool method1(string a);
        bool method1(float b);
        string method1();
        
        string field;
    }
    
    static assert(hasOverload!(A, bool function(string), "method1"));
    static assert(hasOverload!(A, bool function(float), "method1"));
    static assert(hasOverload!(A, string function(), "method1"));
    static assert(hasOverload!(A, string, "field"));
    
    static assert(!hasOverload!(A, bool, "field"));
    static assert(!hasOverload!(A, void function(), "method1"));
    static assert(!hasOverload!(A, bool function(), "method1"));
    static assert(!hasOverload!(A, string function(float), "method1"));
    
    /// TODO: at next realease check overloads by attributes
//    struct D
//    {
//        string toString() const {return "";}
//    }
//    
//    static assert(hasOverload!(D, const string function(), "toString"));
//    static assert(!hasOverload!(D, string function(), "toString"));
}