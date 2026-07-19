---
tags:
  - ruby/metaprogramming
---

# Class Eval and Instance Eval

## Purpose
Execute code in the context of a class or instance for advanced dynamic definitions.

## Explanation
`class_eval` runs a block as if it were written inside the class body (great for adding methods dynamically); `instance_eval` runs a block in the context of a specific object, giving direct access to its instance variables.

These are core building blocks behind many Ruby DSLs (including Rails) and build directly on [[Open Classes]] and [[Define Method]].

## Examples
```ruby
String.class_eval do
  def shout; upcase + "!"; end
end

obj = Object.new
obj.instance_eval { @secret = 42 }
obj.instance_variable_get(:@secret)   #=> 42
```

## Related Notes
- [[Open Classes]]
- [[Define Method]]
- [[Reflection]]

## Next Topics
- [[Reflection]]

## Tags
#ruby/metaprogramming
