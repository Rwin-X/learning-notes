---
tags:
  - ruby/basics
---

# Loops and Iterators

## Purpose
Learn Ruby's approach to repetition: loops, but more importantly, iterators.

## Explanation
Ruby has traditional loops (`while`, `until`, `for`) but idiomatic Ruby favors **iterator methods** with blocks instead — `each`, `times`, `map`, etc. This is a mental shift from C-style languages and is foundational for [[Collections MOC]] and [[Enumerable Deep Dive]] later.

Understanding [[Blocks Basics]] alongside this note will make iteration click.

## Examples
```ruby
# Traditional loop
i = 0
while i < 3
  puts i
  i += 1
end

# Idiomatic Ruby: iterator + block
3.times { |i| puts i }
[1,2,3].each { |n| puts n * 2 }
```

## Related Notes
- [[Conditionals]]
- [[Blocks Basics]]
- [[Ranges]]
- [[Arrays]]

## Next Topics
- [[Blocks Basics]]
- [[Methods (Defining)]]

## Tags
#ruby/basics
