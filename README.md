# Stribog 

This is a collection library that holds all my compile-time utilities developed over long time for several projects. The main target of the library is template magic and code generation.

There are two components in the library:

1. [meta](source/meta) - general purpose extensions of `std.typetuple` and `std.traits` to handle such things as:

  * compile-time interfaces
  * strict expression lists
  * debugging utilities for expression lists
  * n-ary template filters, maps, folds, robins, satisfy
  * template robin function
  * compile time foreach unwinding
  * aggregates members introspections

2. [container](source/container) - specific containers with compile-time code generation:

  * multi key maps - operates like Boost MPL maps, you can define several key-value type pairs.
