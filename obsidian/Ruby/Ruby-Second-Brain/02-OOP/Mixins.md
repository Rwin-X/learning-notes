---
tags:
  - ruby/oop
---

# Mixins

## Purpose
Understand `include`, `extend`, and `prepend` for composing behavior from modules.

## Explanation
Mixins let a class gain module methods without inheritance. `include` adds module methods as instance methods; `extend` adds them as class (singleton) methods; `prepend` inserts the module *ahead* of the class in the method lookup chain, letting it override existing methods.

Mixins are Ruby's answer to the multiple-inheritance problem mentioned in [[Inheritance]], and they're how [[Comparable Module]] and [[Enumerable Module]] get "mixed in" to your own classes.

## Examples
```ruby
module Flyable
  def fly; "#{self.class} is flying"; end
end

class Bird
  include Flyable
end

Bird.new.fly   #=> "Bird is flying"
```

## Related Notes
- [[Modules]]
- [[Inheritance]]
- [[Comparable Module]]
- [[Enumerable Module]]

## Next Topics
- [[Encapsulation]]
- [[Polymorphism]]

## Tags
#ruby/oop
