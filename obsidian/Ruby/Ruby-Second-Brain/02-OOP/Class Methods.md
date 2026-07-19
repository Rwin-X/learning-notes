---
tags:
  - ruby/oop
---

# Class Methods

## Purpose
Define methods that belong to the class itself, not to instances.

## Explanation
A class method is defined with `def self.method_name` and is called on the class directly (`Dog.count`), not on an instance. They're commonly used for factory-style constructors and utility functions related to the class as a whole.

Class methods often work alongside [[Instance vs Class Variables]] to expose class-level state, and are a stepping stone toward understanding [[Class Eval and Instance Eval]] later.

## Examples
```ruby
class Dog
  def self.bark_sound
    "Woof!"
  end
end

Dog.bark_sound   #=> "Woof!"
```

## Related Notes
- [[Instance vs Class Variables]]
- [[Classes and Objects]]

## Next Topics
- [[Inheritance]]
- [[Modules]]

## Tags
#ruby/oop
