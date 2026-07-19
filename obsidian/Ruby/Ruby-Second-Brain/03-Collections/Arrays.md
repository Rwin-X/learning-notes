---
tags:
  - ruby/collections
---

# Arrays

## Purpose
Store ordered lists of objects in Ruby's most-used collection type.

## Explanation
An `Array` is an ordered, indexable, mutable collection that can hold mixed types. Arrays include the [[Enumerable Module]], which is why they support `map`, `select`, `each`, and dozens more methods explored in [[Array Methods (map select reduce)]].

Arrays and [[Hashes]] together form the backbone of practical Ruby data manipulation.

## Examples
```ruby
fruits = ["apple", "banana", "cherry"]
fruits[0]          #=> "apple"
fruits << "date"    # push
fruits.first        #=> "apple"
fruits.last         #=> "date"
fruits.length        #=> 4
```

## Related Notes
- [[Data Types Overview]]
- [[Ranges]]
- [[Enumerable Module]]
- [[Array Methods (map select reduce)]]

## Next Topics
- [[Array Methods (map select reduce)]]
- [[Hashes]]

## Tags
#ruby/collections
