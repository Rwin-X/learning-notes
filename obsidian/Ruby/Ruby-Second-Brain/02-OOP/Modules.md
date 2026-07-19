---
tags:
  - ruby/oop
---

# Modules

## Purpose
Group related methods, constants, and classes into a namespace.

## Explanation
A `module` is similar to a class but cannot be instantiated. Modules serve two main purposes: **namespacing** (organizing related classes to avoid name collisions) and **mixins** — sharing behavior across classes via `include`, covered in depth in [[Mixins]].

Ruby's own [[Enumerable Module]] and [[Comparable Module]] are the most important built-in modules you'll use constantly.

## Examples
```ruby
module Greetable
  def greet
    "Hello, I'm #{name}"
  end
end

class Person
  include Greetable
  attr_reader :name
  def initialize(name); @name = name; end
end

Person.new("Raven").greet   #=> "Hello, I'm Raven"
```

## Related Notes
- [[Inheritance]]
- [[Mixins]]
- [[Enumerable Module]]
- [[Comparable Module]]

## Next Topics
- [[Mixins]]
- [[Encapsulation]]

## Tags
#ruby/oop
