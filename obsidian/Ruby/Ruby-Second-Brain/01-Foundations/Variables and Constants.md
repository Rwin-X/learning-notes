---
tags:
  - ruby/basics
---

# Variables and Constants

## Purpose
Understand how Ruby names and scopes data.

## Explanation
Ruby has several variable scopes distinguished by a naming **sigil**:

- `local_variable` — lowercase, scoped to the current block/method
- `@instance_variable` — belongs to an object instance, see [[Instance vs Class Variables]]
- `@@class_variable` — shared across a class hierarchy
- `$global_variable` — accessible everywhere (avoid in real code)
- `CONSTANT` — uppercase first letter, conventionally not reassigned

Ruby is dynamically typed: you don't declare a type, and a variable's type can change at runtime. Compare with [[Data Types Overview]] to see what values look like.

## Examples
```ruby
name = "Raven"        # local variable
MAX_USERS = 100        # constant

name = 42               # legal -- dynamic typing
puts name.class         #=> Integer
```

## Related Notes
- [[Ruby Syntax Basics]]
- [[Data Types Overview]]
- [[Instance vs Class Variables]]

## Next Topics
- [[Data Types Overview]]

## Tags
#ruby/basics
