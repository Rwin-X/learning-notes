---
tags:
  - ruby/advanced
---

# File IO

## Purpose
Read from and write to files for data persistence.

## Explanation
`File.open` (ideally with a block, so the file auto-closes) or `File.read`/`File.write` handle basic file operations. This is essential for any script that needs to persist data between runs, directly enabling the [[Project Contact Book with File Persistence]] project.

Combine with [[Exception Handling Advanced]] to handle missing files gracefully, and with [[Nested Data Structures]] when serializing structured data.

## Examples
```ruby
File.open("notes.txt", "w") do |f|
  f.puts "Hello, file!"
end

contents = File.read("notes.txt")
puts contents
```

## Related Notes
- [[Nested Data Structures]]
- [[Exception Handling Advanced]]

## Next Topics
- [[Regular Expressions]]
- [[Object Equality]]

## Tags
#ruby/advanced
