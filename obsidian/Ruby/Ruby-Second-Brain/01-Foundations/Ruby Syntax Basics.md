---
tags:
  - ruby/basics
---

# Ruby Syntax Basics

## Purpose
Learn the shape of Ruby code: no semicolons, `end` keywords, and expressive style.

## Explanation
Ruby syntax favors readability. Blocks of code (methods, classes, loops, conditionals) are closed with `end` rather than braces. Semicolons are optional and rarely used. Parentheses on method calls are often optional too.

This note is the gateway to almost everything else in [[Foundations MOC]] — once syntax feels natural, move to [[Variables and Constants]] and [[Data Types Overview]].

## Examples
```ruby
def greet(name)
  puts "Hello, #{name}!"
end

greet "Raven"   # parentheses optional

if true
  puts "conditionals close with end"
end
```

## Related Notes
- [[What Is Ruby]]
- [[Variables and Constants]]
- [[Comments and Documentation]]

## Next Topics
- [[Variables and Constants]]
- [[Data Types Overview]]

## Tags
#ruby/basics
