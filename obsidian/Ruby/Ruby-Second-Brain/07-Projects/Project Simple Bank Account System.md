---
tags:
  - project
  - ruby/oop
---

# Project Simple Bank Account System

## Purpose
Practice core OOP by modeling a bank account with deposits, withdrawals, and validation.

## Explanation
Model a `BankAccount` class with encapsulated balance state, deposit/withdraw methods, and custom errors for invalid operations. This is the first project that applies the full [[OOP MOC]] toolkit: [[Classes and Objects]], [[Attributes (attr_accessor)]], [[Method Visibility]], and [[Exception Handling Advanced]] together.

**Stretch goal:** add an `Account` subclass hierarchy (`SavingsAccount`, `CheckingAccount`) to practice [[Inheritance]] and [[Polymorphism]].

## Examples
```ruby
class InsufficientFundsError < StandardError; end

class BankAccount
  attr_reader :balance

  def initialize(balance = 0)
    @balance = balance
  end

  def withdraw(amount)
    raise InsufficientFundsError if amount > @balance
    @balance -= amount
  end
end
```

## Related Notes
- [[Classes and Objects]]
- [[Attributes (attr_accessor)]]
- [[Exception Handling Advanced]]
- [[Method Visibility]]

## Next Topics
- [[Project Library Management System (OOP)]]

## Tags
#project #ruby/oop
