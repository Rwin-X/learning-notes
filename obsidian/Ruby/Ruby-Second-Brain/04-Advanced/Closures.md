---
tags:
  - ruby/advanced
---

# Closures

## Purpose
Understand how blocks, procs, and lambdas capture their surrounding scope.

## Explanation
A closure is a function that remembers the variables from the scope where it was created, even after that scope has exited. All of Ruby's block-like constructs ([[Blocks Procs and Lambdas]]) are closures — this is what makes patterns like counters and memoization possible.

Understanding closures deeply prepares you for [[Define Method]] in metaprogramming, where blocks become method bodies.

## Examples
```ruby
def make_counter
  count = 0
  increment = lambda { count += 1 }
  increment
end

counter = make_counter
counter.call   #=> 1
counter.call   #=> 2   (count persists between calls)
```

## Related Notes
- [[Blocks Procs and Lambdas]]
- [[Define Method]]

## Next Topics
- [[Exception Handling Advanced]]
- [[Object Equality]]

## Tags
#ruby/advanced
