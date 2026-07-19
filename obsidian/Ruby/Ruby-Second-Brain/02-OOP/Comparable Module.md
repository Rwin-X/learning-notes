---
tags:
  - ruby/oop
---

# Comparable Module

## Purpose
Give your objects full comparison operators (`<`, `>`, `between?`, etc.) by defining one method.

## Explanation
Include the `Comparable` module and define `<=>` (the spaceship operator, from [[Operators]]), and Ruby automatically derives `<`, `<=`, `==`, `>=`, `>`, and `between?` for you.

This is a textbook example of [[Mixins]] in action and shows the payoff of [[Duck Typing]]: any class can become fully comparable with minimal code.

## Examples
```ruby
class Money
  include Comparable
  attr_reader :cents
  def initialize(cents); @cents = cents; end
  def <=>(other); cents <=> other.cents; end
end

Money.new(100) < Money.new(200)   #=> true
```

## Related Notes
- [[Operators]]
- [[Mixins]]
- [[Duck Typing]]
- [[Polymorphism]]

## Next Topics
- [[Enumerable Module]]
- [[Structs]]

## Tags
#ruby/oop
