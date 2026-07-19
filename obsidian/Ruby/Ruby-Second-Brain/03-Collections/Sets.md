---
tags:
  - ruby/collections
---

# Sets

## Purpose
Store unique, unordered collections using Ruby's Set class.

## Explanation
`Set` (from the `set` standard library) behaves like an array with no duplicates and fast membership checks. Useful when you care about uniqueness and don't need ordering guarantees, unlike [[Arrays]].

Sets support many [[Enumerable Deep Dive|Enumerable]] methods and set-theoretic operations like union, intersection, and difference.

## Examples
```ruby
require 'set'

a = Set.new([1, 2, 3])
b = Set.new([2, 3, 4])

a | b   #=> #<Set: {1,2,3,4}>  (union)
a & b   #=> #<Set: {2,3}>       (intersection)
a - b   #=> #<Set: {1}>          (difference)
```

## Related Notes
- [[Arrays]]
- [[Enumerable Deep Dive]]

## Next Topics
- [[Nested Data Structures]]

## Tags
#ruby/collections
