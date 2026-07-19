---
tags:
  - ruby/advanced
---

# Threads and Concurrency Basics

## Purpose
Get an introductory mental model of concurrency in Ruby.

## Explanation
Ruby's `Thread` class allows concurrent execution, though MRI (the standard Ruby implementation) has a Global Interpreter Lock (GIL) limiting true CPU parallelism — threads shine mainly for I/O-bound work. Immutability, as covered in [[Freezing Objects]], helps avoid race conditions when sharing data across threads.

This is an introductory note; production concurrency usually leans on gems or frameworks rather than raw threads.

## Examples
```ruby
threads = 3.times.map do |i|
  Thread.new { puts "Thread #{i} running" }
end
threads.each(&:join)
```

## Related Notes
- [[Freezing Objects]]
- [[Object Equality]]
- [[Garbage Collection Basics]]

## Next Topics
- [[Garbage Collection Basics]]
- [[Method Missing]]

## Tags
#ruby/advanced
