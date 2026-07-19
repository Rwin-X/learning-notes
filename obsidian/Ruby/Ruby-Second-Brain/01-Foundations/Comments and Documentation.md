---
tags:
  - ruby/basics
---

# Comments and Documentation

## Purpose
Write clear comments and know Ruby's documentation conventions.

## Explanation
Single-line comments use `#`; multi-line comments use `=begin`/`=end` (rarely used in practice). Ruby's community documentation tool is **RDoc/YARD**, which parses specially formatted comments above methods and classes.

Good commenting habits matter more once you reach [[Classes and Objects]] and start building things others (including future you) will read.

## Examples
```ruby
# Returns the square of a number
def square(n)
  n * n
end

=begin
This is a multi-line comment block.
Rarely used in idiomatic Ruby.
=end
```

## Related Notes
- [[Ruby Syntax Basics]]
- [[Methods (Defining)]]

## Next Topics
- [[Input and Output]]

## Tags
#ruby/basics
