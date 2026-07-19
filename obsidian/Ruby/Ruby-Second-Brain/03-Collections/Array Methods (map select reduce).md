---
tags:
  - ruby/collections
---

# Array Methods (map select reduce)

## Purpose
Master the three most important transformation methods for arrays.

## Explanation
`map` transforms every element and returns a new array of the same size. `select` (alias `filter`) keeps elements matching a condition. `reduce` (alias `inject`) folds a collection down into a single value.

These three methods are the workhorses of functional-style Ruby and are the foundation for [[Enumerable Deep Dive]]. They also underpin the [[Project Word Frequency Counter]].

## Examples
```ruby
nums = [1, 2, 3, 4, 5]

nums.map { |n| n * 2 }         #=> [2,4,6,8,10]
nums.select { |n| n.even? }     #=> [2,4]
nums.reduce(0) { |sum, n| sum + n }   #=> 15
nums.reduce(:+)                  #=> 15  (shorthand)
```

## Related Notes
- [[Arrays]]
- [[Enumerable Module]]
- [[Enumerable Deep Dive]]
- [[Blocks Basics]]

## Next Topics
- [[Hash Methods]]
- [[Iterators Deep Dive]]

## Tags
#ruby/collections
