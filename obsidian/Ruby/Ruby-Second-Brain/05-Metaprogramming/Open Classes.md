---
tags:
  - ruby/metaprogramming
---

# Open Classes

## Purpose
Understand Ruby's ability to reopen and modify any existing class, including built-ins.

## Explanation
In Ruby, classes are never "closed" — you can reopen `String`, `Array`, or any class and add methods to it at any time, even in third-party gems. This power is double-edged: extremely flexible, but can cause confusing bugs ("monkey patching") if used carelessly.

This capability underlies how [[Comparable Module]] and [[Enumerable Module]] can retroactively enhance any class, and connects to [[Class Eval and Instance Eval]].

## Examples
```ruby
class String
  def shout
    upcase + "!"
  end
end

"hello".shout   #=> "HELLO!"
```

## Related Notes
- [[Define Method]]
- [[Class Eval and Instance Eval]]
- [[Comparable Module]]

## Next Topics
- [[Send Method]]
- [[Class Eval and Instance Eval]]

## Tags
#ruby/metaprogramming
