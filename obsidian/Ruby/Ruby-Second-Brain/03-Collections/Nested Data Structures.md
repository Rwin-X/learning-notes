---
tags:
  - ruby/collections
---

# Nested Data Structures

## Purpose
Work confidently with arrays of hashes, hashes of arrays, and deeper nesting.

## Explanation
Real-world data (JSON APIs, config files) is rarely flat — expect arrays of hashes and hashes containing nested hashes/arrays. Ruby's `dig` method safely traverses nested structures without raising on missing intermediate keys.

This is where [[Arrays]] and [[Hashes]] combine, and it's directly relevant to the [[Project Contact Book with File Persistence]] project.

## Examples
```ruby
users = [
  { name: "Raven", roles: ["admin", "dev"] },
  { name: "Max", roles: ["user"] }
]

users.first[:roles]        #=> ["admin", "dev"]
users.dig(0, :roles, 0)    #=> "admin"
```

## Related Notes
- [[Arrays]]
- [[Hashes]]
- [[Hash Methods]]

## Next Topics
- [[Blocks Procs and Lambdas]]
- [[File IO]]

## Tags
#ruby/collections
