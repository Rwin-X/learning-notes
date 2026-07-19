---
tags:
  - ruby/oop
---

# Instance vs Class Variables

## Purpose
Distinguish per-object state (`@var`) from shared class-wide state (`@@var`).

## Explanation
An instance variable (`@name`) belongs to one object; each instance has its own copy. A class variable (`@@count`) is shared across *all* instances and the class itself — useful for things like tracking how many objects have been created, but risky in inheritance hierarchies since subclasses share the same `@@variable`.

Contrast this with [[Class Methods]], which operate on the class itself rather than an instance.

## Examples
```ruby
class Dog
  @@count = 0

  def initialize(name)
    @name = name       # instance variable
    @@count += 1       # class variable
  end

  def self.count
    @@count
  end
end

Dog.new("Rex"); Dog.new("Fido")
Dog.count   #=> 2
```

## Related Notes
- [[Initialize Method]]
- [[Attributes (attr_accessor)]]
- [[Class Methods]]

## Next Topics
- [[Class Methods]]
- [[Inheritance]]

## Tags
#ruby/oop
