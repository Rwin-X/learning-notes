---
tags:
  - ruby/oop
---

# Duck Typing

## Purpose
Understand Ruby's "if it walks like a duck" approach to typing.

## Explanation
Duck typing means Ruby cares about whether an object *responds to* a method, not what class it belongs to. Instead of checking `is_a?(SomeClass)`, idiomatic Ruby checks `respond_to?(:some_method)` or simply calls the method and lets it fail if unsupported.

This philosophy underlies [[Polymorphism]] in Ruby and is why [[Comparable Module]] and [[Enumerable Module]] work across completely unrelated classes — all they require is that you implement one method (`<=>` or `each`).

## Examples
```ruby
def make_it_quack(duck)
  duck.quack if duck.respond_to?(:quack)
end

class ToyDuck
  def quack; "Squeak!"; end
end

make_it_quack(ToyDuck.new)   #=> "Squeak!"
```

## Related Notes
- [[Polymorphism]]
- [[Comparable Module]]
- [[Enumerable Module]]

## Next Topics
- [[Comparable Module]]
- [[Enumerable Module]]

## Tags
#ruby/oop
