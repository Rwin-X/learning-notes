---
tags:
  - ruby/basics
---

# Ranges

## Purpose
Represent sequences of values concisely with Range objects.

## Explanation
A `Range` (`1..5` inclusive, `1...5` exclusive) represents a sequence and is used constantly for iteration, array slicing, and `case/when` matching as seen in [[Conditionals]]. Ranges are `Enumerable`, so they support methods covered in [[Enumerable Deep Dive]].

## Examples
```ruby
(1..5).to_a       #=> [1, 2, 3, 4, 5]
(1...5).to_a      #=> [1, 2, 3, 4]
(1..5).each { |n| print n }   #=> 12345
('a'..'e').to_a   #=> ["a","b","c","d","e"]
```

## Related Notes
- [[Loops and Iterators]]
- [[Conditionals]]
- [[Arrays]]

## Next Topics
- [[Comments and Documentation]]
- [[Input and Output]]

## Tags
#ruby/basics
