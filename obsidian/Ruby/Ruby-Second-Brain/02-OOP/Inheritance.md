---
tags:
  - ruby/oop
---

# Inheritance

## Purpose
Share behavior between classes using the `<` inheritance operator.

## Explanation
A subclass inherits methods and behavior from its superclass using `class Child < Parent`. `super` calls the parent's version of the current method — essential inside [[Initialize Method]] overrides.

Ruby only supports single inheritance (one direct superclass), which is why [[Modules]] and [[Mixins]] exist — to share behavior across unrelated classes without needing multiple inheritance.

## Examples
```ruby
class Animal
  def initialize(name)
    @name = name
  end

  def speak
    "..."
  end
end

class Dog < Animal
  def speak
    "Woof!"
  end
end

Dog.new("Rex").speak   #=> "Woof!"
```

## Related Notes
- [[Classes and Objects]]
- [[Class Methods]]
- [[Modules]]
- [[Polymorphism]]

## Next Topics
- [[Modules]]
- [[Polymorphism]]

## Tags
#ruby/oop
