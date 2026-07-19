---
tags:
  - ruby/collections
---

# Hash Methods

## Purpose
Learn the essential methods for transforming and querying hashes.

## Explanation
Hashes support `map` (returns an array of pairs unless you `to_h`), `select`, `transform_values`, `merge`, and `each_pair`. Because `Hash` includes [[Enumerable Module]], most array-style methods work on hashes too, just operating on `[key, value]` pairs.

`merge` is especially useful for combining default options with user-supplied ones — a common pattern in [[Method Arguments]].

## Examples
```ruby
prices = { apple: 1.0, banana: 0.5 }

prices.transform_values { |v| v * 2 }  #=> {apple: 2.0, banana: 1.0}
prices.select { |k, v| v > 0.6 }         #=> {apple: 1.0}
prices.merge(cherry: 3.0)                 #=> adds cherry
```

## Related Notes
- [[Hashes]]
- [[Array Methods (map select reduce)]]
- [[Enumerable Module]]

## Next Topics
- [[Iterators Deep Dive]]
- [[Nested Data Structures]]

## Tags
#ruby/collections
