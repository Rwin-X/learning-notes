---
tags:
  - ruby/oop
---

# Initialize Method

## Purpose
Learn how objects are constructed with the special `initialize` method.

## Explanation
`initialize` is a private method automatically called when you use `.new`. It's where you set up an object's starting state, typically by assigning [[Instance vs Class Variables|instance variables]].

Arguments to `.new` are passed straight through to `initialize`, following the same rules as [[Method Arguments]].

## Examples
```ruby
class Dog
  def initialize(name)
    @name = name   # instance variable
  end
end

rex = Dog.new("Rex")
```

## Related Notes
- [[Classes and Objects]]
- [[Instance vs Class Variables]]
- [[Method Arguments]]

## Next Topics
- [[Attributes (attr_accessor)]]
- [[Instance vs Class Variables]]

## Tags
#ruby/oop
