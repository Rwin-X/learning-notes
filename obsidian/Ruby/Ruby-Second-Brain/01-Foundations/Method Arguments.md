---
tags:
  - ruby/basics
---

# Method Arguments

## Purpose
Understand positional, default, keyword, and splat arguments.

## Explanation
Ruby methods support default values, keyword arguments (great for readability at call sites), and splat (`*args`) / double-splat (`**kwargs`) for variable-length argument lists.

Keyword arguments are heavily used in real-world Ruby (including Rails) because they make call sites self-documenting. This pairs with [[Blocks Procs and Lambdas]] when methods also accept blocks.

## Examples
```ruby
def greet(name, greeting: "Hello")
  "#{greeting}, #{name}!"
end
greet("Raven")                      #=> "Hello, Raven!"
greet("Raven", greeting: "Hey")     #=> "Hey, Raven!"

def sum(*nums)
  nums.reduce(0) { |acc, n| acc + n }
end
sum(1, 2, 3, 4)   #=> 10
```

## Related Notes
- [[Methods (Defining)]]
- [[Blocks Basics]]

## Next Topics
- [[Blocks Basics]]
- [[Ranges]]

## Tags
#ruby/basics
