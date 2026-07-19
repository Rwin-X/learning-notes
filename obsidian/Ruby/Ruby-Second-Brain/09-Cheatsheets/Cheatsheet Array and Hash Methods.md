---
tags:
  - cheatsheet
  - ruby/collections
---

# Cheatsheet Array and Hash Methods

## Purpose
Quick reference for the most-used Array and Hash methods.

## Explanation
A fast lookup table for [[Arrays]] and [[Hashes]] methods, complementing the conceptual explanations in [[Array Methods (map select reduce)]] and [[Hash Methods]].

## Examples
```ruby
arr.push(x) / arr << x     # append
arr.pop                    # remove last
arr.include?(x)             # membership
arr.flatten                 # nested arrays -> flat
arr.uniq                    # remove duplicates

hash.keys / hash.values
hash.key?(:k) / hash.has_value?(v)
hash.to_a                   # array of [k,v] pairs
```

## Related Notes
- [[Arrays]]
- [[Hashes]]
- [[Array Methods (map select reduce)]]
- [[Hash Methods]]

## Next Topics
- [[Cheatsheet String Methods]]

## Tags
#cheatsheet #ruby/collections
