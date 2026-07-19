---
tags:
  - ruby/oop
---

# Encapsulation

## Purpose
Control what parts of an object's state and behavior are exposed.

## Explanation
Encapsulation means bundling data and the methods that operate on it, while hiding internal details. Ruby enforces this through [[Method Visibility]] (`private`, `protected`, `public`) and the fact that instance variables are inaccessible from outside without explicit accessor methods, as seen in [[Attributes (attr_accessor)]].

Good encapsulation is what makes [[Duck Typing]] safe — callers depend on behavior, not internal representation.

## Examples
```ruby
class BankAccount
  def initialize(balance)
    @balance = balance
  end

  def deposit(amount)
    @balance += amount
  end

  private

  def log_transaction
    # not accessible outside the class
  end
end
```

## Related Notes
- [[Attributes (attr_accessor)]]
- [[Method Visibility]]
- [[Modules]]

## Next Topics
- [[Method Visibility]]
- [[Polymorphism]]

## Tags
#ruby/oop
