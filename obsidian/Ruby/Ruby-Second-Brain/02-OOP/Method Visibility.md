---
tags:
  - ruby/oop
---

# Method Visibility

## Purpose
Control which methods can be called from outside an object with public/private/protected.

## Explanation
Ruby methods are `public` by default. `private` methods can only be called without an explicit receiver (i.e., from inside the object itself). `protected` methods can be called by other instances of the same class — useful for comparison methods.

This is the mechanical foundation of [[Encapsulation]] and matters a lot once you start writing real [[Projects MOC|projects]] with multiple collaborating classes.

## Examples
```ruby
class Wallet
  def initialize(balance); @balance = balance; end

  def >(other)
    balance > other.balance   # protected access
  end

  protected

  attr_reader :balance
end
```

## Related Notes
- [[Encapsulation]]
- [[Classes and Objects]]
- [[Attributes (attr_accessor)]]

## Next Topics
- [[Duck Typing]]
- [[Structs]]

## Tags
#ruby/oop
