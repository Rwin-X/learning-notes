---
tags:
  - ruby/basics
---

# Symbols

## Purpose
Understand symbols as lightweight, immutable identifiers.

## Explanation
A `Symbol` (`:like_this`) is an immutable, interned label. Unlike strings, two symbols with the same name are the exact same object in memory, which makes them fast and memory-efficient for things that act as identifiers rather than data — hash keys being the classic case, see [[Hashes]].

Symbols show up everywhere in idiomatic Ruby: method names, hash keys, and `attr_accessor` arguments in [[Attributes (attr_accessor)]].

## Examples
```ruby
:name.object_id == :name.object_id   #=> true
"name".object_id == "name".object_id #=> false

user = { name: "Raven", role: :admin }
user[:role]   #=> :admin
```

## Related Notes
- [[Strings]]
- [[Data Types Overview]]
- [[Hashes]]
- [[Attributes (attr_accessor)]]

## Next Topics
- [[Booleans and Nil]]
- [[Hashes]]

## Tags
#ruby/basics
