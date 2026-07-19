---
tags:
  - ruby/oop
---

# Classes and Objects

## Purpose
Understand the fundamental unit of Ruby's object model: the class.

## Explanation
A class is a blueprint for creating objects. You instantiate one with `.new`, which calls [[Initialize Method]] under the hood. Every object in Ruby belongs to a class, reinforcing the "everything is an object" idea from [[What Is Ruby]].

This note is the hub of the entire [[OOP MOC]] — from here you branch into [[Attributes (attr_accessor)]], [[Inheritance]], and [[Method Visibility]].

## Examples
```ruby
class Dog
  def bark
    "Woof!"
  end
end

rex = Dog.new
rex.bark   #=> "Woof!"
rex.class  #=> Dog
```

## Related Notes
- [[What Is Ruby]]
- [[Initialize Method]]
- [[Attributes (attr_accessor)]]
- [[Exception Handling Basics]]

## Next Topics
- [[Initialize Method]]
- [[Attributes (attr_accessor)]]

## Tags
#ruby/oop
