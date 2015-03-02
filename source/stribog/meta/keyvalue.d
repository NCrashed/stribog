/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template for compile time key-value list - extension of std.traits;
*/
module stribog.meta.keyvalue;

import stribog.meta.base;
import stribog.meta.map;

/**
*   Static associative map.
*
*   $(B Pairs) is a list of pairs key-value.
*/
template KeyValueList(Pairs...)
{
    static assert(Pairs.length % 2 == 0, text("KeyValueList is expecting even count of elements, not ", Pairs.length));
    
    /// Number of entries in the map
    enum length = Pairs.length / 2;
    
    /**
    *   Getting values by keys. If $(B Keys) is a one key, then
    *   returns unwrapped value, else a ExpressionExpressionList of values.
    */
    template get(Keys...)
    {
        static assert(Keys.length > 0, "KeyValueList.get is expecting an argument!");
        static if(Keys.length == 1)
        {
            static if(is(Keys[0])) { 
                alias Key = Keys[0];
            } else {
                enum Key = Keys[0];
                static assert(__traits(compiles, Key == Key), text(typeof(Key).stringof, " must have a opCmp!"));
            }
            
            private static template innerFind(T...)
            {
                static if(T.length == 0) {
                    alias innerFind = ExpressionList!();
                } else
                {
                    static if(is(Keys[0])) { 
                        static if(is(T[0] == Key)) {
                            static if(is(T[1])) {
                                alias innerFind = T[1];
                            } else {
                                enum innerFind = T[1];
                            }
                        } else {
                            alias innerFind = innerFind!(T[2 .. $]);
                        }
                    } else
                    {
                        static if(T[0] == Key) {
                            static if(is(T[1])) {
                                alias innerFind = T[1];
                            } else {
                                // hack to avoid compile-time lambdas
                                // see http://forum.dlang.org/thread/lkl0lp$204h$1@digitalmars.com
                                static if(__traits(compiles, {enum innerFind = T[1];}))
                                {
                                    enum innerFind = T[1];
                                } else
                                {
                                    alias innerFind = T[1];
                                }
                            }
                        } else {
                            alias innerFind = innerFind!(T[2 .. $]);
                        }
                    }
                }
            }

            alias get = innerFind!Pairs; 
        } else {
            alias get = ExpressionList!(get!(Keys[0 .. $/2]), get!(Keys[$/2 .. $]));
        }
    }
    
    /// Returns true if map has a $(B Key)
    template has(Key...)
    {
        static assert(Key.length == 1);
        enum has = ExpressionList!(get!Key).length > 0; 
    }
    
    /// Setting values to specific keys (or adding new key-values)
    template set(KeyValues...)
    {
        static assert(KeyValues.length >= 2, "KeyValueList.set is expecting at least one pair!");
        static assert(KeyValues.length % 2 == 0, "KeyValuesExpressionList.set is expecting even count of arguments!");
        
        template inner(KeyValues...)
        {
            static if(KeyValues.length == 2) {
                static if(is(KeyValues[0])) {
                    alias Key = KeyValues[0];
                } else {
                    enum Key = KeyValues[0];
                }
                
                static if(is(KeyValues[1])) {
                    alias Value = KeyValues[1];
                } else {
                    enum Value = KeyValues[1];
                }
                
                private template innerFind(T...)
                {
                    static if(T.length == 0) {
                        alias innerFind = ExpressionList!(Key, Value);
                    } else
                    {
                        static if(is(Key)) { 
                            static if(is(T[0] == Key)) {
                                alias innerFind = ExpressionList!(Key, Value, T[2 .. $]);
                            } else {
                                alias innerFind = ExpressionList!(T[0 .. 2], innerFind!(T[2 .. $]));
                            }
                        } else
                        {
                            static if(T[0] == Key) {
                                alias innerFind = ExpressionList!(Key, Value, T[2 .. $]);
                            } else {
                                alias innerFind = ExpressionList!(T[0 .. 2], innerFind!(T[2 .. $]));
                            }
                        }
                    }
                }
    
                alias inner = innerFind!Pairs; 
            } else {
                alias inner = ExpressionList!(inner!(KeyValues[0 .. $/2]), inner!(KeyValues[$/2 .. $]));
            }
        }
        alias set = KeyValueList!(inner!KeyValues);
    }
    
    /// Applies $(B F) template for each pair (key-value).
    template map(alias F)
    {
        alias map = KeyValueList!(staticMap2!(F, Pairs));
    }
    
    private static template getKeys(T...)
    {
        static if(T.length == 0) {
            alias getKeys = ExpressionList!();
        } else {
            alias getKeys = ExpressionList!(T[0], getKeys!(T[2 .. $]));
        }
    }
    /// Getting expression list of all keys
    alias keys = getKeys!Pairs;
    
    private static template getValues(T...)
    {
        static if(T.length == 0) {
            alias getValues = ExpressionList!();
        } else {
            alias getValues = ExpressionList!(T[1], getValues!(T[2 .. $]));
        }
    }
    /// Getting expression list of all values
    alias values = getValues!Pairs;
    
    /** 
    *   Filters entries with function or template $(B F), leaving entry only if
    *   $(B F) returning $(B true).
    */
    static template filter(alias F)
    {
        alias filter = KeyValueList!(staticFilter2!(F, Pairs));
    } 
    
    /** 
    *   Filters entries with function or template $(B F) passing only a key from an entry, leaving entry only if
    *   $(B F) returning $(B true).
    */
    static template filterByKey(alias F)
    {
        private alias newKeys = staticFilter!(F, keys);
        private alias newValues = staticMap!(get, newKeys);
        alias filterByKey = KeyValueList!(staticRobin!(StrictExpressionList!(newKeys, newValues)));
    }
}
///
unittest
{
    alias map = KeyValueList!("a", 42, "b", 23);
    static assert(map.get!"a" == 42);
    static assert(map.get!("a", "b") == ExpressionList!(42, 23));
    static assert(map.get!"c".length == 0);
    
    alias map2 = KeyValueList!(int, float, float, double, double, 42);
    static assert(is(map2.get!int == float));
    static assert(is(map2.get!float == double));
    static assert(map2.get!double == 42); 
    
    static assert(map.has!"a");
    static assert(map2.has!int);
    static assert(!map2.has!void);
    static assert(!map.has!"c");
    
    alias map3 = map.set!("c", 4);
    static assert(map3.get!"c" == 4);
    alias map4 = map.set!("c", 4, "d", 8);
    static assert(map4.get!("c", "d") == ExpressionList!(4, 8));
    alias map5 = map.set!("a", 4);
    static assert(map5.get!"a" == 4);
    
    template inc(string key, int val)
    {
        alias inc = ExpressionList!(key, val+1);
    }
    
    alias map6 = map.map!inc;
    static assert(map6.get!"a" == 43);
    static assert(map6.get!("a", "b") == ExpressionList!(43, 24));
    
    static assert(map.keys == ExpressionList!("a", "b"));
    static assert(map.values == ExpressionList!(42, 23));
}