# Stribog 

[![Join the chat at https://gitter.im/NCrashed/stribog](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/NCrashed/stribog?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/NCrashed/stribog.svg?branch=master)](https://travis-ci.org/NCrashed/stribog)
[![Join the chat at https://gitter.im/NCrashed/stribog](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/NCrashed/stribog?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

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
  * compile-time stable sorting
  
2. [container](source/container) - specific containers with compile-time code generation:

  * multi key maps - operates like Boost MPL maps, you can define several key-value type pairs.
