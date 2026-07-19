---
tags:
  - ruby/metaprogramming
---

# Send Method

## Purpose
Call methods dynamically by name, including private ones.

## Explanation
`.send(:method_name, *args)` invokes a method by a symbol or string name, computed at runtime — even bypassing [[Method Visibility]] restrictions (use `public_send` to respect them). Useful for generic, data-driven method dispatch.

`send` shows up frequently in testing and metaprogramming utilities, working alongside [[Reflection]] to inspect and invoke methods dynamically.

## Examples
```ruby
class Greeter
  def hello; "Hi!"; end
end

method_name = :hello
Greeter.new.send(method_name)   #=> "Hi!"
```

## Related Notes
- [[Method Visibility]]
- [[Method Missing]]
- [[Reflection]]

## Next Topics
- [[Class Eval and Instance Eval]]
- [[Reflection]]

## Tags
#ruby/metaprogramming
