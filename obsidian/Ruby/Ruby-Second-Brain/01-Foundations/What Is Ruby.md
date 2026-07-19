---
tags:
  - ruby/basics
---

# What Is Ruby

## Purpose
Understand what Ruby is, its design philosophy, and why it's worth learning.

## Explanation
Ruby is a dynamic, interpreted, object-oriented programming language created by Yukihiro "Matz" Matsumoto in the mid-1990s. Its core philosophy is **programmer happiness** — Ruby is designed to be readable, expressive, and enjoyable to write, often prioritizing human ergonomics over machine efficiency.

Everything in Ruby is an object, including numbers, strings, and even `nil`. This consistency is what makes Ruby's object model so elegant once you understand it — see [[Classes and Objects]] for where this leads.

Ruby powers the Rails web framework (see [[Ruby on Rails Overview]]), but the language itself is general-purpose: scripting, automation, CLIs, and more.

## Examples
```ruby
# Ruby reads almost like English
3.times { puts "Hello, Ruby!" }

# Everything is an object -- even a number
puts 5.class      #=> Integer
puts 5.even?      #=> true
```

## Related Notes
- [[Ruby Syntax Basics]]
- [[Installing Ruby]]
- [[Classes and Objects]]

## Next Topics
- [[Installing Ruby]]
- [[Ruby Syntax Basics]]

## Tags
#ruby/basics
