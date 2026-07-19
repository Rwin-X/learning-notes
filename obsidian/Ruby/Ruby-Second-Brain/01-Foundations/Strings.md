---
tags:
  - ruby/basics
---

# Strings

## Purpose
Learn how Ruby represents and manipulates text.

## Explanation
Strings in Ruby are mutable objects supporting a huge method set. Double-quoted strings support **interpolation** (`#{}`); single-quoted strings do not.

Strings are central enough that they get their own [[Cheatsheet String Methods]]. They also interact with [[Regular Expressions]] for pattern matching.

## Examples
```ruby
name = "Raven"
puts "Hello, #{name}!"   #=> Hello, Raven!

s = "ruby"
s.upcase        #=> "RUBY"
s.reverse       #=> "ybur"
s.length        #=> 4
s * 3            #=> "rubyrubyruby"
```

## Related Notes
- [[Data Types Overview]]
- [[Symbols]]
- [[Cheatsheet String Methods]]
- [[Regular Expressions]]

## Next Topics
- [[Numbers]]
- [[Symbols]]

## Tags
#ruby/basics
