---
tags:
  - ruby/basics
---

# Booleans and Nil

## Purpose
Understand truthiness, `nil`, and how Ruby evaluates conditions.

## Explanation
Ruby has `true` and `false` as singleton instances of `TrueClass`/`FalseClass`, and `nil` represents "nothing" as the sole instance of `NilClass`. Critically, **only `nil` and `false` are falsy** — `0` and `""` are truthy, unlike some other languages.

This directly affects how [[Conditionals]] behave and is a common source of bugs for people coming from Python or JavaScript.

## Examples
```ruby
puts "truthy" if 0        #=> prints, 0 is truthy in Ruby
puts "truthy" if ""       #=> prints, empty string is truthy
puts "truthy" if nil      #=> does NOT print

x = nil
x.nil?    #=> true
```

## Related Notes
- [[Data Types Overview]]
- [[Conditionals]]
- [[Operators]]

## Next Topics
- [[Operators]]
- [[Conditionals]]

## Tags
#ruby/basics
