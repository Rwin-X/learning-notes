---
tags:
  - ruby/metaprogramming
---

# Reflection

## Purpose
Inspect objects, classes, and methods at runtime.

## Explanation
Reflection methods like `.class`, `.methods`, `.instance_variables`, `.ancestors`, and `.respond_to?` let a program examine its own structure at runtime. This is how you'd debug or build tooling around the concepts from [[Send Method]] and [[Method Missing]].

This note closes out the [[Metaprogramming MOC]] — from here, the natural next step is applying these techniques inside the wider [[Ecosystem MOC]], e.g. how gems use metaprogramming for DSLs.

## Examples
```ruby
5.class                #=> Integer
5.methods.include?(:+) #=> true
String.ancestors       #=> [String, Comparable, Object, Kernel, BasicObject]
```

## Related Notes
- [[Send Method]]
- [[Method Missing]]
- [[Class Eval and Instance Eval]]

## Next Topics
- [[Gems and Bundler]]

## Tags
#ruby/metaprogramming
