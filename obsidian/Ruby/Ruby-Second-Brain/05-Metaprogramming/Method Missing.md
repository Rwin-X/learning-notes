---
tags:
  - ruby/metaprogramming
---

# Method Missing

## Purpose
Intercept calls to undefined methods for dynamic behavior.

## Explanation
Overriding `method_missing` lets an object respond to method calls that aren't explicitly defined — the mechanism behind many DSLs and dynamic proxies. Always pair it with an overridden `respond_to_missing?` so [[Duck Typing]] checks stay accurate.

This is an advanced technique — powerful, but should be reached for only when [[Define Method]] or plain methods won't do.

## Examples
```ruby
class DynamicProxy
  def method_missing(name, *args)
    "You called #{name} with #{args}"
  end

  def respond_to_missing?(name, include_private = false)
    true
  end
end

DynamicProxy.new.anything(1, 2)   #=> "You called anything with [1, 2]"
```

## Related Notes
- [[Duck Typing]]
- [[Define Method]]
- [[Send Method]]

## Next Topics
- [[Define Method]]
- [[Open Classes]]

## Tags
#ruby/metaprogramming
