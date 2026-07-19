---
tags:
  - ruby/basics
---

# Operators

## Purpose
Cover arithmetic, comparison, and logical operators in Ruby.

## Explanation
Ruby supports the usual arithmetic (`+ - * / %  **`), comparison (`== != < > <= >=`, and the spaceship `<=>`), and logical operators (`&& || !`, plus the lower-precedence `and or not`).

The spaceship operator `<=>` is worth remembering — it underlies [[Comparable Module]] and custom sorting. Operators feed directly into [[Conditionals]].

## Examples
```ruby
5 <=> 3    #=> 1
3 <=> 5    #=> -1
3 <=> 3    #=> 0

true && false   #=> false
true || false   #=> true
```

## Related Notes
- [[Numbers]]
- [[Booleans and Nil]]
- [[Comparable Module]]

## Next Topics
- [[Conditionals]]

## Tags
#ruby/basics
