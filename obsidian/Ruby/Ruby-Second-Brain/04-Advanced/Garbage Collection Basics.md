---
tags:
  - ruby/advanced
---

# Garbage Collection Basics

## Purpose
Understand how Ruby manages memory automatically.

## Explanation
Ruby uses automatic garbage collection — objects with no remaining references become eligible for reclamation without manual intervention. Understanding this conceptually (rather than tuning GC parameters) is enough for most application code, but it's worth knowing as a foundation before touching [[Threads and Concurrency Basics]] or [[Reflection]].

This closes out the [[Advanced MOC]]'s core topics before moving into [[Metaprogramming MOC]].

## Examples
```ruby
GC.start          # manually trigger garbage collection (rarely needed)
GC.stat[:count]   # inspect GC statistics
```

## Related Notes
- [[Threads and Concurrency Basics]]
- [[Object Equality]]

## Next Topics
- [[Method Missing]]
- [[Define Method]]

## Tags
#ruby/advanced
