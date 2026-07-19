---
tags:
  - ruby/metaprogramming
---

# Define Method

## Purpose
Generate methods dynamically at runtime with `define_method`.

## Explanation
`define_method` creates a method from a block, letting you programmatically generate many similar methods instead of writing them by hand — a closure ([[Closures]]) becomes a method body. Common in DSL-style gems.

This is safer and more idiomatic than [[Method Missing]] when you know the method names in advance.

## Examples
```ruby
class Product
  [:name, :price].each do |attr|
    define_method(attr) { instance_variable_get("@#{attr}") }
  end
end
```

## Related Notes
- [[Closures]]
- [[Method Missing]]
- [[Open Classes]]

## Next Topics
- [[Open Classes]]
- [[Send Method]]

## Tags
#ruby/metaprogramming
