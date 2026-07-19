---
tags:
  - ruby/advanced
---

# Freezing Objects

## Purpose
Make objects immutable to prevent accidental mutation.

## Explanation
`.freeze` prevents further modification of an object; attempting to mutate a frozen object raises `FrozenError`. This is especially relevant for constants and shared state, and connects to method naming conventions from [[Methods (Defining)]] where `!`-suffixed methods often mutate in place.

Freezing is a lightweight step toward the safety benefits explored more deeply in [[Threads and Concurrency Basics]].

## Examples
```ruby
CONFIG = { env: "production" }.freeze
CONFIG.frozen?   #=> true

begin
  CONFIG[:env] = "dev"
rescue FrozenError => e
  puts "Can't modify: #{e.message}"
end
```

## Related Notes
- [[Object Equality]]
- [[Methods (Defining)]]
- [[Threads and Concurrency Basics]]

## Next Topics
- [[Threads and Concurrency Basics]]

## Tags
#ruby/advanced
