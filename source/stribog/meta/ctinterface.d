/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template for compile time key-value list - extension of std.traits;
*/
module stribog.meta.ctinterface;

import std.traits;
import std.typetuple;

import stribog.meta.base;
import stribog.meta.satisfy;
import stribog.meta.filter;
import stribog.meta.members;
import stribog.meta.replicate;
import stribog.meta.map;
import stribog.meta.robin;
import stribog.meta.overload;

/// UDA if you don't want to match element in interface
enum trasient;

/**
*   Checks $(B Type) to satisfy compile-time interfaces listed in $(B Interfaces). 
*
*   $(B Type) should expose all methods and fields that are defined in each interface.
*   Compile-time interface description is struct with fields and methods without 
*   implementation. There are no implementations to not use the struct in usual way,
*   linker will stop you. 
*
*   Overloaded methods are handled as expected. Check is provided by name, return type and
*   parameters types of the method that is looked up.
*/
template isExpose(Type, Interfaces...)
{
    private template getMembers(T)
    {
        alias getMembers = ExpressionList!(__traits(allMembers, T));
    }
    
    private template isExposeSingle(Interface)
    {
        alias intMembers = StrictExpressionList!(staticFilter!(filterTrasient, fieldsAndMethods!Interface));
        alias intTypes = StrictExpressionList!(staticReplicate!(Interface, intMembers.expand.length)); 
        alias pairs = staticMap2!(bindType, staticRobin!(intTypes, intMembers)); 
    
        private template filterTrasient(string name) // and aliases
        {
            static if(__traits(compiles, __traits(getAttributes, __traits(getMember, Interface, name))))
            {
                enum filterTrasient 
                    = staticIndexOf!(trasient, __traits(getAttributes, __traits(getMember, Interface, name))) == -1;
            }
            else
            {
                enum filterTrasient = false;
            }
        }
        
        private template bindType(Base, string T) // also expanding overloads
        {
            private template getType(alias T)
            {
                alias getType = typeof(T);
            }
            
            alias overloads_ = staticMap!(getType , ExpressionList!(__traits(getOverloads, Base, T)));
            static if(overloads_.length == 0)
                alias overloads = ExpressionList!(typeof(__traits(getMember, Base, T)));
            else
                alias overloads = overloads_;
                            
            alias names = staticReplicate!(T, overloads.length);
            alias bindType = staticRobin!(StrictExpressionList!overloads, StrictExpressionList!names);
        }
        
        template checkMember(MemberType, string MemberName)
        {
            static if(hasMember!(Type, MemberName))
            { 
                enum checkMember = hasOverload!(Type, Unqual!MemberType, MemberName);
            }
            else
            { 
                enum checkMember = false;
            }
        }
        
        enum isExposeSingle = allSatisfy2!(checkMember, pairs); 
    }
    
    enum isExpose = allSatisfy!(isExposeSingle, Interfaces);
}
/// Example
version(unittest)
{
    struct CITest1
    {
        string a;
        string meth1();
        bool meth2();
    }
    
    struct CITest2
    {
        bool delegate(string) meth3();
    }
    
    struct CITest3
    {
        bool meth1();
    }
    
    struct Test1
    {
        string meth1() {return "";}
        bool meth2() {return true;}
        
        string a;
        
        bool delegate(string) meth3() { return (string) {return true;}; };
    }
    
    static assert(isExpose!(Test1, CITest1, CITest2));
    static assert(!isExpose!(Test1, CITest3));
    
    struct CITest4
    {
        bool meth1();
        int  meth1();
    }
    
    struct Test2
    {
        bool meth1() {return true;}
    }
    
    static assert(!isExpose!(Test2, CITest4));
    
    struct CITest5
    {
        immutable string const1;
        immutable bool const2;
    }
    
    struct Test3
    {
        enum const1 = "";
        enum const2 = true;
    }
    
    static assert(isExpose!(Test3, CITest5));
    
    struct CITest6
    {
        
    }
    static assert(isExpose!(Test3, CITest6));
}