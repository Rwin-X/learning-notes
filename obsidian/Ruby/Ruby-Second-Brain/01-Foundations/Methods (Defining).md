---
tags:
  - ruby/basics
---

# Methods (Defining)

## Purpose
Learn how to define reusable methods with `def`.

## Explanation
Methods are defined with `def name ... end`. Ruby methods implicitly return the value of their last evaluated expression — an explicit `return` is optional and used mainly for early exits.

Method names ending in `?` conventionally return booleans, and names ending in `!` conventionally mutate their receiver or raise on failure — a naming convention worth internalizing now, and revisited in [[Object Equality]] and [[Freezing Objects]].

## Examples
```ruby
def add(a, b)
  a + b     # implicit return
end

def even?(n)
  n % 2 == 0
end

add(2, 3)     #=> 5
even?(4)      #=> true
```

## Related Notes
- [[Loops and Iterators]]
- [[Method Arguments]]
- [[Blocks Basics]]

## Next Topics
- [[Method Arguments]]
- [[Blocks Basics]]

## Tags
#ruby/basics
