/**
*   Copyright: © 2014-2015 Anton Gushcha
*   License: Subject to the terms of the Boost 1.0 license as specified in LICENSE file
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*
*   Template for aggregates members expection - extension of std.traits;
*/
module stribog.meta.iota;

import stribog.meta.base;

/**
*   Template, similar to iota(), but generates a tuple at compile time.
*
*   Useful for "static foreach" loops, where range extrema are compile time constants:
*   -----------
*   foreach (i; Iota!(3))
*   a[i] = b[i];
* 
*   // becomes unrolled and compiled as:
*   a[0] = b[0];
*   a[1] = b[1];
*   a[2] = b[2];
*   -----------
*
*   Source: https://issues.dlang.org/show_bug.cgi?id=4085
*/
template Iota(int stop) {
    static if (stop <= 0)
        alias ExpressionList!() Iota;
    else
        alias ExpressionList!(Iota!(stop-1), stop-1) Iota;
}

/// ditto
template Iota(int start, int stop) {
    static if (stop <= start)
        alias ExpressionList!() Iota;
    else
        alias ExpressionList!(Iota!(start, stop-1), stop-1) Iota;
}

/// ditto
template Iota(int start, int stop, int step) {
    static assert(step != 0, "Iota: step must be != 0");

    static if (step > 0) {
        static if (stop <= start)
            alias ExpressionList!() Iota;
        else
            alias ExpressionList!(Iota!(start, stop-step, step), stop-step) Iota;
    } else {
        static if (stop >= start)
            alias ExpressionList!() Iota;
        else
            alias ExpressionList!(Iota!(start, stop-step, step), stop-step) Iota;
    }
} // End Iota!(a,b,c)

unittest { // Tests of Iota!()
    static assert(Iota!(0).length == 0);

    int[] a;

    foreach (n; Iota!(5))
        a ~= n;
    assert(a == [0, 1, 2, 3, 4]);

    a.length = 0;
    foreach (n; Iota!(-5))
        a ~= n;
    assert(a == new int[0]);

    a.length = 0;
    foreach (n; Iota!(4, 7))
        a ~= n;
    assert(a == [4, 5, 6]);

    a.length = 0;
    foreach (n; Iota!(-1, 4))
        a ~= n;
    static assert(Iota!(-1, 4).length == 5);
    assert(a == [-1, 0, 1, 2, 3]);

    a.length = 0;
    foreach (n; Iota!(4, 2))
        a ~= n;
    assert(a == new int[0]);

    a.length = 0;
    foreach (n; Iota!(0, 10, 2))
        a ~= n;
    assert(a == [0, 2, 4, 6, 8]);

    a.length = 0;
    foreach (n; Iota!(3, 15, 3))
        a ~= n;
    assert(a == [3, 6, 9, 12]);

    a.length = 0;
    foreach (n; Iota!(15, 3, 1))
        a ~= n;
    assert(a == new int[0]);

    a.length = 0;
    foreach (n; Iota!(10, 0, -1))
        a ~= n;
    assert(a == [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]);

    a.length = 0;
    foreach (n; Iota!(15, 3, -2))
        a ~= n;
    assert(a == [15, 13, 11, 9, 7, 5]);

    static assert(!is(typeof( Iota!(15, 3, 0) ))); // stride = 0 statically asserts
} // End tests of Iota!()