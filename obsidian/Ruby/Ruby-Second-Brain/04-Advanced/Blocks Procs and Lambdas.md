---
tags:
  - ruby/advanced
---

# Blocks Procs and Lambdas

## Purpose
Understand the full spectrum of Ruby's callable objects.

## Explanation
A block ([[Blocks Basics]]) isn't an object by itself, but you can capture it as a `Proc` with `&block` or create standalone `Proc.new` / `lambda` objects. Lambdas are stricter than procs: they enforce argument count and `return` only exits the lambda itself, not the enclosing method.

This distinction matters once you start passing behavior around as data, and it directly sets up [[Closures]].

## Examples
```ruby
square = lambda { |x| x * x }
square.call(5)     #=> 25
square.(5)         #=> 25   (shorthand)

add = ->(a, b) { a + b }   # lambda literal
add.call(2, 3)     #=> 5
```

## Related Notes
- [[Blocks Basics]]
- [[Method Arguments]]
- [[Closures]]

## Next Topics
- [[Closures]]
- [[Exception Handling Advanced]]

## Tags
#ruby/advanced
