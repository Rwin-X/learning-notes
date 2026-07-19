---
tags:
  - ruby/advanced
---

# Object Equality

## Purpose
Understand the difference between `==`, `equal?`, and `eql?`.

## Explanation
Ruby has three flavors of equality: `==` (value equality, often overridden), `equal?` (object identity — same object in memory), and `eql?` (used internally by hashes, stricter about type). Understanding this trio prevents subtle bugs, especially when overriding `==` in your own classes as part of [[Comparable Module]].

This connects to [[Freezing Objects]], since identity matters more once objects are immutable.

## Examples
```ruby
a = "hello"
b = "hello"

a == b        #=> true   (same value)
a.equal?(b)   #=> false  (different objects)
a.equal?(a)   #=> true   (same object)
```

## Related Notes
- [[Comparable Module]]
- [[Freezing Objects]]

## Next Topics
- [[Freezing Objects]]
- [[Threads and Concurrency Basics]]

## Tags
#ruby/advanced
