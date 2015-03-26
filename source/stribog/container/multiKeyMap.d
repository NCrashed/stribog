/**
*   Copyright: © 2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file.
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   An analog of Boost MPL maps that have several types of keys and
*   only one value per each key type.
*/
module stribog.container.multiKeyMap;

mixin template makeMultiKeyMap(string mapTypeName, KeyValuesRaw...)
{
    import stribog.meta;
    import std.conv;
    import std.typetuple : Reverse;
    import std.traits : fullyQualifiedName;

    private template KeyValue(_Key, _Value, size_t _i)
    {
        enum i = _i;
        alias Key = _Key;
        alias Value = _Value;
        
        template setNumber(size_t i) {
            alias setNumber = KeyValue!(Key, Value, i);
        }
    
        template mapName() {
            enum mapName = text("map", i);
        }
        
        template genCode() {
            enum genCode = text(fullyQualifiedName!Value ~ "[" ~ fullyQualifiedName!Key ~ "] " ~ mapName!() ~ ";\n");
        }
    }
    
    private template SplitKeyValue(T...)
    {
        static assert(T.length % 2 == 0, text("Key-values pairs count isn't even, got ", T.length, " elements"));
        
        private template makeKeyValue(K, V)
        {
            alias makeKeyValue = KeyValue!(K, V, 0);
        }
        
        private template incNumber(alias Pair, T...)
        {
            enum iacc = Pair.expand[0];
            alias kv = T[0];
            alias kvs = Pair.expand[1];
            alias incNumber = StrictExpressionList!(iacc+1, StrictExpressionList!(kv.setNumber!(iacc), kvs.expand));
        }
        
        alias Temp = staticFold!( incNumber, StrictExpressionList!(0, StrictExpressionList!()), staticMap2!(makeKeyValue, T)).expand;
        alias Temp2 = Temp[1];
        alias SplitKeyValue = Temp2.expand;
    }
    
    private template GenMaps(T...)
    {
        private template accString(string acc, T...)
        {
            enum accString = acc ~ T[0].genCode!();
        }
        
        enum GenMaps = staticFold!(accString, "", T);
    }
    
    private template hasKeyImpl(U, T...)
    {
        private template hasKeyImplImpl(bool acc, Params...)
        {
            static if(acc) 
                enum hasKeyImplImpl = true;
            else {
                alias Param = Params[0];
                alias Key = Param.Key;
                enum hasKeyImplImpl = is(Key == U);
            }
        }
        
        alias hasKeyImpl = staticFold!(hasKeyImplImpl, false, T);
    }
    
    private template getPair(Key, T...)
    {
        private template getPairImpl(alias Res, Params...)
        {
            static if(Res.expand.length > 0) 
                alias getPairImpl = Res;
            else {
                alias Param = Params[0];
                alias LocalKey = Param.Key;
                static if(is(LocalKey == Key)) 
                    alias getPairImpl = StrictExpressionList!(Param);
                else
                    alias getPairImpl = StrictExpressionList!();
            }
        }
        
        alias getPair = staticFold!(getPairImpl, StrictExpressionList!(), T).expand[0];
    }
    
    private template takeKey(alias T) {
        alias takeKey = T.Key;
    }
    
    private template takeValue(alias T) {
        alias takeValue = T.Value;
    }
    
    mixin(q{class }~mapTypeName~q{
    {
        private alias KeyValues = SplitKeyValue!KeyValuesRaw;
        
        public alias KeyTypes = Reverse!(staticMap!(takeKey, KeyValues));
        public alias ValueTypes = Reverse!(staticMap!(takeValue, KeyValues));
        
        size_t length(K)()
            if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return " ~ KV.mapName!() ~ ".length;");  
        }
        
        auto keys(K)()
        	if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return " ~ KV.mapName!() ~ ".keys;");  
        }
        
        auto values(K)()
            if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return " ~ KV.mapName!() ~ ".values;");  
        }
        
        auto byKey(K)()
            if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return " ~ KV.mapName!() ~ ".byKey;");  
        }
        
        auto byValue(K)()
            if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return " ~ KV.mapName!() ~ ".byValue;");  
        }
        
        auto byKeyValue(K)()
            if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return " ~ KV.mapName!() ~ ".byKeyValue;");  
        }
        
        auto opIndex(K)(K val)
            if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return " ~ KV.mapName!() ~ "[val];");  
        }
        
        void opIndexAssign(K,V)(V val, K key)
            if(hasKeyImpl!(K, KeyValues) && is(getPair!(K, KeyValues).Value == V))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin(KV.mapName!() ~ "[key] = val;"); 
        }
        
        auto remove(K)(K val)
            if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return " ~ KV.mapName!() ~ ".remove(val);");  
        }
        
        bool hasKey(K)(K key) if(!hasKeyImpl!(K, KeyValues))
        {
            return false;
        }
        
        bool hasKey(K)(K key) if(hasKeyImpl!(K, KeyValues))
        {
            alias KV = getPair!(K, KeyValues); 
            mixin("return (key in " ~ KV.mapName!() ~ ") !is null;");
        }
        
        //pragma(msg, GenMaps!KeyValues);
        mixin(GenMaps!KeyValues);
    }});
}

version(unittest)
{
    import std.range;
    
    mixin makeMultiKeyMap!("MultiKeyMap", 
        int, uint,
        char, ubyte,
        ulong, char[17],
        int[42], bool
    );
    
    static assert(staticEqual!(
            StrictExpressionList!(MultiKeyMap.KeyTypes),
            StrictExpressionList!(int, char, ulong, int[42]))
    );
    
    static assert(staticEqual!(
            StrictExpressionList!(MultiKeyMap.ValueTypes),
            StrictExpressionList!(uint, ubyte, char[17], bool))
    );
}
unittest
{
    MultiKeyMap map = new MultiKeyMap();
    
    assert(map.keys!int == []);
    map[cast(int)5] = 42u; 
    assert(map[cast(int)5] == 42u);
    assert(map.keys!int == [5]);
    
    map['c'] = cast(ubyte)42u; 
    assert(map['c'] == cast(ubyte)42u);
    assert(map.keys!int == [5]);
    assert(map.keys!char == ['c']);
    
    char[17] str = "1234567890qwertyu".dup[0 .. 17];
    map[cast(ulong)23u] = str; 
    assert(map[cast(ulong)23u] == str);
    assert(map.keys!ulong == [23u]);
    
    int[42] arr = 42.repeat(42).array[0 .. 42];
    map[arr] = true; 
    assert(map[arr]);
    assert(map.keys!(int[42]) == [arr]);
        
    assert(map.hasKey!char('c'));
    map.remove!char('c');
    assert(!map.hasKey!char('c'));
    
    assert(!map.hasKey!bool(true));
}