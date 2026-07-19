---
tags:
  - ruby/collections
---

# Hashes

## Purpose
Store key-value pairs for fast, meaningful lookups.

## Explanation
A `Hash` maps keys to values, most idiomatically using [[Symbols]] as keys (`{name: "Raven"}`). Hashes preserve insertion order and, like [[Arrays]], include [[Enumerable Module]] for iteration and transformation.

Hashes are essential for structured data and show up constantly in [[Nested Data Structures]] and real-world API/JSON-shaped data.

## Examples
```ruby
person = { name: "Raven", role: :admin }
person[:name]         #=> "Raven"
person[:age] = 25       # add a key
person.each { |k, v| puts "#{k}: #{v}" }
```

## Related Notes
- [[Symbols]]
- [[Arrays]]
- [[Hash Methods]]
- [[Nested Data Structures]]

## Next Topics
- [[Hash Methods]]
- [[Nested Data Structures]]

## Tags
#ruby/collections
