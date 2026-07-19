---
tags:
  - ruby/basics
---

# Data Types Overview

## Purpose
See the map of Ruby's core built-in types before diving into each one.

## Explanation
Ruby's core types are all objects: `String`, `Integer`, `Float`, `Symbol`, `TrueClass` / `FalseClass`, `NilClass`, `Array`, and `Hash`. This note is a hub — each type has its own atomic note, and together they form the backbone of the [[Foundations MOC]].

Understanding types here sets up [[Collections MOC]] later, since `Array` and `Hash` are collections in their own right.

## Examples
```ruby
"hello".class   #=> String
42.class         #=> Integer
3.14.class       #=> Float
:symbol.class    #=> Symbol
true.class       #=> TrueClass
nil.class        #=> NilClass
[1,2,3].class    #=> Array
{a: 1}.class     #=> Hash
```

## Related Notes
- [[Variables and Constants]]
- [[Strings]]
- [[Numbers]]
- [[Symbols]]
- [[Booleans and Nil]]

## Next Topics
- [[Strings]]
- [[Numbers]]
- [[Symbols]]
- [[Booleans and Nil]]

## Tags
#ruby/basics
