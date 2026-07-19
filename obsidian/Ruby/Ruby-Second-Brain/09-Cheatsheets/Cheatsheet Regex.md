---
tags:
  - cheatsheet
  - ruby/advanced
---

# Cheatsheet Regex

## Purpose
Quick reference for common regular expression patterns in Ruby.

## Explanation
Fast lookup for the [[Regular Expressions]] syntax most commonly needed in practice, avoiding the need to re-derive patterns from scratch each time.

## Examples
```ruby
/\d+/        # one or more digits
/\A.../       # start of string
/...\z/       # end of string
/[a-z]+/i     # case-insensitive letters
str =~ /pattern/     # returns match index or nil
str.match?(/pattern/) # returns true/false
```

## Related Notes
- [[Regular Expressions]]
- [[Strings]]

## Next Topics
- *(none — see MOC for continuation)*

## Tags
#cheatsheet #ruby/advanced
