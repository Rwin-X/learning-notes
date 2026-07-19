---
tags:
  - ruby/oop
---

# Polymorphism

## Purpose
Understand how different classes can respond to the same method call in their own way.

## Explanation
Polymorphism means objects of different classes can be used interchangeably if they respond to the same method — most visibly through [[Inheritance]] (method overriding) but even more idiomatically through [[Duck Typing]], where shared behavior matters more than a shared ancestor.

This is central to writing flexible Ruby code, and connects directly to how [[Comparable Module]] lets many unrelated classes support `<`, `>`, `==`, etc.

## Examples
```ruby
class Cat
  def speak; "Meow"; end
end

class Dog
  def speak; "Woof"; end
end

[Cat.new, Dog.new].each { |a| puts a.speak }
#=> Meow
#=> Woof
```

## Related Notes
- [[Inheritance]]
- [[Duck Typing]]
- [[Comparable Module]]
- [[Encapsulation]]

## Next Topics
- [[Method Visibility]]
- [[Duck Typing]]

## Tags
#ruby/oop
