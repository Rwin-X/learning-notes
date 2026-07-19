---
tags:
  - ruby/basics
---

# Exception Handling Basics

## Purpose
Handle errors gracefully with begin/rescue.

## Explanation
Ruby uses `begin/rescue/ensure/end` (or the shorthand `rescue` inline in a method def) to catch exceptions. `ensure` always runs, useful for cleanup like closing files — see [[File IO]].

This basic pattern is expanded significantly in [[Exception Handling Advanced]] with custom exception classes and retry logic.

## Examples
```ruby
begin
  result = 10 / 0
rescue ZeroDivisionError => e
  puts "Error: #{e.message}"
ensure
  puts "This always runs"
end
```

## Related Notes
- [[Input and Output]]
- [[Methods (Defining)]]
- [[Exception Handling Advanced]]

## Next Topics
- [[Exception Handling Advanced]]
- [[Classes and Objects]]

## Tags
#ruby/basics
