---
tags:
  - ruby/basics
---

# Conditionals

## Purpose
Control program flow with if/unless/case expressions.

## Explanation
Ruby conditionals include `if/elsif/else`, `unless` (the inverse of `if`), and `case/when` for multi-branch matching. Nearly everything in Ruby is an **expression** that returns a value — including `if` itself, which is a distinctive feature worth internalizing early.

Ruby also supports trailing modifiers (`puts "hi" if true`), a very idiomatic pattern you'll see throughout real Ruby code, including in [[Loops and Iterators]].

## Examples
```ruby
age = 20
message = if age >= 18 then "adult" else "minor" end
puts message   #=> adult

case age
when 0..12 then puts "child"
when 13..17 then puts "teen"
else puts "adult"
end
```

## Related Notes
- [[Booleans and Nil]]
- [[Operators]]
- [[Loops and Iterators]]
- [[Ranges]]

## Next Topics
- [[Loops and Iterators]]
- [[Ranges]]

## Tags
#ruby/basics
