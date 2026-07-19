---
tags:
  - ruby/basics
---

# Input and Output

## Purpose
Read user input and print output — essential for any interactive script.

## Explanation
`puts` prints with a trailing newline, `print` without one, and `p` prints the "inspect" (debug) representation of an object — very useful while learning. `gets.chomp` reads a line of input and strips the trailing newline.

You'll use these constantly in [[Exercises Foundations]] and early [[Projects MOC]] work like the number guessing game.

## Examples
```ruby
puts "What's your name?"
name = gets.chomp
puts "Hello, #{name}!"

p [1, 2, 3]     #=> [1, 2, 3]  (inspect format)
print "no newline"
```

## Related Notes
- [[Strings]]
- [[Ruby Syntax Basics]]

## Next Topics
- [[Exception Handling Basics]]

## Tags
#ruby/basics
