---
tags:
  - ruby/advanced
---

# Exception Handling Advanced

## Purpose
Build custom exception hierarchies and use retry logic.

## Explanation
Beyond the basics in [[Exception Handling Basics]], real applications define custom exception classes (subclassing `StandardError`) to represent domain-specific error conditions, and use `retry` to re-attempt a failed operation.

This pairs with [[Inheritance]] — custom exceptions are just classes in a hierarchy like any other.

## Examples
```ruby
class InsufficientFundsError < StandardError; end

def withdraw(balance, amount)
  raise InsufficientFundsError, "Not enough funds" if amount > balance
  balance - amount
end

begin
  withdraw(50, 100)
rescue InsufficientFundsError => e
  puts e.message
end
```

## Related Notes
- [[Exception Handling Basics]]
- [[Inheritance]]

## Next Topics
- [[File IO]]
- [[Object Equality]]

## Tags
#ruby/advanced
