---
tags:
  - ruby/advanced
---

# Regular Expressions

## Purpose
Match and manipulate text patterns with Ruby's regex support.

## Explanation
Ruby has first-class regex literals (`/pattern/`) and integrates them directly into [[Strings]] methods like `match`, `scan`, `gsub`, and `=~`. Regex is invaluable for validation and text processing tasks.

See [[Cheatsheet Regex]] for a quick-reference of common patterns.

## Examples
```ruby
email = "user@example.com"
email.match?(/\A[\w.]+@[\w.]+\z/)   #=> true

"hello world".gsub(/o/, "0")   #=> "hell0 w0rld"
"a1 b2 c3".scan(/\d/)            #=> ["1","2","3"]
```

## Related Notes
- [[Strings]]
- [[Cheatsheet Regex]]

## Next Topics
- [[Object Equality]]
- [[Freezing Objects]]

## Tags
#ruby/advanced
