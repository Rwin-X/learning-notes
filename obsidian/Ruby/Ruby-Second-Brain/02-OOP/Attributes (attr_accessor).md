---
tags:
  - ruby/oop
---

# Attributes (attr_accessor)

## Purpose
Expose instance variables safely with getter/setter shortcuts.

## Explanation
Instance variables are private by default — you can't read `@name` from outside the object without a method. `attr_reader`, `attr_writer`, and `attr_accessor` generate those getter/setter methods automatically, using [[Symbols]] as arguments.

This is the idiomatic alternative to hand-writing boilerplate getters/setters, and it's the first thing most Ruby classes declare after [[Initialize Method]].

## Examples
```ruby
class Dog
  attr_accessor :name   # generates .name and .name=

  def initialize(name)
    @name = name
  end
end

rex = Dog.new("Rex")
rex.name          #=> "Rex"
rex.name = "Max"
```

## Related Notes
- [[Classes and Objects]]
- [[Initialize Method]]
- [[Symbols]]
- [[Method Visibility]]

## Next Topics
- [[Instance vs Class Variables]]
- [[Method Visibility]]

## Tags
#ruby/oop
