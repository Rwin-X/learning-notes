---
tags:
  - ruby/basics
---

# Numbers

## Purpose
Understand Ruby's numeric types and common numeric operations.

## Explanation
Ruby has `Integer` and `Float` as the main numeric types, both descending from `Numeric`. Integer division truncates; use a `Float` operand to get decimal results. Ruby integers have arbitrary precision — no overflow to worry about.

Numeric methods pair well with [[Operators]] and show up constantly in [[Loops and Iterators]] (e.g. `5.times`).

## Examples
```ruby
7 / 2         #=> 3   (integer division)
7 / 2.0       #=> 3.5
7 % 2         #=> 1   (modulo)
2 ** 10       #=> 1024
10.times { |i| print i }   #=> 0123456789
```

## Related Notes
- [[Data Types Overview]]
- [[Operators]]
- [[Loops and Iterators]]

## Next Topics
- [[Operators]]
- [[Symbols]]

## Tags
#ruby/basics
