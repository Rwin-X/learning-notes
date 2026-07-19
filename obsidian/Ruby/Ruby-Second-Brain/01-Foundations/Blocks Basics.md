---
tags:
  - ruby/basics
---

# Blocks Basics

## Purpose
Understand blocks as anonymous chunks of code passed to methods.

## Explanation
A block is code wrapped in `do...end` or `{}` that can be passed to a method and invoked with `yield`. Blocks are the foundation of Ruby's iterator style seen in [[Loops and Iterators]], and they generalize into [[Blocks Procs and Lambdas]] once you need to store or pass them as objects.

Use `{}` for single-line blocks and `do...end` for multi-line — a style convention, not a functional difference.

## Examples
```ruby
def repeat(n)
  n.times { |i| yield i }
end

repeat(3) do |i|
  puts "Iteration #{i}"
end
```

## Related Notes
- [[Methods (Defining)]]
- [[Loops and Iterators]]
- [[Blocks Procs and Lambdas]]

## Next Topics
- [[Ranges]]
- [[Blocks Procs and Lambdas]]

## Tags
#ruby/basics
