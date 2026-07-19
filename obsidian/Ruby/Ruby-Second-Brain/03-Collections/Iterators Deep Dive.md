---
tags:
  - ruby/collections
---

# Iterators Deep Dive

## Purpose
Go beyond `each` into `each_with_index`, `each_slice`, `each_cons`, and more.

## Explanation
Ruby's iterator family extends far past basic `each`: `each_with_index` pairs elements with their position, `each_slice(n)` chunks a collection, `each_cons(n)` gives sliding windows, and `each_with_object` accumulates into a supplied object.

These build directly on [[Loops and Iterators]] and prepare you for the full method catalogue in [[Enumerable Deep Dive]].

## Examples
```ruby
["a","b","c"].each_with_index { |v, i| puts "#{i}: #{v}" }

(1..6).each_slice(2).to_a    #=> [[1,2],[3,4],[5,6]]
(1..4).each_cons(2).to_a     #=> [[1,2],[2,3],[3,4]]
```

## Related Notes
- [[Loops and Iterators]]
- [[Array Methods (map select reduce)]]
- [[Enumerable Deep Dive]]

## Next Topics
- [[Enumerable Deep Dive]]
- [[Sets]]

## Tags
#ruby/collections
