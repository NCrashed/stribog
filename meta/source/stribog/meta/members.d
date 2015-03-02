/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template for aggregates members expection - extension of std.traits;
*/
module stribog.meta.members;

import std.traits : isIntegral;
import std.typetuple : staticIndexOf;
import stribog.meta.base;
import stribog.meta.filter;

/**
*   More useful version of allMembers trait, that returns only
*   fields and methods of class/struct/interface/union without
*   service members like constructors and Object members.
*
*   Note: if Object methods are explicitly override in $(B T) 
*   (not other base class), then the methods are included into
*   the result.
*/
template fieldsAndMethods(T)  
{
    static if(is(T == class) || is(T == struct) || is(T == interface) || is(T == union))
    {
        /// Getting all inherited members from Object exluding overrided
        private template derivedFromObject()
        {
            alias objectMembers = ExpressionList!(__traits(allMembers, Object));
            alias derivedMembers = ExpressionList!(__traits(derivedMembers, T));
            
            private template removeDerived(string name)
            {
                enum removeDerived = staticIndexOf!(name, derivedMembers);
            }
            
            alias derivedFromObject = staticFilter!(removeDerived, objectMembers);
        }
        
        /// Filter unrelated symbols like constructors and Object methods
        private template filterUtil(string name)
        {
            static if(name == "this")
            {
                enum filterUtil = false;
            } 
            else
            {
                static if(is(T == class))
                {
                    enum filterUtil = staticIndexOf!(name, derivedFromObject!()) == -1;
                }
                else
                {
                    enum filterUtil = true;
                }
            }
        }
        
        alias fieldsAndMethods = staticFilter!(filterUtil, __traits(allMembers, T));
    }
    else
    {
        alias fieldsAndMethods = ExpressionList!();
    }
}
/// Example
unittest
{
    struct A
    {
        string a;
        float b;
        void foo();
        string bar(float);
    }
    
    class B
    {
        string a;
        float b;
        void foo() {}
        string bar(float) {return "";}
    }
    
    class C
    {
        override string toString() const {return "";}
    }
    
    static assert(staticEqual!(StrictExpressionList!(fieldsAndMethods!A), StrictExpressionList!("a", "b", "foo", "bar")));
    static assert(staticEqual!(StrictExpressionList!(fieldsAndMethods!B), StrictExpressionList!("a", "b", "foo", "bar"))); 
    static assert(staticEqual!(StrictExpressionList!(fieldsAndMethods!C), StrictExpressionList!("toString"))); 
}

/// Checks if $(B T1) and $(B T2) have an operator $(B op): T1 op T2
template hasOp(T1, T2, string op)
{
    static if(isIntegral!T1 && isIntegral!T2 && op == "/")
    {
        enum hasOp = true; // to not fall into 0 divizion
    } else
    {
        enum hasOp = __traits(compiles, mixin("T1.init" ~ op ~ "T2.init"));
    }
}
///
unittest
{
    static assert(hasOp!(float, int, "*"));
    static assert(hasOp!(double, double, "/"));
    static assert(!hasOp!(double, void, "/"));
    static assert(hasOp!(int, int, "/"));
    
    struct B {}
    
    struct A
    {
        void opBinary(string op)(B b) if(op == "*") {}
    }
    
    static assert(hasOp!(A, B, "*"));
}

/// Shortcut for trait allMembers
template allMembers(T)
{
    alias allMembers = ExpressionList!(__traits(allMembers, T));
}

// hack to feed up parser a traits alias
private template Alias(alias T)
{
    alias Alias = T;
}

/// Shortcut for getMember
template getMember(T, string name)
{   
    alias getMember = Alias!(__traits(getMember, T, name));
}